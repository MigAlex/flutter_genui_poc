import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../../../commons/extensions/conversation_ext.dart';
import '../../../genui_agent/advisor_agent.dart';
import '../model/car_fuel.dart';
import 'car_advisor_state.dart';

/// Flow panelu doradcy — **inny niż czat, mimo tych samych klocków genui**.
///
/// Czat: wiadomość usera → model tworzy nową powierzchnię → lista rośnie.
/// Panel: zmiana stanu → model podmienia JEDNĄ powierzchnię w miejscu.
///
/// Powierzchnię zakłada host w konstruktorze, bo model przy
/// `SurfaceOperations.updateOnly` nie ma do tego prawa. Kolejność ma znaczenie:
/// najpierw subskrypcja eventów, dopiero potem bootstrap — inaczej
/// `ConversationSurfaceAdded` przeleciałoby, zanim ktokolwiek słucha.
class CarAdvisorCubit extends Cubit<CarAdvisorState> {
  CarAdvisorCubit(this._agent, this._catalog) : super(const CarAdvisorState()) {
    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _handleSend);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );
    _eventsSub = _conversation.events.listen(_onEvent);
    _agent.bootstrapPanel(_transport);
  }

  final AdvisorAgent _agent;
  final Catalog _catalog;

  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final StreamSubscription<ConversationEvent> _eventsSub;

  String get agentLabel => _agent.label;
  bool get isMock => _agent.isMock;

  /// Rozmiar promptu i to, czy w ogóle wspomina o `CarCard` — do paska A/B.
  PromptDiagnostics get diagnostics =>
      _agent.diagnostics(withCarCard: state.carCardInCatalog);

  SurfaceContext contextFor(String surfaceId) =>
      _controller.contextFor(surfaceId);

  void setBudget(int pln) => _safeEmit(
    state.copyWith(criteria: state.criteria.copyWith(budgetPln: pln)),
  );

  void setBody(CarBody body) =>
      _safeEmit(state.copyWith(criteria: state.criteria.copyWith(body: body)));

  void setFuel(CarFuel? fuel) =>
      _safeEmit(state.copyWith(criteria: state.criteria.copyWith(fuel: fuel)));

  void setMaxMileage(int km) => _safeEmit(
    state.copyWith(criteria: state.criteria.copyWith(maxMileageKm: km)),
  );

  void toggleCriteria({required bool collapsed}) =>
      _safeEmit(state.copyWith(criteriaCollapsed: collapsed));

  /// Wkłada/wyjmuje `CarCard` z katalogu idącego do promptu. Nie wysyła nic
  /// sam — te same kryteria mają polecieć dwa razy, więc request zostaje ręczny.
  ///
  /// **Czyści historię rozmowy i to jest sedno, nie sprzątanie.** Bez tego
  /// wariant bez widgetu widzi w historii własną odpowiedź sprzed przełączenia
  /// — pełną `CarCard` — a prompt panelu każe „przebuduj cały panel". Model
  /// naśladuje wtedy poprzednią turę jak przykład few-shot i próbuje użyć
  /// komponentu, którego już nie ma w jego katalogu.
  void toggleCarCard({required bool enabled}) {
    _agent.reset();
    _safeEmit(
      state.copyWith(
        carCardInCatalog: enabled,
        // Poprzedni werdykt dotyczył drugiego wariantu — zostawiony na pasku
        // czytałby się jak wynik tego, który właśnie włączono.
        lastComponents: const {},
        latestText: null,
      ),
    );
  }

  /// Wysyła **stan panelu**, nie tekst usera. Tu kończy się czat.
  void requestAdvice() {
    _safeEmit(
      state.copyWith(
        requestCount: state.requestCount + 1,
        // Kryteria ustawia się przed pierwszym wynikiem; potem miejsce należy
        // do wygenerowanego panelu.
        criteriaCollapsed: true,
      ),
    );
    _conversation.sendRequest(
      ChatMessage.user(state.criteria.describeForModel()),
    );
  }

  Future<void> _handleSend(ChatMessage message) async {
    _safeEmit(state.copyWith(isWaiting: true, error: null, latestText: null));
    try {
      final components = await _agent.respond(
        message,
        _transport,
        withCarCard: state.carCardInCatalog,
      );
      _safeEmit(state.copyWith(lastComponents: components));
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
    } finally {
      _safeEmit(state.copyWith(isWaiting: false));
    }
  }

  void _onEvent(ConversationEvent event) {
    switch (event) {
      case ConversationSurfaceAdded(:final surfaceId):
        _safeEmit(state.copyWith(panelSurfaceId: surfaceId));
      case ConversationComponentsUpdated(:final surfaceId):
        _safeEmit(state.copyWith(panelSurfaceId: surfaceId, hasContent: true));
      case ConversationSurfaceRemoved():
        // Nie powinno się zdarzyć — `updateOnly` nie daje modelowi
        // `deleteSurface`. Gdy jednak padnie, panel bez powierzchni jest
        // martwy, więc niech to widać.
        _safeEmit(
          state.copyWith(
            panelSurfaceId: null,
            hasContent: false,
            error:
                'Powierzchnia panelu została usunięta — model dostał '
                'operację, której nie powinien mieć.',
          ),
        );
      // Event leci RAZ NA CHUNK streamu → doklejamy, nie podmieniamy. Od genui
      // 0.10.2 `incomingText` nie trymuje chunków (żeby dało się je skleić bez
      // zlepiania słów), więc `trim()` per chunk przywracałby naprawiony błąd.
      case ConversationContentReceived(:final text):
        final buffered = '${state.latestText ?? ''}$text'.trimLeft();
        if (buffered.isNotEmpty) _safeEmit(state.copyWith(latestText: buffered));
      case ConversationError(:final error):
        _safeEmit(state.copyWith(error: error.toString()));
      // `isWaiting` prowadzimy sami, więc ten event nic nie wnosi. Wypisany
      // jawnie zamiast `default`, żeby `switch` na sealed `ConversationEvent`
      // był wyczerpujący: nowy typ eventu w genui ma zepsuć kompilację,
      // a nie co turę drukować się do konsoli.
      case ConversationWaiting():
        break;
    }
  }

  void _safeEmit(CarAdvisorState newState) {
    if (!isClosed) emit(newState);
  }

  /// Kolejność ma znaczenie: najpierw pętla, potem parser, na końcu kontroler.
  /// Odwrotnie parsowalibyśmy do już zamkniętego kontrolera.
  ///
  /// `awaitIdle()` broni przed pułapką cyklu życia `Conversation` — opis
  /// w [ConversationIdle]. Ten ekran jest wypychany przez `pushNamed`, więc
  /// da się go zamknąć w trakcie tury: cofnięcie w czasie czekania na poradę
  /// to najzwyklejsza rzecz pod słońcem.
  @override
  Future<void> close() async {
    await _conversation.awaitIdle();
    await _eventsSub.cancel();
    _conversation.dispose();
    _transport.dispose();
    _controller.dispose();
    return super.close();
  }
}
