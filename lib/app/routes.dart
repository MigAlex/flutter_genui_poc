import 'package:go_router/go_router.dart';
import 'package:status_screen/status_screen.dart';

import '../features/car_advisor/page/car_advisor_page.dart';
import '../features/genui_chat/page/genui_chat_page.dart';
import '../features/triage_panel/page/triage_panel_page.dart';

/// Enum zamiast gołych stringów — nawigujemy przez `goNamed`/`pushNamed`,
/// więc literówka w ścieżce jest błędem kompilacji, nie pustym ekranem
/// w runtime.
///
/// Trzy tryby genui: **czat** (nowa powierzchnia na turę), **panel**
/// (jedna powierzchnia przebudowywana w miejscu) i **triage** (pasek nad
/// nietkniętym ekranem domenowym, z kontraktem powierzchni po stronie hosta).
///
/// Czwarty — kreator krokowy — został z POC-a usunięty 2026-08-12; wnioski
/// z niego (DataModel per powierzchnia, dispose w trakcie tury, host jako
/// właściciel FSM) zostały spisane poza repo — w kodzie ich już nie ma.
enum AppRoutes {
  chat('/'),
  advisor('/advisor'),
  triage('/triage');

  const AppRoutes(this.path);

  final String path;
}

/// Router żyje w DI, nie jako globalny `final`. Dzięki temu `getIt.reset()`
/// w teardownie testu daje świeżą nawigację, zamiast przenosić stos
/// z poprzedniego testu.
GoRouter buildAppRouter() => GoRouter(
  // Kazdy nieznany deep link laduje na grywalnym 404 (_shared/status_screen).
  errorBuilder: (context, state) => StatusScreen(
    code: '404',
    message: state.uri.toString(),
    onBack: () => context.go('/'),
  ),
  routes: [
    GoRoute(
      path: AppRoutes.chat.path,
      name: AppRoutes.chat.name,
      builder: (context, state) => const GenUiChatPage(),
    ),
    GoRoute(
      path: AppRoutes.advisor.path,
      name: AppRoutes.advisor.name,
      builder: (context, state) => const CarAdvisorPage(),
    ),
    GoRoute(
      path: AppRoutes.triage.path,
      name: AppRoutes.triage.name,
      builder: (context, state) => const TriagePanelPage(),
    ),
  ],
);
