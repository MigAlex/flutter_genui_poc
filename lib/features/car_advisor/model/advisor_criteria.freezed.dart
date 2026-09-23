// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advisor_criteria.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdvisorCriteria {

 int get budgetPln; CarBody get body;/// `null` = paliwo bez znaczenia.
 CarFuel? get fuel; int get maxMileageKm;
/// Create a copy of AdvisorCriteria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvisorCriteriaCopyWith<AdvisorCriteria> get copyWith => _$AdvisorCriteriaCopyWithImpl<AdvisorCriteria>(this as AdvisorCriteria, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AdvisorCriteria;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvisorCriteria&&(identical(other.budgetPln, _this.budgetPln) || other.budgetPln == _this.budgetPln)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.fuel, _this.fuel) || other.fuel == _this.fuel)&&(identical(other.maxMileageKm, _this.maxMileageKm) || other.maxMileageKm == _this.maxMileageKm));
}


@override
int get hashCode {
  final _this = this as AdvisorCriteria;
  return Object.hash(runtimeType,_this.budgetPln,_this.body,_this.fuel,_this.maxMileageKm);
}

@override
String toString() {
  final _this = this as AdvisorCriteria;
  return 'AdvisorCriteria(budgetPln: ${_this.budgetPln}, body: ${_this.body}, fuel: ${_this.fuel}, maxMileageKm: ${_this.maxMileageKm})';
}


}

/// @nodoc
abstract mixin class $AdvisorCriteriaCopyWith<$Res>  {
  factory $AdvisorCriteriaCopyWith(AdvisorCriteria value, $Res Function(AdvisorCriteria) _then) = _$AdvisorCriteriaCopyWithImpl;
@useResult
$Res call({
 int budgetPln, CarBody body, CarFuel? fuel, int maxMileageKm
});




}
/// @nodoc
class _$AdvisorCriteriaCopyWithImpl<$Res>
    implements $AdvisorCriteriaCopyWith<$Res> {
  _$AdvisorCriteriaCopyWithImpl(this._self, this._then);

  final AdvisorCriteria _self;
  final $Res Function(AdvisorCriteria) _then;

/// Create a copy of AdvisorCriteria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budgetPln = null,Object? body = null,Object? fuel = freezed,Object? maxMileageKm = null,}) {
  return _then(AdvisorCriteria(
budgetPln: null == budgetPln ? _self.budgetPln : budgetPln // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as CarBody,fuel: freezed == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as CarFuel?,maxMileageKm: null == maxMileageKm ? _self.maxMileageKm : maxMileageKm // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdvisorCriteria].
extension AdvisorCriteriaPatterns on AdvisorCriteria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvisorCriteria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvisorCriteria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvisorCriteria value)  $default,){
final _that = this;
switch (_that) {
case _AdvisorCriteria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvisorCriteria value)?  $default,){
final _that = this;
switch (_that) {
case _AdvisorCriteria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int budgetPln,  CarBody body,  CarFuel? fuel,  int maxMileageKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvisorCriteria() when $default != null:
return $default(_that.budgetPln,_that.body,_that.fuel,_that.maxMileageKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int budgetPln,  CarBody body,  CarFuel? fuel,  int maxMileageKm)  $default,) {final _that = this;
switch (_that) {
case _AdvisorCriteria():
return $default(_that.budgetPln,_that.body,_that.fuel,_that.maxMileageKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int budgetPln,  CarBody body,  CarFuel? fuel,  int maxMileageKm)?  $default,) {final _that = this;
switch (_that) {
case _AdvisorCriteria() when $default != null:
return $default(_that.budgetPln,_that.body,_that.fuel,_that.maxMileageKm);case _:
  return null;

}
}

}

/// @nodoc


class _AdvisorCriteria extends AdvisorCriteria {
  const _AdvisorCriteria({this.budgetPln = 60000, this.body = CarBody.wagon, this.fuel, this.maxMileageKm = 150000}): super._();
  

@override@JsonKey() final  int budgetPln;
@override@JsonKey() final  CarBody body;
/// `null` = paliwo bez znaczenia.
@override final  CarFuel? fuel;
@override@JsonKey() final  int maxMileageKm;

/// Create a copy of AdvisorCriteria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvisorCriteriaCopyWith<_AdvisorCriteria> get copyWith => __$AdvisorCriteriaCopyWithImpl<_AdvisorCriteria>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvisorCriteria&&(identical(other.budgetPln, budgetPln) || other.budgetPln == budgetPln)&&(identical(other.body, body) || other.body == body)&&(identical(other.fuel, fuel) || other.fuel == fuel)&&(identical(other.maxMileageKm, maxMileageKm) || other.maxMileageKm == maxMileageKm));
}


@override
int get hashCode {
    return Object.hash(runtimeType,budgetPln,body,fuel,maxMileageKm);
}

@override
String toString() {
    return 'AdvisorCriteria(budgetPln: $budgetPln, body: $body, fuel: $fuel, maxMileageKm: $maxMileageKm)';
}


}

/// @nodoc
abstract mixin class _$AdvisorCriteriaCopyWith<$Res> implements $AdvisorCriteriaCopyWith<$Res> {
  factory _$AdvisorCriteriaCopyWith(_AdvisorCriteria value, $Res Function(_AdvisorCriteria) _then) = __$AdvisorCriteriaCopyWithImpl;
@override @useResult
$Res call({
 int budgetPln, CarBody body, CarFuel? fuel, int maxMileageKm
});




}
/// @nodoc
class __$AdvisorCriteriaCopyWithImpl<$Res>
    implements _$AdvisorCriteriaCopyWith<$Res> {
  __$AdvisorCriteriaCopyWithImpl(this._self, this._then);

  final _AdvisorCriteria _self;
  final $Res Function(_AdvisorCriteria) _then;

/// Create a copy of AdvisorCriteria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budgetPln = null,Object? body = null,Object? fuel = freezed,Object? maxMileageKm = null,}) {
  return _then(_AdvisorCriteria(
budgetPln: null == budgetPln ? _self.budgetPln : budgetPln // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as CarBody,fuel: freezed == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as CarFuel?,maxMileageKm: null == maxMileageKm ? _self.maxMileageKm : maxMileageKm // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
