// TYMCZASOWY przebieg kontrolny na ŻYWYM Haiku — cztery scenariusze demo.
// Odpowiada na pytanie z karty zadania: czy pasek składa się poprawnie,
// w jakiej latencji i czy model trzyma się reguły „max 3 komponenty".
//
//   flutter test test/triage_live_check_test.dart --dart-define-from-file=secrets.json
//
// Świeży agent i świeży cubit na scenariusz — historia NIE przechodzi między
// przypadkami (pomyłka z modułu doradcy).
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/data/anthropic/anthropic_stream_api.dart';
import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/commons/a2ui/surface_contract.dart';
import 'package:flutter_genui_poc/features/triage_panel/cubit/triage_panel_cubit.dart';
import 'package:flutter_genui_poc/features/triage_panel/failure/failure_injector.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/support_case.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/triage_action.dart';
import 'package:flutter_genui_poc/genui_agent/claude_triage_agent.dart';
import 'package:flutter_genui_poc/genui_catalog/triage_catalog.dart';

void main() {
  final wyniki = <String>[];

  tearDownAll(() {
    // ignore: avoid_print
    print('\n=== PRZEBIEG NA ŻYWYM HAIKU ===\n${wyniki.join('\n')}\n');
  });

  for (final order in SupportCases.all) {
    test(
      'ŻYWY Haiku: ${order.id}',
      () async {
        final bus = TriageActionBus();
        final catalog = triageCatalog(bus);
        final agent = ClaudeTriageAgent(
          api: AnthropicStreamApi.withKey(anthropicApiKey),
          catalog: catalog,
        );
        final cubit = TriagePanelCubit(agent, catalog, bus);
        addTearDown(() async {
          await cubit.close();
          bus.dispose();
        });

        // `hasStripContent` leci z eventu genui **w trakcie** strumienia,
        // a werdykt dopiero po `injector.finish()` — to dwie różne chwile
        // i obie są ciekawe: pierwsza to co widzi konsultant, druga to co
        // orzekł host.
        final zegar = Stopwatch()..start();
        int? doPaska;
        final sub = cubit.stream.listen((s) {
          if (s.hasStripContent && doPaska == null) {
            doPaska = zegar.elapsedMilliseconds;
          }
        });
        addTearDown(sub.cancel);

        cubit.answerCall(order);

        final state = await cubit.stream
            .firstWhere((s) => s.verdict != null || s.error != null)
            .timeout(const Duration(seconds: 90));
        zegar.stop();

        final komponenty = state.lastComponents.toList()..sort();
        final domenowe = state.lastComponents
            .where((c) => c != 'Column' && c != 'Text')
            .toList();
        final werdykt = switch (state.verdict) {
          SurfaceAccepted() => 'PRZYJĘTA',
          final SurfaceRejected r => 'ODRZUCONA (${r.runtimeType})',
          null => 'brak werdyktu',
        };

        wyniki.add(
          '${order.id.padRight(16)} '
          'pasek ${(doPaska ?? -1).toString().padLeft(5)} ms · '
          'werdykt ${zegar.elapsedMilliseconds.toString().padLeft(5)} ms · '
          '${werdykt.padRight(14)} · '
          'domenowych ${domenowe.length} · '
          '${komponenty.join(', ')}'
          '${state.error != null ? ' · BŁĄD: ${state.error}' : ''}',
        );

        expect(state.error, isNull, reason: 'agent zwrócił błąd');
        expect(state.verdict, isA<SurfaceAccepted>(),
            reason: 'kontrakt odrzucił powierzchnię: $werdykt');
        expect(domenowe.length, lessThanOrEqualTo(3),
            reason: 'model złamał regułę „max 3 komponenty": $domenowe');
        expect(domenowe, contains('ActionRow'),
            reason: 'brak ActionRow — jedynego obowiązkowego komponentu');
        if (order.overCreditLimit) {
          expect(domenowe, contains('CreditLimitBanner'),
              reason: 'przekroczony limit bez CreditLimitBanner');
        }
      },
      timeout: const Timeout(Duration(seconds: 120)),
      skip: anthropicApiKey.isEmpty ? 'Brak ANTHROPIC_API_KEY' : null,
    );
  }

  // Cztery wymuszone awarie — na ŻYWYM modelu, nie na atrapie. To jest ten
  // moment demo, w którym pasek znika, a karta zostaje.
  for (final tryb in [
    TriageFailure.prose,
    TriageFailure.wrongCatalog,
    TriageFailure.missingRequired,
    TriageFailure.network,
  ]) {
    test(
      'ŻYWY Haiku: awaria „${tryb.label}"',
      () async {
        final bus = TriageActionBus();
        final catalog = triageCatalog(bus);
        final agent = ClaudeTriageAgent(
          api: AnthropicStreamApi.withKey(anthropicApiKey),
          catalog: catalog,
        );
        final cubit = TriagePanelCubit(agent, catalog, bus);
        addTearDown(() async {
          await cubit.close();
          bus.dispose();
        });

        // `missingRequired` wycina `CreditLimitBanner`, więc ma sens wyłącznie
        // na scenariuszu z przekroczonym limitem.
        final order = tryb == TriageFailure.missingRequired
            ? SupportCases.b2bOverLimit
            : SupportCases.stuckShipment;

        cubit.setFailure(tryb);
        cubit.answerCall(order);

        final state = await cubit.stream
            .firstWhere((s) => !s.isWaiting && s.activeCase != null)
            .timeout(const Duration(seconds: 90));

        final werdykt = switch (state.verdict) {
          SurfaceAccepted() => 'PRZYJĘTA',
          final SurfaceRejected r => r.runtimeType.toString(),
          null => 'brak',
        };
        wyniki.add(
          'awaria ${tryb.name.padRight(16)} '
          'werdykt ${werdykt.padRight(18)} · '
          'błąd: ${state.error != null ? 'TAK' : 'nie'} · '
          'proza: ${state.latestText != null ? 'TAK' : 'nie'} · '
          'komponentów ${state.lastComponents.length}',
        );

        // Wspólne kryterium wszystkich czterech: użytkownik NIE dostaje
        // wygenerowanego paska bez ostrzeżenia. Albo jawny błąd, albo
        // odrzucona powierzchnia, albo proza pokazana jako proza.
        final cichaWpadka = state.error == null &&
            state.latestText == null &&
            state.verdict is! SurfaceRejected;
        expect(
          cichaWpadka,
          isFalse,
          reason: 'awaria „${tryb.name}" przeszła po cichu — '
              'werdykt: $werdykt, komponenty: ${state.lastComponents}',
        );
      },
      timeout: const Timeout(Duration(seconds: 120)),
      skip: anthropicApiKey.isEmpty ? 'Brak ANTHROPIC_API_KEY' : null,
    );
  }

  test('waga promptu tego katalogu', () {
    final bus = TriageActionBus();
    addTearDown(bus.dispose);
    final agent = ClaudeTriageAgent(
      api: AnthropicStreamApi.withKey('x'),
      catalog: triageCatalog(bus),
    );
    // ignore: avoid_print
    print('PROMPT TRIAGE: ${agent.promptLength} znaków');
    expect(agent.promptLength, greaterThan(0));
  });
}
