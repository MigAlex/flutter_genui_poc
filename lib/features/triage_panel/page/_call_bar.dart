part of 'triage_panel_page.dart';

/// Cztery „telefony przychodzące" zamiast prawdziwej telefonii.
///
/// W realu numer dzwoniącego łączy się z zamówieniem **zanim konsultant
/// odbierze** — i to jest cały budżet czasu, jaki ma model: te 1–2 sekundy,
/// w których pada „dzień dobry".
class _CallBar extends StatelessWidget {
  const _CallBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriagePanelCubit>();
    final theme = context.theme;

    return BlocBuilder<TriagePanelCubit, TriagePanelState>(
      buildWhen: (prev, curr) =>
          prev.activeCase != curr.activeCase || prev.isWaiting != curr.isWaiting,
      builder: (context, state) {
        final active = state.activeCase;

        return Padding(
          padding: hPadding12 + vPadding8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                active == null
                    ? 'Telefon przychodzący — wybierz rozmowę'
                    : 'Rozmowa: ${active.orderNumber} · ${active.customerName}',
                style: theme.textTheme.labelLarge,
              ),
              vGap8,
              // Przewijany poziomo, nie zawijany: cztery telefony plus
              // „sytuacja się zmieniła" zawijały się na telefonie do trzech
              // rzędów i zjadały miejsce paskowi, czyli temu, po co ten ekran
              // istnieje.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: AppSizes.p8,
                  children: [
                    for (final order in SupportCases.all)
                      ActionChip(
                        avatar: Icon(
                          order.id == active?.id
                              ? Icons.phone_in_talk
                              : Icons.phone_outlined,
                          size: 16,
                        ),
                        label: Text(order.callReason),
                        onPressed: state.isWaiting
                            ? null
                            : () => cubit.answerCall(order),
                      ),
                    if (active != null)
                      ActionChip(
                        avatar: const Icon(Icons.refresh, size: 16),
                        // Ta sama powierzchnia, nowy opis sytuacji — pasek
                        // przebudowuje się w miejscu, historia nie narasta.
                        label: const Text('Sytuacja się zmieniła'),
                        onPressed: state.isWaiting
                            ? null
                            : () => cubit.refreshStrip(active),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
