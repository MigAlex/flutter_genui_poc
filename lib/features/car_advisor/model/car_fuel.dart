/// Rodzaj paliwa. `wireName` to wartość, którą widzi **model** (enum w schemacie
/// `CarCard`), `label` to napis dla człowieka. Rozdzielone świadomie: prompt
/// zostaje po angielsku (tak wygląda cały protokół A2UI), UI po polsku.
enum CarFuel {
  petrol('petrol', 'benzyna'),
  diesel('diesel', 'diesel'),
  hybrid('hybrid', 'hybryda'),
  electric('electric', 'elektryk');

  const CarFuel(this.wireName, this.label);

  final String wireName;
  final String label;

  /// Zwraca `null` dla nieznanej wartości — model potrafi wymyślić własną,
  /// a wtedy wolimy pokazać surowy string niż podmienić go na cudzy sens.
  static CarFuel? fromWire(String? name) {
    for (final fuel in values) {
      if (fuel.wireName == name) return fuel;
    }
    return null;
  }
}

/// Typ nadwozia — wyłącznie kryterium wejściowe panelu (model nie dostaje go
/// jako enum w schemacie, tylko w opisie stanu).
enum CarBody {
  wagon('wagon', 'kombi'),
  suv('SUV', 'SUV'),
  hatchback('hatchback', 'hatchback'),
  sedan('sedan', 'sedan');

  const CarBody(this.wireName, this.label);

  final String wireName;
  final String label;
}
