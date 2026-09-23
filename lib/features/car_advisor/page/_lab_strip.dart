part of 'car_advisor_page.dart';

/// Pasek laboratoryjny — **tu widać, czy przełącznik naprawdę zadziałał**,
/// bez grzebania w logach.
///
/// Sedno to nie sam werdykt „użył / nie użył", tylko para: *czy prompt w ogóle
/// wspomina o `CarCard`* obok *czego model użył*. Bez pierwszej liczby drugą
/// da się wytłumaczyć na dwa sprzeczne sposoby — model nie chciał vs model
/// nie mógł.
class _LabStrip extends StatelessWidget {
  const _LabStrip();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdvisorCubit>();
    final theme = context.theme;
    final scheme = theme.colorScheme;

    return BlocBuilder<CarAdvisorCubit, CarAdvisorState>(
      builder: (context, state) {
        final diagnostics = cubit.diagnostics;

        return Material(
          color: scheme.surfaceContainerHighest,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: hPadding12 + vPadding8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '`CarCard` w katalogu modelu',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Switch(
                        value: state.carCardInCatalog,
                        onChanged: (v) => cubit.toggleCarCard(enabled: v),
                      ),
                    ],
                  ),
                  // Sens samego trybu mock stoi w `AgentBanner` na górze ekranu.
                  // Tutaj zostaje wyłącznie powód, dla którego nie ma liczb:
                  // atrapa nie buduje system promptu, więc nie ma czego mierzyć.
                  if (cubit.isMock)
                    Text(
                      'Diagnostyka promptu niedostępna w trybie mock.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      'prompt: ${diagnostics.length} zn. · zawiera "CarCard": '
                      '${diagnostics.mentionsCarCard ? 'TAK' : 'NIE'} '
                      '· ${cubit.agentLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  if (state.hasResult) ...[
                    vGap8,
                    Row(
                      children: [
                        _Verdict(
                          used: state.carCardUsed,
                          available: state.carCardInCatalog,
                        ),
                        hGap8,
                        Expanded(
                          child: Text(
                            '{${(state.lastComponents.toList()..sort()).join(', ')}}',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Trzy różne rzeczy, nie dwie. „Model nie użył, bo nie chciał" i „model nie
/// mógł, bo widgetu nie było w jego katalogu" wyglądają na ekranie tak samo,
/// a znaczą coś zupełnie innego — więc werdykt musi je rozróżniać sam.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.used, required this.available});

  final bool used;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    final (label, bg, fg) = switch ((available, used)) {
      (true, true) => (
        'CarCard użyty',
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      (true, false) => (
        'miał CarCard, nie użył',
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      (false, false) => (
        'bez CarCard — generyki',
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      // Nie powinno wystąpić: prompt nie zna widgetu, a model go użył.
      // Zwykle znaczy, że przycięty został tylko renderer, nie prompt.
      (false, true) => (
        'ALARM: użyty spoza katalogu',
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
    };

    return Container(
      padding: hPadding8 + vPadding2,
      decoration: BoxDecoration(color: bg, borderRadius: borderRadiusM),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
