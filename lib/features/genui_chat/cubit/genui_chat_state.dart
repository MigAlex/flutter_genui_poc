import 'package:freezed_annotation/freezed_annotation.dart';

part 'genui_chat_state.freezed.dart';

/// Jedna tura rozmowy: prompt użytkownika + surface'y, które model pod niego
/// wygenerował. Dzięki temu widać KTÓRE pytanie dało KTÓRE UI.
@freezed
abstract class ChatTurn with _$ChatTurn {
  const factory ChatTurn({
    required String prompt,
    @Default(<String>[]) List<String> surfaceIds,
  }) = _ChatTurn;
}

@freezed
abstract class GenUiChatState with _$GenUiChatState {
  const factory GenUiChatState({
    @Default(<ChatTurn>[]) List<ChatTurn> turns,
    @Default(false) bool isWaiting,
    String? error,

    /// Zwykły tekst od modelu (gdy odpowiedział prozą zamiast A2UI).
    /// Bez tego taka odpowiedź znikała bez śladu i ekran zostawał pusty.
    String? latestText,
  }) = _GenUiChatState;

  const GenUiChatState._();

  /// Płaska lista wszystkich surface'ów (wygoda przy testach i renderze).
  List<String> get surfaceIds => [for (final turn in turns) ...turn.surfaceIds];
}
