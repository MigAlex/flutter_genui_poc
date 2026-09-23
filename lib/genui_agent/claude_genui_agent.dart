
import 'package:genui/genui.dart';

import '../commons/a2ui/component_names.dart';
import '../commons/logging/genui_wire_log.dart';
import 'genui_agent.dart';
import '../data/anthropic/anthropic_stream_api.dart';

/// Realny agent: **Claude Haiku 4.5** przez Anthropic Messages API.
///
/// Dart nie ma oficjalnego SDK Anthropic, więc lecimy surowym HTTP na
/// `POST /v1/messages` ze streamingiem SSE. Tekstowe delty modelu trafiają
/// prosto do `transport.addChunk(...)`, gdzie parser genui wyławia z nich
/// wiadomości A2UI.
///
/// System prompt (instrukcje protokołu A2UI + schemat katalogu widgetów)
/// generuje sam genui przez [PromptBuilder] — nie piszemy go ręcznie.
class ClaudeGenUiAgent implements GenUiAgent {
  ClaudeGenUiAgent({required this.api, required Catalog catalog})
    : _systemPrompt = PromptBuilder.chat(
        catalog: catalog,
        systemPromptFragments: [
          PromptFragments.uiGenerationRestriction(prefix: 'IMPORTANT: '),
          _alwaysRespondWithUi,
        ],
      ).systemPromptJoined();

  /// Bez tego Haiku traktuje prompt jak zwykły czat i na „siema" odpowiada
  /// tekstem zamiast wygenerować UI (zweryfikowane empirycznie).
  static const _alwaysRespondWithUi = '''
IMPORTANT: Every single response you produce MUST be A2UI JSON that creates a
surface. Never reply with plain conversational text — not even for greetings,
small talk, thanks, or short questions.

If the user just says hello or writes something that does not obviously need a
form, still render a surface: a short Text greeting plus 2-4 Buttons offering
concrete next steps you can help with. The buttons are how the user talks back
to you, so always give them something to click.''';

  /// Transport. Agent nie zna Dio ani nagłówków — to należy do warstwy
  /// `data/` (konwencja projektu: Api cienkie, Dio nie wycieka wyżej).
  final AnthropicStreamApi api;

  final String _systemPrompt;

  /// Historia rozmowy w formacie Messages API (stateless — wysyłamy całość).
  final List<Map<String, Object?>> _history = [];

  /// Rozmowa jest stateless, więc CAŁA historia leci w każdym requeście,
  /// a pojedyncza odpowiedź A2UI to ~2 kB JSON-a — bez okna rośnie w
  /// nieskończoność. Realna apka streszczałaby starsze tury; w POC-u
  /// wystarczy limit. Ucinamy zawsze parzyście, żeby pierwsza pozostała
  /// wiadomość dalej miała rolę `user` (API wymaga naprzemienności).
  static const _maxHistoryMessages = 24;

  static const _model = 'claude-haiku-4-5';

  @override
  String get label => 'Claude Haiku 4.5';

  @override
  bool get isMock => false;

  @override
  Future<void> respond(ChatMessage message, A2uiTransportAdapter transport) async {
    _history.add({'role': 'user', 'content': _userContent(message)});


    // Akumulujemy pełną odpowiedź, żeby dopisać ją do historii.
    final assistantText = StringBuffer();

    // Inspektor „drutu" — przy GenUI to jedyny sposób, żeby zobaczyć, co
    // naprawdę poszło i wróciło. Debug-only, patrz [GenUiWire].
    GenUiWire.request(
      channel: 'czat',
      model: _model,
      systemPrompt: _systemPrompt,
      history: _history,
    );
    final stopwatch = Stopwatch()..start();
    final usage = TokenUsage();
    Duration? firstChunkAfter;
    var chunks = 0;

    try {
      final deltas = api.streamText(
        model: _model,
        maxTokens: 8192,
        systemPrompt: _systemPrompt,
        messages: _history,
        usage: usage,
      );

      await for (final text in deltas) {
        firstChunkAfter ??= stopwatch.elapsed;
        chunks++;
        assistantText.write(text);
        transport.addChunk(text); // → parser A2UI → SurfaceController
      }
    } catch (e) {
      GenUiWire.failure(channel: 'czat', error: e, elapsed: stopwatch.elapsed);
      // Wycofujemy wiadomość usera — inaczej po nieudanym requeście historia
      // kończy się na `user`, następna tura dokłada drugie `user` z rzędu
      // i API odrzuca całość za brak naprzemienności ról.
      _history.removeLast();
      rethrow;
    }

    final raw = assistantText.toString();
    GenUiWire.response(
      channel: 'czat',
      elapsed: stopwatch.elapsed,
      firstChunkAfter: firstChunkAfter,
      chunks: chunks,
      raw: raw,
      componentNames: componentNamesIn(raw),
      usage: usage,
    );

    _history.add({'role': 'assistant', 'content': raw});
    _trimHistory();
  }

  @override
  void reset() => _history.clear();

  void _trimHistory() {
    final excess = _history.length - _maxHistoryMessages;
    if (excess <= 0) return;
    _history.removeRange(0, excess.isEven ? excess : excess + 1);
  }

  /// Zamienia wiadomość genui na treść dla modelu: albo prompt użytkownika,
  /// albo opis interakcji z wygenerowanym UI (klik przycisku itp.).
  String _userContent(ChatMessage message) {
    final interactions = message.parts.uiInteractionParts;
    if (interactions.isNotEmpty) {
      // Wszystkie części, nie tylko pierwsza — jedna wiadomość potrafi nieść
      // kilka interakcji (np. submit formularza z kilkoma polami).
      final payloads = interactions.map((part) => part.interaction).join('\n');
      return 'The user interacted with the UI you generated. '
          'Here is the raw A2UI interaction payload:\n'
          '$payloads\n'
          'Respond with a new surface reflecting this interaction.';
    }
    return message.text;
  }

}
