
import 'package:genui/genui.dart';

import '../commons/a2ui/a2ui_sink.dart';
import '../commons/a2ui/component_names.dart';
import '../commons/logging/genui_wire_log.dart';
import '../commons/logging/token_tally.dart';
import '../genui_catalog/triage_catalog.dart';
import 'triage_agent.dart';
import '../data/anthropic/anthropic_stream_api.dart';

/// Claude Haiku 4.5 w trybie paska.
///
/// Ten sam tryb co doradca (`updateOnly`, host zakłada powierzchnię), ale bez
/// osi A/B: tu nie badamy, czy model sięgnie po własny widget — tylko czy host
/// potrafi obronić ekran przed tym, co model przysłał.
///
/// **Historia jest czyszczona przy każdym telefonie** (`reset()` woła cubit).
/// Nie dla oszczędności: każdy telefon to inne zamówienie, a `_stripDiscipline`
/// każe przebudować cały pasek, więc poprzednia odpowiedź w historii działa jak
/// przykład few-shot i model naśladuje układ sprzed zmiany sytuacji. Ten sam
/// błąd skaził eksperyment ④ w module doradcy.
class ClaudeTriageAgent implements TriageAgent {
  ClaudeTriageAgent({required this.api, required Catalog catalog})
    : _systemPrompt = _buildPrompt(catalog);

  /// Transport. Agent nie zna Dio ani nagłówków — to należy do warstwy
  /// `data/` (konwencja projektu: Api cienkie, Dio nie wycieka wyżej).
  final AnthropicStreamApi api;


  final String _systemPrompt;
  final List<Map<String, Object?>> _history = [];

  static const _model = 'claude-haiku-4-5';

  @override
  String get label => 'Claude Haiku 4.5';

  @override
  bool get isMock => false;

  @override
  int get promptLength => _systemPrompt.length;

  /// Bilans narastający. Zliczamy **po** zamknięciu strumienia, bo wyjście
  /// przychodzi dopiero w `message_delta` — turę doliczoną wcześniej trzeba
  /// byłoby poprawiać.
  @override
  TokenTally get tally => _tally;
  TokenTally _tally = const TokenTally();

  @override
  void bootstrapStrip(A2uiSink sink) => sink.addChunk(stripBootstrapChunk());

  @override
  void reset() => _history.clear();

  @override
  Future<void> respond(ChatMessage message, A2uiSink sink) async {
    _history.add({'role': 'user', 'content': message.text});


    GenUiWire.request(
      channel: 'triage',
      model: _model,
      systemPrompt: _systemPrompt,
      history: _history,
    );

    final assistantText = StringBuffer();
    final stopwatch = Stopwatch()..start();
    final usage = TokenUsage();
    Duration? firstChunkAfter;
    var chunks = 0;

    try {
      final deltas = api.streamText(
        model: _model,
        maxTokens: 4096,
        systemPrompt: _systemPrompt,
        messages: _history,
        usage: usage,
      );

      await for (final text in deltas) {
        firstChunkAfter ??= stopwatch.elapsed;
        chunks++;
        assistantText.write(text);
        sink.addChunk(text);
      }
    } catch (e) {
      GenUiWire.failure(
        channel: 'triage',
        error: e,
        elapsed: stopwatch.elapsed,
      );
      // Bez tego historia kończy się na `user` i następna tura dokłada drugie
      // `user` z rzędu — API odrzuca całość za brak naprzemienności ról.
      _history.removeLast();
      rethrow;
    }

    final raw = assistantText.toString();

    GenUiWire.response(
      channel: 'triage',
      elapsed: stopwatch.elapsed,
      firstChunkAfter: firstChunkAfter,
      chunks: chunks,
      raw: raw,
      componentNames: componentNamesIn(raw),
      usage: usage,
    );

    _tally = _tally.add(usage);

    _history.add({'role': 'assistant', 'content': raw});
  }

  static String _buildPrompt(Catalog catalog) => PromptBuilder.custom(
    catalog: catalog,
    allowedOperations: SurfaceOperations.updateOnly(dataModel: false),
    systemPromptFragments: [
      PromptFragments.uiGenerationRestriction(prefix: 'IMPORTANT: '),
      _stripDiscipline,
    ],
  ).systemPromptJoined();

  /// Model musi znać `surfaceId`, którego sam nie stworzył — inaczej wymyśli
  /// własny, update poleci do bufora i po minucie zniknie bez komunikatu.
  static final _stripDiscipline =
      '''
IMPORTANT: The strip surface ALREADY EXISTS. Its surfaceId is
"$triageStripSurfaceId" and its catalogId is "$triageCatalogId". You cannot
create or delete surfaces. Every response MUST be exactly one A2UI
`updateComponents` message targeting surfaceId "$triageStripSurfaceId", with
a component `id: "root"` as the entry point. Never reply with plain
conversational text — nobody is chatting with you, a phone is ringing.

Rebuild the whole strip on every turn: send the complete component list, not
a diff.''';

}
