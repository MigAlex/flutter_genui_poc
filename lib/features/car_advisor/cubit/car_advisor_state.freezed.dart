// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_advisor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CarAdvisorState {

 AdvisorCriteria get criteria;/// Id powierzchni panelu — jedna na cały ekran, założona przez hosta.
 String? get panelSurfaceId;/// Czy powierzchnia ma już jakąkolwiek treść. Osobno od [panelSurfaceId],
/// bo powierzchnia istnieje od startu (bootstrap), a komponenty dopiero
/// po pierwszej odpowiedzi — renderowanie pustego `Surface` pokazałoby
/// user'owi nic, zamiast podpowiedzi „ustaw kryteria".
 bool get hasContent; bool get isWaiting;/// Czy `CarCard` jest w katalogu **idącym do promptu**.
///
/// Wyłączony = model o widgecie nie wie i musi złożyć ofertę z `Card`
/// i `Text`. To jest przełącznik demonstracyjny („katalog jest sufitem
/// tego, co model umie narysować"), a nie dawne A/B na regule użycia —
/// tamto zmieniało prompt o 323 znaki i na żywym Haiku nie zmieniało
/// wyniku, więc jako przełącznik w UI wyglądało po prostu na zepsute.
 bool get carCardInCatalog;/// Czy panel kryteriów jest zwinięty do jednej linii podsumowania.
///
/// Zwija się **sam po pierwszym wyniku**: suwaki i chipy zajmują ~2/3
/// ekranu telefonu, więc wygenerowany panel — czyli to, po co ten ekran
/// istnieje — lądował pod zgięciem i trzeba go było scrollować w okienku
/// wysokości kilku centymetrów.
 bool get criteriaCollapsed;/// Komponenty użyte w ostatniej odpowiedzi modelu — wynik eksperymentu.
 Set<String> get lastComponents; int get requestCount; String? get error;/// Proza od modelu. Na tym ekranie to **objaw błędu**, nie treść:
/// dyscyplina panelu mówi „zawsze updateComponents".
 String? get latestText;
/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarAdvisorStateCopyWith<CarAdvisorState> get copyWith => _$CarAdvisorStateCopyWithImpl<CarAdvisorState>(this as CarAdvisorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CarAdvisorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarAdvisorState&&(identical(other.criteria, _this.criteria) || other.criteria == _this.criteria)&&(identical(other.panelSurfaceId, _this.panelSurfaceId) || other.panelSurfaceId == _this.panelSurfaceId)&&(identical(other.hasContent, _this.hasContent) || other.hasContent == _this.hasContent)&&(identical(other.isWaiting, _this.isWaiting) || other.isWaiting == _this.isWaiting)&&(identical(other.carCardInCatalog, _this.carCardInCatalog) || other.carCardInCatalog == _this.carCardInCatalog)&&(identical(other.criteriaCollapsed, _this.criteriaCollapsed) || other.criteriaCollapsed == _this.criteriaCollapsed)&&const DeepCollectionEquality().equals(other.lastComponents, _this.lastComponents)&&(identical(other.requestCount, _this.requestCount) || other.requestCount == _this.requestCount)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.latestText, _this.latestText) || other.latestText == _this.latestText));
}


@override
int get hashCode {
  final _this = this as CarAdvisorState;
  return Object.hash(runtimeType,_this.criteria,_this.panelSurfaceId,_this.hasContent,_this.isWaiting,_this.carCardInCatalog,_this.criteriaCollapsed,const DeepCollectionEquality().hash(_this.lastComponents),_this.requestCount,_this.error,_this.latestText);
}

@override
String toString() {
  final _this = this as CarAdvisorState;
  return 'CarAdvisorState(criteria: ${_this.criteria}, panelSurfaceId: ${_this.panelSurfaceId}, hasContent: ${_this.hasContent}, isWaiting: ${_this.isWaiting}, carCardInCatalog: ${_this.carCardInCatalog}, criteriaCollapsed: ${_this.criteriaCollapsed}, lastComponents: ${_this.lastComponents}, requestCount: ${_this.requestCount}, error: ${_this.error}, latestText: ${_this.latestText})';
}


}

/// @nodoc
abstract mixin class $CarAdvisorStateCopyWith<$Res>  {
  factory $CarAdvisorStateCopyWith(CarAdvisorState value, $Res Function(CarAdvisorState) _then) = _$CarAdvisorStateCopyWithImpl;
@useResult
$Res call({
 AdvisorCriteria criteria, String? panelSurfaceId, bool hasContent, bool isWaiting, bool carCardInCatalog, bool criteriaCollapsed, Set<String> lastComponents, int requestCount, String? error, String? latestText
});


$AdvisorCriteriaCopyWith<$Res> get criteria;

}
/// @nodoc
class _$CarAdvisorStateCopyWithImpl<$Res>
    implements $CarAdvisorStateCopyWith<$Res> {
  _$CarAdvisorStateCopyWithImpl(this._self, this._then);

  final CarAdvisorState _self;
  final $Res Function(CarAdvisorState) _then;

/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? criteria = null,Object? panelSurfaceId = freezed,Object? hasContent = null,Object? isWaiting = null,Object? carCardInCatalog = null,Object? criteriaCollapsed = null,Object? lastComponents = null,Object? requestCount = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(CarAdvisorState(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as AdvisorCriteria,panelSurfaceId: freezed == panelSurfaceId ? _self.panelSurfaceId : panelSurfaceId // ignore: cast_nullable_to_non_nullable
as String?,hasContent: null == hasContent ? _self.hasContent : hasContent // ignore: cast_nullable_to_non_nullable
as bool,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,carCardInCatalog: null == carCardInCatalog ? _self.carCardInCatalog : carCardInCatalog // ignore: cast_nullable_to_non_nullable
as bool,criteriaCollapsed: null == criteriaCollapsed ? _self.criteriaCollapsed : criteriaCollapsed // ignore: cast_nullable_to_non_nullable
as bool,lastComponents: null == lastComponents ? _self.lastComponents : lastComponents // ignore: cast_nullable_to_non_nullable
as Set<String>,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdvisorCriteriaCopyWith<$Res> get criteria {
  
  return $AdvisorCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}
}


/// Adds pattern-matching-related methods to [CarAdvisorState].
extension CarAdvisorStatePatterns on CarAdvisorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarAdvisorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarAdvisorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarAdvisorState value)  $default,){
final _that = this;
switch (_that) {
case _CarAdvisorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarAdvisorState value)?  $default,){
final _that = this;
switch (_that) {
case _CarAdvisorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AdvisorCriteria criteria,  String? panelSurfaceId,  bool hasContent,  bool isWaiting,  bool carCardInCatalog,  bool criteriaCollapsed,  Set<String> lastComponents,  int requestCount,  String? error,  String? latestText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarAdvisorState() when $default != null:
return $default(_that.criteria,_that.panelSurfaceId,_that.hasContent,_that.isWaiting,_that.carCardInCatalog,_that.criteriaCollapsed,_that.lastComponents,_that.requestCount,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AdvisorCriteria criteria,  String? panelSurfaceId,  bool hasContent,  bool isWaiting,  bool carCardInCatalog,  bool criteriaCollapsed,  Set<String> lastComponents,  int requestCount,  String? error,  String? latestText)  $default,) {final _that = this;
switch (_that) {
case _CarAdvisorState():
return $default(_that.criteria,_that.panelSurfaceId,_that.hasContent,_that.isWaiting,_that.carCardInCatalog,_that.criteriaCollapsed,_that.lastComponents,_that.requestCount,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AdvisorCriteria criteria,  String? panelSurfaceId,  bool hasContent,  bool isWaiting,  bool carCardInCatalog,  bool criteriaCollapsed,  Set<String> lastComponents,  int requestCount,  String? error,  String? latestText)?  $default,) {final _that = this;
switch (_that) {
case _CarAdvisorState() when $default != null:
return $default(_that.criteria,_that.panelSurfaceId,_that.hasContent,_that.isWaiting,_that.carCardInCatalog,_that.criteriaCollapsed,_that.lastComponents,_that.requestCount,_that.error,_that.latestText);case _:
  return null;

}
}

}

/// @nodoc


class _CarAdvisorState extends CarAdvisorState {
  const _CarAdvisorState({this.criteria = const AdvisorCriteria(), this.panelSurfaceId, this.hasContent = false, this.isWaiting = false, this.carCardInCatalog = true, this.criteriaCollapsed = false,  Set<String> lastComponents = const <String>{}, this.requestCount = 0, this.error, this.latestText}): _lastComponents = lastComponents,super._();
  

@override@JsonKey() final  AdvisorCriteria criteria;
/// Id powierzchni panelu — jedna na cały ekran, założona przez hosta.
@override final  String? panelSurfaceId;
/// Czy powierzchnia ma już jakąkolwiek treść. Osobno od [panelSurfaceId],
/// bo powierzchnia istnieje od startu (bootstrap), a komponenty dopiero
/// po pierwszej odpowiedzi — renderowanie pustego `Surface` pokazałoby
/// user'owi nic, zamiast podpowiedzi „ustaw kryteria".
@override@JsonKey() final  bool hasContent;
@override@JsonKey() final  bool isWaiting;
/// Czy `CarCard` jest w katalogu **idącym do promptu**.
///
/// Wyłączony = model o widgecie nie wie i musi złożyć ofertę z `Card`
/// i `Text`. To jest przełącznik demonstracyjny („katalog jest sufitem
/// tego, co model umie narysować"), a nie dawne A/B na regule użycia —
/// tamto zmieniało prompt o 323 znaki i na żywym Haiku nie zmieniało
/// wyniku, więc jako przełącznik w UI wyglądało po prostu na zepsute.
@override@JsonKey() final  bool carCardInCatalog;
/// Czy panel kryteriów jest zwinięty do jednej linii podsumowania.
///
/// Zwija się **sam po pierwszym wyniku**: suwaki i chipy zajmują ~2/3
/// ekranu telefonu, więc wygenerowany panel — czyli to, po co ten ekran
/// istnieje — lądował pod zgięciem i trzeba go było scrollować w okienku
/// wysokości kilku centymetrów.
@override@JsonKey() final  bool criteriaCollapsed;
/// Komponenty użyte w ostatniej odpowiedzi modelu — wynik eksperymentu.
 final  Set<String> _lastComponents;
/// Komponenty użyte w ostatniej odpowiedzi modelu — wynik eksperymentu.
@override@JsonKey() Set<String> get lastComponents {
  if (_lastComponents is EqualUnmodifiableSetView) return _lastComponents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_lastComponents);
}

@override@JsonKey() final  int requestCount;
@override final  String? error;
/// Proza od modelu. Na tym ekranie to **objaw błędu**, nie treść:
/// dyscyplina panelu mówi „zawsze updateComponents".
@override final  String? latestText;

/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarAdvisorStateCopyWith<_CarAdvisorState> get copyWith => __$CarAdvisorStateCopyWithImpl<_CarAdvisorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarAdvisorState&&(identical(other.criteria, criteria) || other.criteria == criteria)&&(identical(other.panelSurfaceId, panelSurfaceId) || other.panelSurfaceId == panelSurfaceId)&&(identical(other.hasContent, hasContent) || other.hasContent == hasContent)&&(identical(other.isWaiting, isWaiting) || other.isWaiting == isWaiting)&&(identical(other.carCardInCatalog, carCardInCatalog) || other.carCardInCatalog == carCardInCatalog)&&(identical(other.criteriaCollapsed, criteriaCollapsed) || other.criteriaCollapsed == criteriaCollapsed)&&const DeepCollectionEquality().equals(other.lastComponents, _lastComponents)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.error, error) || other.error == error)&&(identical(other.latestText, latestText) || other.latestText == latestText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,criteria,panelSurfaceId,hasContent,isWaiting,carCardInCatalog,criteriaCollapsed,const DeepCollectionEquality().hash(_lastComponents),requestCount,error,latestText);
}

@override
String toString() {
    return 'CarAdvisorState(criteria: $criteria, panelSurfaceId: $panelSurfaceId, hasContent: $hasContent, isWaiting: $isWaiting, carCardInCatalog: $carCardInCatalog, criteriaCollapsed: $criteriaCollapsed, lastComponents: $lastComponents, requestCount: $requestCount, error: $error, latestText: $latestText)';
}


}

/// @nodoc
abstract mixin class _$CarAdvisorStateCopyWith<$Res> implements $CarAdvisorStateCopyWith<$Res> {
  factory _$CarAdvisorStateCopyWith(_CarAdvisorState value, $Res Function(_CarAdvisorState) _then) = __$CarAdvisorStateCopyWithImpl;
@override @useResult
$Res call({
 AdvisorCriteria criteria, String? panelSurfaceId, bool hasContent, bool isWaiting, bool carCardInCatalog, bool criteriaCollapsed, Set<String> lastComponents, int requestCount, String? error, String? latestText
});


@override $AdvisorCriteriaCopyWith<$Res> get criteria;

}
/// @nodoc
class __$CarAdvisorStateCopyWithImpl<$Res>
    implements _$CarAdvisorStateCopyWith<$Res> {
  __$CarAdvisorStateCopyWithImpl(this._self, this._then);

  final _CarAdvisorState _self;
  final $Res Function(_CarAdvisorState) _then;

/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? criteria = null,Object? panelSurfaceId = freezed,Object? hasContent = null,Object? isWaiting = null,Object? carCardInCatalog = null,Object? criteriaCollapsed = null,Object? lastComponents = null,Object? requestCount = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(_CarAdvisorState(
criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as AdvisorCriteria,panelSurfaceId: freezed == panelSurfaceId ? _self.panelSurfaceId : panelSurfaceId // ignore: cast_nullable_to_non_nullable
as String?,hasContent: null == hasContent ? _self.hasContent : hasContent // ignore: cast_nullable_to_non_nullable
as bool,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,carCardInCatalog: null == carCardInCatalog ? _self.carCardInCatalog : carCardInCatalog // ignore: cast_nullable_to_non_nullable
as bool,criteriaCollapsed: null == criteriaCollapsed ? _self.criteriaCollapsed : criteriaCollapsed // ignore: cast_nullable_to_non_nullable
as bool,lastComponents: null == lastComponents ? _self._lastComponents : lastComponents // ignore: cast_nullable_to_non_nullable
as Set<String>,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CarAdvisorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdvisorCriteriaCopyWith<$Res> get criteria {
  
  return $AdvisorCriteriaCopyWith<$Res>(_self.criteria, (value) {
    return _then(_self.copyWith(criteria: value));
  });
}
}

// dart format on
