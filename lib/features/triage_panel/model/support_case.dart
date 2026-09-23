import 'package:freezed_annotation/freezed_annotation.dart';

import 'triage_action.dart';

part 'support_case.freezed.dart';

enum CustomerTier {
  fresh('nowy'),
  regular('stały'),
  vip('VIP'),
  business('B2B');

  const CustomerTier(this.label);

  final String label;
}

/// Stan jednego zamówienia w chwili, gdy dzwoni telefon — **to jest prompt**.
///
/// Konsultant nic nie pisze. Host bierze stan, który i tak ma na ekranie,
/// i zamienia go na opis dla modelu ([describeForModel]). Model nie liczy
/// limitu, nie ocenia ryzyka i nie decyduje o wyjątku — **szereguje fakty,
/// które i tak są prawdziwe**.
///
/// Wszystkie pola mają wartości domyślne, żeby scenariusz opisywało się przez
/// to, co go wyróżnia (cztery-pięć linii), a nie przez dwadzieścia pól z zerami.
@freezed
abstract class SupportCase with _$SupportCase {
  const factory SupportCase({
    required String id,

    /// Krótkie „po co on dzwoni" — etykieta przycisku telefonu w demie.
    /// Sam konsultant tego nie wie; my wiemy, bo to POC.
    required String callReason,
    required String orderNumber,
    required String customerName,
    @Default(CustomerTier.regular) CustomerTier tier,
    @Default(2) int customerSinceYears,
    @Default('Lublin') String deliveryCity,
    @Default(3) int itemCount,
    @Default(489) int totalPln,
    @Default('BLIK') String paymentMethod,
    @Default('opłacone') String paymentStatus,
    String? paymentFailureReason,
    @Default('InPost') String carrier,
    @Default('w doręczeniu') String shipmentStatus,
    @Default('6304 1129 8877') String trackingNumber,
    @Default('sortownia Łódź, 12.08') String lastScan,
    @Default(0) int daysWithoutScan,
    @Default(7) int statusHistoryCount,
    @Default(0) int openComplaints,
    @Default(0) int returnsCount,
    @Default(0) int corrections,
    @Default(0) int notesCount,

    /// Zwrot: czy klient go zgłasza, ile dni minęło i jakie jest okno.
    @Default(false) bool returnRequested,
    @Default(0) int returnDaysSince,
    @Default(14) int returnWindowDays,

    /// Limit kupiecki — dotyczy wyłącznie [CustomerTier.business].
    @Default(0) int creditLimitPln,
    @Default(0) int creditUsedPln,
    @Default(0) int blockedOrders,

    /// Windykacja — jedyny powód, dla którego `OfferCard` bywa zakazany.
    @Default(false) bool inCollections,

    /// Akcje, które host potrafi wykonać dla tego zamówienia. Model dostaje je
    /// w prompcie i może je **narysować**; wykonanie należy do hosta.
    @Default(<TriageAction>[]) List<TriageAction> availableActions,
  }) = _SupportCase;

  const SupportCase._();

  bool get isBusiness => tier == CustomerTier.business;

  int get creditOverByPln =>
      creditUsedPln > creditLimitPln ? creditUsedPln - creditLimitPln : 0;

  /// Reguła biznesowa, nie ocena modelu: przekroczony limit **musi** być
  /// widoczny na pasku.
  bool get overCreditLimit => isBusiness && creditOverByPln > 0;

  bool get returnAfterWindow => returnRequested && returnDaysSince > returnWindowDays;

  /// Kiedy oferta rabatowa jest niedopuszczalna. Świadomie po stronie hosta:
  /// to jest zdanie z regulaminu, a nie kwestia gustu modelu.
  bool get offerForbidden => inCollections || overCreditLimit;

  /// Czy w ogóle jest co szeregować. Brak sygnałów → **brak requestu**;
  /// zwykły `if`, który wycina większość ruchu z rachunku za tokeny.
  bool get hasSignals =>
      daysWithoutScan > 0 ||
      paymentFailureReason != null ||
      returnRequested ||
      overCreditLimit ||
      openComplaints > 0 ||
      inCollections;

  /// Opis stanu dla modelu.
  ///
  /// Po angielsku, jak reszta system promptu A2UI — mieszanie języków potrafi
  /// przełączyć model na polski także w polach technicznych. Treść dla
  /// konsultanta prosimy po polsku osobnym zdaniem.
  ///
  /// `CASE-ID` na pierwszej linii jest **dla atrapy**, nie dla modelu: mock
  /// odgrywa zaprojektowany wynik danego scenariusza i musi wiedzieć, który to.
  /// Prawdziwy model ignoruje tę linię tak samo jak każdą inną etykietę.
  String describeForModel() {
    final buffer = StringBuffer()
      ..writeln('CASE-ID: $id')
      ..writeln(
        'ORDER STATE (not a chat message — the consultant did not type this):',
      )
      ..writeln('- order: $orderNumber, $itemCount items, $totalPln PLN')
      ..writeln(
        '- customer: $customerName, tier ${tier.label}, '
        '$customerSinceYears years, open complaints: $openComplaints',
      )
      ..writeln(
        '- payment: $paymentMethod, $paymentStatus'
        '${paymentFailureReason == null ? '' : ' (reason: $paymentFailureReason)'}',
      )
      ..writeln(
        '- shipment: $carrier, $shipmentStatus, last scan $lastScan'
        '${daysWithoutScan > 0 ? ', NO SCAN FOR $daysWithoutScan DAYS' : ''}',
      );

    if (returnRequested) {
      buffer.writeln(
        '- return requested: $returnDaysSince days after delivery, '
        'window is $returnWindowDays days '
        '(${returnAfterWindow ? 'OUTSIDE the window' : 'inside the window'})',
      );
    }
    if (isBusiness) {
      buffer.writeln(
        '- B2B credit: limit $creditLimitPln PLN, used $creditUsedPln PLN'
        '${overCreditLimit ? ', OVER BY $creditOverByPln PLN' : ''}, '
        'blocked orders: $blockedOrders',
      );
    }
    if (inCollections) buffer.writeln('- account is IN DEBT COLLECTION');

    buffer
      ..writeln(
        '- available actions: '
        '${availableActions.map((a) => '${a.id} ("${a.label}")').join(', ')}',
      )
      ..writeln()
      ..write(
        'Rebuild the assist strip for this call. Polish user-facing copy. '
        'At most 3 components — pick the ones that answer "why is this person '
        'calling", most important first.',
      );

    return buffer.toString();
  }
}

/// Cztery scenariusze demo. **Stałe w kodzie, zero sieci** — POC ma pokazywać
/// zachowanie panelu, a nie umieć w bazę zamówień.
///
/// Przypadki 5–12 z karty zadania (priorytet przy limicie 3 komponentów, „czy
/// model umie NIE generować", pokusa `OfferCard`) są świadomie na parkingu:
/// bez pomiaru świeżym agentem per komórka są anegdotą, a pomiar wypadł
/// z zakresu razem z E2E.
abstract final class SupportCases {
  static const stuckShipment = SupportCase(
    id: 'stuck_shipment',
    callReason: 'Paczka stoi 4 dni',
    orderNumber: '84-119277',
    customerName: 'M. Sobczak',
    daysWithoutScan: 4,
    lastScan: 'sortownia Łódź, 12.08',
    shipmentStatus: 'w drodze',
    availableActions: [
      (id: 'carrier_claim', label: 'Reklamuj u przewoźnika'),
      (id: 'reship', label: 'Wyślij ponownie'),
      (id: 'refund', label: 'Zwróć środki'),
    ],
  );

  static const rejectedPayment = SupportCase(
    id: 'rejected_payment',
    callReason: 'Płatność odrzucona',
    orderNumber: '84-119512',
    customerName: 'K. Adamiec',
    tier: CustomerTier.fresh,
    customerSinceYears: 0,
    itemCount: 1,
    totalPln: 1299,
    paymentMethod: 'karta ···4417',
    paymentStatus: 'odrzucona',
    paymentFailureReason: 'do_not_honour (bank odbiorcy)',
    shipmentStatus: 'wstrzymane',
    carrier: '—',
    trackingNumber: '—',
    lastScan: 'brak — zamówienie wstrzymane',
    statusHistoryCount: 3,
    availableActions: [
      (id: 'retry_payment', label: 'Ponów płatność'),
      (id: 'change_method', label: 'Zmień metodę'),
      (id: 'cancel_order', label: 'Anuluj zamówienie'),
    ],
  );

  static const lateReturnVip = SupportCase(
    id: 'late_return_vip',
    callReason: 'Zwrot 3 dni po terminie, VIP',
    orderNumber: '84-118004',
    customerName: 'A. Wrona',
    tier: CustomerTier.vip,
    customerSinceYears: 6,
    itemCount: 2,
    totalPln: 890,
    paymentMethod: 'przelew',
    shipmentStatus: 'doręczone',
    lastScan: 'doręczone, 29.07',
    statusHistoryCount: 9,
    returnRequested: true,
    returnDaysSince: 17,
    returnsCount: 1,
    availableActions: [
      (id: 'exceptional_return', label: 'Zwrot wyjątkowy'),
      (id: 'decline_return', label: 'Odmów'),
      (id: 'voucher', label: 'Zaproponuj voucher'),
    ],
  );

  static const b2bOverLimit = SupportCase(
    id: 'b2b_over_limit',
    callReason: 'B2B: limit przekroczony o 12k',
    orderNumber: '84-119640',
    customerName: 'Hurtownia Kalina sp. z o.o.',
    tier: CustomerTier.business,
    customerSinceYears: 4,
    deliveryCity: 'Zamość',
    itemCount: 41,
    totalPln: 38200,
    paymentMethod: 'przelew 30 dni',
    paymentStatus: 'przeterminowana (2 faktury)',
    paymentFailureReason: 'zaległość 12 400 PLN, 21 dni po terminie',
    shipmentStatus: 'wstrzymane',
    carrier: 'DPD',
    trackingNumber: '—',
    lastScan: 'brak — zamówienia wstrzymane',
    statusHistoryCount: 5,
    creditLimitPln: 40000,
    creditUsedPln: 52400,
    blockedOrders: 3,
    inCollections: true,
    corrections: 1,
    notesCount: 2,
    availableActions: [
      (id: 'unblock_once', label: 'Odblokuj jednorazowo'),
      (id: 'call_finance', label: 'Przełącz do finansów'),
      (id: 'payment_plan', label: 'Ustal harmonogram'),
    ],
  );

  /// Kolejność = kolejność przycisków „telefon przychodzący" na demie.
  static const all = [
    stuckShipment,
    rejectedPayment,
    lateReturnVip,
    b2bOverLimit,
  ];
}
