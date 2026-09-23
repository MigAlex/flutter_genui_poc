import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/genui_catalog/advisor_catalog.dart';

/// Testy warunków wstępnych eksperymentu ④.
///
/// Nie sprawdzają, co zrobi model — tego offline sprawdzić się nie da.
/// Sprawdzają coś, co jest warunkiem sensowności A/B: że **oba** warianty
/// pokazują modelowi `CarCard`, a różni je wyłącznie reguła użycia. Bez tego
/// „model pominął CarCard" nie byłoby wynikiem, tylko błędem konfiguracji.
void main() {
  String promptFor({required bool withUsageRule}) => PromptBuilder.custom(
    catalog: advisorCatalog(withUsageRule: withUsageRule),
    allowedOperations: SurfaceOperations.updateOnly(dataModel: false),
  ).systemPromptJoined();

  test('CarCard jest w katalogu w obu wariantach', () {
    for (final withRule in [true, false]) {
      final names = advisorCatalog(
        withUsageRule: withRule,
      ).items.map((i) => i.name);
      expect(names, contains('CarCard'), reason: 'wariant rule=$withRule');
    }
  });

  test('Oba warianty promptu pokazują modelowi CarCard', () {
    expect(promptFor(withUsageRule: true), contains('CarCard'));
    expect(
      promptFor(withUsageRule: false),
      contains('CarCard'),
      reason:
          'to jest sedno eksperymentu: bez reguły model WIDZI widget '
          'i mimo to go nie używa',
    );
  });

  test('Regułę użycia niesie wyłącznie wariant guided', () {
    expect(promptFor(withUsageRule: true), contains(carCardUsageRule.trim()));
    expect(
      promptFor(withUsageRule: false),
      isNot(contains('you MUST use the `CarCard`')),
    );
  });

  test('Warianty różnią się TYLKO regułą — reszta katalogu identyczna', () {
    final guided = advisorCatalog(withUsageRule: true);
    final plain = advisorCatalog(withUsageRule: false);

    expect(guided.catalogId, plain.catalogId);
    expect(
      guided.items.map((i) => i.name).toList(),
      plain.items.map((i) => i.name).toList(),
    );
  });

  group('withCarCard — przełącznik demonstracyjny, druga oś', () {
    test('Wyłączony wyjmuje widget z katalogu', () {
      final names = advisorCatalog(
        withUsageRule: true,
        withCarCard: false,
      ).items.map((i) => i.name);

      expect(names, isNot(contains('CarCard')));
      // Reszta katalogu ma zostać nietknięta — inaczej porównanie „z widgetem
      // vs bez" mierzyłoby przy okazji zmianę całego słownictwa modelu.
      expect(names, containsAll(['Column', 'Text', 'Card', 'Button']));
    });

    test('Wyłączony znika też z PROMPTU — to jest cały mechanizm', () {
      final prompt = PromptBuilder.custom(
        catalog: advisorCatalog(withUsageRule: true, withCarCard: false),
        allowedOperations: SurfaceOperations.updateOnly(dataModel: false),
      ).systemPromptJoined();

      expect(
        prompt,
        isNot(contains('CarCard')),
        reason:
            'gdyby tu został, model dalej by go używał, a przełącznik '
            'wyglądałby na zepsuty — dokładnie tak było z regułą użycia',
      );
    });

    test('Reguła użycia znika razem z widgetem', () {
      final prompt = PromptBuilder.custom(
        catalog: advisorCatalog(withUsageRule: true, withCarCard: false),
        allowedOperations: SurfaceOperations.updateOnly(dataModel: false),
      ).systemPromptJoined();

      expect(
        prompt,
        isNot(contains('you MUST use the `CarCard`')),
        reason: 'rozkaz użycia nieistniejącego komponentu to zaproszenie '
            'do halucynacji',
      );
    });
  });

  test('Advisor ma własny catalogId, nie basicowy', () {
    expect(advisorCatalogId, 'com.poc.car_advisor');
    expect(
      advisorCatalogId,
      isNot(BasicCatalogItems.asCatalog().catalogId),
      reason: 'ten sam id oznaczałby, że mock czatu przypadkiem tu pasuje',
    );
  });
}
