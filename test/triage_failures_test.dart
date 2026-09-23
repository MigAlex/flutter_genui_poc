import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/commons/a2ui/surface_contract.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_cubit.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_state.dart';
import 'package:flutter_genui_poc/features/triage_panel/failure/failure_injector.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/support_case.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/triage_action.dart';
import 'package:flutter_genui_poc/genui_agent/mock_triage_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/triage_catalog.dart';

/// Cztery wymuszone awarie muszą dawać **cztery rozróżnialne komunikaty** —
/// to jest kryterium odbioru modułu. Jeden generyczny „coś poszło nie tak"
/// znaczyłby, że host nie wie, co się stało, a więc nie umie tego naprawić.
void main() {
  Future<TriagePanelState> runWith(
    TriageFailure failure,
    SupportCase order,
  ) async {
    final bus = TriageActionBus();
    final cubit = TriagePanelCubit(MockTriageAgent(), triageCatalog(bus), bus);
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    cubit.setFailure(failure);

    final settled = cubit.stream
        .firstWhere((s) => !s.isWaiting && (s.verdict != null || s.error != null))
        .timeout(const Duration(seconds: 5));
    cubit.answerCall(order);
    return settled;
  }

  test('Proza zamiast A2UI — pasek zdjęty, rozpoznane jako brak A2UI', () async {
    final state = await runWith(
      TriageFailure.prose,
      SupportCases.stuckShipment,
    );

    expect(state.verdict, isA<NoA2ui>());
    expect(state.lastComponents, isEmpty);
    expect(state.showGeneratedStrip, isFalse);
    expect(state.showFallbackStrip, isTrue);
  });

  test('Zły catalogId — powierzchnia inna niż w kontrakcie', () async {
    final state = await runWith(
      TriageFailure.wrongCatalog,
      SupportCases.stuckShipment,
    );

    final verdict = state.verdict;
    expect(verdict, isA<WrongSurface>());
    expect((verdict! as WrongSurface).actual, triageBrokenSurfaceId);
    // Komponenty PRZYSZŁY — to jest właśnie ta cicha awaria: renderer nie zna
    // katalogu tej powierzchni, więc na ekranie nie byłoby nic i ani słowa
    // w logu. Widać ją wyłącznie dlatego, że host sprawdza adres.
    expect(state.lastComponents, isNotEmpty);
  });

  test('Brak wymaganego komponentu — werdykt z nazwą reguły', () async {
    final state = await runWith(
      TriageFailure.missingRequired,
      SupportCases.b2bOverLimit,
    );

    final verdict = state.verdict;
    expect(verdict, isA<RequiredComponentMissing>());
    expect(
      (verdict! as RequiredComponentMissing).component,
      TriageComponents.creditLimitBanner,
    );
    expect(state.lastComponents, isNot(contains(TriageComponents.creditLimitBanner)));
    // Reszta paska przyszła i jest poprawna — dlatego bez kontraktu ta awaria
    // wygląda na ekranie jak zwykły, ładny pasek.
    expect(state.lastComponents, contains(TriageComponents.actionRow));
    expect(state.showFallbackStrip, isTrue);
  });

  test('Błąd sieci — wyjątek przed requestem, komunikat zamiast spinnera', () async {
    final state = await runWith(
      TriageFailure.network,
      SupportCases.stuckShipment,
    );

    expect(state.isWaiting, isFalse);
    expect(state.error, contains('Błąd sieci'));
    expect(state.verdict, isNull);
  });

  test('Cztery awarie dają cztery RÓŻNE komunikaty', () async {
    final diagnoses = <String>{};

    for (final (failure, order) in [
      (TriageFailure.prose, SupportCases.stuckShipment),
      (TriageFailure.wrongCatalog, SupportCases.stuckShipment),
      (TriageFailure.missingRequired, SupportCases.b2bOverLimit),
      (TriageFailure.network, SupportCases.stuckShipment),
    ]) {
      final state = await runWith(failure, order);
      final diagnosis = state.diagnosis;
      expect(diagnosis, isNotNull, reason: '${failure.label} nie powiedziało nic');
      diagnoses.add(diagnosis!);
    }

    expect(diagnoses, hasLength(4));
  });

  // Wyłączony kontrakt nie ukrywa problemu — pokazuje, jak wygląda jego brak.
  test('Bez egzekwowania kontraktu odrzucony pasek i tak idzie na ekran', () async {
    final bus = TriageActionBus();
    final cubit = TriagePanelCubit(MockTriageAgent(), triageCatalog(bus), bus);
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    cubit
      ..setFailure(TriageFailure.missingRequired)
      ..toggleContract(enforced: false);

    final settled = cubit.stream
        .firstWhere((s) => !s.isWaiting && s.verdict != null && s.hasStripContent)
        .timeout(const Duration(seconds: 5));
    cubit.answerCall(SupportCases.b2bOverLimit);
    final state = await settled;

    expect(state.rejected, isTrue, reason: 'werdykt liczy się zawsze');
    expect(state.showFallbackStrip, isFalse);
    expect(state.showGeneratedStrip, isTrue, reason: 'ciche pominięcie');
  });
}
