import 'dart:convert';

import 'package:genui/genui.dart';

import '../genui_catalog/advisor_catalog.dart';
import 'advisor_agent.dart';

/// Atrapa panelu: syntetyzuje `updateComponents` na **istniejącą** powierzchnię.
///
/// Osobna od mocka czatu z jednego powodu: tamten ma zaszyty basicowy
/// `catalogId` i o advisorowy katalog rozbiłby się ciszą (pusty stub w
/// kontrolerze → panel bez komponentów, zero komunikatu).
///
/// **Respektuje przełącznik `CarCard` w katalogu**, ale nie udaje decyzji
/// modelu. Z widgetem w katalogu rysuje `CarCard` (dowód, że *renderer* go
/// zna), bez widgetu — składa tę samą treść z generyków, bo to jedyne, co
/// modelowi w tej konfiguracji zostaje. Czego mock NIE pokazuje: czy model
/// mając `CarCard` faktycznie po niego sięgnie. Tego atrapa nie rozstrzyga
/// i nie będzie udawać.
class MockAdvisorAgent implements AdvisorAgent {
  int _revision = 0;

  @override
  String get label => 'Mock (bez klucza API)';

  @override
  bool get isMock => true;

  @override
  void bootstrapPanel(A2uiTransportAdapter transport) {
    transport.addChunk(panelBootstrapChunk());
  }

  @override
  PromptDiagnostics diagnostics({required bool withCarCard}) =>
      (length: 0, mentionsCarCard: false);

  /// Atrapa nie ma historii — jej odpowiedź nie zależy od poprzednich tur.
  /// Metoda istnieje, bo kontrakt jej wymaga, i to jest właściwe: gdyby mock
  /// ją omijał, przełącznik zachowywałby się inaczej na mocku niż na modelu.
  @override
  void reset() {}

  @override
  Future<Set<String>> respond(
    ChatMessage message,
    A2uiTransportAdapter transport, {
    required bool withCarCard,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _revision++;

    // Atrapa **respektuje przełącznik**. Nie dlatego, że udaje decyzję modelu
    // (tej udawać nie będzie), tylko dlatego, że bez widgetu w katalogu
    // wygenerowanie go byłoby kłamstwem o tym, co model może narysować —
    // a przełącznik zachowywałby się inaczej na atrapie niż na Claudzie.
    final components = withCarCard ? _panel() : _panelWithoutCarCard();

    transport.addChunk(
      jsonEncode({
        'version': 'v0.9',
        'updateComponents': {
          'surfaceId': advisorPanelSurfaceId,
          'components': components,
        },
      }),
    );

    return componentNamesIn(jsonEncode(components));
  }

  /// Panel: nagłówek + dwie karty. Ten sam `surfaceId` co poprzednio, więc
  /// zawartość **podmienia się w miejscu** zamiast dokładać kolejny bąbelek.
  List<Map<String, Object?>> _panel() => [
    {
      'id': 'root',
      'component': 'Column',
      'children': ['intro', 'car1', 'car2'],
      'align': 'start',
    },
    {
      'id': 'intro',
      'component': 'Text',
      'text':
          'Mock nie czyta kryteriów — pokazuje, '
          'że renderer zna CarCard (odświeżenie #$_revision).',
    },
    _car(
      'car1',
      title: 'Skoda Octavia III 1.5 TSI Style',
      pricePln: 59900,
      year: 2019,
      mileageKm: 128000,
      fuel: 'petrol',
      highlight: 'Duży bagażnik, tani serwis, łańcuch rozrządu.',
    ),
    _car(
      'car2',
      title: 'Toyota Corolla TS 1.8 Hybrid Comfort',
      pricePln: 68500,
      year: 2020,
      mileageKm: 96000,
      fuel: 'hybrid',
      highlight: 'Hybryda bez DPF-u — dobra, gdy jeździsz głównie w mieście.',
    ),
  ];

  /// Ta sama treść złożona z generyków — dokładnie to, co model musi zrobić,
  /// gdy nie ma `CarCard` w katalogu. Karta auta powstaje ręcznie z `Card`,
  /// `Column` i trzech `Text`, bez ikon, bez formatowania ceny, bez naszego
  /// themingu. **Różnica na ekranie jest sednem demonstracji.**
  List<Map<String, Object?>> _panelWithoutCarCard() => [
    {
      'id': 'root',
      'component': 'Column',
      'children': ['intro', 'car1', 'car2'],
      'align': 'start',
    },
    {
      'id': 'intro',
      'component': 'Text',
      'text':
          'Bez CarCard w katalogu model składa ofertę z generyków '
          '(odświeżenie #$_revision).',
    },
    ..._genericCar(
      'car1',
      title: 'Skoda Octavia III 1.5 TSI Style',
      body: '59900 PLN · 2019 · 128000 km · petrol',
      highlight: 'Duży bagażnik, tani serwis, łańcuch rozrządu.',
    ),
    ..._genericCar(
      'car2',
      title: 'Toyota Corolla TS 1.8 Hybrid Comfort',
      body: '68500 PLN · 2020 · 96000 km · hybrid',
      highlight: 'Hybryda bez DPF-u — dobra, gdy jeździsz głównie w mieście.',
    ),
  ];

  /// Jedna „karta" auta na generykach = **pięć** komponentów zamiast jednego.
  /// To jest ta arytmetyka, o której mówi teza o katalogu jako design systemie.
  List<Map<String, Object?>> _genericCar(
    String id, {
    required String title,
    required String body,
    required String highlight,
  }) => [
    {'id': id, 'component': 'Card', 'child': '${id}_col'},
    {
      'id': '${id}_col',
      'component': 'Column',
      'children': ['${id}_title', '${id}_body', '${id}_hl'],
      'align': 'start',
    },
    {
      'id': '${id}_title',
      'component': 'Text',
      'text': title,
      'variant': 'h4',
    },
    {'id': '${id}_body', 'component': 'Text', 'text': body},
    {'id': '${id}_hl', 'component': 'Text', 'text': highlight},
  ];

  Map<String, Object?> _car(
    String id, {
    required String title,
    required int pricePln,
    required int year,
    required int mileageKm,
    required String fuel,
    required String highlight,
  }) => {
    'id': id,
    'component': 'CarCard',
    'title': title,
    'pricePln': pricePln,
    'year': year,
    'mileageKm': mileageKm,
    'fuel': fuel,
    'highlight': highlight,
    'actionLabel': 'Pokaż podobne',
    'action': {
      'event': {'name': 'show_similar'},
    },
  };
}
