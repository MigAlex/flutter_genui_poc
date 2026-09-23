// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'triage_panel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TriagePanelState {

/// `null` = nikt jeszcze nie zadzwonił. Ekran startowy pokazuje wtedy same
/// przyciski „telefon przychodzący".
 SupportCase? get activeCase;/// Powierzchnia, którą renderuje pasek. Zwykle stała; przy wymuszonej
/// awarii „zły catalogId" przeskakuje na tę z zepsutym katalogiem — i to
/// jest cały sens tamtej awarii.
 String? get stripSurfaceId;/// Czy na powierzchni są już komponenty. Osobno od [stripSurfaceId], bo
/// powierzchnia istnieje od startu (założył ją host), a komponenty dopiero
/// po odpowiedzi.
 bool get hasStripContent; bool get isWaiting;/// Czy host **egzekwuje** kontrakt. Wyłączony = werdykt nadal się liczy
/// i widać go na pasku diagnostycznym, ale powierzchnia idzie na ekran
/// mimo złamanej reguły. Ta para (widzę / egzekwuję) jest sednem demo:
/// przy wyłączonym kontrakcie brak wymaganego komponentu **wygląda
/// dokładnie jak jego brak w danych**.
 bool get contractEnforced; TriageFailure get failure;/// Komponenty, które host **realnie dostarczył** do renderera (czyli już
/// po ewentualnej awarii) — nie to, co wygenerował model.
 Set<String> get lastComponents; ContractVerdict? get verdict;/// Tury modelu vs kliknięcia konsultanta. Te dwie liczby obok siebie są
/// jedynym uczciwym argumentem w sporze „każde kliknięcie kosztuje".
 int get modelTurns; int get userActions;/// Bilans tokenów narastająco. Obok liczby tur odpowiada na drugie pytanie
/// z tego samego sporu: nie „ile razy", tylko „za ile".
 TokenTally get tokens; String? get error;/// Proza od modelu. Na tym ekranie to **objaw**, nie treść.
 String? get latestText;
/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriagePanelStateCopyWith<TriagePanelState> get copyWith => _$TriagePanelStateCopyWithImpl<TriagePanelState>(this as TriagePanelState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TriagePanelState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriagePanelState&&(identical(other.activeCase, _this.activeCase) || other.activeCase == _this.activeCase)&&(identical(other.stripSurfaceId, _this.stripSurfaceId) || other.stripSurfaceId == _this.stripSurfaceId)&&(identical(other.hasStripContent, _this.hasStripContent) || other.hasStripContent == _this.hasStripContent)&&(identical(other.isWaiting, _this.isWaiting) || other.isWaiting == _this.isWaiting)&&(identical(other.contractEnforced, _this.contractEnforced) || other.contractEnforced == _this.contractEnforced)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&const DeepCollectionEquality().equals(other.lastComponents, _this.lastComponents)&&(identical(other.verdict, _this.verdict) || other.verdict == _this.verdict)&&(identical(other.modelTurns, _this.modelTurns) || other.modelTurns == _this.modelTurns)&&(identical(other.userActions, _this.userActions) || other.userActions == _this.userActions)&&(identical(other.tokens, _this.tokens) || other.tokens == _this.tokens)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.latestText, _this.latestText) || other.latestText == _this.latestText));
}


@override
int get hashCode {
  final _this = this as TriagePanelState;
  return Object.hash(runtimeType,_this.activeCase,_this.stripSurfaceId,_this.hasStripContent,_this.isWaiting,_this.contractEnforced,_this.failure,const DeepCollectionEquality().hash(_this.lastComponents),_this.verdict,_this.modelTurns,_this.userActions,_this.tokens,_this.error,_this.latestText);
}

@override
String toString() {
  final _this = this as TriagePanelState;
  return 'TriagePanelState(activeCase: ${_this.activeCase}, stripSurfaceId: ${_this.stripSurfaceId}, hasStripContent: ${_this.hasStripContent}, isWaiting: ${_this.isWaiting}, contractEnforced: ${_this.contractEnforced}, failure: ${_this.failure}, lastComponents: ${_this.lastComponents}, verdict: ${_this.verdict}, modelTurns: ${_this.modelTurns}, userActions: ${_this.userActions}, tokens: ${_this.tokens}, error: ${_this.error}, latestText: ${_this.latestText})';
}


}

/// @nodoc
abstract mixin class $TriagePanelStateCopyWith<$Res>  {
  factory $TriagePanelStateCopyWith(TriagePanelState value, $Res Function(TriagePanelState) _then) = _$TriagePanelStateCopyWithImpl;
@useResult
$Res call({
 SupportCase? activeCase, String? stripSurfaceId, bool hasStripContent, bool isWaiting, bool contractEnforced, TriageFailure failure, Set<String> lastComponents, ContractVerdict? verdict, int modelTurns, int userActions, TokenTally tokens, String? error, String? latestText
});


$SupportCaseCopyWith<$Res>? get activeCase;

}
/// @nodoc
class _$TriagePanelStateCopyWithImpl<$Res>
    implements $TriagePanelStateCopyWith<$Res> {
  _$TriagePanelStateCopyWithImpl(this._self, this._then);

  final TriagePanelState _self;
  final $Res Function(TriagePanelState) _then;

/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeCase = freezed,Object? stripSurfaceId = freezed,Object? hasStripContent = null,Object? isWaiting = null,Object? contractEnforced = null,Object? failure = null,Object? lastComponents = null,Object? verdict = freezed,Object? modelTurns = null,Object? userActions = null,Object? tokens = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(TriagePanelState(
activeCase: freezed == activeCase ? _self.activeCase : activeCase // ignore: cast_nullable_to_non_nullable
as SupportCase?,stripSurfaceId: freezed == stripSurfaceId ? _self.stripSurfaceId : stripSurfaceId // ignore: cast_nullable_to_non_nullable
as String?,hasStripContent: null == hasStripContent ? _self.hasStripContent : hasStripContent // ignore: cast_nullable_to_non_nullable
as bool,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,contractEnforced: null == contractEnforced ? _self.contractEnforced : contractEnforced // ignore: cast_nullable_to_non_nullable
as bool,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as TriageFailure,lastComponents: null == lastComponents ? _self.lastComponents : lastComponents // ignore: cast_nullable_to_non_nullable
as Set<String>,verdict: freezed == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as ContractVerdict?,modelTurns: null == modelTurns ? _self.modelTurns : modelTurns // ignore: cast_nullable_to_non_nullable
as int,userActions: null == userActions ? _self.userActions : userActions // ignore: cast_nullable_to_non_nullable
as int,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as TokenTally,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportCaseCopyWith<$Res>? get activeCase {
    if (_self.activeCase == null) {
    return null;
  }

  return $SupportCaseCopyWith<$Res>(_self.activeCase!, (value) {
    return _then(_self.copyWith(activeCase: value));
  });
}
}


/// Adds pattern-matching-related methods to [TriagePanelState].
extension TriagePanelStatePatterns on TriagePanelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TriagePanelState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TriagePanelState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TriagePanelState value)  $default,){
final _that = this;
switch (_that) {
case _TriagePanelState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TriagePanelState value)?  $default,){
final _that = this;
switch (_that) {
case _TriagePanelState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SupportCase? activeCase,  String? stripSurfaceId,  bool hasStripContent,  bool isWaiting,  bool contractEnforced,  TriageFailure failure,  Set<String> lastComponents,  ContractVerdict? verdict,  int modelTurns,  int userActions,  TokenTally tokens,  String? error,  String? latestText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriagePanelState() when $default != null:
return $default(_that.activeCase,_that.stripSurfaceId,_that.hasStripContent,_that.isWaiting,_that.contractEnforced,_that.failure,_that.lastComponents,_that.verdict,_that.modelTurns,_that.userActions,_that.tokens,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SupportCase? activeCase,  String? stripSurfaceId,  bool hasStripContent,  bool isWaiting,  bool contractEnforced,  TriageFailure failure,  Set<String> lastComponents,  ContractVerdict? verdict,  int modelTurns,  int userActions,  TokenTally tokens,  String? error,  String? latestText)  $default,) {final _that = this;
switch (_that) {
case _TriagePanelState():
return $default(_that.activeCase,_that.stripSurfaceId,_that.hasStripContent,_that.isWaiting,_that.contractEnforced,_that.failure,_that.lastComponents,_that.verdict,_that.modelTurns,_that.userActions,_that.tokens,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SupportCase? activeCase,  String? stripSurfaceId,  bool hasStripContent,  bool isWaiting,  bool contractEnforced,  TriageFailure failure,  Set<String> lastComponents,  ContractVerdict? verdict,  int modelTurns,  int userActions,  TokenTally tokens,  String? error,  String? latestText)?  $default,) {final _that = this;
switch (_that) {
case _TriagePanelState() when $default != null:
return $default(_that.activeCase,_that.stripSurfaceId,_that.hasStripContent,_that.isWaiting,_that.contractEnforced,_that.failure,_that.lastComponents,_that.verdict,_that.modelTurns,_that.userActions,_that.tokens,_that.error,_that.latestText);case _:
  return null;

}
}

}

/// @nodoc


class _TriagePanelState extends TriagePanelState {
  const _TriagePanelState({this.activeCase, this.stripSurfaceId, this.hasStripContent = false, this.isWaiting = false, this.contractEnforced = true, this.failure = TriageFailure.none,  Set<String> lastComponents = const <String>{}, this.verdict, this.modelTurns = 0, this.userActions = 0, this.tokens = const TokenTally(), this.error, this.latestText}): _lastComponents = lastComponents,super._();
  

/// `null` = nikt jeszcze nie zadzwonił. Ekran startowy pokazuje wtedy same
/// przyciski „telefon przychodzący".
@override final  SupportCase? activeCase;
/// Powierzchnia, którą renderuje pasek. Zwykle stała; przy wymuszonej
/// awarii „zły catalogId" przeskakuje na tę z zepsutym katalogiem — i to
/// jest cały sens tamtej awarii.
@override final  String? stripSurfaceId;
/// Czy na powierzchni są już komponenty. Osobno od [stripSurfaceId], bo
/// powierzchnia istnieje od startu (założył ją host), a komponenty dopiero
/// po odpowiedzi.
@override@JsonKey() final  bool hasStripContent;
@override@JsonKey() final  bool isWaiting;
/// Czy host **egzekwuje** kontrakt. Wyłączony = werdykt nadal się liczy
/// i widać go na pasku diagnostycznym, ale powierzchnia idzie na ekran
/// mimo złamanej reguły. Ta para (widzę / egzekwuję) jest sednem demo:
/// przy wyłączonym kontrakcie brak wymaganego komponentu **wygląda
/// dokładnie jak jego brak w danych**.
@override@JsonKey() final  bool contractEnforced;
@override@JsonKey() final  TriageFailure failure;
/// Komponenty, które host **realnie dostarczył** do renderera (czyli już
/// po ewentualnej awarii) — nie to, co wygenerował model.
 final  Set<String> _lastComponents;
/// Komponenty, które host **realnie dostarczył** do renderera (czyli już
/// po ewentualnej awarii) — nie to, co wygenerował model.
@override@JsonKey() Set<String> get lastComponents {
  if (_lastComponents is EqualUnmodifiableSetView) return _lastComponents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_lastComponents);
}

@override final  ContractVerdict? verdict;
/// Tury modelu vs kliknięcia konsultanta. Te dwie liczby obok siebie są
/// jedynym uczciwym argumentem w sporze „każde kliknięcie kosztuje".
@override@JsonKey() final  int modelTurns;
@override@JsonKey() final  int userActions;
/// Bilans tokenów narastająco. Obok liczby tur odpowiada na drugie pytanie
/// z tego samego sporu: nie „ile razy", tylko „za ile".
@override@JsonKey() final  TokenTally tokens;
@override final  String? error;
/// Proza od modelu. Na tym ekranie to **objaw**, nie treść.
@override final  String? latestText;

/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriagePanelStateCopyWith<_TriagePanelState> get copyWith => __$TriagePanelStateCopyWithImpl<_TriagePanelState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriagePanelState&&(identical(other.activeCase, activeCase) || other.activeCase == activeCase)&&(identical(other.stripSurfaceId, stripSurfaceId) || other.stripSurfaceId == stripSurfaceId)&&(identical(other.hasStripContent, hasStripContent) || other.hasStripContent == hasStripContent)&&(identical(other.isWaiting, isWaiting) || other.isWaiting == isWaiting)&&(identical(other.contractEnforced, contractEnforced) || other.contractEnforced == contractEnforced)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other.lastComponents, _lastComponents)&&(identical(other.verdict, verdict) || other.verdict == verdict)&&(identical(other.modelTurns, modelTurns) || other.modelTurns == modelTurns)&&(identical(other.userActions, userActions) || other.userActions == userActions)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.error, error) || other.error == error)&&(identical(other.latestText, latestText) || other.latestText == latestText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,activeCase,stripSurfaceId,hasStripContent,isWaiting,contractEnforced,failure,const DeepCollectionEquality().hash(_lastComponents),verdict,modelTurns,userActions,tokens,error,latestText);
}

@override
String toString() {
    return 'TriagePanelState(activeCase: $activeCase, stripSurfaceId: $stripSurfaceId, hasStripContent: $hasStripContent, isWaiting: $isWaiting, contractEnforced: $contractEnforced, failure: $failure, lastComponents: $lastComponents, verdict: $verdict, modelTurns: $modelTurns, userActions: $userActions, tokens: $tokens, error: $error, latestText: $latestText)';
}


}

/// @nodoc
abstract mixin class _$TriagePanelStateCopyWith<$Res> implements $TriagePanelStateCopyWith<$Res> {
  factory _$TriagePanelStateCopyWith(_TriagePanelState value, $Res Function(_TriagePanelState) _then) = __$TriagePanelStateCopyWithImpl;
@override @useResult
$Res call({
 SupportCase? activeCase, String? stripSurfaceId, bool hasStripContent, bool isWaiting, bool contractEnforced, TriageFailure failure, Set<String> lastComponents, ContractVerdict? verdict, int modelTurns, int userActions, TokenTally tokens, String? error, String? latestText
});


@override $SupportCaseCopyWith<$Res>? get activeCase;

}
/// @nodoc
class __$TriagePanelStateCopyWithImpl<$Res>
    implements _$TriagePanelStateCopyWith<$Res> {
  __$TriagePanelStateCopyWithImpl(this._self, this._then);

  final _TriagePanelState _self;
  final $Res Function(_TriagePanelState) _then;

/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeCase = freezed,Object? stripSurfaceId = freezed,Object? hasStripContent = null,Object? isWaiting = null,Object? contractEnforced = null,Object? failure = null,Object? lastComponents = null,Object? verdict = freezed,Object? modelTurns = null,Object? userActions = null,Object? tokens = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(_TriagePanelState(
activeCase: freezed == activeCase ? _self.activeCase : activeCase // ignore: cast_nullable_to_non_nullable
as SupportCase?,stripSurfaceId: freezed == stripSurfaceId ? _self.stripSurfaceId : stripSurfaceId // ignore: cast_nullable_to_non_nullable
as String?,hasStripContent: null == hasStripContent ? _self.hasStripContent : hasStripContent // ignore: cast_nullable_to_non_nullable
as bool,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,contractEnforced: null == contractEnforced ? _self.contractEnforced : contractEnforced // ignore: cast_nullable_to_non_nullable
as bool,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as TriageFailure,lastComponents: null == lastComponents ? _self._lastComponents : lastComponents // ignore: cast_nullable_to_non_nullable
as Set<String>,verdict: freezed == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as ContractVerdict?,modelTurns: null == modelTurns ? _self.modelTurns : modelTurns // ignore: cast_nullable_to_non_nullable
as int,userActions: null == userActions ? _self.userActions : userActions // ignore: cast_nullable_to_non_nullable
as int,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as TokenTally,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TriagePanelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportCaseCopyWith<$Res>? get activeCase {
    if (_self.activeCase == null) {
    return null;
  }

  return $SupportCaseCopyWith<$Res>(_self.activeCase!, (value) {
    return _then(_self.copyWith(activeCase: value));
  });
}
}

// dart format on
