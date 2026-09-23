import 'dart:convert';

import '../../../commons/a2ui/a2ui_messages.dart';
import '../../../commons/a2ui/a2ui_sink.dart';
import '../../../genui_catalog/triage_catalog.dart';

/// Cztery sposoby, na jakie generatywny pasek psuje się w realu.
///
/// Osobna oś niż przypadki: przełącznik działa na **każdym** scenariuszu
/// i — co ważniejsze — identycznie na atrapie i na żywym Haiku, bo psuje
/// odpowiedź **po** stronie hosta. Na scenie to mocniejsze zdanie niż mock:
/// *„to jest prawdziwy model, a ja psuję mu odpowiedź w locie".*
enum TriageFailure {
  none('bez awarii'),

  /// Najczęstsza przyczyna pustego ekranu: model gada zamiast rysować.
  prose('proza zamiast A2UI'),

  /// Najcichsza: powierzchnia jest, komponenty przyszły, renderer nie zna
  /// katalogu → zero komunikatu i pusty pasek.
  wrongCatalog('zły catalogId'),

  /// Najgroźniejsza, bo **wygląda poprawnie**: model przemilcza sygnał,
  /// którego nie wolno przemilczeć.
  missingRequired('brak wymaganego komponentu'),

  network('błąd sieci');

  const TriageFailure(this.label);

  final String label;

  /// Czy chunki mogą lecieć na żywo. Tryby mutujące potrzebują **całej**
  /// odpowiedzi, żeby ją przepisać — więc w nich świadomie tracimy streaming.
  /// To jedyna rzecz, którą przechwytywacz zmienia poza samą awarią.
  bool get forwardsLive => this == none;

  bool get failsBeforeRequest => this == network;
}

/// Przechwytywacz między agentem a `SurfaceController`.
///
/// Siedzi na [A2uiSink], więc nie wie, czy odpowiedź pochodzi z atrapy, czy
/// z modelu — i o to chodzi: cztery awarie mają być tą samą demonstracją
/// w obu trybach.
class FailureInjector implements A2uiSink {
  FailureInjector({
    required this._target,
    required this.mode,
    this.brokenSurfaceNeeded = true,
  });

  final A2uiSink _target;
  final TriageFailure mode;

  /// Czy powierzchnia z zepsutym katalogiem dopiero ma powstać. Drugie
  /// `createSurface` z tym samym id byłoby błędem protokołu, a nie awarią,
  /// którą demonstrujemy.
  final bool brokenSurfaceNeeded;

  final _raw = StringBuffer();

  @override
  void addChunk(String chunk) {
    _raw.write(chunk);
    if (mode.forwardsLive) _target.addChunk(chunk);
  }

  /// Domyka turę i zwraca **to, co realnie poszło na drut** — na tym, a nie na
  /// intencji modelu, liczy się werdykt kontraktu.
  String finish() {
    final raw = _raw.toString();

    return switch (mode) {
      TriageFailure.none || TriageFailure.network => raw,
      TriageFailure.prose => _emit(_proseAnswer),
      TriageFailure.wrongCatalog => _emitOnBrokenSurface(raw),
      TriageFailure.missingRequired => _emit(
        _withoutComponent(raw, TriageComponents.creditLimitBanner),
      ),
    };
  }

  String _emit(String payload) {
    _target.addChunk(payload);
    return payload;
  }

  /// Podmienia adres powierzchni na taką, którą host założył z **nieznanym
  /// katalogiem**. Komponenty dojdą, renderer podstawi pusty stub i na ekranie
  /// będzie cisza — dokładnie tak, jak przy literówce w `catalogId`.
  String _emitOnBrokenSurface(String raw) {
    if (brokenSurfaceNeeded) {
      _target.addChunk(
        jsonEncode({
          'version': 'v0.9',
          'createSurface': {
            'surfaceId': triageBrokenSurfaceId,
            'catalogId': triageBrokenCatalogId,
          },
        }),
      );
    }
    return _emit(
      raw.replaceAll('"$triageStripSurfaceId"', '"$triageBrokenSurfaceId"'),
    );
  }

  static const _proseAnswer =
      'Klient prawdopodobnie dzwoni w sprawie tego zamówienia. Proponuję '
      'sprawdzić status przesyłki i w razie potrzeby złożyć reklamację '
      'u przewoźnika.';

  /// Wycina komponent z odpowiedzi **razem z referencją w `children`** —
  /// wisząca referencja dawałaby pusty pasek z innego powodu niż badany,
  /// a wtedy demonstracja pokazywałaby co innego, niż mówi jej etykieta.
  static String _withoutComponent(String raw, String component) {
    final messages = A2uiMessages.decode(raw);
    final rewritten = <String>[];

    for (final message in messages) {
      final update = message['updateComponents'] as Map<String, Object?>?;
      final components = update?['components'];
      if (update == null || components is! List) {
        rewritten.add(jsonEncode(message));
        continue;
      }

      final removedIds = <String>{};
      final kept = <Object?>[];

      for (final entry in components) {
        if (entry is Map<String, Object?> && entry['component'] == component) {
          if (entry['id'] case final String id) removedIds.add(id);
          continue;
        }
        kept.add(entry);
      }

      rewritten.add(
        jsonEncode({
          ...message,
          'updateComponents': {
            ...update,
            'components': [
              for (final entry in kept) _withoutChildren(entry, removedIds),
            ],
          },
        }),
      );
    }

    return rewritten.join('\n');
  }

  static Object? _withoutChildren(Object? entry, Set<String> removedIds) {
    if (entry is! Map<String, Object?>) return entry;
    final children = entry['children'];
    if (children is! List) return entry;

    return {
      ...entry,
      'children': [
        for (final child in children)
          if (!removedIds.contains(child)) child,
      ],
    };
  }
}
