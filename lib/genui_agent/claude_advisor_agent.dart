
import 'package:genui/genui.dart';

import '../commons/logging/genui_wire_log.dart';
import '../genui_catalog/advisor_catalog.dart';
import 'advisor_agent.dart';
import '../data/anthropic/anthropic_stream_api.dart';

/// Claude Haiku 4.5 w trybie **panelu**, nie czatu.
///
/// Dwie różnice wobec `ClaudeGenUiAgent` z czatu i obie są istotą eksperymentu:
///
/// 1. `PromptBuilder.custom(allowedOperations: SurfaceOperations.updateOnly)` —
///    model może wyłącznie **podmieniać zawartość** istniejącej powierzchni.
///    Powierzchnię zakłada host (`bootstrapPanel`).
/// 2. Trzyma **dwa** system prompty — z `CarCard` w katalogu i bez niego — żeby
///    przełącznik działał w locie, bez restartu apki. Przełączana jest
///    **obecność widgetu**, nie sama reguła użycia: reguła zmienia prompt
///    o 323 znaki i na żywym Haiku nie zmienia niczego w wyniku (macierz 2×2),
///    więc jako przełącznik w UI była myląca — wyglądała na zepsutą.
class ClaudeAdvisorAgent implements AdvisorAgent {
  /// [withExample] i [withUsageRule] to **osie eksperymentu ④**, ustawiane raz
  /// przy budowie agenta (tak używa ich `advisor_ab_e2e_test`). Produkcyjnie
  /// oba `true`; DI nie podaje żadnego z nich.
  ClaudeAdvisorAgent({
    required this.api,
    bool withExample = true,
    bool withUsageRule = true,
  }) : withExample = withExample,
       withUsageRule = withUsageRule,
       _promptWithCard = _buildPrompt(
         withUsageRule: withUsageRule,
         withExample: withExample,
         withCarCard: true,
       ),
       _promptWithoutCard = _buildPrompt(
         withUsageRule: withUsageRule,
         withExample: withExample,
         withCarCard: false,
       );

  /// Transport. Agent nie zna Dio ani nagłówków — to należy do warstwy
  /// `data/` (konwencja projektu: Api cienkie, Dio nie wycieka wyżej).
  final AnthropicStreamApi api;


  /// Czy katalog niesie `exampleData` (warstwa 3 wpływu na model).
  final bool withExample;

  /// Czy katalog niesie regułę „użyj CarCard" (warstwa 4).
  final bool withUsageRule;

  final String _promptWithCard;
  final String _promptWithoutCard;
  final List<Map<String, Object?>> _history = [];

  static const _model = 'claude-haiku-4-5';
  static const _maxHistoryMessages = 12;

  @override
  String get label => 'Claude Haiku 4.5';

  @override
  bool get isMock => false;

  @override
  void bootstrapPanel(A2uiTransportAdapter transport) {
    transport.addChunk(panelBootstrapChunk());
  }

  @override
  PromptDiagnostics diagnostics({required bool withCarCard}) {
    final prompt = _promptFor(withCarCard);
    return (length: prompt.length, mentionsCarCard: prompt.contains('CarCard'));
  }

  String _promptFor(bool withCarCard) =>
      withCarCard ? _promptWithCard : _promptWithoutCard;

  @override
  void reset() => _history.clear();

  @override
  Future<Set<String>> respond(
    ChatMessage message,
    A2uiTransportAdapter transport, {
    required bool withCarCard,
  }) async {
    _history.add({'role': 'user', 'content': _userContent(message)});


    final assistantText = StringBuffer();

    // Inspektor „drutu". Wariant jedzie w nagłówku, bo bez niego dwa przebiegi
    // w logu są nie do odróżnienia. `CarCard` na pierwszym miejscu, bo to
    // jedyna oś przełączalna z UI — pozostałe dwie ustawia konstruktor.
    GenUiWire.request(
      channel: 'panel',
      model: _model,
      systemPrompt: _promptFor(withCarCard),
      history: _history,
      variant:
          'CarCard w katalogu ${withCarCard ? 'TAK' : 'NIE'} · '
          'reguła ${withUsageRule ? 'WŁ' : 'WYŁ'} · '
          'exampleData ${withExample ? 'WŁ' : 'WYŁ'}',
    );
    final stopwatch = Stopwatch()..start();
    final usage = TokenUsage();
    Duration? firstChunkAfter;
    var chunks = 0;

    try {
      final deltas = api.streamText(
        model: _model,
        maxTokens: 8192,
        systemPrompt: _promptFor(withCarCard),
        messages: _history,
        usage: usage,
      );

      await for (final text in deltas) {
        firstChunkAfter ??= stopwatch.elapsed;
        chunks++;
        assistantText.write(text);
        transport.addChunk(text);
      }
    } catch (e) {
      GenUiWire.failure(channel: 'panel', error: e, elapsed: stopwatch.elapsed);
      // Bez tego historia kończy się na `user` i następna tura dokłada drugie
      // `user` z rzędu — API odrzuca całość za brak naprzemienności ról.
      _history.removeLast();
      rethrow;
    }

    final raw = assistantText.toString();
    final components = componentNamesIn(raw);

    GenUiWire.response(
      channel: 'panel',
      elapsed: stopwatch.elapsed,
      firstChunkAfter: firstChunkAfter,
      chunks: chunks,
      raw: raw,
      componentNames: components,
      usage: usage,
      // Werdykt prosto w konsoli, żeby nie trzeba go było składać z oczu
      // na pasku laboratoryjnym. Rozróżnia dwa bardzo różne „pominięcia":
      // model NIE MÓGŁ (nie ma widgetu w katalogu) vs model NIE CHCIAŁ.
      verdict: switch ((withCarCard, components.contains('CarCard'))) {
        (true, true) => 'CarCard UŻYTY',
        (true, false) => 'CarCard POMINIĘTY — miał go w katalogu i nie użył',
        (false, false) => 'CarCard poza katalogiem — model złożył z generyków',
        (false, true) =>
          'ALARM: model użył CarCard, którego nie było w jego katalogu '
              '— sprawdź, czy prompt na pewno został przycięty',
      },
    );

    _history.add({'role': 'assistant', 'content': raw});
    _trimHistory();

    return components;
  }

  void _trimHistory() {
    final excess = _history.length - _maxHistoryMessages;
    if (excess <= 0) return;
    _history.removeRange(0, excess.isEven ? excess : excess + 1);
  }

  String _userContent(ChatMessage message) {
    final interactions = message.parts.uiInteractionParts;
    if (interactions.isNotEmpty) {
      final payloads = interactions.map((part) => part.interaction).join('\n');
      return 'The user interacted with the panel you generated. '
          'Here is the raw A2UI interaction payload:\n'
          '$payloads\n'
          'Rebuild the panel taking this interaction into account.';
    }
    return message.text;
  }

  static String _buildPrompt({
    required bool withUsageRule,
    required bool withExample,
    required bool withCarCard,
  }) => PromptBuilder.custom(
    catalog: advisorCatalog(
      withUsageRule: withUsageRule,
      withExample: withExample,
      withCarCard: withCarCard,
    ),
    allowedOperations: SurfaceOperations.updateOnly(dataModel: false),
    systemPromptFragments: [
      PromptFragments.uiGenerationRestriction(prefix: 'IMPORTANT: '),
      _panelDiscipline,
    ],
  ).systemPromptJoined();

  /// Model musi znać `surfaceId`, którego sam nie stworzył — inaczej wymyśli
  /// własny, update poleci do bufora i po minucie zniknie bez komunikatu.
  static final _panelDiscipline =
      '''
IMPORTANT: The panel surface ALREADY EXISTS. Its surfaceId is
"$advisorPanelSurfaceId" and its catalogId is "$advisorCatalogId".
You cannot create or delete surfaces. Every single response you produce MUST be
exactly one A2UI `updateComponents` message targeting surfaceId
"$advisorPanelSurfaceId", containing a component with `id: "root"` as the entry
point. Never reply with plain conversational text, not even for greetings or
short questions — the user is operating sliders, not chatting.

Rebuild the whole panel on every turn: send the complete component list, not
a diff.''';

}
