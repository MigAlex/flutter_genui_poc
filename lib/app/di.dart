import 'package:dio/dio.dart';
import 'package:genui/genui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../data/anthropic/anthropic_headers_interceptor.dart';
import '../data/anthropic/anthropic_stream_api.dart';
import '../data/anthropic/endpoints.dart';
import '../features/car_advisor/cubit/car_advisor_cubit.dart';
import '../features/genui_chat/cubit/genui_chat_cubit.dart';
import '../features/triage_panel/cubit/triage_panel_cubit.dart';
import '../features/triage_panel/model/triage_action.dart';
import '../genui_agent/advisor_agent.dart';
import '../genui_agent/claude_advisor_agent.dart';
import '../genui_agent/claude_genui_agent.dart';
import '../genui_agent/claude_triage_agent.dart';
import '../genui_agent/genui_agent.dart';
import '../genui_agent/mock_advisor_agent.dart';
import '../genui_agent/mock_genui_agent.dart';
import '../genui_agent/mock_triage_agent.dart';
import '../genui_agent/triage_agent.dart';
import '../genui_catalog/advisor_catalog.dart';
import '../genui_catalog/triage_catalog.dart';
import 'routes.dart';

final getIt = GetIt.instance;

const anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

/// Katalogi pod nazwami, bo `Catalog` jest zarejestrowany trzy razy i sam typ
/// nie wystarcza do rozróżnienia. Rejestracja bezimienna (czat) zostaje, żeby
/// nie ruszać dwóch starszych modułów.
const advisorCatalogInstance = 'advisorCatalog';
const triageCatalogInstance = 'triageCatalog';

void setupDI() {
  // ── Warstwa data/ ────────────────────────────────────────────────────────
  //
  // Konwencja projektu (`conv-flutter-networking`): Dio dla REST, nagłówki
  // przez `Interceptor`, paths w `Endpoints`, Api cienkie. Trzej agenci
  // dzielą JEDNĄ instancję — wcześniej każdy trzymał własnego `http.Client`
  // i własną kopię tej samej pętli SSE.
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: Endpoints.anthropicBase,
        // Model potrafi generować 8 s (zmierzone: 13,9 s przy dużym ekranie),
        // a domyślny `receiveTimeout` Dio ucinałby stream w połowie.
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 2),
      ),
    )..interceptors.add(AnthropicHeadersInterceptor(anthropicApiKey)),
    dispose: (dio) => dio.close(),
  );

  getIt.registerLazySingleton<AnthropicStreamApi>(
    () => AnthropicStreamApi(getIt<Dio>()),
  );

  // JEDEN katalog na ekran czatu — świadomie singleton, nie dwa wywołania
  // `asCatalog()`. Katalog jedzie dwoma torami: do `PromptBuilder` (model wie,
  // że widget istnieje) i do `SurfaceController` (renderer umie go narysować).
  getIt.registerLazySingleton<Catalog>(_buildCatalog);

  // Katalog doradcy: wąski, z własnym `catalogId` i własnym `CarCard`.
  getIt.registerLazySingleton<Catalog>(
    () => advisorCatalog(withUsageRule: true),
    instanceName: advisorCatalogInstance,
  );

  // Klucz jest → realny Claude. Brak klucza → mock (POC działa bez konfiguracji).
  getIt.registerLazySingleton<GenUiAgent>(
    () => anthropicApiKey.isEmpty
        ? MockGenUiAgent()
        : ClaudeGenUiAgent(
            api: getIt<AnthropicStreamApi>(),
            catalog: getIt<Catalog>(),
          ),
  );

  getIt.registerLazySingleton<AdvisorAgent>(
    () =>
        anthropicApiKey.isEmpty ? MockAdvisorAgent() : ClaudeAdvisorAgent(api: getIt<AnthropicStreamApi>()),
  );

  // Magistrala akcji paska triage'u. Singleton z `dispose`, bo katalog (też
  // singleton) trzyma do niej referencję w builderze `ActionRow` — gdyby żyła
  // krócej niż katalog, klik po powrocie na ekran trafiałby w zamknięty stream.
  getIt.registerLazySingleton<TriageActionBus>(
    TriageActionBus.new,
    dispose: (bus) => bus.dispose(),
  );

  // JEDEN katalog triage'u w oba tory: `PromptBuilder` (model wie, co istnieje)
  // i `SurfaceController` (renderer umie to narysować). Dwa wywołania fabryki
  // dałyby dwa różne `ActionRow` z dwiema różnymi magistralami — klik
  // z wygenerowanego paska nie trafiałby wtedy nigdzie.
  getIt.registerLazySingleton<Catalog>(
    () => triageCatalog(getIt<TriageActionBus>()),
    instanceName: triageCatalogInstance,
  );

  getIt.registerLazySingleton<TriageAgent>(
    () => anthropicApiKey.isEmpty
        ? MockTriageAgent()
        : ClaudeTriageAgent(
            api: getIt<AnthropicStreamApi>(),
            catalog: getIt<Catalog>(instanceName: triageCatalogInstance),
          ),
  );

  getIt.registerLazySingleton<GoRouter>(buildAppRouter);

  getIt.registerFactory<GenUiChatCubit>(
    () => GenUiChatCubit(getIt<GenUiAgent>(), getIt<Catalog>()),
  );

  getIt.registerFactory<CarAdvisorCubit>(
    () => CarAdvisorCubit(
      getIt<AdvisorAgent>(),
      getIt<Catalog>(instanceName: advisorCatalogInstance),
    ),
  );

  getIt.registerFactory<TriagePanelCubit>(
    () => TriagePanelCubit(
      getIt<TriageAgent>(),
      getIt<Catalog>(instanceName: triageCatalogInstance),
      getIt<TriageActionBus>(),
    ),
  );
}

/// Katalog przycięty do tego, czego czat realnie używa.
///
/// **Nie robimy tego dla kosztu** — ~20 000 znaków protokołu A2UI to podłoga,
/// której nie da się ściąć, więc przycięcie katalogu daje raptem −10%. Dźwignią
/// kosztową jest prompt caching w [ClaudeGenUiAgent] (liczby: README).
///
Catalog _buildCatalog() => BasicCatalogItems.asNoAssetCatalog().copyWithout(
  itemsToRemove: [BasicCatalogItems.tabs, BasicCatalogItems.modal],
);
