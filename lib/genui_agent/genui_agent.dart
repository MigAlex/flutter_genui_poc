import 'package:genui/genui.dart';

/// Wspólny kontrakt „mózgu" generującego UI. Implementacje:
/// - [MockGenUiAgent] — syntetyczny A2UI, bez klucza API
/// - [ClaudeGenUiAgent] — realny Claude (Anthropic Messages API)
abstract interface class GenUiAgent {
  /// Krótka nazwa do pokazania w UI (żeby było wiadomo kto rysuje).
  String get label;

  bool get isMock;

  /// Wywoływane przez `A2uiTransportAdapter.onSend`. Ma wypchnąć
  /// tekst A2UI do `transport.addChunk(...)`.
  Future<void> respond(ChatMessage message, A2uiTransportAdapter transport);

  /// Zapomina rozmowę. **Część kontraktu, nie detal `ClaudeGenUiAgent`:**
  /// „wyczyść czat" bez tego czyści tylko ekran, a model dalej pamięta
  /// wszystko i odpowiada w kontekście skasowanych tur — czyli UI kłamie.
  void reset();
}
