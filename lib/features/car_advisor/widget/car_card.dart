import 'package:flutter/material.dart';

import '../../../commons/resources/app_sizes.dart';
import '../../../commons/extensions/build_context_ext.dart';

/// Karta jednej oferty auta — **zwykły widget Flutter, zero genui**.
///
/// Świadomie nic nie wie o katalogu, `CatalogItemContext` ani A2UI: dzięki temu
/// testuje się go `pumpWidget`-em bez całego pipeline'u, a most do genui żyje
/// osobno w `lib/genui_catalog/car_card_item.dart`. Gdyby te dwie rzeczy siedziały
/// w jednym pliku, każdy test widgetu ciągnąłby za sobą parser protokołu.
class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.title,
    required this.pricePln,
    required this.year,
    required this.mileageKm,
    required this.fuelLabel,
    this.highlight,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final int pricePln;
  final int year;
  final int mileageKm;

  /// Gotowy napis („benzyna"), nie enum — mapowanie z wartości protokołu robi
  /// warstwa katalogu, widget zostaje głupi.
  final String fuelLabel;
  final String? highlight;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: bPadding12,
      child: Padding(
        padding: allPadding12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                hGap8,
                Text(
                  '${_grouped(pricePln)} zł',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            vGap8,
            Wrap(
              spacing: AppSizes.p8,
              runSpacing: AppSizes.p8,
              children: [
                _Spec(Icons.calendar_today_outlined, '$year'),
                _Spec(Icons.speed_outlined, '${_grouped(mileageKm)} km'),
                _Spec(Icons.local_gas_station_outlined, fuelLabel),
              ],
            ),
            if (highlight case final text? when text.isNotEmpty) ...[
              vGap8,
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onPressed != null) ...[
              vGap8,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onPressed,
                  child: Text(actionLabel ?? 'Szczegóły'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Jedna para ikona + wartość w pasku parametrów.
class _Spec extends StatelessWidget {
  const _Spec(this.icon, this.value);

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      padding: hPadding8 + vPadding4,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: borderRadiusM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          hGap4,
          Text(
            value,
            style: context.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Separator tysięcy: **twarda spacja** (U+00A0), nie zwykła — inaczej cena
/// potrafi się złamać w połowie przy wąskim ekranie. Stała, bo testy muszą
/// porównywać się do tego samego znaku, a wzrokowo są nie do odróżnienia.
const groupSeparator = '\u00A0';

/// `59900` → `59 900`.
String _grouped(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value.isNegative ? '-' : '');

  for (var i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(groupSeparator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
