part of 'car_advisor_page.dart';

/// Kontrolki = prompt. Każda zmiana modyfikuje stan, ale **nie wysyła**
/// requestu — wysyłka jest jawnym kliknięciem, bo każdy request to realny
/// koszt tokenów, a suwak potrafi wygenerować ich dziesiątki na sekundę.
///
/// Panel **zwija się po pierwszym wyniku**. Rozwinięty zajmuje ~2/3 ekranu
/// telefonu, więc wygenerowana powierzchnia — czyli to, po co ten ekran
/// istnieje — oglądało się przez szczelinę. Kryteria ustawia się raz, wyniki
/// czyta się długo; miejsce należy do tego drugiego.
class _CriteriaPanel extends StatelessWidget {
  const _CriteriaPanel();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdvisorCubit>();

    return Card(
      margin: allPadding12,
      child: Padding(
        padding: allPadding12,
        child: BlocBuilder<CarAdvisorCubit, CarAdvisorState>(
          buildWhen: (prev, curr) =>
              prev.criteria != curr.criteria ||
              prev.isWaiting != curr.isWaiting ||
              prev.criteriaCollapsed != curr.criteriaCollapsed,
          builder: (context, state) {
            final criteria = state.criteria;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CriteriaHeader(
                  criteria: criteria,
                  collapsed: state.criteriaCollapsed,
                  onToggle: () => cubit.toggleCriteria(
                    collapsed: !state.criteriaCollapsed,
                  ),
                ),
                if (!state.criteriaCollapsed) ...[
                  vGap8,
                  _SliderRow(
                    label: 'Budżet',
                    value: '${criteria.budgetPln ~/ 1000} tys. zł',
                    sliderValue: criteria.budgetPln.toDouble(),
                    min: 20000,
                    max: 200000,
                    divisions: 36,
                    onChanged: (v) => cubit.setBudget(v.round()),
                  ),
                  _SliderRow(
                    label: 'Przebieg do',
                    value: '${criteria.maxMileageKm ~/ 1000} tys. km',
                    sliderValue: criteria.maxMileageKm.toDouble(),
                    min: 20000,
                    max: 300000,
                    divisions: 28,
                    onChanged: (v) => cubit.setMaxMileage(v.round()),
                  ),
                  vGap8,
                  Wrap(
                    spacing: AppSizes.p8,
                    children: [
                      for (final body in CarBody.values)
                        ChoiceChip(
                          label: Text(body.label),
                          selected: criteria.body == body,
                          onSelected: (_) => cubit.setBody(body),
                        ),
                    ],
                  ),
                  vGap8,
                  Wrap(
                    spacing: AppSizes.p8,
                    children: [
                      ChoiceChip(
                        label: const Text('dowolne'),
                        selected: criteria.fuel == null,
                        onSelected: (_) => cubit.setFuel(null),
                      ),
                      for (final fuel in CarFuel.values)
                        ChoiceChip(
                          label: Text(fuel.label),
                          selected: criteria.fuel == fuel,
                          onSelected: (_) => cubit.setFuel(fuel),
                        ),
                    ],
                  ),
                ],
                vGap12,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isWaiting ? null : cubit.requestAdvice,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      state.isWaiting ? 'Model buduje panel…' : 'Dobierz auta',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Nagłówek panelu: po zwinięciu **musi nieść komplet kryteriów**, bo to one
/// są promptem. Zwinięcie, które ukrywa, co poszło do modelu, zamieniłoby
/// oszczędność miejsca na zgadywanie.
class _CriteriaHeader extends StatelessWidget {
  const _CriteriaHeader({
    required this.criteria,
    required this.collapsed,
    required this.onToggle,
  });

  final AdvisorCriteria criteria;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Row(
      children: [
        Expanded(
          child: collapsed
              ? Text(
                  '${criteria.budgetPln ~/ 1000} tys. zł · '
                  'do ${criteria.maxMileageKm ~/ 1000} tys. km · '
                  '${criteria.body.label} · ${criteria.fuel?.label ?? 'dowolne'}',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                )
              : Text('Kryteria', style: theme.textTheme.labelLarge),
        ),
        IconButton(
          onPressed: onToggle,
          icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less),
          tooltip: collapsed ? 'Pokaż kryteria' : 'Zwiń kryteria',
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.sliderValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String value;
  final double sliderValue;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: theme.textTheme.labelLarge),
        ),
        Expanded(
          child: Slider(
            value: sliderValue.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 84,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
