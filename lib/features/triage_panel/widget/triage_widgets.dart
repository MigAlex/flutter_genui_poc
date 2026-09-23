/// Sześć klocków paska + siódmy do zakazywania — **zwykłe widgety Flutter,
/// zero genui**.
///
/// Trzymane w jednym pliku świadomie: to jest jedna rodzina wizualna nad
/// wspólnym `TriageBlock`, a nie sześć niezależnych komponentów. Most do genui
/// (nazwa + schemat + builder) żyje osobno w `lib/genui_catalog/triage_items.dart`,
/// dzięki czemu każdy z nich testuje się `pumpWidget`-em bez parsera protokołu.
///
/// W realnym wdrożeniu to **nie byłyby nowe widgety** — opakowałbyś w
/// `CatalogItem` te, które karta zamówienia już ma. Tu powstają od zera tylko
/// dlatego, że POC nie ma prawdziwej karty zamówienia sprzed genui.
library;

import 'package:flutter/material.dart';

import '../../../commons/extensions/build_context_ext.dart';
import '../../../commons/resources/app_sizes.dart';
import '../model/triage_action.dart';
import 'triage_block.dart';

class ShipmentTracker extends StatelessWidget {
  const ShipmentTracker({
    required this.carrier,
    required this.lastScan,
    required this.daysStuck,
    required this.status,
    super.key,
  });

  final String carrier;
  final String lastScan;
  final int daysStuck;
  final String status;

  @override
  Widget build(BuildContext context) {
    return TriageBlock(
      icon: Icons.local_shipping_outlined,
      title: 'Przesyłka · $carrier',
      badge: daysStuck > 0 ? '$daysStuck dni bez zmiany' : status,
      tone: daysStuck >= 3 ? TriageTone.danger : TriageTone.neutral,
      lines: [
        'Ostatni skan: $lastScan',
        if (daysStuck > 0) 'Status: $status — brak ruchu od $daysStuck dni',
      ],
    );
  }
}

class PaymentBlock extends StatelessWidget {
  const PaymentBlock({
    required this.method,
    required this.status,
    required this.amountPln,
    this.failureReason,
    super.key,
  });

  final String method;
  final String status;
  final int amountPln;
  final String? failureReason;

  @override
  Widget build(BuildContext context) {
    final failed = failureReason != null;

    return TriageBlock(
      icon: Icons.credit_card_outlined,
      title: 'Płatność · $method',
      badge: '$amountPln zł',
      tone: failed ? TriageTone.danger : TriageTone.neutral,
      lines: [
        'Status: $status',
        if (failureReason case final reason?) 'Powód: $reason',
      ],
    );
  }
}

class ReturnPolicyBlock extends StatelessWidget {
  const ReturnPolicyBlock({
    required this.daysSince,
    required this.windowDays,
    required this.eligible,
    required this.exceptionAvailable,
    super.key,
  });

  final int daysSince;
  final int windowDays;
  final bool eligible;
  final bool exceptionAvailable;

  @override
  Widget build(BuildContext context) {
    return TriageBlock(
      icon: Icons.assignment_return_outlined,
      title: 'Zwrot',
      badge: eligible ? 'w terminie' : '${daysSince - windowDays} dni po terminie',
      tone: eligible ? TriageTone.good : TriageTone.warning,
      lines: [
        'Zgłoszony $daysSince dni po doręczeniu, okno to $windowDays dni.',
        if (!eligible && exceptionAvailable)
          'Wyjątek dostępny — decyzję podejmuje konsultant, nie system.',
      ],
    );
  }
}

class CreditLimitBanner extends StatelessWidget {
  const CreditLimitBanner({
    required this.limitPln,
    required this.usedPln,
    required this.overByPln,
    required this.blockedOrders,
    super.key,
  });

  final int limitPln;
  final int usedPln;
  final int overByPln;
  final int blockedOrders;

  @override
  Widget build(BuildContext context) {
    return TriageBlock(
      icon: Icons.account_balance_outlined,
      title: 'Limit kupiecki przekroczony',
      badge: '+$overByPln zł',
      tone: TriageTone.danger,
      lines: [
        'Limit $limitPln zł, wykorzystane $usedPln zł.',
        'Zamówienia wstrzymane: $blockedOrders.',
      ],
    );
  }
}

class CustomerProfileBadge extends StatelessWidget {
  const CustomerProfileBadge({
    required this.tier,
    required this.sinceYears,
    required this.openComplaints,
    super.key,
  });

  final String tier;
  final int sinceYears;
  final int openComplaints;

  @override
  Widget build(BuildContext context) {
    return TriageBlock(
      icon: Icons.person_outline,
      title: 'Klient · $tier',
      badge: '$sinceYears lat',
      tone: openComplaints > 0 ? TriageTone.warning : TriageTone.good,
      lines: [
        if (openComplaints > 0)
          'Otwarte reklamacje: $openComplaints'
        else
          'Bez otwartych reklamacji.',
      ],
    );
  }
}

/// Jedyny obowiązkowy klocek. Pasek bez akcji nie skraca rozmowy — informuje.
///
/// **Model rysuje przycisk, nie wykonuje akcji.** Kliknięcie idzie do hosta
/// przez [TriageActionBus] i **nie kosztuje tury modelu** (patrz komentarz przy
/// magistrali) — to jest ta liczba, którą pokazuje licznik na pasku
/// laboratoryjnym.
class ActionRow extends StatelessWidget {
  const ActionRow({required this.actions, required this.onAction, super.key});

  final List<TriageAction> actions;
  final ValueChanged<TriageAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: bPadding8,
      child: Wrap(
        spacing: AppSizes.p8,
        runSpacing: AppSizes.p8,
        children: [
          for (final action in actions.take(3))
            FilledButton.tonal(
              onPressed: () => onAction(action),
              child: Text(action.label),
            ),
        ],
      ),
    );
  }
}

/// Istnieje po to, żeby dało się go **zakazać**. W windykacji albo przy
/// przekroczonym limicie obecność tego komponentu na pasku odrzuca całą
/// powierzchnię — reguła stanu, nie wycięcie widgetu z katalogu.
class OfferCard extends StatelessWidget {
  const OfferCard({
    required this.campaign,
    required this.discount,
    required this.validUntil,
    super.key,
  });

  final String campaign;
  final String discount;
  final String validUntil;

  @override
  Widget build(BuildContext context) {
    return TriageBlock(
      icon: Icons.local_offer_outlined,
      title: 'Oferta · $campaign',
      badge: discount,
      tone: TriageTone.good,
      lines: ['Ważna do $validUntil.'],
    );
  }
}

/// Nagłówek „karta zamówienia" i pojedynczy wiersz sekcji — statyczna część
/// ekranu, ta sama, którą konsultant miał przed wdrożeniem genui.
class OrderSection extends StatelessWidget {
  const OrderSection({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: vPadding6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
