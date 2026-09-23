import 'dart:convert';

/// Co host **realnie zobaczył** na drucie po jednej turze modelu.
///
/// To jest wejście do walidacji ([SurfaceContract]), więc świadomie opisuje
/// obserwację, a nie intencję: `isA2ui: false` znaczy „przyszła proza", a nie
/// „model się pomylił".
typedef SurfaceSnapshot = ({
  /// Czy w strumieniu była chociaż jedna wiadomość A2UI. `false` = proza.
  bool isA2ui,

  /// Powierzchnia, do której model adresował `updateComponents`.
  String? surfaceId,

  /// Nazwy komponentów (`"component": "X"`), nie ich id.
  Set<String> componentNames,

  /// Czy w drzewie jest komponent o `id: "root"` — punkt wejścia renderera.
  bool hasRoot,
});

/// Czytanie surowej odpowiedzi modelu **po fakcie**, do diagnostyki i walidacji.
///
/// ⚠️ To NIE jest parser produkcyjny i nie wolno go wołać w `onSend`: model
/// owija odpowiedź w ` ```json `, tnie chunki w środku identyfikatorów i potrafi
/// wysłać dwie wiadomości A2UI w jednym strumieniu. Buforowanie i sklejanie
/// należy do `A2uiTransportAdapter` — tutaj patrzymy na **całość**, która już
/// poszła na drut, żeby powiedzieć, co w niej było.
///
/// Stąd skanowanie po klamrach zamiast `jsonDecode` całości: w jednym stringu
/// siedzi kilka niezależnych obiektów JSON, przeplecionych ogrodzeniami
/// markdownu i czasem prozą.
abstract final class A2uiMessages {
  /// Wyławia wszystkie samodzielne obiekty JSON z surowego tekstu.
  ///
  /// Obiekty niedekodowalne są **pomijane po cichu** — celowo: fragment,
  /// którego nie da się zdekodować, to dla hosta to samo co jego brak,
  /// a wyjątek w diagnostyce zabiłby ekran zamiast go opisać.
  static List<Map<String, Object?>> decode(String raw) {
    final messages = <Map<String, Object?>>[];

    var depth = 0;
    var start = -1;
    var inString = false;
    var escaped = false;

    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch == r'\') {
          escaped = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }

      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (ch == '}' && depth > 0) {
        depth--;
        if (depth == 0 && start >= 0) {
          final candidate = raw.substring(start, i + 1);
          final decoded = _tryDecode(candidate);
          if (decoded != null) messages.add(decoded);
          start = -1;
        }
      }
    }

    return messages;
  }

  static Map<String, Object?>? _tryDecode(String candidate) {
    try {
      final value = jsonDecode(candidate);
      return value is Map<String, Object?> ? value : null;
    } on FormatException {
      return null;
    }
  }

  /// Sprowadza całą turę do czterech faktów, na których da się orzekać.
  static SurfaceSnapshot snapshot(String raw) {
    final messages = decode(raw);
    final names = <String>{};
    final ids = <String>{};
    String? surfaceId;
    var isA2ui = false;

    for (final message in messages) {
      final update = message['updateComponents'] as Map<String, Object?>?;
      final create = message['createSurface'] as Map<String, Object?>?;

      if (create != null) {
        isA2ui = true;
        surfaceId ??= create['surfaceId'] as String?;
      }
      if (update == null) continue;

      isA2ui = true;
      // `updateComponents` wygrywa z `createSurface`: to ono niesie drzewo,
      // więc to jego powierzchnia jest tą, o którą pytamy.
      surfaceId = update['surfaceId'] as String? ?? surfaceId;

      final components = update['components'];
      if (components is! List) continue;

      for (final component in components) {
        if (component is! Map<String, Object?>) continue;
        final name = component['component'];
        final id = component['id'];
        if (name is String) names.add(name);
        if (id is String) ids.add(id);
      }
    }

    return (
      isA2ui: isA2ui,
      surfaceId: surfaceId,
      componentNames: names,
      hasRoot: ids.contains('root'),
    );
  }
}
