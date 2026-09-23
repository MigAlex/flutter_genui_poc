import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/commons/widgets/agent_banner.dart';
import 'package:flutter_genui_poc/features/car_advisor/page/car_advisor_page.dart';
import 'package:flutter_genui_poc/features/genui_chat/cubit/genui_chat_cubit.dart';
import 'package:flutter_genui_poc/features/genui_chat/page/genui_chat_page.dart';
import 'package:flutter_genui_poc/genui_agent/genui_agent.dart';

/// Pilnuje jednej rzeczy, której łatwo nie zauważyć przy refaktorze:
/// **na żadnym ekranie nie wolno stracić informacji, kto właśnie odpowiada.**
///
/// Mock i realny model rysują to samo, tym samym pipeline'em. Bez trwałego
/// sygnału najłatwiejszy błąd tego POC-a to wziąć render atrapy za dowód na
/// zachowanie modelu. Wcześniej etykieta agenta na czacie **znikała po
/// pierwszej wiadomości** — dokładnie ten regres ma tu zostać złapany.
void main() {
  setUp(setupDI);
  tearDown(getIt.reset);

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  final screens = <String, Widget>{
    'czat': const GenUiChatPage(),
    'panel': const CarAdvisorPage(),
  };

  for (final MapEntry(key: name, value: screen) in screens.entries) {
    testWidgets('$name: baner agenta jest widoczny od startu', (tester) async {
      await pumpScreen(tester, screen);

      expect(find.byType(AgentBanner), findsOneWidget);
      // Bez klucza API DI wybiera atrapy — tryb musi być nazwany wprost,
      // nie zasugerowany kolorem.
      expect(find.textContaining('MOCK', findRichText: true), findsOneWidget);
    });
  }

  testWidgets('Czat: baner NIE znika po wysłaniu wiadomości', (tester) async {
    // Agent-zaślepka zamiast atrapy z DI: interesuje nas wyłącznie to, czy
    // baner przeżyje zmianę stanu z „pusto" na „jest tura". Prawdziwa
    // powierzchnia uzbroiłaby `Timer` pending-update i test wywaliłby się
    // na `!timersPending` w teardownie, nie na zbadanym zachowaniu.
    getIt.unregister<GenUiChatCubit>();
    getIt.registerFactory<GenUiChatCubit>(
      () => GenUiChatCubit(_SilentAgent(), getIt<Catalog>()),
    );

    await pumpScreen(tester, const GenUiChatPage());
    expect(find.byType(AgentBanner), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'siema');
    await tester.testTextInput.receiveAction(TextInputAction.send);

    // Świadomie BEZ `pumpAndSettle`: po pierwszej powierzchni `SurfaceController`
    // armuje `Timer` na pending-update i drzewo nigdy nie „osiada"
    // (udokumentowana pułapka testowa genui). Wystarczy przepompować tyle,
    // ile trwa odpowiedź atrapy.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.byType(AgentBanner),
      findsOneWidget,
      reason:
          'to był realny regres: etykieta żyła tylko w podpowiedzi '
          'na pustym ekranie',
    );
  });

  testWidgets('Tap w baner otwiera rozpiskę „co dowodzi mock, a co model"', (
    tester,
  ) async {
    await pumpScreen(tester, const CarAdvisorPage());

    await tester.tap(find.byType(AgentBanner));
    await tester.pumpAndSettle();

    expect(find.text('Tryb: mock'), findsOneWidget);
    expect(find.textContaining('Model sięga po Twój widget'), findsOneWidget);
    expect(find.textContaining('Realna latencja'), findsOneWidget);
  });
}

/// Nic nie generuje, więc nie zakłada powierzchni i nie uzbraja timerów.
class _SilentAgent implements GenUiAgent {
  @override
  String get label => 'silent';

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
