// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupportCase {

 String get id;/// Krótkie „po co on dzwoni" — etykieta przycisku telefonu w demie.
/// Sam konsultant tego nie wie; my wiemy, bo to POC.
 String get callReason; String get orderNumber; String get customerName; CustomerTier get tier; int get customerSinceYears; String get deliveryCity; int get itemCount; int get totalPln; String get paymentMethod; String get paymentStatus; String? get paymentFailureReason; String get carrier; String get shipmentStatus; String get trackingNumber; String get lastScan; int get daysWithoutScan; int get statusHistoryCount; int get openComplaints; int get returnsCount; int get corrections; int get notesCount;/// Zwrot: czy klient go zgłasza, ile dni minęło i jakie jest okno.
 bool get returnRequested; int get returnDaysSince; int get returnWindowDays;/// Limit kupiecki — dotyczy wyłącznie [CustomerTier.business].
 int get creditLimitPln; int get creditUsedPln; int get blockedOrders;/// Windykacja — jedyny powód, dla którego `OfferCard` bywa zakazany.
 bool get inCollections;/// Akcje, które host potrafi wykonać dla tego zamówienia. Model dostaje je
/// w prompcie i może je **narysować**; wykonanie należy do hosta.
 List<TriageAction> get availableActions;
/// Create a copy of SupportCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportCaseCopyWith<SupportCase> get copyWith => _$SupportCaseCopyWithImpl<SupportCase>(this as SupportCase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupportCase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportCase&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.callReason, _this.callReason) || other.callReason == _this.callReason)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.customerSinceYears, _this.customerSinceYears) || other.customerSinceYears == _this.customerSinceYears)&&(identical(other.deliveryCity, _this.deliveryCity) || other.deliveryCity == _this.deliveryCity)&&(identical(other.itemCount, _this.itemCount) || other.itemCount == _this.itemCount)&&(identical(other.totalPln, _this.totalPln) || other.totalPln == _this.totalPln)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.paymentFailureReason, _this.paymentFailureReason) || other.paymentFailureReason == _this.paymentFailureReason)&&(identical(other.carrier, _this.carrier) || other.carrier == _this.carrier)&&(identical(other.shipmentStatus, _this.shipmentStatus) || other.shipmentStatus == _this.shipmentStatus)&&(identical(other.trackingNumber, _this.trackingNumber) || other.trackingNumber == _this.trackingNumber)&&(identical(other.lastScan, _this.lastScan) || other.lastScan == _this.lastScan)&&(identical(other.daysWithoutScan, _this.daysWithoutScan) || other.daysWithoutScan == _this.daysWithoutScan)&&(identical(other.statusHistoryCount, _this.statusHistoryCount) || other.statusHistoryCount == _this.statusHistoryCount)&&(identical(other.openComplaints, _this.openComplaints) || other.openComplaints == _this.openComplaints)&&(identical(other.returnsCount, _this.returnsCount) || other.returnsCount == _this.returnsCount)&&(identical(other.corrections, _this.corrections) || other.corrections == _this.corrections)&&(identical(other.notesCount, _this.notesCount) || other.notesCount == _this.notesCount)&&(identical(other.returnRequested, _this.returnRequested) || other.returnRequested == _this.returnRequested)&&(identical(other.returnDaysSince, _this.returnDaysSince) || other.returnDaysSince == _this.returnDaysSince)&&(identical(other.returnWindowDays, _this.returnWindowDays) || other.returnWindowDays == _this.returnWindowDays)&&(identical(other.creditLimitPln, _this.creditLimitPln) || other.creditLimitPln == _this.creditLimitPln)&&(identical(other.creditUsedPln, _this.creditUsedPln) || other.creditUsedPln == _this.creditUsedPln)&&(identical(other.blockedOrders, _this.blockedOrders) || other.blockedOrders == _this.blockedOrders)&&(identical(other.inCollections, _this.inCollections) || other.inCollections == _this.inCollections)&&const DeepCollectionEquality().equals(other.availableActions, _this.availableActions));
}


@override
int get hashCode {
  final _this = this as SupportCase;
  return Object.hashAll([runtimeType,_this.id,_this.callReason,_this.orderNumber,_this.customerName,_this.tier,_this.customerSinceYears,_this.deliveryCity,_this.itemCount,_this.totalPln,_this.paymentMethod,_this.paymentStatus,_this.paymentFailureReason,_this.carrier,_this.shipmentStatus,_this.trackingNumber,_this.lastScan,_this.daysWithoutScan,_this.statusHistoryCount,_this.openComplaints,_this.returnsCount,_this.corrections,_this.notesCount,_this.returnRequested,_this.returnDaysSince,_this.returnWindowDays,_this.creditLimitPln,_this.creditUsedPln,_this.blockedOrders,_this.inCollections,const DeepCollectionEquality().hash(_this.availableActions)]);
}

@override
String toString() {
  final _this = this as SupportCase;
  return 'SupportCase(id: ${_this.id}, callReason: ${_this.callReason}, orderNumber: ${_this.orderNumber}, customerName: ${_this.customerName}, tier: ${_this.tier}, customerSinceYears: ${_this.customerSinceYears}, deliveryCity: ${_this.deliveryCity}, itemCount: ${_this.itemCount}, totalPln: ${_this.totalPln}, paymentMethod: ${_this.paymentMethod}, paymentStatus: ${_this.paymentStatus}, paymentFailureReason: ${_this.paymentFailureReason}, carrier: ${_this.carrier}, shipmentStatus: ${_this.shipmentStatus}, trackingNumber: ${_this.trackingNumber}, lastScan: ${_this.lastScan}, daysWithoutScan: ${_this.daysWithoutScan}, statusHistoryCount: ${_this.statusHistoryCount}, openComplaints: ${_this.openComplaints}, returnsCount: ${_this.returnsCount}, corrections: ${_this.corrections}, notesCount: ${_this.notesCount}, returnRequested: ${_this.returnRequested}, returnDaysSince: ${_this.returnDaysSince}, returnWindowDays: ${_this.returnWindowDays}, creditLimitPln: ${_this.creditLimitPln}, creditUsedPln: ${_this.creditUsedPln}, blockedOrders: ${_this.blockedOrders}, inCollections: ${_this.inCollections}, availableActions: ${_this.availableActions})';
}


}

/// @nodoc
abstract mixin class $SupportCaseCopyWith<$Res>  {
  factory $SupportCaseCopyWith(SupportCase value, $Res Function(SupportCase) _then) = _$SupportCaseCopyWithImpl;
@useResult
$Res call({
 String id, String callReason, String orderNumber, String customerName, CustomerTier tier, int customerSinceYears, String deliveryCity, int itemCount, int totalPln, String paymentMethod, String paymentStatus, String? paymentFailureReason, String carrier, String shipmentStatus, String trackingNumber, String lastScan, int daysWithoutScan, int statusHistoryCount, int openComplaints, int returnsCount, int corrections, int notesCount, bool returnRequested, int returnDaysSince, int returnWindowDays, int creditLimitPln, int creditUsedPln, int blockedOrders, bool inCollections, List<TriageAction> availableActions
});




}
/// @nodoc
class _$SupportCaseCopyWithImpl<$Res>
    implements $SupportCaseCopyWith<$Res> {
  _$SupportCaseCopyWithImpl(this._self, this._then);

  final SupportCase _self;
  final $Res Function(SupportCase) _then;

/// Create a copy of SupportCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? callReason = null,Object? orderNumber = null,Object? customerName = null,Object? tier = null,Object? customerSinceYears = null,Object? deliveryCity = null,Object? itemCount = null,Object? totalPln = null,Object? paymentMethod = null,Object? paymentStatus = null,Object? paymentFailureReason = freezed,Object? carrier = null,Object? shipmentStatus = null,Object? trackingNumber = null,Object? lastScan = null,Object? daysWithoutScan = null,Object? statusHistoryCount = null,Object? openComplaints = null,Object? returnsCount = null,Object? corrections = null,Object? notesCount = null,Object? returnRequested = null,Object? returnDaysSince = null,Object? returnWindowDays = null,Object? creditLimitPln = null,Object? creditUsedPln = null,Object? blockedOrders = null,Object? inCollections = null,Object? availableActions = null,}) {
  return _then(SupportCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,callReason: null == callReason ? _self.callReason : callReason // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as CustomerTier,customerSinceYears: null == customerSinceYears ? _self.customerSinceYears : customerSinceYears // ignore: cast_nullable_to_non_nullable
as int,deliveryCity: null == deliveryCity ? _self.deliveryCity : deliveryCity // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,totalPln: null == totalPln ? _self.totalPln : totalPln // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentFailureReason: freezed == paymentFailureReason ? _self.paymentFailureReason : paymentFailureReason // ignore: cast_nullable_to_non_nullable
as String?,carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,shipmentStatus: null == shipmentStatus ? _self.shipmentStatus : shipmentStatus // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,lastScan: null == lastScan ? _self.lastScan : lastScan // ignore: cast_nullable_to_non_nullable
as String,daysWithoutScan: null == daysWithoutScan ? _self.daysWithoutScan : daysWithoutScan // ignore: cast_nullable_to_non_nullable
as int,statusHistoryCount: null == statusHistoryCount ? _self.statusHistoryCount : statusHistoryCount // ignore: cast_nullable_to_non_nullable
as int,openComplaints: null == openComplaints ? _self.openComplaints : openComplaints // ignore: cast_nullable_to_non_nullable
as int,returnsCount: null == returnsCount ? _self.returnsCount : returnsCount // ignore: cast_nullable_to_non_nullable
as int,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,returnRequested: null == returnRequested ? _self.returnRequested : returnRequested // ignore: cast_nullable_to_non_nullable
as bool,returnDaysSince: null == returnDaysSince ? _self.returnDaysSince : returnDaysSince // ignore: cast_nullable_to_non_nullable
as int,returnWindowDays: null == returnWindowDays ? _self.returnWindowDays : returnWindowDays // ignore: cast_nullable_to_non_nullable
as int,creditLimitPln: null == creditLimitPln ? _self.creditLimitPln : creditLimitPln // ignore: cast_nullable_to_non_nullable
as int,creditUsedPln: null == creditUsedPln ? _self.creditUsedPln : creditUsedPln // ignore: cast_nullable_to_non_nullable
as int,blockedOrders: null == blockedOrders ? _self.blockedOrders : blockedOrders // ignore: cast_nullable_to_non_nullable
as int,inCollections: null == inCollections ? _self.inCollections : inCollections // ignore: cast_nullable_to_non_nullable
as bool,availableActions: null == availableActions ? _self.availableActions : availableActions // ignore: cast_nullable_to_non_nullable
as List<TriageAction>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportCase].
extension SupportCasePatterns on SupportCase {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportCase() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportCase value)  $default,){
final _that = this;
switch (_that) {
case _SupportCase():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportCase value)?  $default,){
final _that = this;
switch (_that) {
case _SupportCase() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String callReason,  String orderNumber,  String customerName,  CustomerTier tier,  int customerSinceYears,  String deliveryCity,  int itemCount,  int totalPln,  String paymentMethod,  String paymentStatus,  String? paymentFailureReason,  String carrier,  String shipmentStatus,  String trackingNumber,  String lastScan,  int daysWithoutScan,  int statusHistoryCount,  int openComplaints,  int returnsCount,  int corrections,  int notesCount,  bool returnRequested,  int returnDaysSince,  int returnWindowDays,  int creditLimitPln,  int creditUsedPln,  int blockedOrders,  bool inCollections,  List<TriageAction> availableActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportCase() when $default != null:
return $default(_that.id,_that.callReason,_that.orderNumber,_that.customerName,_that.tier,_that.customerSinceYears,_that.deliveryCity,_that.itemCount,_that.totalPln,_that.paymentMethod,_that.paymentStatus,_that.paymentFailureReason,_that.carrier,_that.shipmentStatus,_that.trackingNumber,_that.lastScan,_that.daysWithoutScan,_that.statusHistoryCount,_that.openComplaints,_that.returnsCount,_that.corrections,_that.notesCount,_that.returnRequested,_that.returnDaysSince,_that.returnWindowDays,_that.creditLimitPln,_that.creditUsedPln,_that.blockedOrders,_that.inCollections,_that.availableActions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String callReason,  String orderNumber,  String customerName,  CustomerTier tier,  int customerSinceYears,  String deliveryCity,  int itemCount,  int totalPln,  String paymentMethod,  String paymentStatus,  String? paymentFailureReason,  String carrier,  String shipmentStatus,  String trackingNumber,  String lastScan,  int daysWithoutScan,  int statusHistoryCount,  int openComplaints,  int returnsCount,  int corrections,  int notesCount,  bool returnRequested,  int returnDaysSince,  int returnWindowDays,  int creditLimitPln,  int creditUsedPln,  int blockedOrders,  bool inCollections,  List<TriageAction> availableActions)  $default,) {final _that = this;
switch (_that) {
case _SupportCase():
return $default(_that.id,_that.callReason,_that.orderNumber,_that.customerName,_that.tier,_that.customerSinceYears,_that.deliveryCity,_that.itemCount,_that.totalPln,_that.paymentMethod,_that.paymentStatus,_that.paymentFailureReason,_that.carrier,_that.shipmentStatus,_that.trackingNumber,_that.lastScan,_that.daysWithoutScan,_that.statusHistoryCount,_that.openComplaints,_that.returnsCount,_that.corrections,_that.notesCount,_that.returnRequested,_that.returnDaysSince,_that.returnWindowDays,_that.creditLimitPln,_that.creditUsedPln,_that.blockedOrders,_that.inCollections,_that.availableActions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String callReason,  String orderNumber,  String customerName,  CustomerTier tier,  int customerSinceYears,  String deliveryCity,  int itemCount,  int totalPln,  String paymentMethod,  String paymentStatus,  String? paymentFailureReason,  String carrier,  String shipmentStatus,  String trackingNumber,  String lastScan,  int daysWithoutScan,  int statusHistoryCount,  int openComplaints,  int returnsCount,  int corrections,  int notesCount,  bool returnRequested,  int returnDaysSince,  int returnWindowDays,  int creditLimitPln,  int creditUsedPln,  int blockedOrders,  bool inCollections,  List<TriageAction> availableActions)?  $default,) {final _that = this;
switch (_that) {
case _SupportCase() when $default != null:
return $default(_that.id,_that.callReason,_that.orderNumber,_that.customerName,_that.tier,_that.customerSinceYears,_that.deliveryCity,_that.itemCount,_that.totalPln,_that.paymentMethod,_that.paymentStatus,_that.paymentFailureReason,_that.carrier,_that.shipmentStatus,_that.trackingNumber,_that.lastScan,_that.daysWithoutScan,_that.statusHistoryCount,_that.openComplaints,_that.returnsCount,_that.corrections,_that.notesCount,_that.returnRequested,_that.returnDaysSince,_that.returnWindowDays,_that.creditLimitPln,_that.creditUsedPln,_that.blockedOrders,_that.inCollections,_that.availableActions);case _:
  return null;

}
}

}

/// @nodoc


class _SupportCase extends SupportCase {
  const _SupportCase({required this.id, required this.callReason, required this.orderNumber, required this.customerName, this.tier = CustomerTier.regular, this.customerSinceYears = 2, this.deliveryCity = 'Lublin', this.itemCount = 3, this.totalPln = 489, this.paymentMethod = 'BLIK', this.paymentStatus = 'opłacone', this.paymentFailureReason, this.carrier = 'InPost', this.shipmentStatus = 'w doręczeniu', this.trackingNumber = '6304 1129 8877', this.lastScan = 'sortownia Łódź, 12.08', this.daysWithoutScan = 0, this.statusHistoryCount = 7, this.openComplaints = 0, this.returnsCount = 0, this.corrections = 0, this.notesCount = 0, this.returnRequested = false, this.returnDaysSince = 0, this.returnWindowDays = 14, this.creditLimitPln = 0, this.creditUsedPln = 0, this.blockedOrders = 0, this.inCollections = false,  List<TriageAction> availableActions = const <TriageAction>[]}): _availableActions = availableActions,super._();
  

@override final  String id;
/// Krótkie „po co on dzwoni" — etykieta przycisku telefonu w demie.
/// Sam konsultant tego nie wie; my wiemy, bo to POC.
@override final  String callReason;
@override final  String orderNumber;
@override final  String customerName;
@override@JsonKey() final  CustomerTier tier;
@override@JsonKey() final  int customerSinceYears;
@override@JsonKey() final  String deliveryCity;
@override@JsonKey() final  int itemCount;
@override@JsonKey() final  int totalPln;
@override@JsonKey() final  String paymentMethod;
@override@JsonKey() final  String paymentStatus;
@override final  String? paymentFailureReason;
@override@JsonKey() final  String carrier;
@override@JsonKey() final  String shipmentStatus;
@override@JsonKey() final  String trackingNumber;
@override@JsonKey() final  String lastScan;
@override@JsonKey() final  int daysWithoutScan;
@override@JsonKey() final  int statusHistoryCount;
@override@JsonKey() final  int openComplaints;
@override@JsonKey() final  int returnsCount;
@override@JsonKey() final  int corrections;
@override@JsonKey() final  int notesCount;
/// Zwrot: czy klient go zgłasza, ile dni minęło i jakie jest okno.
@override@JsonKey() final  bool returnRequested;
@override@JsonKey() final  int returnDaysSince;
@override@JsonKey() final  int returnWindowDays;
/// Limit kupiecki — dotyczy wyłącznie [CustomerTier.business].
@override@JsonKey() final  int creditLimitPln;
@override@JsonKey() final  int creditUsedPln;
@override@JsonKey() final  int blockedOrders;
/// Windykacja — jedyny powód, dla którego `OfferCard` bywa zakazany.
@override@JsonKey() final  bool inCollections;
/// Akcje, które host potrafi wykonać dla tego zamówienia. Model dostaje je
/// w prompcie i może je **narysować**; wykonanie należy do hosta.
 final  List<TriageAction> _availableActions;
/// Akcje, które host potrafi wykonać dla tego zamówienia. Model dostaje je
/// w prompcie i może je **narysować**; wykonanie należy do hosta.
@override@JsonKey() List<TriageAction> get availableActions {
  if (_availableActions is EqualUnmodifiableListView) return _availableActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableActions);
}


/// Create a copy of SupportCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportCaseCopyWith<_SupportCase> get copyWith => __$SupportCaseCopyWithImpl<_SupportCase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportCase&&(identical(other.id, id) || other.id == id)&&(identical(other.callReason, callReason) || other.callReason == callReason)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.customerSinceYears, customerSinceYears) || other.customerSinceYears == customerSinceYears)&&(identical(other.deliveryCity, deliveryCity) || other.deliveryCity == deliveryCity)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.totalPln, totalPln) || other.totalPln == totalPln)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentFailureReason, paymentFailureReason) || other.paymentFailureReason == paymentFailureReason)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.shipmentStatus, shipmentStatus) || other.shipmentStatus == shipmentStatus)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.lastScan, lastScan) || other.lastScan == lastScan)&&(identical(other.daysWithoutScan, daysWithoutScan) || other.daysWithoutScan == daysWithoutScan)&&(identical(other.statusHistoryCount, statusHistoryCount) || other.statusHistoryCount == statusHistoryCount)&&(identical(other.openComplaints, openComplaints) || other.openComplaints == openComplaints)&&(identical(other.returnsCount, returnsCount) || other.returnsCount == returnsCount)&&(identical(other.corrections, corrections) || other.corrections == corrections)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&(identical(other.returnRequested, returnRequested) || other.returnRequested == returnRequested)&&(identical(other.returnDaysSince, returnDaysSince) || other.returnDaysSince == returnDaysSince)&&(identical(other.returnWindowDays, returnWindowDays) || other.returnWindowDays == returnWindowDays)&&(identical(other.creditLimitPln, creditLimitPln) || other.creditLimitPln == creditLimitPln)&&(identical(other.creditUsedPln, creditUsedPln) || other.creditUsedPln == creditUsedPln)&&(identical(other.blockedOrders, blockedOrders) || other.blockedOrders == blockedOrders)&&(identical(other.inCollections, inCollections) || other.inCollections == inCollections)&&const DeepCollectionEquality().equals(other.availableActions, _availableActions));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,callReason,orderNumber,customerName,tier,customerSinceYears,deliveryCity,itemCount,totalPln,paymentMethod,paymentStatus,paymentFailureReason,carrier,shipmentStatus,trackingNumber,lastScan,daysWithoutScan,statusHistoryCount,openComplaints,returnsCount,corrections,notesCount,returnRequested,returnDaysSince,returnWindowDays,creditLimitPln,creditUsedPln,blockedOrders,inCollections,const DeepCollectionEquality().hash(_availableActions)]);
}

@override
String toString() {
    return 'SupportCase(id: $id, callReason: $callReason, orderNumber: $orderNumber, customerName: $customerName, tier: $tier, customerSinceYears: $customerSinceYears, deliveryCity: $deliveryCity, itemCount: $itemCount, totalPln: $totalPln, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentFailureReason: $paymentFailureReason, carrier: $carrier, shipmentStatus: $shipmentStatus, trackingNumber: $trackingNumber, lastScan: $lastScan, daysWithoutScan: $daysWithoutScan, statusHistoryCount: $statusHistoryCount, openComplaints: $openComplaints, returnsCount: $returnsCount, corrections: $corrections, notesCount: $notesCount, returnRequested: $returnRequested, returnDaysSince: $returnDaysSince, returnWindowDays: $returnWindowDays, creditLimitPln: $creditLimitPln, creditUsedPln: $creditUsedPln, blockedOrders: $blockedOrders, inCollections: $inCollections, availableActions: $availableActions)';
}


}

/// @nodoc
abstract mixin class _$SupportCaseCopyWith<$Res> implements $SupportCaseCopyWith<$Res> {
  factory _$SupportCaseCopyWith(_SupportCase value, $Res Function(_SupportCase) _then) = __$SupportCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String callReason, String orderNumber, String customerName, CustomerTier tier, int customerSinceYears, String deliveryCity, int itemCount, int totalPln, String paymentMethod, String paymentStatus, String? paymentFailureReason, String carrier, String shipmentStatus, String trackingNumber, String lastScan, int daysWithoutScan, int statusHistoryCount, int openComplaints, int returnsCount, int corrections, int notesCount, bool returnRequested, int returnDaysSince, int returnWindowDays, int creditLimitPln, int creditUsedPln, int blockedOrders, bool inCollections, List<TriageAction> availableActions
});




}
/// @nodoc
class __$SupportCaseCopyWithImpl<$Res>
    implements _$SupportCaseCopyWith<$Res> {
  __$SupportCaseCopyWithImpl(this._self, this._then);

  final _SupportCase _self;
  final $Res Function(_SupportCase) _then;

/// Create a copy of SupportCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? callReason = null,Object? orderNumber = null,Object? customerName = null,Object? tier = null,Object? customerSinceYears = null,Object? deliveryCity = null,Object? itemCount = null,Object? totalPln = null,Object? paymentMethod = null,Object? paymentStatus = null,Object? paymentFailureReason = freezed,Object? carrier = null,Object? shipmentStatus = null,Object? trackingNumber = null,Object? lastScan = null,Object? daysWithoutScan = null,Object? statusHistoryCount = null,Object? openComplaints = null,Object? returnsCount = null,Object? corrections = null,Object? notesCount = null,Object? returnRequested = null,Object? returnDaysSince = null,Object? returnWindowDays = null,Object? creditLimitPln = null,Object? creditUsedPln = null,Object? blockedOrders = null,Object? inCollections = null,Object? availableActions = null,}) {
  return _then(_SupportCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,callReason: null == callReason ? _self.callReason : callReason // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as CustomerTier,customerSinceYears: null == customerSinceYears ? _self.customerSinceYears : customerSinceYears // ignore: cast_nullable_to_non_nullable
as int,deliveryCity: null == deliveryCity ? _self.deliveryCity : deliveryCity // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,totalPln: null == totalPln ? _self.totalPln : totalPln // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentFailureReason: freezed == paymentFailureReason ? _self.paymentFailureReason : paymentFailureReason // ignore: cast_nullable_to_non_nullable
as String?,carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,shipmentStatus: null == shipmentStatus ? _self.shipmentStatus : shipmentStatus // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,lastScan: null == lastScan ? _self.lastScan : lastScan // ignore: cast_nullable_to_non_nullable
as String,daysWithoutScan: null == daysWithoutScan ? _self.daysWithoutScan : daysWithoutScan // ignore: cast_nullable_to_non_nullable
as int,statusHistoryCount: null == statusHistoryCount ? _self.statusHistoryCount : statusHistoryCount // ignore: cast_nullable_to_non_nullable
as int,openComplaints: null == openComplaints ? _self.openComplaints : openComplaints // ignore: cast_nullable_to_non_nullable
as int,returnsCount: null == returnsCount ? _self.returnsCount : returnsCount // ignore: cast_nullable_to_non_nullable
as int,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,returnRequested: null == returnRequested ? _self.returnRequested : returnRequested // ignore: cast_nullable_to_non_nullable
as bool,returnDaysSince: null == returnDaysSince ? _self.returnDaysSince : returnDaysSince // ignore: cast_nullable_to_non_nullable
as int,returnWindowDays: null == returnWindowDays ? _self.returnWindowDays : returnWindowDays // ignore: cast_nullable_to_non_nullable
as int,creditLimitPln: null == creditLimitPln ? _self.creditLimitPln : creditLimitPln // ignore: cast_nullable_to_non_nullable
as int,creditUsedPln: null == creditUsedPln ? _self.creditUsedPln : creditUsedPln // ignore: cast_nullable_to_non_nullable
as int,blockedOrders: null == blockedOrders ? _self.blockedOrders : blockedOrders // ignore: cast_nullable_to_non_nullable
as int,inCollections: null == inCollections ? _self.inCollections : inCollections // ignore: cast_nullable_to_non_nullable
as bool,availableActions: null == availableActions ? _self._availableActions : availableActions // ignore: cast_nullable_to_non_nullable
as List<TriageAction>,
  ));
}


}

// dart format on
