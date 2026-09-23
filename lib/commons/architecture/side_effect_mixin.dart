import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Jednorazowe zdarzenia (snackbar, nawigacja, dialog) **obok** stanu.
///
/// Konwencja projektu (`conv-flutter-state`): snackbar nie jest stanem ekranu.
/// Gdyby nim był, wróciłby po obrocie telefonu i po każdym `rebuild`, a wtedy
/// „reklamacja złożona" pokazywałaby się drugi raz bez drugiej reklamacji.
///
/// `safeEmit` mieszka tutaj celowo — wszędzie, gdzie jest `await`, stan może
/// polecieć do zamkniętego cubita.
mixin SideEffectMixin<State, Effect> on Cubit<State> {
  final _effects = StreamController<Effect>.broadcast();

  Stream<Effect> get sideEffects => _effects.stream;

  void emitSideEffect(Effect effect) {
    if (!_effects.isClosed) _effects.add(effect);
  }

  void safeEmit(State state) {
    if (!isClosed) emit(state);
  }

  @override
  Future<void> close() async {
    await _effects.close();
    return super.close();
  }
}
