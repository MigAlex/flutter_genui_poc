import 'dart:convert';
import '../commons/logging/token_tally.dart';

import 'package:genui/genui.dart';

import '../commons/a2ui/a2ui_sink.dart';
import '../features/triage_panel/model/support_case.dart';
import '../genui_catalog/triage_catalog.dart';
import 'triage_agent.dart';

/// Atrapa paska: odgrywa **zaprojektowany** wynik dla każdego z czterech
/// scenariuszy demo.
///
/// Dyscyplina jak w `MockAdvisorAgent`: atrapa **nie udaje decyzji modelu**.
/// Czyta `CASE-ID` z opisu stanu i rysuje układ, który sam zaprojektowałeś —
/// dowodzi więc renderera, katalogu, kontraktu i czterech awarii, ale ani
/// przez chwilę nie dowodzi, że model wybierze te same komponenty.
///
/// **Kontraktu nie łamie z własnej woli.** Karta zadania przewidywała jeden
/// scenariusz atrapy celowo psujący kontrakt; robi to jednak lepiej
/// przechwytywacz awarii (`TriageFailure.missingRequired`), bo działa tak samo
/// na żywym Haiku. Atrapa łamiąca kontrakt zawsze dawałaby demonstrację,
/// której na modelu nie da się powtórzyć.
class MockTriageAgent implements TriageAgent {
  var _revision = 0;

  @override
  String get label => 'Mock (bez klucza API)';

  @override
  bool get isMock => true;

  @override
  int get promptLength => 0;

  @override
  TokenTally get tally => const TokenTally();

  @override
  void bootstrapStrip(A2uiSink sink) => sink.addChunk(stripBootstrapChunk());

  @override
  void reset() {}

  @override
  Future<void> respond(ChatMessage message, A2uiSink sink) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _revision++;

    final order = _caseFrom(message.text);
    final components = _strip(order);

    sink.addChunk(
      jsonEncode({
        'version': 'v0.9',
        'updateComponents': {
          'surfaceId': triageStripSurfaceId,
          'components': components,
        },
      }),
    );
  }

  /// Odczyt scenariusza z opisu stanu. Świadomie po znaczniku, a nie po treści:
  /// atrapa **nie próbuje rozumieć** stanu zamówienia — od tego jest model.
  SupportCase _caseFrom(String description) {
    final id = RegExp(r'CASE-ID:\s*(\w+)').firstMatch(description)?.group(1);
    return SupportCases.all.firstWhere(
      (order) => order.id == id,
      orElse: () => SupportCases.stuckShipment,
    );
  }

  List<Map<String, Object?>> _strip(SupportCase order) {
    final blocks = <Map<String, Object?>>[
      if (order.daysWithoutScan > 0)
        {
          'id': 'shipment',
          'component': TriageComponents.shipmentTracker,
          'carrier': order.carrier,
          'lastScan': order.lastScan,
          'daysStuck': order.daysWithoutScan,
          'status': order.shipmentStatus,
        },
      if (order.overCreditLimit)
        {
          'id': 'credit',
          'component': TriageComponents.creditLimitBanner,
          'limitPln': order.creditLimitPln,
          'usedPln': order.creditUsedPln,
          'overByPln': order.creditOverByPln,
          'blockedOrders': order.blockedOrders,
        },
      if (order.paymentFailureReason != null)
        {
          'id': 'payment',
          'component': TriageComponents.paymentBlock,
          'method': order.paymentMethod,
          'status': order.paymentStatus,
          'amountPln': order.totalPln,
          'failureReason': order.paymentFailureReason,
        },
      if (order.returnRequested)
        {
          'id': 'return',
          'component': TriageComponents.returnPolicyBlock,
          'daysSince': order.returnDaysSince,
          'windowDays': order.returnWindowDays,
          'eligible': !order.returnAfterWindow,
          'exceptionAvailable': order.tier == CustomerTier.vip,
        },
      if (order.tier == CustomerTier.vip || order.openComplaints > 0)
        {
          'id': 'profile',
          'component': TriageComponents.customerProfileBadge,
          'tier': order.tier.label,
          'sinceYears': order.customerSinceYears,
          'openComplaints': order.openComplaints,
        },
    ];

    // Reguła „max 3" obowiązuje tak samo atrapę — inaczej pasek atrapy
    // wyglądałby inaczej niż pasek modelu i demo pokazywałoby dwa różne UI.
    // `ActionRow` jest ostatni i obowiązkowy, więc na sygnały zostają dwa
    // miejsca.
    final chosen = blocks.take(2).toList();
    final ids = [for (final block in chosen) block['id'] as String, 'actions'];

    return [
      {
        'id': 'root',
        'component': 'Column',
        'children': ids,
        'align': 'start',
      },
      ...chosen,
      {
        'id': 'actions',
        'component': TriageComponents.actionRow,
        'actions': [
          for (final action in order.availableActions.take(3))
            {'id': action.id, 'label': action.label},
        ],
      },
    ];
  }

  /// Numer odświeżenia — widać po nim, że pasek **przebudował się w miejscu**,
  /// a nie że nic się nie stało.
  int get revision => _revision;
}
