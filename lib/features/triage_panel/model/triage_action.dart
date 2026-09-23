import 'dart:async';

/// Akcja, którą model może **narysować**, ale której nie wykonuje.
///
/// `id` jest kontraktem z hostem (host wie, co zrobić), `label` jest tekstem
/// dla konsultanta. Rekord, nie klasa: to para wartości bez zachowania.
typedef TriageAction = ({String id, String label});

/// Kliknięcie w akcję z wygenerowanego paska — **obsługiwane przez host,
/// nie przez model**.
///
/// > **Dlaczego to nie jest `UserActionEvent`.** Kanoniczna droga genui
/// > (`itemContext.dispatchEvent(UserActionEvent(...))`) wraca do `Conversation`
/// > jako `uiInteractionParts` i **wyzwala pełną turę modelu**. Tutaj chcemy
/// > dokładnie odwrotnie: klik w „Reklamuj u przewoźnika" ma kosztować **zero
/// > requestów**, bo reklamację składa nasz serwis, a nie model. Więc akcja nie
/// > wchodzi w ogóle do rozmowy — leci własną szyną do hosta.
///
/// To jest ta sama zasada co „tapnięcie-dane vs tapnięcie-intencji", tylko
/// z trzecim przypadkiem: **tapnięcie-wykonanie**, które w ogóle nie jest
/// sprawą modelu.
class TriageActionBus {
  final _controller = StreamController<TriageAction>.broadcast();

  Stream<TriageAction> get stream => _controller.stream;

  void dispatch(TriageAction action) {
    if (!_controller.isClosed) _controller.add(action);
  }

  void dispose() => _controller.close();
}
