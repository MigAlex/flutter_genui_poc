import 'dart:convert';

import 'package:genui/genui.dart';

import '../genui_catalog/advisor_catalog.dart';

// Przeniesione do commons, bo od czasu inspektora „drutu" potrzebuje tego
// także agent czatu. Re-eksport, żeby dotychczasowe importy zostały bez zmian.
export '../commons/a2ui/component_names.dart';

/// Diagnostyka promptu na potrzeby paska laboratoryjnego.
///
/// [mentionsCarCard] mówi wprost, czy model w ogóle wie o widgecie — i to jest
/// **jedyny wiarygodny sygnał, że przełącznik zadziałał**. Przy wyłączonym
/// `CarCard` ma być `false`; jeśli jest `true`, katalog promptu nie został
/// przycięty i to, co widać na ekranie, nie ma nic wspólnego z przełącznikiem.
typedef PromptDiagnostics = ({int length, bool mentionsCarCard});

/// Agent panelu doradcy. Osobny byt niż `GenUiAgent` z czatu, bo kontrakt jest
/// inny: umie założyć powierzchnię, wybiera wariant promptu i raportuje, jakich
/// komponentów użył model.
abstract interface class AdvisorAgent {
  String get label;

  /// Czy to atrapa. Pasek A/B musi to pokazać, żeby nie brać renderu mocka
  /// za dowód na zachowanie modelu.
  bool get isMock;

  /// Zakłada powierzchnię panelu — **robi to host, nie model**.
  ///
  /// Przy `SurfaceOperations.updateOnly` model nie ma `createSurface`, a
  /// `SurfaceController` buforuje update'y do nieistniejącej powierzchni przez
  /// `pendingUpdateTimeout` (domyślnie minuta) i po timeoucie je **gubi bez
  /// śladu**. Bez tego wywołania panel byłby pusty, a przyczyna niewidoczna.
  void bootstrapPanel(A2uiTransportAdapter transport);

  PromptDiagnostics diagnostics({required bool withCarCard});

  /// Zapomina historię rozmowy. **Wymóg poprawności eksperymentu, nie wygoda:**
  /// oba warianty A/B muszą startować z tego samego, pustego kontekstu.
  ///
  /// Bez tego wariant bez reguły dostaje w historii własną odpowiedź wariantu
  /// z regułą — a `_panelDiscipline` każe „przebuduj cały panel na każdej
  /// turze". Model naśladuje wtedy poprzednie drzewo jak przykład few-shot,
  /// więc `CarCard` pojawia się także tam, gdzie reguły nie ma. Wynik wygląda
  /// wtedy na „reguła nie ma znaczenia", a naprawdę znaczy „porównano wariant
  /// z wariantem plus jego własna odpowiedź".
  void reset();

  /// Zwraca zbiór nazw komponentów, których użył model — to jest wynik
  /// eksperymentu, nie efekt uboczny.
  ///
  /// [withCarCard] decyduje, czy katalog **idący do promptu** niesie nasz
  /// widget. Katalog renderera zawiera go zawsze (patrz `advisorCatalog`).
  Future<Set<String>> respond(
    ChatMessage message,
    A2uiTransportAdapter transport, {
    required bool withCarCard,
  });
}

/// Wiadomość A2UI zakładająca powierzchnię panelu. Wspólna dla mocka i Claude'a,
/// żeby `surfaceId`/`catalogId` nie rozjechały się między torami.
String panelBootstrapChunk() => jsonEncode({
  'version': 'v0.9',
  'createSurface': {
    'surfaceId': advisorPanelSurfaceId,
    'catalogId': advisorCatalogId,
  },
});
