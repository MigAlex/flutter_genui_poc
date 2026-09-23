// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'genui_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatTurn {

 String get prompt; List<String> get surfaceIds;
/// Create a copy of ChatTurn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatTurnCopyWith<ChatTurn> get copyWith => _$ChatTurnCopyWithImpl<ChatTurn>(this as ChatTurn, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatTurn;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatTurn&&(identical(other.prompt, _this.prompt) || other.prompt == _this.prompt)&&const DeepCollectionEquality().equals(other.surfaceIds, _this.surfaceIds));
}


@override
int get hashCode {
  final _this = this as ChatTurn;
  return Object.hash(runtimeType,_this.prompt,const DeepCollectionEquality().hash(_this.surfaceIds));
}

@override
String toString() {
  final _this = this as ChatTurn;
  return 'ChatTurn(prompt: ${_this.prompt}, surfaceIds: ${_this.surfaceIds})';
}


}

/// @nodoc
abstract mixin class $ChatTurnCopyWith<$Res>  {
  factory $ChatTurnCopyWith(ChatTurn value, $Res Function(ChatTurn) _then) = _$ChatTurnCopyWithImpl;
@useResult
$Res call({
 String prompt, List<String> surfaceIds
});




}
/// @nodoc
class _$ChatTurnCopyWithImpl<$Res>
    implements $ChatTurnCopyWith<$Res> {
  _$ChatTurnCopyWithImpl(this._self, this._then);

  final ChatTurn _self;
  final $Res Function(ChatTurn) _then;

/// Create a copy of ChatTurn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompt = null,Object? surfaceIds = null,}) {
  return _then(ChatTurn(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,surfaceIds: null == surfaceIds ? _self.surfaceIds : surfaceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatTurn].
extension ChatTurnPatterns on ChatTurn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatTurn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatTurn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatTurn value)  $default,){
final _that = this;
switch (_that) {
case _ChatTurn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatTurn value)?  $default,){
final _that = this;
switch (_that) {
case _ChatTurn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prompt,  List<String> surfaceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatTurn() when $default != null:
return $default(_that.prompt,_that.surfaceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prompt,  List<String> surfaceIds)  $default,) {final _that = this;
switch (_that) {
case _ChatTurn():
return $default(_that.prompt,_that.surfaceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prompt,  List<String> surfaceIds)?  $default,) {final _that = this;
switch (_that) {
case _ChatTurn() when $default != null:
return $default(_that.prompt,_that.surfaceIds);case _:
  return null;

}
}

}

/// @nodoc


class _ChatTurn implements ChatTurn {
  const _ChatTurn({required this.prompt,  List<String> surfaceIds = const <String>[]}): _surfaceIds = surfaceIds;
  

@override final  String prompt;
 final  List<String> _surfaceIds;
@override@JsonKey() List<String> get surfaceIds {
  if (_surfaceIds is EqualUnmodifiableListView) return _surfaceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surfaceIds);
}


/// Create a copy of ChatTurn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatTurnCopyWith<_ChatTurn> get copyWith => __$ChatTurnCopyWithImpl<_ChatTurn>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatTurn&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other.surfaceIds, _surfaceIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,prompt,const DeepCollectionEquality().hash(_surfaceIds));
}

@override
String toString() {
    return 'ChatTurn(prompt: $prompt, surfaceIds: $surfaceIds)';
}


}

/// @nodoc
abstract mixin class _$ChatTurnCopyWith<$Res> implements $ChatTurnCopyWith<$Res> {
  factory _$ChatTurnCopyWith(_ChatTurn value, $Res Function(_ChatTurn) _then) = __$ChatTurnCopyWithImpl;
@override @useResult
$Res call({
 String prompt, List<String> surfaceIds
});




}
/// @nodoc
class __$ChatTurnCopyWithImpl<$Res>
    implements _$ChatTurnCopyWith<$Res> {
  __$ChatTurnCopyWithImpl(this._self, this._then);

  final _ChatTurn _self;
  final $Res Function(_ChatTurn) _then;

/// Create a copy of ChatTurn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? surfaceIds = null,}) {
  return _then(_ChatTurn(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,surfaceIds: null == surfaceIds ? _self._surfaceIds : surfaceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$GenUiChatState {

 List<ChatTurn> get turns; bool get isWaiting; String? get error;/// Zwykły tekst od modelu (gdy odpowiedział prozą zamiast A2UI).
/// Bez tego taka odpowiedź znikała bez śladu i ekran zostawał pusty.
 String? get latestText;
/// Create a copy of GenUiChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenUiChatStateCopyWith<GenUiChatState> get copyWith => _$GenUiChatStateCopyWithImpl<GenUiChatState>(this as GenUiChatState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GenUiChatState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenUiChatState&&const DeepCollectionEquality().equals(other.turns, _this.turns)&&(identical(other.isWaiting, _this.isWaiting) || other.isWaiting == _this.isWaiting)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.latestText, _this.latestText) || other.latestText == _this.latestText));
}


@override
int get hashCode {
  final _this = this as GenUiChatState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.turns),_this.isWaiting,_this.error,_this.latestText);
}

@override
String toString() {
  final _this = this as GenUiChatState;
  return 'GenUiChatState(turns: ${_this.turns}, isWaiting: ${_this.isWaiting}, error: ${_this.error}, latestText: ${_this.latestText})';
}


}

/// @nodoc
abstract mixin class $GenUiChatStateCopyWith<$Res>  {
  factory $GenUiChatStateCopyWith(GenUiChatState value, $Res Function(GenUiChatState) _then) = _$GenUiChatStateCopyWithImpl;
@useResult
$Res call({
 List<ChatTurn> turns, bool isWaiting, String? error, String? latestText
});




}
/// @nodoc
class _$GenUiChatStateCopyWithImpl<$Res>
    implements $GenUiChatStateCopyWith<$Res> {
  _$GenUiChatStateCopyWithImpl(this._self, this._then);

  final GenUiChatState _self;
  final $Res Function(GenUiChatState) _then;

/// Create a copy of GenUiChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? turns = null,Object? isWaiting = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(GenUiChatState(
turns: null == turns ? _self.turns : turns // ignore: cast_nullable_to_non_nullable
as List<ChatTurn>,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenUiChatState].
extension GenUiChatStatePatterns on GenUiChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenUiChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenUiChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenUiChatState value)  $default,){
final _that = this;
switch (_that) {
case _GenUiChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenUiChatState value)?  $default,){
final _that = this;
switch (_that) {
case _GenUiChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatTurn> turns,  bool isWaiting,  String? error,  String? latestText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenUiChatState() when $default != null:
return $default(_that.turns,_that.isWaiting,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatTurn> turns,  bool isWaiting,  String? error,  String? latestText)  $default,) {final _that = this;
switch (_that) {
case _GenUiChatState():
return $default(_that.turns,_that.isWaiting,_that.error,_that.latestText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatTurn> turns,  bool isWaiting,  String? error,  String? latestText)?  $default,) {final _that = this;
switch (_that) {
case _GenUiChatState() when $default != null:
return $default(_that.turns,_that.isWaiting,_that.error,_that.latestText);case _:
  return null;

}
}

}

/// @nodoc


class _GenUiChatState extends GenUiChatState {
  const _GenUiChatState({ List<ChatTurn> turns = const <ChatTurn>[], this.isWaiting = false, this.error, this.latestText}): _turns = turns,super._();
  

 final  List<ChatTurn> _turns;
@override@JsonKey() List<ChatTurn> get turns {
  if (_turns is EqualUnmodifiableListView) return _turns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_turns);
}

@override@JsonKey() final  bool isWaiting;
@override final  String? error;
/// Zwykły tekst od modelu (gdy odpowiedział prozą zamiast A2UI).
/// Bez tego taka odpowiedź znikała bez śladu i ekran zostawał pusty.
@override final  String? latestText;

/// Create a copy of GenUiChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenUiChatStateCopyWith<_GenUiChatState> get copyWith => __$GenUiChatStateCopyWithImpl<_GenUiChatState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenUiChatState&&const DeepCollectionEquality().equals(other.turns, _turns)&&(identical(other.isWaiting, isWaiting) || other.isWaiting == isWaiting)&&(identical(other.error, error) || other.error == error)&&(identical(other.latestText, latestText) || other.latestText == latestText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_turns),isWaiting,error,latestText);
}

@override
String toString() {
    return 'GenUiChatState(turns: $turns, isWaiting: $isWaiting, error: $error, latestText: $latestText)';
}


}

/// @nodoc
abstract mixin class _$GenUiChatStateCopyWith<$Res> implements $GenUiChatStateCopyWith<$Res> {
  factory _$GenUiChatStateCopyWith(_GenUiChatState value, $Res Function(_GenUiChatState) _then) = __$GenUiChatStateCopyWithImpl;
@override @useResult
$Res call({
 List<ChatTurn> turns, bool isWaiting, String? error, String? latestText
});




}
/// @nodoc
class __$GenUiChatStateCopyWithImpl<$Res>
    implements _$GenUiChatStateCopyWith<$Res> {
  __$GenUiChatStateCopyWithImpl(this._self, this._then);

  final _GenUiChatState _self;
  final $Res Function(_GenUiChatState) _then;

/// Create a copy of GenUiChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? turns = null,Object? isWaiting = null,Object? error = freezed,Object? latestText = freezed,}) {
  return _then(_GenUiChatState(
turns: null == turns ? _self._turns : turns // ignore: cast_nullable_to_non_nullable
as List<ChatTurn>,isWaiting: null == isWaiting ? _self.isWaiting : isWaiting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,latestText: freezed == latestText ? _self.latestText : latestText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
