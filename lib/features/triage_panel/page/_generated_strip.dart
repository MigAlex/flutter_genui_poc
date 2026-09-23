part of 'triage_panel_page.dart';

/// Górna warstwa ekranu: **jedyna rzecz, którą składa model**.
///
/// Wszystko, co może pójść nie tak, kończy się tutaj — i tylko tutaj. Karta
/// zamówienia pod spodem nie zna ani genui, ani stanu tej powierzchni.
class _GeneratedStrip extends StatelessWidget {
  const _GeneratedStrip();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriagePanelCubit>();

    return BlocBuilder<TriagePanelCubit, TriagePanelState>(
      builder: (context, state) {
        final order = state.activeCase;
        if (order == null) return const _CallHint();

        final surfaceId = state.stripSurfaceId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vGap8,
            _StripHeader(state: state),
            vGap8,
            if (state.isWaiting) const _StripSpinner(),
            if (!order.hasSignals && !state.isWaiting)
              const _StripNotice(
                title: 'Bramka przed promptem',
                message:
                    'Zero sygnałów w tym zamówieniu — host nie wysłał requestu. '
                    'To zwykły `if`, nie decyzja modelu.',
              ),
            if (state.latestText case final prose?)
              _StripNotice(
                title: 'Model odpowiedział prozą zamiast A2UI',
                message: prose,
                isError: true,
              ),
            if (state.error case final error?)
              _StripNotice(title: 'Awaria', message: error, isError: true),
            if (state.showGeneratedStrip && surfaceId != null)
              Surface(surfaceContext: cubit.contextFor(surfaceId)),
            if (state.showFallbackStrip) _FallbackStrip(order: order),
          ],
        );
      },
    );
  }
}

/// Pasek zapasowy — deterministyczny, złożony przez **host** ze stanu
/// zamówienia.
///
/// Odrzucona powierzchnia nie może zostawiać pustki: konsultant dostaje
/// uboższą, ale prawdziwą wersję tego samego. To jest różnica między
/// „walidacja hosta" a „walidacja, która psuje ekran".
class _FallbackStrip extends StatelessWidget {
  const _FallbackStrip({required this.order});

  final SupportCase order;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriagePanelCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TriageBlock(
          icon: Icons.shield_outlined,
          title: 'Wersja zapasowa hosta',
          badge: 'bez modelu',
          tone: TriageTone.warning,
          lines: [
            if (order.overCreditLimit)
              'Limit kupiecki przekroczony o ${order.creditOverByPln} zł '
                  '(${order.blockedOrders} wstrzymane zamówienia).',
            if (order.daysWithoutScan > 0)
              'Przesyłka bez skanu od ${order.daysWithoutScan} dni '
                  '(${order.carrier}).',
            if (order.paymentFailureReason case final reason?)
              'Płatność: ${order.paymentStatus} — $reason.',
            if (order.returnRequested)
              'Zwrot zgłoszony ${order.returnDaysSince} dni po doręczeniu '
                  '(okno ${order.returnWindowDays} dni).',
          ],
        ),
        ActionRow(
          actions: order.availableActions,
          onAction: cubit.dispatchAction,
        ),
      ],
    );
  }
}

/// Nagłówek paska: `surfaceId`, liczba komponentów i werdykt kontraktu.
/// To jest miejsce, w którym „cisza w UI" przestaje być cicha.
class _StripHeader extends StatelessWidget {
  const _StripHeader({required this.state});

  final TriagePanelState state;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final scheme = context.colorScheme;
    final verdict = state.verdict;

    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
        hGap4,
        Expanded(
          child: Text(
            'pasek generowany · ${state.stripSurfaceId ?? '—'}'
            '${state.lastComponents.isEmpty ? '' : ' · ${state.lastComponents.length} komponentów'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (verdict != null) _VerdictChip(verdict: verdict),
      ],
    );
  }
}

class _VerdictChip extends StatelessWidget {
  const _VerdictChip({required this.verdict});

  final ContractVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final rejected = verdict is SurfaceRejected;

    return Container(
      padding: hPadding8 + vPadding2,
      decoration: BoxDecoration(
        color: rejected ? scheme.errorContainer : scheme.primaryContainer,
        borderRadius: borderRadiusFull,
      ),
      child: Text(
        switch (verdict) {
          SurfaceAccepted() => 'kontrakt OK',
          SurfaceRejected(:final rule) => rule,
        },
        style: context.textTheme.labelSmall?.copyWith(
          color: rejected ? scheme.onErrorContainer : scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _StripSpinner extends StatelessWidget {
  const _StripSpinner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: vPadding8,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          hGap8,
          Expanded(
            child: Text(
              'Model składa pasek. Karta zamówienia poniżej już jest.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StripNotice extends StatelessWidget {
  const _StripNotice({
    required this.title,
    required this.message,
    this.isError = false,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Card(
      margin: bPadding8,
      color: isError ? scheme.errorContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: allPadding12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.labelMedium),
            vGap4,
            SelectableText(message, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CallHint extends StatelessWidget {
  const _CallHint();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Padding(
      padding: allPadding24,
      child: Column(
        children: [
          Icon(Icons.support_agent, size: 40, color: scheme.onSurfaceVariant),
          vGap12,
          Text(
            'Odbierz telefon powyżej.\n'
            'Promptem jest stan zamówienia — konsultant nic nie pisze.',
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
