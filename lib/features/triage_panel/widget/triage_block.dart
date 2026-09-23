import 'package:flutter/material.dart';

import '../../../commons/extensions/build_context_ext.dart';
import '../../../commons/resources/app_sizes.dart';

/// Waga sygnału na pasku. **Nie jest polem schematu** — model nie decyduje
/// o tym, co jest alarmujące; wynika to z danych, które i tak są prawdziwe.
enum TriageTone { neutral, warning, danger, good }

/// Wspólny kadr wszystkich klocków paska: ikona, tytuł, opcjonalna plakietka
/// i kilka linii treści.
///
/// Istnieje, bo sześć klocków różniących się tylko treścią i kolorem to sześć
/// okazji, żeby pasek wyglądał jak sklejony z trzech różnych aplikacji.
/// **Katalog udostępniany modelowi jest design systemem** — spójność kadru jest
/// tu funkcją, nie kosmetyką.
class TriageBlock extends StatelessWidget {
  const TriageBlock({
    required this.icon,
    required this.title,
    required this.lines,
    this.badge,
    this.tone = TriageTone.neutral,
    this.child,
    super.key,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final String? badge;
  final TriageTone tone;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final theme = context.theme;

    final (background, foreground) = switch (tone) {
      TriageTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurface),
      TriageTone.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TriageTone.danger => (scheme.errorContainer, scheme.onErrorContainer),
      TriageTone.good => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };

    return Container(
      margin: bPadding8,
      padding: allPadding12,
      decoration: BoxDecoration(color: background, borderRadius: borderRadiusL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: foreground),
              hGap8,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge case final text?) ...[
                hGap8,
                Container(
                  padding: hPadding8 + vPadding2,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: borderRadiusFull,
                  ),
                  child: Text(text, style: theme.textTheme.labelSmall),
                ),
              ],
            ],
          ),
          for (final line in lines) ...[
            vGap4,
            Text(
              line,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ],
          if (child case final widget?) ...[vGap8, widget],
        ],
      ),
    );
  }
}
