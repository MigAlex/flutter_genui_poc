part of 'triage_panel_page.dart';

/// Karta zamówienia: **piętnaście sekcji zwykłego Fluttera, zero AI**.
///
/// Nie jest tłem dla paska — jest powodem, dla którego pasek wolno wpuścić na
/// produkcję. Każdy fakt, który model mógłby przemilczeć, jest tutaj i tak.
/// Ta proporcja (jeden pasek nad kompletem danych) to sedno wzorca; odwrotna
/// — model rysuje ekran, dane są w nim — to zupełnie inna ocena ryzyka.
class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TriagePanelCubit, TriagePanelState>(
      buildWhen: (prev, curr) => prev.activeCase != curr.activeCase,
      builder: (context, state) {
        final order = state.activeCase;
        if (order == null) return emptyWidgetShrink;

        return Card(
          margin: vPadding8,
          child: Padding(
            padding: allPadding12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Zamówienie ${order.orderNumber}',
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      'zwykły Flutter · bez AI',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                for (final (label, value) in _sections(order))
                  OrderSection(label: label, value: value),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Piętnaście wierszy — dokładnie ten sam zestaw co na slajdzie
  /// materiałami prezentacyjnymi (poza repo), żeby demo i slajdy mówiły to samo.
  List<(String, String)> _sections(SupportCase order) => [
    ('Status', order.shipmentStatus),
    ('Klient', order.customerName),
    ('Adres dostawy', order.deliveryCity),
    ('Adres faktury', 'jak dostawy'),
    ('Pozycje', '${order.itemCount}'),
    ('Wartość', '${order.totalPln} zł'),
    (
      'Płatność',
      '${order.paymentMethod} · ${order.paymentStatus}',
    ),
    (
      'Limit kupiecki',
      order.isBusiness
          ? '${order.creditUsedPln} / ${order.creditLimitPln} zł'
          : 'nie dotyczy',
    ),
    ('Przesyłka', '${order.carrier} ${order.trackingNumber}'),
    ('Historia statusów', '${order.statusHistoryCount} wpisów'),
    (
      'Zwroty',
      order.returnsCount == 0 ? 'brak' : '${order.returnsCount}',
    ),
    (
      'Reklamacje',
      order.openComplaints == 0 ? 'brak' : '${order.openComplaints} otwarte',
    ),
    ('Korekty', order.corrections == 0 ? 'brak' : '${order.corrections}'),
    ('Lojalnościowy', order.tier == CustomerTier.vip ? 'VIP' : 'nie dotyczy'),
    ('Notatki BOK', '${order.notesCount}'),
  ];
}
