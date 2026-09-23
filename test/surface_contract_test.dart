import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/commons/a2ui/a2ui_messages.dart';
import 'package:flutter_genui_poc/commons/a2ui/surface_contract.dart';
import 'package:flutter_genui_poc/features/triage_panel/contract/triage_contract.dart';
import 'package:flutter_genui_poc/features/triage_panel/model/support_case.dart';
import 'package:flutter_genui_poc/genui_catalog/triage_catalog.dart';

/// Kontrakt powierzchni testujemy **bez genui i bez Fluttera** — to czysta
/// funkcja ze stanu i snapshotu w werdykt. Gdyby wymagał pipeline'u, nie dałoby
/// się go użyć w innym feature'rze, a po to powstał generyczny.
void main() {
  String wire(List<Map<String, Object?>> components, {String? surfaceId}) =>
      jsonEncode({
        'version': 'v0.9',
        'updateComponents': {
          'surfaceId': surfaceId ?? triageStripSurfaceId,
          'components': components,
        },
      });

  Map<String, Object?> component(String name, {String? id}) => {
    'id': id ?? name.toLowerCase(),
    'component': name,
  };

  List<Map<String, Object?>> strip(List<String> names) => [
    {
      'id': 'root',
      'component': 'Column',
      'children': [for (final name in names) name.toLowerCase()],
    },
    for (final name in names) component(name),
  ];

  ContractVerdict verify(String raw, SupportCase order) => triageContract()
      .verify(A2uiMessages.snapshot(raw), order, requireCompleteness: true);

  group('A2uiMessages', () {
    test('Wyławia wiadomości owinięte w ```json i sklejone po dwie', () {
      final raw =
          '```json\n${wire(strip([TriageComponents.actionRow]))}\n```\n'
          '```json\n${jsonEncode({'version': 'v0.9'})}\n```';

      final snapshot = A2uiMessages.snapshot(raw);

      expect(snapshot.isA2ui, isTrue);
      expect(snapshot.hasRoot, isTrue);
      expect(snapshot.surfaceId, triageStripSurfaceId);
      expect(snapshot.componentNames, contains(TriageComponents.actionRow));
    });

    test('Proza to nie A2UI — i to jest osobny fakt, nie pusty zbiór', () {
      final snapshot = A2uiMessages.snapshot(
        'Klient dzwoni w sprawie przesyłki, proponuję reklamację.',
      );

      expect(snapshot.isA2ui, isFalse);
      expect(snapshot.componentNames, isEmpty);
    });
  });

  group('Kontrakt paska triage', () {
    test('Poprawny pasek przechodzi', () {
      final raw = wire(
        strip([
          TriageComponents.shipmentTracker,
          TriageComponents.actionRow,
        ]),
      );

      expect(verify(raw, SupportCases.stuckShipment), isA<SurfaceAccepted>());
    });

    // Kierunek pierwszy: model PRZEMILCZAŁ coś, czego nie wolno przemilczeć.
    // To jest cichy tryb awarii, dla którego cały kontrakt istnieje — brak
    // komponentu wygląda tak samo jak brak sygnału w danych.
    test('Brak wymaganego CreditLimitBanner odrzuca powierzchnię', () {
      final raw = wire(
        strip([TriageComponents.paymentBlock, TriageComponents.actionRow]),
      );

      final verdict = verify(raw, SupportCases.b2bOverLimit);

      expect(verdict, isA<RequiredComponentMissing>());
      expect(
        (verdict as RequiredComponentMissing).component,
        TriageComponents.creditLimitBanner,
      );
      expect(verdict.rule, contains(TriageComponents.creditLimitBanner));
    });

    // Kierunek drugi: model DODAŁ coś, czego w tym stanie nie wolno.
    test('Obecny zakazany OfferCard odrzuca powierzchnię', () {
      final raw = wire(
        strip([
          TriageComponents.creditLimitBanner,
          TriageComponents.offerCard,
          TriageComponents.actionRow,
        ]),
      );

      final verdict = verify(raw, SupportCases.b2bOverLimit);

      expect(verdict, isA<ForbiddenComponentPresent>());
      expect(
        (verdict as ForbiddenComponentPresent).component,
        TriageComponents.offerCard,
      );
    });

    test('Ten sam OfferCard u klienta bez zaległości jest w porządku', () {
      final raw = wire(
        strip([TriageComponents.offerCard, TriageComponents.actionRow]),
      );

      // Zakaz jest warunkowy — gdyby polegał na wycięciu widgetu z katalogu,
      // ten przypadek też by padł.
      expect(verify(raw, SupportCases.stuckShipment), isA<SurfaceAccepted>());
    });

    test('Komponent spoza whitelisty odrzuca powierzchnię', () {
      final raw = wire(strip(['InvoicePreview', TriageComponents.actionRow]));

      expect(verify(raw, SupportCases.stuckShipment), isA<ComponentNotAllowed>());
    });

    test('Brak root odrzuca powierzchnię', () {
      final raw = wire([component(TriageComponents.actionRow, id: 'actions')]);

      expect(verify(raw, SupportCases.stuckShipment), isA<MissingRoot>());
    });

    test('Powierzchnia spoza kontraktu (zły katalog) jest wychwycona', () {
      final raw = wire(
        strip([TriageComponents.actionRow]),
        surfaceId: triageBrokenSurfaceId,
      );

      final verdict = verify(raw, SupportCases.stuckShipment);

      expect(verdict, isA<WrongSurface>());
      expect((verdict as WrongSurface).actual, triageBrokenSurfaceId);
    });

    // `ConversationSurfaceAdded` niesie drzewo, które MOŻE być w budowie.
    // Egzekwowanie listy wymaganych w tym momencie odrzucałoby poprawne
    // powierzchnie w połowie ich powstawania — i wyglądałoby to losowo.
    test('Bez wymogu kompletności brak wymaganego jeszcze nie odrzuca', () {
      final raw = wire(
        strip([TriageComponents.paymentBlock, TriageComponents.actionRow]),
      );

      final verdict = triageContract().verify(
        A2uiMessages.snapshot(raw),
        SupportCases.b2bOverLimit,
        requireCompleteness: false,
      );

      expect(verdict, isA<SurfaceAccepted>());
    });
  });
}
