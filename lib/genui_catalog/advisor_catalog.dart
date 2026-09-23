import 'package:genui/genui.dart';

import 'car_card_item.dart';

/// **Własny `catalogId`** — i to jest mina, nie formalność.
///
/// Mock czatu (`MockGenUiAgent`) ma zaszyty basicowy id `a2ui.org/.../basic_catalog`.
/// Gdyby ten ekran poszedł na jego mocku, `SurfaceController` zarejestrowałby
/// **pusty stub** dla nieznanego id i dostalibyśmy powierzchnię bez komponentów
/// **bez jednego słowa w logu** — najcichszą z trzech przyczyn pustego ekranu.
/// Dlatego advisor ma własnego mocka, który zna ten id.
const advisorCatalogId = 'com.poc.car_advisor';

/// Powierzchnia panelu jest **jedna i stała**. Zakłada ją host (patrz
/// `AdvisorAgent.bootstrapPanel`), bo przy `SurfaceOperations.updateOnly`
/// model nie ma prawa jej stworzyć.
const advisorPanelSurfaceId = 'advisor_panel';

/// Reguła KIEDY użyć `CarCard` — jedyna różnica między wariantami A/B.
///
/// Bez niej model **widzi** `CarCard` w prompcie i mimo to składa ofertę
/// z `Card` + `Text` (zweryfikowane w kursie na żywym Haiku). Twój widget jest
/// dla modelu egzotyką bez instrukcji, a `Card`/`Text` zna ze specyfikacji A2UI
/// i danych treningowych.
const carCardUsageRule = '''
IMPORTANT: When you present ANY specific car offer, you MUST use the `CarCard`
component — one component per offer. Never compose a car offer out of
Card/Text/Column/Row yourself, and never describe a car in prose next to it.
Use Text only for the short intro line above the offers.''';

/// Katalog przycięty do tego, czego panel realnie potrzebuje: kontenery,
/// tekst, przycisk — i `CarCard`. Wąsko **dla trafności**, nie dla kosztu
/// (pomiar z 2026-08-04: ~20k znaków to nieredukowalna podłoga protokołu).
List<CatalogItem> _advisorItems({
  required bool withExample,
  required bool withCarCard,
}) => [
  BasicCatalogItems.column,
  BasicCatalogItems.row,
  BasicCatalogItems.text,
  BasicCatalogItems.divider,
  BasicCatalogItems.card,
  BasicCatalogItems.button,
  if (withCarCard) carCardItem(withExample: withExample),
];

/// Dwa warianty eksperymentu A/B z **jednej** listy itemów: identyczne
/// komponenty i `catalogId`, różni je wyłącznie [carCardUsageRule].
///
/// [withUsageRule] zabiera modelowi *regułę użycia*, [withCarCard] zabiera
/// *sam widget*. To dwie różne osie, które łatwo pomylić; wynik macierzy 2×2
/// na żywym Haiku jest w `docs/experiment-04-05-live-haiku.md`.
///
/// ⚠️ **Wyłączaj `withCarCard` tylko w katalogu idącym do `PromptBuilder`.**
/// `SurfaceController` ma go znać zawsze: renderer wiedzący WIĘCEJ niż model
/// jest nieszkodliwy, odwrotny rozjazd daje powierzchnię bez komponentów albo
/// błąd walidacji zapętlający requesty.
Catalog advisorCatalog({
  required bool withUsageRule,
  bool withExample = true,
  bool withCarCard = true,
}) => Catalog(
  _advisorItems(withExample: withExample, withCarCard: withCarCard),
  catalogId: advisorCatalogId,
  systemPromptFragments: [if (withUsageRule && withCarCard) carCardUsageRule],
);
