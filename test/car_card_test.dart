import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/features/car_advisor/widget/car_card.dart';

/// Widget jest czystym Flutterem, więc testuje się go bez genui — o to
/// chodziło w rozdzieleniu `CarCard` od `carCardItem`.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('Formatuje cenę i przebieg po polsku', (tester) async {
    await tester.pumpWidget(
      wrap(
        const CarCard(
          title: 'Skoda Octavia III',
          pricePln: 59900,
          year: 2019,
          mileageKm: 128000,
          fuelLabel: 'benzyna',
        ),
      ),
    );

    // `groupSeparator` to twarda spacja — porównanie do zwykłej przechodzi
    // wzrokowo, ale nie w teście.
    expect(find.text('59${groupSeparator}900 zł'), findsOneWidget);
    expect(find.text('128${groupSeparator}000 km'), findsOneWidget);
    expect(find.text('2019'), findsOneWidget);
    expect(find.text('benzyna'), findsOneWidget);
  });

  testWidgets('Bez akcji nie pokazuje przycisku', (tester) async {
    await tester.pumpWidget(
      wrap(
        const CarCard(
          title: 'Toyota Corolla',
          pricePln: 68500,
          year: 2020,
          mileageKm: 96000,
          fuelLabel: 'hybryda',
        ),
      ),
    );

    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('Z akcją woła callback', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      wrap(
        CarCard(
          title: 'Toyota Corolla',
          pricePln: 68500,
          year: 2020,
          mileageKm: 96000,
          fuelLabel: 'hybryda',
          actionLabel: 'Pokaż podobne',
          onPressed: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Pokaż podobne'));
    expect(taps, 1);
  });
}
