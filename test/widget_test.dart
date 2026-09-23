import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/app/routes.dart';
import 'package:flutter_genui_poc/genui_agent/genui_agent.dart';
import 'package:flutter_genui_poc/features/genui_chat/cubit/genui_chat_cubit.dart';
import 'package:flutter_genui_poc/genui_agent/mock_genui_agent.dart';
import 'package:flutter_genui_poc/main.dart';

void main() {
  setUp(setupDI);
  tearDown(getIt.reset);

  testWidgets('App buduje się i pokazuje hint startowy', (tester) async {
    await tester.pumpWidget(const GenUiPocApp());
    expect(find.text('Napisz cokolwiek poniżej'), findsOneWidget);
  });

  // Sprawdza wyłącznie zachowanie UI przy wysyłce, więc agent jest zaślepką —
  // dzięki temu test nie zależy od latencji ani timerów prawdziwego agenta.
  testWidgets('Wysłanie: pole się czyści, wiadomość zostaje widoczna', (
    tester,
  ) async {
    await getIt.reset();
    getIt.registerLazySingleton<Catalog>(BasicCatalogItems.asCatalog);
    getIt.registerLazySingleton<GenUiAgent>(_NoopAgent.new);
    getIt.registerFactory<GenUiChatCubit>(
      () => GenUiChatCubit(getIt<GenUiAgent>(), getIt<Catalog>()),
    );
    // Od czasu dodania drugiego ekranu apka startuje przez router — bez tego
    // `GenUiPocApp` nie ma czego zbudować.
    getIt.registerLazySingleton<GoRouter>(buildAppRouter);

    await tester.pumpWidget(const GenUiPocApp());

    await tester.enterText(find.byType(TextField), 'siema');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty, reason: 'pole ma się wyczyścić');
    expect(
      find.text('siema'),
      findsOneWidget,
      reason: 'wiadomość usera ma zostać na ekranie',
    );
  });

  // Napędza PRAWDZIWY pipeline genui (transport → A2uiParserTransformer →
  // SurfaceController) i sprawdza, że surowy A2UI od mocka przeszedł do stanu
  // jako nowa powierzchnia. `await close()` disposuje controller i anuluje
  // wewnętrzny timer genui (czysty teardown).
  test('Prompt → mock A2UI parsuje się i dodaje surface do stanu', () async {
    final cubit = GenUiChatCubit(
      MockGenUiAgent(),
      BasicCatalogItems.asCatalog(),
    );
    addTearDown(cubit.close);

    cubit.sendPrompt('Zaplanuj mi wyjazd');

    final state = await cubit.stream
        .firstWhere((s) => s.surfaceIds.isNotEmpty)
        .timeout(const Duration(seconds: 5));

    expect(state.surfaceIds, isNotEmpty);
    expect(state.error, isNull);
  });

  // Reset musi zdjąć TRZY rzeczy naraz: tury na ekranie, powierzchnie
  // w kontrolerze i pamięć agenta. Test pilnuje głównie tej trzeciej —
  // najłatwiej ją przeoczyć, bo jej brak nie widać na ekranie: model
  // odpowiadałby dalej w kontekście tur, których user już nie widzi.
  test('resetChat czyści stan ORAZ historię agenta', () async {
    final agent = _SpyAgent();
    final cubit = GenUiChatCubit(agent, BasicCatalogItems.asCatalog());
    addTearDown(cubit.close);

    cubit.sendPrompt('Zaplanuj mi wyjazd');
    await cubit.stream
        .firstWhere((s) => s.turns.isNotEmpty)
        .timeout(const Duration(seconds: 5));

    await cubit.resetChat();

    expect(cubit.state.turns, isEmpty, reason: 'ekran ma być pusty');
    expect(cubit.state.surfaceIds, isEmpty);
    expect(agent.resetCount, 1, reason: 'model ma zapomnieć rozmowę');

    // Pipeline po odbudowie musi dalej działać — inaczej „wyczyść" znaczy
    // „zepsuj czat do restartu aplikacji".
    cubit.sendPrompt('jeszcze raz');
    final after = await cubit.stream
        .firstWhere((s) => s.turns.isNotEmpty)
        .timeout(const Duration(seconds: 5));
    expect(after.turns, hasLength(1));
  });
}

/// Agent-szpieg: liczy `reset()`, poza tym nic nie robi.
class _SpyAgent implements GenUiAgent {
  int resetCount = 0;

  @override
  String get label => 'spy';

  @override
  bool get isMock => true;

  @override
  Future<void> respond(
    ChatMessage message,
    A2uiTransportAdapter transport,
  ) async {}

  @override
  void reset() => resetCount++;
}

/// Agent-zaślepka: nic nie generuje, nie odpala timerów.
class _NoopAgent implements GenUiAgent {
  @override
  String get label => 'noop';

  @override
  bool get isMock => true;

  @override
  Future<void> respond(
    ChatMessage message,
    A2uiTransportAdapter transport,
  ) async {}

  @override
  void reset() {}
}
