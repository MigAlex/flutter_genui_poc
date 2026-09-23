import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Podgląd „drutu" między apką a modelem — request i response w debug console.
///
/// Powód istnienia: przy GenUI **nie widać, co się dzieje**. Prompt generuje
/// `PromptBuilder`, odpowiedź jest strumieniem strzępów JSON-a, a jedyne, co
/// widzisz gołym okiem, to gotowe widgety albo pusty ekran. Ten log pokazuje
/// trzy rzeczy, których inaczej nie da się sprawdzić bez proxy:
///
/// 1. **co dokładnie poszło** (rozmiar promptu, wariant A/B, treść wiadomości),
/// 2. **ile to kosztowało** (`cache_read` vs `cache_creation` — czy caching
///    realnie trafia, czy tylko API przyjmuje jego formę),
/// 3. **czego model użył** (nazwy komponentów) — czyli wynik eksperymentu.
///
/// Cały moduł jest **debug-only**: w release `kDebugMode` jest `false` i żadna
/// z metod nic nie robi (ani formatowania, ani alokacji stringów).
///
/// ⚠️ Nigdy nie loguje klucza API ani nagłówków — tylko ciało requestu.
abstract final class GenUiWire {
  static const _width = 74;

  /// Gdy `true`, [response] dokłada pełny surowy A2UI od modelu, a [request]
  /// przestaje ucinać treść wychodzącej wiadomości.
  ///
  /// **Domyślnie włączone w debugu** — „chcę widzieć, co poszło i co wróciło"
  /// to najczęstszy powód, dla którego się w ogóle tu zagląda, a podsumowanie
  /// bez ciała nie odpowiada na pytanie „czemu model nie zna moich danych".
  /// Wyciszasz, gdy log zaczyna przeszkadzać (jedna odpowiedź to kilka
  /// kilobajtów) — np. przed demem:
  ///
  /// ```bash
  /// flutter run --dart-define=GENUI_WIRE_RAW=false
  /// ```
  static bool dumpRawBody = const bool.fromEnvironment(
    'GENUI_WIRE_RAW',
    defaultValue: true,
  );

  /// Kanał = ekran. Pojawia się w każdej linii, bo przy trzech torach naraz
  /// (czat / panel / triage) log bez tego jest nie do rozplątania.
  static void request({
    required String channel,
    required String model,
    required String systemPrompt,
    required List<Map<String, Object?>> history,
    String? variant,
  }) {
    if (!kDebugMode) return;

    final userContent = history.isEmpty
        ? ''
        : (history.last['content'] as String? ?? '');
    final roles = <String, int>{};
    for (final m in history) {
      final role = m['role'] as String? ?? '?';
      roles[role] = (roles[role] ?? 0) + 1;
    }

    _open('$channel ▸ REQUEST', color: _cyan);
    _row('model', '$model${variant == null ? '' : '   wariant: $variant'}');
    _row(
      'system',
      '${_num(systemPrompt.length)} zn. · cache: ephemeral · '
          'zawiera "CarCard": ${systemPrompt.contains('CarCard') ? 'TAK' : 'NIE'}',
    );
    _row(
      'historia',
      '${history.length} wiad. '
          '(${roles.entries.map((e) => '${e.value}×${e.key}').join(', ')}) '
          '≈ ${_kb(jsonEncode(history).length)}',
    );
    // Przy `dumpRawBody` pokazujemy CAŁĄ treść wychodzącą: to w niej siedzi
    // payload interakcji razem z doklejonym DataModelem, więc ucięcie akurat
    // tutaj kasowałoby odpowiedź na pytanie „czy model dostał moje pola".
    _block('treść', userContent, maxLines: dumpRawBody ? 200 : 8);
    _close();
  }

  /// [componentNames] zostaje puste, gdy model odpowiedział prozą — wtedy
  /// werdykt mówi to wprost, zamiast pokazywać pusty zbiór bez komentarza.
  static void response({
    required String channel,
    required Duration elapsed,
    required Duration? firstChunkAfter,
    required int chunks,
    required String raw,
    required Set<String> componentNames,
    TokenUsage? usage,
    String? verdict,
  }) {
    if (!kDebugMode) return;

    // Proza zamiast A2UI to najczęstsza przyczyna pustego ekranu — ten jeden
    // przypadek ma się różnić kolorem ramki, żeby dało się go złapać wzrokiem
    // bez czytania treści.
    final saidNothing = componentNames.isEmpty;

    _open('$channel ▸ RESPONSE', color: saidNothing ? _yellow : _green);
    _row(
      'czas',
      '${_num(elapsed.inMilliseconds)} ms'
          '${firstChunkAfter == null ? '' : _c(' (pierwszy chunk po ${_num(firstChunkAfter.inMilliseconds)} ms)', _dim)}',
    );
    _row('stream', '$chunks delt · ${_num(raw.length)} zn.');
    if (usage != null) {
      _row('tokeny', _c(usage.describe(), usage.cacheHit ? _green : _dim));
    }
    _row(
      'komponenty',
      saidNothing
          ? _c('— (model odpowiedział prozą, nie A2UI)', _yellow)
          : '{${(componentNames.toList()..sort()).join(', ')}}',
    );
    if (verdict != null) _row('werdykt', verdict);
    _close();

    if (dumpRawBody) rawBody(channel: channel, raw: raw);
  }

  static void failure({
    required String channel,
    required Object error,
    required Duration elapsed,
  }) {
    if (!kDebugMode) return;

    _open('$channel ▸ BŁĄD', color: _red);
    _row('czas', '${_num(elapsed.inMilliseconds)} ms');
    _block('powód', error.toString(), maxLines: 6, bodyColor: _red);
    _close();
  }

  /// Pełna odpowiedź modelu, gdy chcesz zobaczyć surowy A2UI zamiast podsumowania.
  /// Osobno, bo to potrafi być kilka kilobajtów — wołaj świadomie.
  static void rawBody({required String channel, required String raw}) {
    if (!kDebugMode) return;

    _open('$channel ▸ SUROWA ODPOWIEDŹ', color: _grey);
    _block('', raw, maxLines: 200, bodyColor: _grey);
    _close();
  }

  // --- kolory ---------------------------------------------------------------

  /// Kolorowanie ANSI — bez niego trzy tory zlewają się w jedną ścianę.
  /// Gołe `ESC[36m` zamiast kolorów? `--dart-define=GENUI_WIRE_COLOR=false`.
  static bool useColors = const bool.fromEnvironment(
    'GENUI_WIRE_COLOR',
    defaultValue: true,
  );

  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[2m';
  static const _cyan = '\x1B[36m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _grey = '\x1B[90m';

  static String _c(String text, String color) =>
      useColors ? '$color$text$_reset' : text;

  static String _frame = _cyan;

  // --- formatowanie ---------------------------------------------------------

  static void _open(String title, {String color = _cyan}) {
    _frame = color;
    debugPrint(
      _c('┌─ GENUI ▸ $title ${'─' * _dashes(title)}', color),
    );
  }

  static int _dashes(String title) {
    final used = 'GENUI ▸ $title '.length + 3;
    return used >= _width ? 1 : _width - used;
  }

  static void _close() => debugPrint(_c('└${'─' * (_width - 1)}', _frame));

  static void _row(String label, String value) => debugPrint(
    '${_c('│', _frame)} ${_c(label.padRight(11), _dim)}$value',
  );

  /// Treść wielolinijkowa z wcięciem pod etykietę. Ucinamy po [maxLines],
  /// bo prompt panelu potrafi mieć kilkadziesiąt linii i zalałby konsolę.
  static void _block(
    String label,
    String text, {
    required int maxLines,
    String? bodyColor,
  }) {
    final lines = text.trim().split('\n');
    final shown = lines.take(maxLines).toList();

    for (var i = 0; i < shown.length; i++) {
      final prefix = _c((i == 0 ? label : '').padRight(11), _dim);
      final body = bodyColor == null ? shown[i] : _c(shown[i], bodyColor);
      debugPrint('${_c('│', _frame)} $prefix$body');
    }
    if (lines.length > maxLines) {
      debugPrint(
        '${_c('│', _frame)} ${' ' * 11}'
        '${_c('… (+${lines.length - maxLines} linii)', _dim)}',
      );
    }
  }

  static String _num(int v) {
    final s = v.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  static String _kb(int bytes) => bytes < 1024
      ? '$bytes B'
      : '${(bytes / 1024).toStringAsFixed(1)} kB';
}

/// Zużycie tokenów z jednej tury — sedno pytania „czy prompt caching realnie
/// trafia". Anthropic wysyła to w dwóch miejscach: wejście i zapis/odczyt
/// cache'u w `message_start`, wyjście dopiero w `message_delta`.
class TokenUsage {
  TokenUsage({
    this.input = 0,
    this.output = 0,
    this.cacheCreation = 0,
    this.cacheRead = 0,
  });

  int input;
  int output;
  int cacheCreation;
  int cacheRead;

  /// Wyławia liczniki z eventu SSE. Zwraca `true`, gdy cokolwiek zaktualizował.
  bool absorb(Map<String, Object?> event) {
    final type = event['type'];
    final Map<String, Object?>? usage = switch (type) {
      'message_start' =>
        (event['message'] as Map<String, Object?>?)?['usage']
            as Map<String, Object?>?,
      'message_delta' => event['usage'] as Map<String, Object?>?,
      _ => null,
    };
    if (usage == null) return false;

    input = (usage['input_tokens'] as int?) ?? input;
    output = (usage['output_tokens'] as int?) ?? output;
    cacheCreation =
        (usage['cache_creation_input_tokens'] as int?) ?? cacheCreation;
    cacheRead = (usage['cache_read_input_tokens'] as int?) ?? cacheRead;
    return true;
  }

  /// Czy caching realnie trafił w tej turze (a nie tylko został przyjęty).
  bool get cacheHit => cacheRead > 0;

  /// Werdykt jest ważniejszy od samych liczb: pierwsza tura ma zapisać cache,
  /// każda następna z tym samym system promptem — odczytać. Odczyt równy zero
  /// przy drugiej turze oznacza, że caching NIE działa, choć API nie protestuje.
  String describe() {
    final verdict = switch ((cacheCreation, cacheRead)) {
      (0, 0) => 'cache nietknięty',
      (> 0, 0) => 'cache ZAPISANY',
      (0, > 0) => 'cache ODCZYTANY',
      _ => 'cache zapis+odczyt',
    };
    return 'in $input · out $output · '
        'cache zapis $cacheCreation / odczyt $cacheRead → $verdict';
  }

  Map<String, int> toJson() => {
    'input': input,
    'output': output,
    'cacheCreation': cacheCreation,
    'cacheRead': cacheRead,
  };
}
