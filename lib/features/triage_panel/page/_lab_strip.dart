part of 'triage_panel_page.dart';

/// Pasek laboratoryjny — sterowanie eksperymentem ma być **widoczne**, bo to
/// jest POC, a nie makieta produktu.
///
/// Trzy rzeczy naraz, bo dopiero razem coś znaczą:
/// **którą awarię wymuszam** · **czy host egzekwuje kontrakt** · **ile to
/// kosztowało tur modelu wobec kliknięć konsultanta**.
class _LabStrip extends StatelessWidget {
  const _LabStrip();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriagePanelCubit>();
    final theme = context.theme;
    final scheme = theme.colorScheme;

    return BlocBuilder<TriagePanelCubit, TriagePanelState>(
      builder: (context, state) {
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
                        flex: 2,
                        child: Text(
                          'Wymuś awarię',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      // `isExpanded` + `Expanded`, bo najdłuższa etykieta
                      // („brak wymaganego komponentu") wyznacza szerokość
                      // wewnętrzną dropdownu i na 375 dp wychodzi poza ekran.
                      Expanded(
                        flex: 3,
                        child: DropdownButton<TriageFailure>(
                          value: state.failure,
                          isExpanded: true,
                          onChanged: (value) =>
                              cubit.setFailure(value ?? TriageFailure.none),
                          items: [
                            for (final failure in TriageFailure.values)
                              DropdownMenuItem(
                                value: failure,
                                child: Text(
                                  failure.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reguły hosta (kontrakt powierzchni)',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Switch(
                        value: state.contractEnforced,
                        onChanged: (value) =>
                            cubit.toggleContract(enforced: value),
                      ),
                    ],
                  ),
                  Text(
                    'tury modelu: ${state.modelTurns} · '
                    'kliknięcia konsultanta: ${state.userActions} · '
                    '${cubit.isMock ? 'prompt: n/d (mock)' : 'prompt: ${cubit.promptLength} zn.'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  // Druga połowa tego samego argumentu: obok „ile razy"
                  // stoi „za ile". Atrapa mówi wprost, że nie kosztuje —
                  // zero i „nie dotyczy" to dwie różne informacje.
                  Text(
                    cubit.isMock
                        ? 'tokeny: 0 (atrapa nie woła modelu)'
                        : state.tokens.describe(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (state.diagnosis case final diagnosis?) ...[
                    vGap4,
                    Text(
                      diagnosis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: state.rejected || state.error != null
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  // Bez tego zdania wyłączony kontrakt wygląda jak wyłączona
                  // walidacja „bo tak". Sedno jest odwrotne: przy wyłączonym
                  // kontrakcie brak wymaganego komponentu wygląda dokładnie
                  // tak samo jak jego brak w danych.
                  if (!state.contractEnforced && state.rejected)
                    Text(
                      'Kontrakt wyłączony — powierzchnia poszła na ekran mimo '
                      'złamanej reguły. Właśnie tak wygląda ciche pominięcie.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
