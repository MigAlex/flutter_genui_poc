import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/genui_agent/advisor_agent.dart';
import 'package:flutter_genui_poc/features/car_advisor/cubit/car_advisor_cubit.dart';
import 'package:flutter_genui_poc/features/car_advisor/page/car_advisor_page.dart';
import 'package:flutter_genui_poc/features/car_advisor/widget/car_card.dart';
import 'package:flutter_genui_poc/genui_agent/mock_advisor_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/advisor_catalog.dart';

/// Napędza PRAWDZIWY pipeline genui (transport → parser → SurfaceController)
/// na atrapie agenta. Sprawdza dwie rzeczy, których nie da się wyczytać
/// z kodu: że własny `CarCard` faktycznie przechodzi przez katalog do
/// renderera, i że panel **podmienia się w miejscu** zamiast mnożyć
/// powierzchnie.
void main() {
  test('Mock: panel dostaje CarCard i zostaje na jednej powierzchni', () async {
    final cubit = CarAdvisorCubit(
      MockAdvisorAgent(),
      advisorCatalog(withUsageRule: true),
    );
    addTearDown(cubit.close);

    cubit.requestAdvice();

    final first = await cubit.stream
        .firstWhere((s) => s.hasContent && s.hasResult)
        .timeout(const Duration(seconds: 5));

    expect(first.panelSurfaceId, advisorPanelSurfaceId);
    expect(first.carCardUsed, isTrue);
    expect(first.lastComponents, contains('CarCard'));
    expect(first.error, isNull);

    // Druga tura: id powierzchni MA zostać ten sam. Gdyby model dostał
    // `createSurface`, dostalibyśmy tu drugą powierzchnię — czyli czat,
    // a nie panel.
    cubit.requestAdvice();

    final second = await cubit.stream
        .firstWhere((s) => s.requestCount == 2 && !s.isWaiting)
        .timeout(const Duration(seconds: 5));

    expect(second.panelSurfaceId, first.panelSurfaceId);
  });

  testWidgets('Ekran renderuje własny CarCard po kliknięciu „Dobierz auta"', (
    tester,
  ) async {
    setupDI();
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: CarAdvisorPage()));

    expect(find.byType(CarCard), findsNothing, reason: 'zanim padnie request');

    await tester.tap(find.text('Dobierz auta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(CarCard), findsNWidgets(2));
    expect(find.textContaining('CarCard użyty'), findsOneWidget);
  });

  // Panel kryteriów + powierzchnia + pasek A/B na jednym ekranie to trzy
  // sztywne pasy w Column — na telefonie najłatwiej tu o overflow, a domyślne
  // 800×600 testu jest zbyt łaskawe, żeby to pokazać.
  testWidgets('Mieści się na ekranie telefonu (375×812)', (tester) async {
    setupDI();
    addTearDown(getIt.reset);

    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CarAdvisorPage()));

    await tester.tap(find.text('Dobierz auta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CarCard), findsWidgets);
  });

  // Regres, który psuje się CICHO: apka dalej działa, tylko eksperyment
  // przestaje mierzyć to, co miał. Wariant bez reguły widziałby w historii
  // własną odpowiedź wariantu z regułą (pełną `CarCard`), a prompt panelu
  // każe „przebuduj cały panel" — model naśladuje poprzednie drzewo jak
  // przykład few-shot i `CarCard` wychodzi w obu wariantach.
  test('Przełączenie A/B czyści historię i poprzedni werdykt', () async {
    final agent = _ResetSpyAdvisorAgent();
    final cubit = CarAdvisorCubit(agent, advisorCatalog(withUsageRule: true));
    addTearDown(cubit.close);

    cubit.requestAdvice();
    await cubit.stream
        .firstWhere((s) => s.hasResult)
        .timeout(const Duration(seconds: 5));
    expect(cubit.state.carCardUsed, isTrue);

    cubit.toggleCarCard(enabled: false);

    expect(agent.resetCount, 1, reason: 'oba warianty startują z pustego');
    expect(
      cubit.state.hasResult,
      isFalse,
      reason: 'werdykt poprzedniego wariantu nie może wisieć nad nowym',
    );
  });

  // Zwinięcie panelu kryteriów to nie kosmetyka: rozwinięty zabiera ~2/3
  // ekranu telefonu, więc wygenerowana powierzchnia zostaje bez miejsca.
  test('Panel kryteriów zwija się po wysłaniu zapytania', () async {
    final cubit = CarAdvisorCubit(
      MockAdvisorAgent(),
      advisorCatalog(withUsageRule: true),
    );
    addTearDown(cubit.close);

    expect(cubit.state.criteriaCollapsed, isFalse);

    cubit.requestAdvice();

    expect(cubit.state.criteriaCollapsed, isTrue);
  });
}

/// Liczy `reset()`; resztę deleguje do atrapy panelu.
class _ResetSpyAdvisorAgent implements AdvisorAgent {
  final _inner = MockAdvisorAgent();
  int resetCount = 0;

  @override
  String get label => _inner.label;

  @override
  bool get isMock => true;

  @override
  void bootstrapPanel(A2uiTransportAdapter transport) =>
      _inner.bootstrapPanel(transport);

  @override
  PromptDiagnostics diagnostics({required bool withCarCard}) =>
      _inner.diagnostics(withCarCard: withCarCard);

  @override
  void reset() => resetCount++;

  @override
  Future<Set<String>> respond(
    ChatMessage message,
    A2uiTransportAdapter transport, {
    required bool withCarCard,
  }) => _inner.respond(message, transport, withCarCard: withCarCard);
}
