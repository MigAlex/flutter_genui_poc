import 'package:flutter/material.dart';

import '../resources/app_sizes.dart';
import '../extensions/build_context_ext.dart';

/// Trwały pasek „kto właśnie odpowiada" — widoczny na **każdym** ekranie POC-a.
///
/// Powód istnienia jest dydaktyczny, nie kosmetyczny. Mock i realny model
/// rysują **to samo** przez ten sam pipeline, więc po samym ekranie nie da się
/// ich odróżnić — a wnioski, które wolno z nich wyciągnąć, są rozłączne:
///
/// * mock dowodzi **renderera** (katalog → widget, binding, cykl życia),
/// * model dowodzi **zachowania modelu** (czy trzyma protokół, reguły, schemat).
///
/// Wcześniej ta informacja była na każdym ekranie inna i na czacie **znikała po
/// pierwszej wiadomości**. Najłatwiejszy sposób oszukania się na tym POC-u to
/// wziąć ładny render mocka za dowód, że model zachowa się tak samo.
class AgentBanner extends StatelessWidget {
  const AgentBanner({
    required this.isMock,
    required this.label,
    required this.proves,
    super.key,
  });

  final bool isMock;
  final String label;

  /// Co konkretnie dowodzi TEN ekran w bieżącym trybie — inne zdanie per ekran,
  /// bo czat, panel i triage pokazują różne mechanizmy.
  final String proves;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final theme = context.theme;

    final background = isMock
        ? scheme.tertiaryContainer
        : scheme.primaryContainer;
    final foreground = isMock
        ? scheme.onTertiaryContainer
        : scheme.onPrimaryContainer;

    return Material(
      color: background,
      child: InkWell(
        onTap: () => _showExplainer(context),
        child: Padding(
          padding: hPadding12 + vPadding6,
          child: Row(
            children: [
              Icon(
                isMock ? Icons.science_outlined : Icons.cloud_outlined,
                size: 16,
                color: foreground,
              ),
              hGap8,
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                    ),
                    children: [
                      TextSpan(
                        text: isMock ? 'MOCK' : label.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' · $proves'),
                    ],
                  ),
                ),
              ),
              Icon(Icons.help_outline, size: 14, color: foreground),
            ],
          ),
        ),
      ),
    );
  }

  void _showExplainer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isMock ? 'Tryb: mock' : 'Tryb: $label'),
        // Scroll, bo tabela dowodów na niskim ekranie (albo przy dużym
        // `textScaler`) nie mieści się w dialogu — bez tego RenderFlex
        // overflow zamiast treści.
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMock
                      ? 'Odpowiedzi syntetyzuje atrapa w kodzie apki. Nic nie leci '
                            'do sieci, wynik jest za każdym razem ten sam.'
                      : 'Odpowiedzi generuje model przez sieć. Ten sam prompt może '
                            'dać inny ekran za drugim razem.',
                  style: context.textTheme.bodyMedium,
                ),
                vGap12,
                const _ProofTable(),
                vGap12,
                Text(
                  isMock
                      ? 'Przełączasz kluczem przy starcie:\n'
                            'flutter run --dart-define=ANTHROPIC_API_KEY=…'
                      : 'Bez klucza DI wybiera mocka — POC działa bez konfiguracji.',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Jasne'),
          ),
        ],
      ),
    );
  }
}

/// Rozłączność wniosków w jednym miejscu — to jest właściwa odpowiedź na
/// pytanie „czym się różni mock od Haiku", bo różnica nie leży w tym, co widać
/// na ekranie, tylko w tym, co wolno z tego wywnioskować.
class _ProofTable extends StatelessWidget {
  const _ProofTable();

  static const _rows = <(String, bool, bool)>[
    ('Własny widget przechodzi katalog → renderer', true, true),
    ('Binding: zapis → DataModel → subskrypcja hosta', true, true),
    ('Cykl życia powierzchni, walidacja hosta', true, true),
    ('Model sięga po Twój widget, nie po generyki', false, true),
    ('Model emituje {"path": …}, a nie wartość', false, true),
    ('Model trzyma whitelistę komponentów kroku', false, true),
    ('Model nie odpowiada prozą zamiast A2UI', false, true),
    ('Realna latencja i koszt tokenów', false, true),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FixedColumnWidth(52),
        2: FixedColumnWidth(52),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
          children: [
            const _Cell('Co dowodzi', isHeader: true),
            const _Cell('mock', isHeader: true),
            const _Cell('model', isHeader: true),
          ],
        ),
        for (final (what, byMock, byModel) in _rows)
          TableRow(
            children: [
              _Cell(what),
              _Mark(on: byMock),
              _Mark(on: byModel),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.isHeader = false});

  final String text;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? context.textTheme.labelSmall
        : context.textTheme.bodySmall;

    return Padding(
      padding: hPadding6 + vPadding4,
      child: Text(
        text,
        style: style,
        textAlign: isHeader ? TextAlign.center : null,
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Padding(
      padding: vPadding4,
      child: Icon(
        on ? Icons.check_circle : Icons.remove_circle_outline,
        size: 15,
        color: on ? scheme.primary : scheme.outline,
      ),
    );
  }
}
