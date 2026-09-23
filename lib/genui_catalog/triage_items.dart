import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../features/triage_panel/model/triage_action.dart';
import '../features/triage_panel/widget/triage_widgets.dart';

/// Nazwy komponentów w jednym miejscu — używa ich katalog, kontrakt hosta,
/// atrapa i testy. Literówka w którymkolwiek z tych miejsc daje **pustą
/// powierzchnię bez komunikatu**, więc gołych stringów tu nie ma.
abstract final class TriageComponents {
  static const shipmentTracker = 'ShipmentTracker';
  static const paymentBlock = 'PaymentBlock';
  static const returnPolicyBlock = 'ReturnPolicyBlock';
  static const creditLimitBanner = 'CreditLimitBanner';
  static const customerProfileBadge = 'CustomerProfileBadge';
  static const actionRow = 'ActionRow';
  static const offerCard = 'OfferCard';

  /// Komponenty domenowe (bez `Column`/`Text`, które są rusztowaniem).
  static const domain = {
    shipmentTracker,
    paymentBlock,
    returnPolicyBlock,
    creditLimitBanner,
    customerProfileBadge,
    actionRow,
    offerCard,
  };
}

int _asInt(Object? value) => switch (value) {
  final int v => v,
  final double v => v.round(),
  final String v => int.tryParse(v) ?? 0,
  _ => 0,
};

bool _asBool(Object? value) => switch (value) {
  final bool v => v,
  'true' => true,
  _ => false,
};

String _asString(Object? value) => value is String ? value : '';

/// Siedem mostów `widget ↔ genui`. Każdy to **nazwa + schemat + builder** —
/// żadnego rejestru typów po stronie paczki, `CatalogItem` JEST tym mapowaniem.
///
/// `dataSchema` mówi **co** komponent przyjmuje. **Kiedy** go użyć mówią
/// `systemPromptFragments` katalogu (`triage_catalog.dart`) — sam schemat daje
/// widget, którego model nie tknie.
List<CatalogItem> triageItems(TriageActionBus bus) => [
  CatalogItem(
    name: TriageComponents.shipmentTracker,
    dataSchema: S.object(
      description:
          'Shipment status block. Use when the parcel is in transit, stuck, '
          'or when the customer questions delivery.',
      properties: {
        'carrier': S.string(description: 'Carrier name, e.g. "InPost".'),
        'lastScan': S.string(
          description: 'Last scan in Polish, e.g. "sortownia Łódź, 12.08".',
        ),
        'daysStuck': S.integer(
          description: 'Days without a new scan. 0 when moving normally.',
        ),
        'status': S.string(
          description: 'Short status in Polish, e.g. "w drodze".',
        ),
      },
      required: ['carrier', 'lastScan', 'daysStuck', 'status'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return ShipmentTracker(
        carrier: _asString(data['carrier']),
        lastScan: _asString(data['lastScan']),
        daysStuck: _asInt(data['daysStuck']),
        status: _asString(data['status']),
      );
    },
  ),
  CatalogItem(
    name: TriageComponents.paymentBlock,
    dataSchema: S.object(
      description:
          'Payment state block. Use when a payment failed, is overdue, or '
          'a refund is in progress.',
      properties: {
        'method': S.string(description: 'Payment method, e.g. "BLIK".'),
        'status': S.string(description: 'Status in Polish, e.g. "odrzucona".'),
        'amountPln': S.integer(description: 'Amount in PLN, plain integer.'),
        'failureReason': S.string(
          description: 'Short reason of the failure, Polish. Omit when paid.',
        ),
      },
      required: ['method', 'status', 'amountPln'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return PaymentBlock(
        method: _asString(data['method']),
        status: _asString(data['status']),
        amountPln: _asInt(data['amountPln']),
        failureReason: data['failureReason'] as String?,
      );
    },
  ),
  CatalogItem(
    name: TriageComponents.returnPolicyBlock,
    dataSchema: S.object(
      description:
          'Return window block. Use when the customer asks about a return.',
      properties: {
        'daysSince': S.integer(description: 'Days since delivery.'),
        'windowDays': S.integer(description: 'Return window length in days.'),
        'eligible': S.boolean(
          description: 'True when still inside the return window.',
        ),
        'exceptionAvailable': S.boolean(
          description: 'True when the consultant may grant an exception.',
        ),
      },
      required: ['daysSince', 'windowDays', 'eligible'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return ReturnPolicyBlock(
        daysSince: _asInt(data['daysSince']),
        windowDays: _asInt(data['windowDays']),
        eligible: _asBool(data['eligible']),
        exceptionAvailable: _asBool(data['exceptionAvailable']),
      );
    },
  ),
  CatalogItem(
    name: TriageComponents.creditLimitBanner,
    dataSchema: S.object(
      description:
          'B2B credit limit banner. MANDATORY whenever the account is over '
          'its credit limit — the consultant must not miss it.',
      properties: {
        'limitPln': S.integer(description: 'Credit limit in PLN.'),
        'usedPln': S.integer(description: 'Used amount in PLN.'),
        'overByPln': S.integer(description: 'How much over the limit, PLN.'),
        'blockedOrders': S.integer(description: 'Number of blocked orders.'),
      },
      required: ['limitPln', 'usedPln', 'overByPln', 'blockedOrders'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return CreditLimitBanner(
        limitPln: _asInt(data['limitPln']),
        usedPln: _asInt(data['usedPln']),
        overByPln: _asInt(data['overByPln']),
        blockedOrders: _asInt(data['blockedOrders']),
      );
    },
  ),
  CatalogItem(
    name: TriageComponents.customerProfileBadge,
    dataSchema: S.object(
      description:
          'Customer context badge. Use for VIP customers or when there are '
          'open complaints that change how the call should be handled.',
      properties: {
        'tier': S.string(description: 'Tier label in Polish, e.g. "VIP".'),
        'sinceYears': S.integer(description: 'Years as a customer.'),
        'openComplaints': S.integer(description: 'Open complaints count.'),
      },
      required: ['tier', 'sinceYears', 'openComplaints'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return CustomerProfileBadge(
        tier: _asString(data['tier']),
        sinceYears: _asInt(data['sinceYears']),
        openComplaints: _asInt(data['openComplaints']),
      );
    },
  ),
  CatalogItem(
    name: TriageComponents.actionRow,
    dataSchema: S.object(
      description:
          'Row of up to three actions the consultant can take right now. '
          'Always the last component of the strip.',
      properties: {
        'actions': S.list(
          description:
              'Actions to render. Use ONLY ids from the available actions '
              'listed in the order state.',
          maxItems: 3,
          items: S.object(
            properties: {
              'id': S.string(description: 'Action id from the order state.'),
              'label': S.string(description: 'Button label in Polish.'),
            },
            required: ['id', 'label'],
          ),
        ),
      },
      required: ['actions'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      final raw = data['actions'];
      final actions = <TriageAction>[
        if (raw is List)
          for (final item in raw)
            if (item is Map<String, Object?>)
              (id: _asString(item['id']), label: _asString(item['label'])),
      ];

      // Klik NIE idzie przez `UserActionEvent` — poszedłby wtedy do
      // `Conversation` i kosztował pełną turę modelu. Tu wykonanie należy do
      // hosta, więc akcja leci własną szyną. Szczegóły: `TriageActionBus`.
      return ActionRow(actions: actions, onAction: bus.dispatch);
    },
  ),
  CatalogItem(
    name: TriageComponents.offerCard,
    dataSchema: S.object(
      description:
          'Promotional offer card. Only for customers whose account is in '
          'good standing.',
      properties: {
        'campaign': S.string(description: 'Campaign name.'),
        'discount': S.string(description: 'Discount, e.g. "-15%".'),
        'validUntil': S.string(description: 'Valid-until date, e.g. "31.08".'),
      },
      required: ['campaign', 'discount', 'validUntil'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return OfferCard(
        campaign: _asString(data['campaign']),
        discount: _asString(data['discount']),
        validUntil: _asString(data['validUntil']),
      );
    },
  ),
];
