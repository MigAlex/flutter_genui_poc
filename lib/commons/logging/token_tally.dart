import 'genui_wire_log.dart';

/// Bilans tokenów **narastająco przez całą sesję** — w odróżnieniu od
/// [TokenUsage], które opisuje jedną turę i ginie razem z nią w logu.
///
/// Po co osobna klasa: pytanie „ile to kosztuje" nie ma odpowiedzi w jednej
/// turze. System prompt genui z pełnym katalogiem waży dziesiątki tysięcy
/// znaków i leci w **każdym** requeście, a każde kliknięcie w wygenerowanym UI
/// to potencjalnie nowy request. Dopiero suma po kilku turach pokazuje, czy
/// prompt caching realnie ratuje rachunek, czy tylko nie protestuje.
///
/// Niemutowalny, bo ląduje w `@freezed` stanie — mutowalny akumulator w stanie
/// łamałby porównanie i `emit` przestawałby cokolwiek zmieniać.
class TokenTally {
  const TokenTally({
    this.turns = 0,
    this.input = 0,
    this.output = 0,
    this.cacheCreation = 0,
    this.cacheRead = 0,
  });

  /// Ile tur modelu złożyło się na ten bilans.
  final int turns;

  /// Wejście **poza** cache'em — to jest ta część, za którą płacisz pełną stawkę.
  final int input;
  final int output;

  /// Zapis cache'u: droższy od zwykłego wejścia, ale jednorazowy.
  final int cacheCreation;

  /// Odczyt cache'u: ułamek stawki wejściowej. To jest cała oszczędność.
  final int cacheRead;

  TokenTally add(TokenUsage usage) => TokenTally(
    turns: turns + 1,
    input: input + usage.input,
    output: output + usage.output,
    cacheCreation: cacheCreation + usage.cacheCreation,
    cacheRead: cacheRead + usage.cacheRead,
  );

  /// Wszystko, co poszło na wejściu — łącznie z tym, co obsłużył cache.
  int get inputTotal => input + cacheCreation + cacheRead;

  int get total => inputTotal + output;

  /// Ile wejścia obsłużył cache (0..1). `null`, gdy nie było jeszcze tury —
  /// zero i „brak danych" to na tym pasku dwie różne informacje.
  double? get cacheShare =>
      inputTotal == 0 ? null : cacheRead / inputTotal;

  /// Średnie wejście na turę — liczba, po której widać, że prompt leci w całości
  /// za każdym razem.
  int get inputPerTurn => turns == 0 ? 0 : inputTotal ~/ turns;

  String describe() {
    if (turns == 0) return 'tokeny: brak tury modelu';
    final share = cacheShare;
    final cache = share == null
        ? 'cache n/d'
        : 'cache ${(share * 100).round()}%';
    return 'tokeny: ${_n(inputTotal)} in / ${_n(output)} out · '
        '$cache · ${_n(inputPerTurn)} in/turę';
  }

  static String _n(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is TokenTally &&
      other.turns == turns &&
      other.input == input &&
      other.output == output &&
      other.cacheCreation == cacheCreation &&
      other.cacheRead == cacheRead;

  @override
  int get hashCode => Object.hash(turns, input, output, cacheCreation, cacheRead);

  @override
  String toString() => describe();
}
