import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../features/car_advisor/model/car_fuel.dart';
import '../features/car_advisor/widget/car_card.dart';

/// Most między widgetem [CarCard] a genui: **nazwa + schemat + builder**.
///
/// Nie ma żadnego rejestru typów ani mapowania po stronie paczki — `CatalogItem`
/// JEST tym mapowaniem. `BasicCatalogItems` to dokładnie takie same obiekty,
/// bez uprzywilejowanego statusu.
///
/// Uwaga na podział ról (L2 §4.2): **`dataSchema` mówi CO widget przyjmuje,
/// a nie KIEDY go użyć.** Reguła użycia mieszka w `systemPromptFragments`
/// katalogu (`advisor_catalog.dart`) i to ona realnie przełącza zachowanie
/// modelu — sam schemat daje widget, którego model nie tknie.
final _schema = S.object(
  description:
      'A rich card presenting ONE concrete used-car offer: price, production '
      'year, mileage and fuel type, plus a short reason why it fits. Renders '
      'as a native Material card in the host app.',
  properties: {
    'title': S.string(
      description:
          'Make, model and trim, e.g. "Skoda Octavia III 1.5 TSI Style".',
    ),
    'pricePln': S.integer(
      description: 'Price in PLN as a plain integer, no spaces or currency.',
    ),
    'year': S.integer(description: 'Production year, e.g. 2019.'),
    'mileageKm': S.integer(description: 'Mileage in kilometers.'),
    'fuel': S.string(
      description: 'Fuel type of the car.',
      enumValues: ['petrol', 'diesel', 'hybrid', 'electric'],
    ),
    'highlight': S.string(
      description:
          'ONE short sentence in Polish explaining why this car matches the '
          'user criteria. Keep it under 140 characters.',
    ),
    'actionLabel': S.string(
      description: 'Label of the optional button, e.g. "Pokaż podobne".',
    ),
    'action': A2uiSchemas.action(
      description:
          'Optional action dispatched when the user taps the card button.',
    ),
  },
  required: ['title', 'pricePln', 'year', 'mileageKm', 'fuel'],
);

/// Odczyt surowej mapy od modelu. Kształt jak w `BasicCatalogItems` —
/// extension type zamiast klasy, żeby nie kopiować danych.
extension type _CarCardData.fromMap(JsonMap _json) {
  String get title => _json['title'] as String? ?? '';
  int get pricePln => _asInt(_json['pricePln']);
  int get year => _asInt(_json['year']);
  int get mileageKm => _asInt(_json['mileageKm']);
  String? get fuel => _json['fuel'] as String?;
  String? get highlight => _json['highlight'] as String?;
  String? get actionLabel => _json['actionLabel'] as String?;
  JsonMap? get action => _json['action'] as JsonMap?;
}

/// Model bywa niekonsekwentny w typach liczbowych (`59900` vs `59900.0`
/// vs `"59900"`), a wywalenie się rendera na tym byłoby najgłupszą możliwą
/// przyczyną pustego panelu.
int _asInt(Object? value) => switch (value) {
  final int v => v,
  final double v => v.round(),
  final String v => int.tryParse(v) ?? 0,
  _ => 0,
};

/// [withExample] steruje **warstwą 3** wpływu na model (`exampleData`).
///
/// Istnieje wyłącznie po to, żeby dało się ją odciąć w eksperymencie: dopóki
/// przykład jest włączony, nie sposób stwierdzić, czy zachowanie modelu bierze
/// się z niego, czy z reguły użycia w `systemPromptFragments` (warstwa 4).
/// Produkcyjnie zawsze `true` — DI i renderer nie podają tego argumentu.
CatalogItem carCardItem({bool withExample = true}) => CatalogItem(
  name: 'CarCard',
  dataSchema: _schema,
  widgetBuilder: (itemContext) {
    final data = _CarCardData.fromMap(itemContext.data as JsonMap);
    final eventName = (data.action?['event'] as JsonMap?)?['name'] as String?;

    return CarCard(
      title: data.title,
      pricePln: data.pricePln,
      year: data.year,
      mileageKm: data.mileageKm,
      // Nieznaną wartość pokazujemy surową zamiast podmieniać na domyślną —
      // gdy model wymyśli 'lpg', chcemy to zobaczyć, a nie zobaczyć „benzyna".
      fuelLabel: CarFuel.fromWire(data.fuel)?.label ?? (data.fuel ?? '—'),
      highlight: data.highlight,
      actionLabel: data.actionLabel,
      onPressed: eventName == null
          ? null
          : () => itemContext.dispatchEvent(
              UserActionEvent(
                name: eventName,
                sourceComponentId: itemContext.id,
                surfaceId: itemContext.surfaceId,
              ),
            ),
    );
  },
  // ⚠️ NIE jest to „warstwa wpływu na model", wbrew temu, co zakładał kurs.
  // Zmierzone 2026-08-11 na genui 0.10.1: `exampleData` **nie trafia do system
  // promptu** — ani przez `PromptBuilder.chat`, ani `custom`. Prompt z nim
  // i bez niego jest identyczny co do bajtu. W całej paczce czyta to wyłącznie
  // `lib/test/validation.dart`, czyli helper renderujący przykłady w testach.
  //
  // Zostaje, bo w tej roli jest przydatne (darmowy smoke-test buildera), ale
  // nie licz na to, że skłoni model do użycia widgetu. Od tego jest
  // `systemPromptFragments` katalogu i `description` w schemacie.
  exampleData: [
    if (withExample)
      () => '''
      [
        {
          "id": "root",
          "component": "CarCard",
          "title": "Skoda Octavia III 1.5 TSI Style",
          "pricePln": 59900,
          "year": 2019,
          "mileageKm": 128000,
          "fuel": "petrol",
          "highlight": "Duży bagażnik i tani serwis — mieści się w budżecie z zapasem.",
          "actionLabel": "Pokaż podobne",
          "action": { "event": { "name": "show_similar" } }
        }
      ]
    ''',
  ],
);
