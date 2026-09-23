import 'dart:async';

import 'package:genui/genui.dart';

/// Obejście pułapki cyklu życia `Conversation` — wspólne dla wszystkich trzech
/// torów POC-a (czat, panel, triage).
///
/// > **Pułapka genui (zweryfikowana na 0.10.1, obejście utrzymane na 0.10.3):**
/// > `Conversation.sendRequest` ma `finally { _updateState(...) }`, które dotyka
/// > jego `ValueNotifier` **po** tym, jak nasz `onSend` się skończy. Rozmontowanie
/// > pipeline'u w trakcie tury — zamknięcie ekranu albo reset czatu — wywala
/// > wtedy „used after being disposed" z wnętrza paczki, w miejscu bez związku
/// > z naszym kodem.
///
/// Czekanie na future z własnego `onSend` **nie wystarcza**: kończy się o kilka
/// mikrotasków wcześniej niż tamten `finally`. Zamiast zgadywać liczbę obrotów
/// pętli zdarzeń, pytamy genui wprost — jej własne `isWaiting` gaśnie dokładnie
/// w tym `finally`.
///
/// ⚠️ Łatka przez `await Future.delayed(Duration.zero)` **nie przechodzi**:
/// w `testWidgets` liczy się jako pending timer i test pada na „A Timer is still
/// pending".
extension ConversationIdle on Conversation {
  /// Kończy się, gdy `Conversation` sama uzna turę za zakończoną.
  /// Natychmiast, gdy żadna tura nie leci.
  Future<void> awaitIdle() {
    if (!state.value.isWaiting) return Future<void>.value();

    final idle = Completer<void>();
    void check() {
      if (!state.value.isWaiting && !idle.isCompleted) idle.complete();
    }

    state.addListener(check);
    return idle.future.whenComplete(() => state.removeListener(check));
  }
}
