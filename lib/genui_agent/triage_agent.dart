import 'dart:convert';

import 'package:genui/genui.dart';

import '../commons/a2ui/a2ui_sink.dart';
import '../commons/logging/token_tally.dart';
import '../genui_catalog/triage_catalog.dart';

/// Agent paska triage'u. Trzeci kontrakt agenta w tym POC-u i najprostszy —
/// bo cała diagnostyka przeniosła się z agenta do **kontraktu powierzchni**.
///
/// Różnica wobec `AdvisorAgent`: agent nie raportuje, czego użył model.
/// Raportuje to przechwytywacz, bo między agentem a rendererem może siedzieć
/// wymuszona awaria — i wtedy „co wygenerował model" i „co host realnie
/// dostarczył" to dwie różne rzeczy. Werdykt liczymy z tej drugiej.
abstract interface class TriageAgent {
  String get label;

  /// Czy to atrapa. Musi być widoczne na ekranie: mock i model rysują to samo
  /// tym samym pipeline'em, a dowodzą czegoś innego.
  bool get isMock;

  /// Zakłada powierzchnię paska — **robi to host, nie model**.
  void bootstrapStrip(A2uiSink sink);

  /// Długość system promptu (0 dla atrapy — nie buduje promptu).
  int get promptLength;

  /// Bilans tokenów narastająco. Atrapa zwraca pusty — mock nie kosztuje,
  /// i pasek ma to pokazać, zamiast udawać liczbę.
  TokenTally get tally;

  /// Zapomina historię rozmowy. Panel jest bezstanowy z definicji: każdy
  /// telefon to nowa sytuacja, a nie ciąg dalszy poprzedniej.
  void reset();

  Future<void> respond(ChatMessage message, A2uiSink sink);
}

/// Wiadomość zakładająca powierzchnię paska. Wspólna dla atrapy i Claude'a,
/// żeby `surfaceId`/`catalogId` nie rozjechały się między torami.
String stripBootstrapChunk() => jsonEncode({
  'version': 'v0.9',
  'createSurface': {
    'surfaceId': triageStripSurfaceId,
    'catalogId': triageCatalogId,
  },
});
