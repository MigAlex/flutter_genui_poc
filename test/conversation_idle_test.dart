import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/features/car_advisor/cubit/car_advisor_cubit.dart';
import 'package:flutter_genui_poc/features/genui_chat/cubit/genui_chat_cubit.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_cubit.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/support_case.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/triage_action.dart';
import 'package:flutter_genui_poc/genui_agent/mock_advisor_agent.dart';
import 'package:flutter_genui_poc/genui_agent/mock_genui_agent.dart';
import 'package:flutter_genui_poc/genui_agent/mock_triage_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/advisor_catalog.dart';
import 'package:flutter_genui_poc/genui_catalog/triage_catalog.dart';

/// Regresja na pułapkę cyklu życia `Conversation` (patrz `ConversationIdle`).
///
/// Każdy test **startuje turę i zamyka cubita, zanim ta tura wróci** — czyli
/// robi to, co user cofający się z ekranu w czasie oczekiwania.
///
/// ⚠️ **Kluczowy jest `_settle()` po `close()`.** Wyjątek nie leci w momencie
/// zamknięcia, tylko dopiero gdy tura wraca (mocki mają 300–400 ms latencji)
/// i `sendRequest` dotyka w swoim `finally` już zdisposowanego notifiera.
/// Bez tego czekania test kończy się wcześniej niż awaria i jest zielony
/// także ze zdjętą łatką — pierwsza wersja tego pliku miała dokładnie ten błąd.
///
/// `testWidgets` też tu nie zadziała: sterowany zegar `pump` nie dogania
/// wewnętrznych strumieni genui i `awaitIdle()` zakleszcza się na dobre.
void main() {
  test('Czat: close() w trakcie tury nie wywala genui', () async {
    final cubit = GenUiChatCubit(
      MockGenUiAgent(),
      BasicCatalogItems.asCatalog(),
    )..sendPrompt('siema');

    // `onSend` ustawia `isWaiting` synchronicznie — dowód, że zamykamy
    // NAPRAWDĘ w trakcie tury, a nie po niej.
    expect(cubit.state.isWaiting, isTrue);

    await cubit.close();
    await _settle();
  });

  test('Panel doradcy: close() w trakcie tury nie wywala genui', () async {
    final cubit = CarAdvisorCubit(
      MockAdvisorAgent(),
      advisorCatalog(withUsageRule: true),
    )..requestAdvice();

    expect(cubit.state.isWaiting, isTrue);

    await cubit.close();
    await _settle();
  });

  // Trzeci tor ma tę samą pułapkę i jeden powód więcej, żeby na nią wpaść:
  // konsultant rozłącza się w trakcie składania paska.
  test('Panel BOK: close() w trakcie tury nie wywala genui', () async {
    final bus = TriageActionBus();
    addTearDown(bus.dispose);

    final cubit = TriagePanelCubit(MockTriageAgent(), triageCatalog(bus), bus)
      ..answerCall(SupportCases.stuckShipment);

    expect(cubit.state.isWaiting, isTrue);

    await cubit.close();
    await _settle();
  });
}

/// Przeżywa turę mocka (300–400 ms) z zapasem. Bez tego spóźniona awaria
/// wypada poza test i nikt jej nie zobaczy.
Future<void> _settle() => Future<void>.delayed(const Duration(seconds: 1));
