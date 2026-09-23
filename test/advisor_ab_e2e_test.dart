import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/data/anthropic/anthropic_stream_api.dart';
import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/commons/logging/genui_wire_log.dart';
import 'package:flutter_genui_poc/features/car_advisor/cubit/car_advisor_cubit.dart';
import 'package:flutter_genui_poc/features/car_advisor/cubit/car_advisor_state.dart';
import 'package:flutter_genui_poc/features/car_advisor/model/car_fuel.dart';
import 'package:flutter_genui_poc/genui_agent/claude_advisor_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/advisor_catalog.dart';

/// Eksperyment ④ na **żywym** Haiku: czy model sięgnie po własny `CarCard`,
/// gdy katalog go zawiera, ale nic nie mówi, kiedy go użyć.
///
/// Jedyną zmienną jest `withUsageRule`. Katalog, `catalogId`, lista widgetów
/// i kryteria są identyczne w obu przebiegach, a `mentionsCarCard` musi być
/// `true` po obu stronach — bez tego wynik nie znaczy nic, bo różnicę dałoby
/// się wytłumaczyć tym, że model po prostu nie znał widgetu.
///
/// Każdy wariant dostaje **świeżego agenta**: historia rozmowy jest polem
/// agenta, więc jeden obiekt na oba przebiegi pokazałby modelowi w wariancie B
/// jego własną odpowiedź z wariantu A. To by rozstrzygnęło eksperyment za niego.
///
/// Uruchomienie:
///   flutter test test/advisor_ab_e2e_test.dart --dart-define-from-file=secrets.json
void main() {
  // Surowy A2UI do konsoli — ten przebieg JEST zapisem eksperymentu.
  setUpAll(() => GenUiWire.dumpRawBody = true);
  tearDownAll(() => GenUiWire.dumpRawBody = false);

  /// Jedna komórka macierzy. Świeży agent i świeży cubit za każdym razem —
  /// historia rozmowy jest polem agenta, więc reużycie pokazałoby kolejnej
  /// komórce odpowiedź z poprzedniej i rozstrzygnęło eksperyment za model.
  Future<CarAdvisorState> runCell({
    required bool withUsageRule,
    required bool withExample,
  }) async {
    // Obie osie eksperymentu ustawia KONSTRUKTOR agenta. Runtime'owy
    // przełącznik w UI steruje czym innym — obecnością `CarCard` w katalogu —
    // i tu zostaje włączony, bo bez widgetu pytanie „czy model go użyje"
    // nie miałoby sensu.
    final api = AnthropicStreamApi.withKey(anthropicApiKey);
    final agent = ClaudeAdvisorAgent(
      api: api,
      withExample: withExample,
      withUsageRule: withUsageRule,
    );
    final cubit = CarAdvisorCubit(
      agent,
      advisorCatalog(withUsageRule: withUsageRule, withExample: withExample),
    );

    // Te same kryteria w każdej komórce — zmienne mają być tylko dwie.
    cubit
      ..setBudget(60000)
      ..setBody(CarBody.wagon)
      ..setFuel(CarFuel.diesel)
      ..setMaxMileage(180000);

    final done = cubit.stream
        .firstWhere((s) => !s.isWaiting && (s.hasResult || s.error != null))
        .timeout(const Duration(seconds: 90));

    cubit.requestAdvice();
    final state = await done;

    await cubit.close();
    api.close();
    return state;
  }

  String cell(CarAdvisorState s) =>
      '${s.carCardUsed ? 'UŻYTY  ' : 'POMINIĘTY'}  '
      '{${(s.lastComponents.toList()..sort()).join(', ')}}'
      '${s.error == null ? '' : '  BŁĄD: ${s.error}'}'
      '${s.latestText == null ? '' : '  PROZA: ${s.latestText}'}';

  test(
    'Macierz 2×2 na żywym Haiku: reguła użycia × exampleData',
    () async {
      // A i B powtórzone razem z C i D, bo porównywać wolno tylko przebiegi
      // z tej samej sesji — model nie jest deterministyczny.
      final a = await runCell(withUsageRule: true, withExample: true);
      final b = await runCell(withUsageRule: false, withExample: true);
      final c = await runCell(withUsageRule: false, withExample: false);
      final d = await runCell(withUsageRule: true, withExample: false);

      // Jedna sonda na komórkę, bo osie siedzą teraz w konstruktorze.
      // Sondy pytają tylko o `diagnostics()` (zero sieci), ale każda trzyma
      // własnego klienta — zbieramy je, żeby zamknąć na końcu.
      final probeApis = <AnthropicStreamApi>[];
      ClaudeAdvisorAgent probeFor({
        required bool withUsageRule,
        required bool withExample,
      }) {
        final api = AnthropicStreamApi.withKey(anthropicApiKey);
        probeApis.add(api);
        return ClaudeAdvisorAgent(
          api: api,
          withUsageRule: withUsageRule,
          withExample: withExample,
        );
      }

      final probes = {
        'A': probeFor(withUsageRule: true, withExample: true),
        'B': probeFor(withUsageRule: false, withExample: true),
        'C': probeFor(withUsageRule: false, withExample: false),
        'D': probeFor(withUsageRule: true, withExample: false),
      };
      final diag = {
        for (final e in probes.entries)
          e.key: e.value.diagnostics(withCarCard: true),
      };
      final lenA = diag['A']!.length;
      final lenB = diag['B']!.length;
      final lenC = diag['C']!.length;
      final lenD = diag['D']!.length;
      final seesA = diag['A']!.mentionsCarCard;
      final seesC = diag['C']!.mentionsCarCard;
      for (final api in probeApis) {
        api.close();
      }

      // ignore: avoid_print — ten wydruk JEST wynikiem eksperymentu.
      print('''

╔══════════════════════════════════════════════════════════════════════════╗
║  EKSPERYMENT ④ — macierz reguła × exampleData (żywe Haiku 4.5)           ║
╚══════════════════════════════════════════════════════════════════════════╝

  wariant │ reguła │ example │ prompt   │ wynik
  ────────┼────────┼─────────┼──────────┼──────────────────────────────────
  A       │  WŁ    │   WŁ    │ $lenA zn. │ ${cell(a)}
  B       │  WYŁ   │   WŁ    │ $lenB zn. │ ${cell(b)}
  C       │  WYŁ   │   WYŁ   │ $lenC zn. │ ${cell(c)}
  D       │  WŁ    │   WYŁ   │ $lenD zn. │ ${cell(d)}

  CarCard widoczny w prompcie: A=$seesA · C=$seesC   (musi być true w obu)

  ODCZYT:
   · C pominął  → warstwę 4 (regułę) niosło `exampleData`; reguła zbędna przy przykładzie
   · C użył     → wystarczy sam schemat+description; obie warstwy były nadmiarowe
   · C pominął, D użył → reguła DZIAŁA samodzielnie (potwierdza tezę kursu)
''');

      // Twarde jest tylko to, że widget był widoczny i nic nie padło.
      expect(seesA, isTrue);
      expect(seesC, isTrue);
      for (final s in [a, b, c, d]) {
        expect(s.error, isNull);
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
    skip: anthropicApiKey.isEmpty
        ? 'Brak ANTHROPIC_API_KEY — pomijam eksperyment na żywym API'
        : false,
  );

  /// Eksperyment ⑤: czy prompt caching **realnie trafia**, czy API tylko
  /// przyjmuje jego formę bez protestu.
  ///
  /// Dwie tury na TYM SAMYM agencie, czyli z identycznym system promptem.
  /// Pierwsza ma zapisać cache, druga odczytać. Odczyt równy zero w drugiej
  /// turze oznaczałby, że płacimy pełną stawkę za ~30 tys. znaków przy każdym
  /// kliknięciu — a nikt by tego nie zauważył, bo nic się nie psuje.
  test(
    'Prompt caching: druga tura tym samym promptem czyta cache',
    () async {
      final api = AnthropicStreamApi.withKey(anthropicApiKey);
      final agent = ClaudeAdvisorAgent(api: api);
      final cubit = CarAdvisorCubit(agent, advisorCatalog(withUsageRule: true))
        ..setBudget(60000)
        ..setBody(CarBody.wagon);

      Future<CarAdvisorState> turn() {
        final done = cubit.stream
            .firstWhere((s) => !s.isWaiting && (s.hasResult || s.error != null))
            .timeout(const Duration(seconds: 90));
        cubit.requestAdvice();
        return done;
      }

      await turn();
      // Druga tura zmienia kryteria, żeby wiadomość usera była inna —
      // cache dotyczy system promptu, nie treści rozmowy.
      cubit.setMaxMileage(120000);
      final second = await turn();

      await cubit.close();
      api.close();

      expect(second.error, isNull);
      // Liczby są w logu `GenUiWire` powyżej — wiersz „tokeny" drugiej tury
      // ma pokazać `cache odczyt > 0`.
    },
    timeout: const Timeout(Duration(minutes: 4)),
    skip: anthropicApiKey.isEmpty
        ? 'Brak ANTHROPIC_API_KEY — pomijam eksperyment na żywym API'
        : false,
  );
}
