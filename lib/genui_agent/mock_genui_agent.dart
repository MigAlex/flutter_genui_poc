import 'dart:convert';

import 'package:genui/genui.dart';

import 'genui_agent.dart';

/// POC: udawany „LLM". Zamiast wołać model, syntetyzuje wiadomości A2UI
/// (protokół v0.9) i strumieniuje je do transportu jako tekst — dokładnie
/// tak, jak robiłby to prawdziwy model. To pokazuje rdzeń GenUI:
/// **JSON od modelu → widgety z Catalogu**, bez klucza API.
///
/// W realnej apce ta klasa wywołałaby `firebase_vertexai` / `google_generative_ai`
/// i przekazała strumień chunków do `transport.addChunk(...)`.
class MockGenUiAgent implements GenUiAgent {
  /// a2ui.org basic catalog (widgety z `BasicCatalogItems`).
  ///
  /// ⚠️ **Nie wpisuj tego URL-a z palca.** W genui 0.10.3 kanoniczny adres
  /// zmienił się z `.../v0_9/basic_catalog.json` na
  /// `.../v0_9/catalogs/basic/catalog.json`; stary żyje dalej jako
  /// `legacyBasicCatalogId` (`@Deprecated`) i katalog odpowiada na oba przez
  /// nowy mechanizm `catalogIdAliases`. Dlatego zaszyty stary string **nadal
  /// działa** — i właśnie dlatego jest groźny: milczy, dopóki ktoś nie usunie
  /// aliasu. Bierzemy stałą z paczki, żeby taka zmiana była błędem kompilacji,
  /// a nie pustą powierzchnią bez logu.
  static const _catalogId = basicCatalogId;

  int _surfaceCounter = 0;

  @override
  String get label => 'Mock (bez klucza API)';

  @override
  bool get isMock => true;

  /// Mock nie ma historii rozmowy — zeruje licznik powierzchni, żeby po
  /// wyczyszczeniu czatu id zaczynały się znów od `s1` (inaczej „nowa"
  /// rozmowa startuje od `s7` i wygląda jak kontynuacja starej).
  @override
  void reset() => _surfaceCounter = 0;

  /// Wywoływane przez `A2uiTransportAdapter.onSend`. Patrzy na wiadomość
  /// (prompt tekstowy vs interakcja z UI) i emituje odpowiedni ekran.
  @override
  Future<void> respond(
    ChatMessage message,
    A2uiTransportAdapter transport,
  ) async {
    // Symulacja latencji modelu.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final interaction = _extractInteraction(message);
    final surfaceId = 's${++_surfaceCounter}';

    final List<Map<String, Object?>> components = switch (interaction) {
      'pick_beach' => _beachDetail(),
      'pick_mountains' => _mountainsDetail(),
      'restart' => _menu(),
      _ => _menu(), // pierwszy prompt tekstowy → menu startowe
    };

    // 1. createSurface — zapowiedź nowej powierzchni UI.
    transport.addChunk(
      jsonEncode({
        'version': 'v0.9',
        'createSurface': {'surfaceId': surfaceId, 'catalogId': _catalogId},
      }),
    );

    // 2. updateComponents — drzewo komponentów (root + dzieci).
    transport.addChunk(
      jsonEncode({
        'version': 'v0.9',
        'updateComponents': {'surfaceId': surfaceId, 'components': components},
      }),
    );
  }

  /// Wyciąga nazwę zdarzenia z interakcji UI (klik przycisku), jeśli jest.
  String? _extractInteraction(ChatMessage message) {
    final parts = message.parts.uiInteractionParts;
    if (parts.isEmpty) return null;
    final raw =
        parts.first.interaction; // JSON: {version, action:{event:{name}}}
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    final action = decoded['action'] as Map<String, Object?>?;
    final event = action?['event'] as Map<String, Object?>?;
    return event?['name'] as String?;
  }

  // --- Ekrany (drzewa komponentów A2UI) ---

  List<Map<String, Object?>> _menu() => [
    _column('root', ['title', 'subtitle', 'buttons'], align: 'start'),
    _text('title', 'Zaplanujmy wyjazd ✈️', variant: 'headlineSmall'),
    _text('subtitle', 'Wybierz klimat — UI generuje „model":'),
    _row('buttons', ['btnBeach', 'btnMountains']),
    _button('btnBeach', 'lblBeach', 'pick_beach'),
    _text('lblBeach', '🏖️  Plaża'),
    _button('btnMountains', 'lblMtn', 'pick_mountains'),
    _text('lblMtn', '🏔️  Góry'),
  ];

  List<Map<String, Object?>> _beachDetail() => [
    _column('root', ['t', 'd', 'btnBack'], align: 'start'),
    _text('t', '🏖️ Plaża', variant: 'headlineSmall'),
    _text(
      'd',
      'Sugeruję Algarve: 25°C, ceny poza sezonem, klify w Lagos. '
          'Spakuj krem i lekką kurtkę na wieczory.',
    ),
    _button('btnBack', 'lblBack', 'restart'),
    _text('lblBack', '← Inny klimat'),
  ];

  List<Map<String, Object?>> _mountainsDetail() => [
    _column('root', ['t', 'd', 'btnBack'], align: 'start'),
    _text('t', '🏔️ Góry', variant: 'headlineSmall'),
    _text(
      'd',
      'Dolomity: szlak Tre Cime di Lavaredo (~10 km, pętla), '
          'schroniska na trasie. Wrzesień = mniej tłumu, stabilna pogoda.',
    ),
    _button('btnBack', 'lblBack', 'restart'),
    _text('lblBack', '← Inny klimat'),
  ];

  // --- Buildery komponentów (kształt: {id, component, ...properties}) ---

  Map<String, Object?> _text(String id, String text, {String? variant}) => {
    'id': id,
    'component': 'Text',
    'text': text,
    'variant': ?variant,
  };

  Map<String, Object?> _column(
    String id,
    List<String> children, {
    String? align,
  }) => {
    'id': id,
    'component': 'Column',
    'children': children,
    'align': ?align,
  };

  Map<String, Object?> _row(String id, List<String> children) => {
    'id': id,
    'component': 'Row',
    'children': children,
  };

  Map<String, Object?> _button(String id, String childId, String eventName) => {
    'id': id,
    'component': 'Button',
    'child': childId,
    'action': {
      'event': {'name': eventName},
    },
  };
}
