import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/commons/a2ui/a2ui_sink.dart';
import 'package:flutter_genui_poc/commons/a2ui/surface_contract.dart';
import 'package:flutter_genui_poc/commons/logging/token_tally.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_cubit.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_state.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/support_case.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/triage_action.dart';
import 'package:flutter_genui_poc/features/triage_panel/page/triage_panel_page.dart';
import 'package:flutter_genui_poc/features/triage_panel/widget/triage_widgets.dart';
import 'package:flutter_genui_poc/genui_agent/mock_triage_agent.dart';
import 'package:flutter_genui_poc/genui_agent/triage_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/triage_catalog.dart';

/// Napędza PRAWDZIWY pipeline genui (transport → parser → `SurfaceController`)
/// na atrapie agenta.
void main() {
  ({TriagePanelCubit cubit, TriageActionBus bus}) buildCubit() {
    final bus = TriageActionBus();
    final cubit = TriagePanelCubit(MockTriageAgent(), triageCatalog(bus), bus);
    return (cubit: cubit, bus: bus);
  }

  /// Czeka na stan po turze. Domyślnie **także na komponenty**, bo werdykt
  /// kontraktu liczy się z tego, co poszło na drut, a `ConversationComponentsUpdated`
  /// przychodzi chwilę później — sam werdykt nie znaczy jeszcze, że pasek jest
  /// na ekranie.
  Future<TriagePanelState> answer(
    TriagePanelCubit cubit,
    SupportCase order, {
    bool Function(TriagePanelState)? until,
  }) async {
    // Future zakładany PRZED akcją: emisje bywają synchroniczne, a `stream`
    // jest broadcastem — `firstWhere` po fakcie przegapiłby stan.
    final settled = cubit.stream
        .firstWhere(
          until ??
              (s) => !s.isWaiting && s.verdict != null && s.hasStripContent,
        )
        .timeout(const Duration(seconds: 5));
    cubit.answerCall(order);
    return settled;
  }

  test('Pasek powstaje na powierzchni hosta i przechodzi kontrakt', () async {
    final (:cubit, :bus) = buildCubit();
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    final state = await answer(cubit, SupportCases.stuckShipment);

    expect(state.stripSurfaceId, triageStripSurfaceId);
    expect(state.verdict, isA<SurfaceAccepted>());
    expect(state.lastComponents, contains(TriageComponents.shipmentTracker));
    expect(state.lastComponents, contains(TriageComponents.actionRow));
    expect(state.showGeneratedStrip, isTrue);
  });

  test('Drugi telefon zostaje na TEJ SAMEJ powierzchni', () async {
    final (:cubit, :bus) = buildCubit();
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    final first = await answer(cubit, SupportCases.stuckShipment);
    final second = await answer(cubit, SupportCases.rejectedPayment);

    // Gdyby model dostał `createSurface`, dostalibyśmy drugą powierzchnię —
    // czyli czat, a nie pasek przebudowywany w miejscu.
    expect(second.stripSurfaceId, first.stripSurfaceId);
    expect(second.lastComponents, contains(TriageComponents.paymentBlock));
    expect(second.lastComponents, isNot(contains(TriageComponents.shipmentTracker)));
    expect(second.modelTurns, 2);
  });

  test('Przypadek B2B dostaje wymagany CreditLimitBanner', () async {
    final (:cubit, :bus) = buildCubit();
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    final state = await answer(cubit, SupportCases.b2bOverLimit);

    expect(state.lastComponents, contains(TriageComponents.creditLimitBanner));
    expect(state.verdict, isA<SurfaceAccepted>());
  });

  // Sedno tezy o koszcie: model rysuje przycisk, akcję wykonuje host.
  test('Kliknięcie akcji nie kosztuje tury modelu', () async {
    final (:cubit, :bus) = buildCubit();
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    await answer(cubit, SupportCases.stuckShipment);
    final turnsBefore = cubit.state.modelTurns;

    final effect = cubit.sideEffects.first.timeout(const Duration(seconds: 2));
    bus.dispatch((id: 'carrier_claim', label: 'Reklamuj u przewoźnika'));
    await effect;

    expect(cubit.state.userActions, 1);
    expect(cubit.state.modelTurns, turnsBefore, reason: 'zero requestów');
  });

  // Bramka przed promptem: zwykły `if` po stronie hosta, który wycina
  // większość ruchu z rachunku za tokeny.
  test('Zamówienie bez sygnałów nie generuje requestu', () async {
    final (:cubit, :bus) = buildCubit();
    addTearDown(bus.dispose);
    addTearDown(cubit.close);

    cubit.answerCall(
      const SupportCase(
        id: 'quiet',
        callReason: 'Zwykłe pytanie',
        orderNumber: '84-000001',
        customerName: 'Nikt',
      ),
    );

    expect(cubit.state.modelTurns, 0);
    expect(cubit.state.isWaiting, isFalse);
    expect(cubit.state.hasStripContent, isFalse);
  });

  testWidgets('Ekran renderuje wygenerowany pasek nad kartą zamówienia', (
    tester,
  ) async {
    setupDI();
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: TriagePanelPage()));

    expect(find.byType(ShipmentTracker), findsNothing);

    await tester.tap(find.text('Paczka stoi 4 dni'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(ShipmentTracker), findsOneWidget);
    expect(find.byType(ActionRow), findsOneWidget);

    // Karta zamówienia leży pod paskiem, poza cache'em `ListView` — trzeba do
    // niej doscrollować, żeby w ogóle powstała.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Zamówienie 84-119277'), findsOneWidget);
    expect(find.text('Klient'), findsOneWidget);
  });

  // To jest CAŁA teza wzorca „pasek nad ekranem": agent może paść, a ekran
  // domenowy zostaje użyteczny. Bez tego testu reszta modułu jest ozdobą.
  testWidgets('Agent rzuca → karta zamówienia nadal się renderuje', (
    tester,
  ) async {
    setupDI();
    getIt.unregister<TriageAgent>();
    getIt.registerLazySingleton<TriageAgent>(_ExplodingTriageAgent.new);
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: TriagePanelPage()));

    await tester.tap(find.text('Paczka stoi 4 dni'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Awaria'), findsOneWidget);
    expect(find.byType(ShipmentTracker), findsNothing);
    // Karta zamówienia jest na miejscu — konsultant pracuje tak, jak pracował
    // przed wdrożeniem genui.
    expect(find.text('Zamówienie 84-119277'), findsOneWidget);
    expect(find.text('Klient'), findsOneWidget);
    expect(find.text('M. Sobczak'), findsOneWidget);
  });

  // Pasek + karta + pasek laboratoryjny to trzy sztywne pasy w `Column`;
  // domyślne 800×600 testu jest zbyt łaskawe, żeby pokazać overflow.
  testWidgets('Mieści się na ekranie telefonu (375×812)', (tester) async {
    setupDI();
    addTearDown(getIt.reset);

    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TriagePanelPage()));

    // Czwarty telefon jest poza prawą krawędzią przewijanego paska rozmów —
    // na 375 dp trzeba go najpierw dosunąć, dokładnie jak na demie.
    final call = find.text('B2B: limit przekroczony o 12k');
    await tester.ensureVisible(call);
    await tester.pumpAndSettle();

    await tester.tap(call);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CreditLimitBanner), findsOneWidget);
  });
}

/// Agent, który zawsze pada. Osobno od wymuszonej awarii sieci, bo tamta jest
/// symulacją hosta, a ten sprawdza ścieżkę „coś w agencie wybuchło naprawdę".
class _ExplodingTriageAgent implements TriageAgent {
  @override
  String get label => 'Agent, który pada';

  @override
  bool get isMock => true;

  @override
  int get promptLength => 0;

  @override
  TokenTally get tally => const TokenTally();

  @override
  void bootstrapStrip(A2uiSink sink) => sink.addChunk(stripBootstrapChunk());

  @override
  void reset() {}

  @override
  Future<void> respond(ChatMessage message, A2uiSink sink) async {
    throw Exception('agent padł');
  }
}
