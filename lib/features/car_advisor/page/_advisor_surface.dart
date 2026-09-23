part of 'car_advisor_page.dart';

/// Jedna powierzchnia, przebudowywana w miejscu.
///
/// `Surface` renderujemy dopiero, gdy przyszły komponenty — powierzchnia
/// istnieje od startu (założył ją host), więc bez tego warunku user widziałby
/// pustkę zamiast podpowiedzi „ustaw kryteria".
class _AdvisorSurface extends StatelessWidget {
  const _AdvisorSurface();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdvisorCubit>();

    return BlocBuilder<CarAdvisorCubit, CarAdvisorState>(
      builder: (context, state) {
        final surfaceId = state.panelSurfaceId;

        return ListView(
          padding: hPadding12,
          children: [
            if (state.error != null) _AdvisorNotice.error(state.error!),
            // Na tym ekranie proza to objaw: dyscyplina panelu mówi
            // „zawsze updateComponents".
            if (state.latestText != null)
              _AdvisorNotice.prose(state.latestText!),
            if (state.hasContent && surfaceId != null)
              Surface(surfaceContext: cubit.contextFor(surfaceId))
            else if (!state.isWaiting)
              const _AdvisorHint(),
            if (state.isWaiting) ...[
              vGap12,
              const Center(child: CircularProgressIndicator()),
            ],
            vGap12,
          ],
        );
      },
    );
  }
}

class _AdvisorHint extends StatelessWidget {
  const _AdvisorHint();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Padding(
      padding: allPadding16,
      child: Column(
        children: [
          Icon(Icons.tune, size: 40, color: scheme.onSurfaceVariant),
          vGap12,
          Text(
            'Ustaw kryteria i kliknij „Dobierz auta".\n'
            'Prompt powstaje ze stanu suwaków, nie z tego, co wpiszesz.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorNotice extends StatelessWidget {
  const _AdvisorNotice.error(this.message) : isError = true;
  const _AdvisorNotice.prose(this.message) : isError = false;

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Card(
      color: isError ? scheme.errorContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: allPadding12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isError
                  ? 'Błąd'
                  : 'Model odpowiedział prozą zamiast przebudować panel',
              style: context.textTheme.labelMedium,
            ),
            vGap8,
            SelectableText(message, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
