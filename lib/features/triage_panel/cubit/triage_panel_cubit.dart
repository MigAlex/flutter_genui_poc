import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../../../commons/a2ui/a2ui_messages.dart';
import '../../../commons/a2ui/a2ui_sink.dart';
import '../../../commons/a2ui/surface_contract.dart';
import '../../../commons/architecture/side_effect_mixin.dart';
import '../../../commons/extensions/conversation_ext.dart';
import '../../../genui_agent/triage_agent.dart';
import '../contract/triage_contract.dart';
import '../failure/failure_injector.dart';
import '../model/support_case.dart';
import '../model/triage_action.dart';
import 'triage_panel_state.dart';

/// Efekt uboczny ekranu: akcja z paska wykonana przez **host**.
sealed class TriageSideEffect {
  const TriageSideEffect();
}

final class ActionExecuted extends TriageSideEffect {
  const ActionExecuted(this.action);

  final TriageAction action;
}

/// Trzeci tryb genui w tym POC-u: **asysta nad nietkniętym ekranem**.
///
/// Czat dokłada bąbelki, doradca przebudowuje panel, a triage robi trzecią
/// rzecz: generuje **pasek nad kartą zamówienia, która nic o modelu nie wie**.
/// Dzięki temu awaria degraduje do stanu sprzed wdrożenia — nie ma stanu
/// „zepsuty ekran", jest tylko „brak asysty".
///
/// Cztery rzeczy, których nie ma w dwóch poprzednich modułach:
///
/// 1. **Kontrakt powierzchni** — host waliduje, zanim pokaże ([triageContract]).
/// 2. **Przechwytywacz awarii** między agentem a rendererem.
/// 3. **Klik bez tury modelu** — akcje idą magistralą hosta, nie przez
///    `UserActionEvent` (patrz [TriageActionBus]).
/// 4. **Bramka przed promptem** — brak sygnałów, brak requestu.
class TriagePanelCubit extends Cubit<TriagePanelState>
    with SideEffectMixin<TriagePanelState, TriageSideEffect> {
  TriagePanelCubit(this._agent, this._catalog, this._bus)
    : super(const TriagePanelState()) {
    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _handleSend);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );
    // Kolejność: najpierw subskrypcje, potem bootstrap. Odwrotnie
    // `ConversationSurfaceAdded` przeleciałoby, zanim ktokolwiek słucha.
    _eventsSub = _conversation.events.listen(_onEvent);
    _actionsSub = _bus.stream.listen(_onAction);
    _agent.bootstrapStrip(TransportSink(_transport));
  }

  final TriageAgent _agent;
  final Catalog _catalog;
  final TriageActionBus _bus;
  final _contract = triageContract();

  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final StreamSubscription<ConversationEvent> _eventsSub;
  late final StreamSubscription<TriageAction> _actionsSub;

  /// Powierzchnia z zepsutym katalogiem powstaje **raz** — drugie
  /// `createSurface` z tym samym id byłoby błędem protokołu, a nie awarią,
  /// którą demonstrujemy.
  var _brokenSurfaceCreated = false;

  String get agentLabel => _agent.label;
  bool get isMock => _agent.isMock;
  int get promptLength => _agent.promptLength;

  SurfaceContext contextFor(String surfaceId) =>
      _controller.contextFor(surfaceId);

  /// „Dzwoni telefon". Host łączy numer z zamówieniem i **sam** decyduje, czy
  /// jest o co pytać model.
  void answerCall(SupportCase order) {
    // Każdy telefon to inna sytuacja. Historia z poprzedniej rozmowy działa
    // wtedy jak przykład few-shot i model naśladuje poprzedni układ — ten sam
    // błąd skaził eksperyment A/B w module doradcy.
    _agent.reset();

    safeEmit(
      state.copyWith(
        activeCase: order,
        hasStripContent: false,
        lastComponents: const {},
        verdict: null,
        error: null,
        latestText: null,
      ),
    );

    // Bramka przed promptem: brak sygnałów → brak requestu. Zwykły `if`,
    // który wycina z rachunku za tokeny większość ruchu.
    if (!order.hasSignals) return;

    safeEmit(state.copyWith(modelTurns: state.modelTurns + 1));
    _conversation.sendRequest(ChatMessage.user(order.describeForModel()));
  }

  /// Sytuacja zmieniła się w trakcie rozmowy („klient dopłacił zaległość").
  /// Ten sam `surfaceId`, więc pasek przebudowuje się **w miejscu** — nie
  /// przybywa bąbelków.
  void refreshStrip(SupportCase order) {
    safeEmit(
      state.copyWith(
        activeCase: order,
        modelTurns: state.modelTurns + 1,
        error: null,
        latestText: null,
      ),
    );
    _conversation.sendRequest(ChatMessage.user(order.describeForModel()));
  }

  /// Akcja klikniętą na pasku **zapasowym** — ta sama szyna co z paska
  /// generowanego, więc licznik i snackbar zachowują się identycznie.
  void dispatchAction(TriageAction action) => _bus.dispatch(action);

  void setFailure(TriageFailure failure) =>
      safeEmit(state.copyWith(failure: failure));

  void toggleContract({required bool enforced}) =>
      safeEmit(state.copyWith(contractEnforced: enforced));

  Future<void> _handleSend(ChatMessage message) async {
    safeEmit(
      state.copyWith(
        isWaiting: true,
        hasStripContent: false,
        error: null,
        latestText: null,
        verdict: null,
        lastComponents: const {},
      ),
    );

    final injector = FailureInjector(
      target: TransportSink(_transport),
      mode: state.failure,
      brokenSurfaceNeeded: !_brokenSurfaceCreated,
    );

    try {
      if (state.failure.failsBeforeRequest) {
        throw const SocketFailure('połączenie odrzucone (wymuszone)');
      }

      await _agent.respond(message, injector);

      final delivered = injector.finish();
      if (state.failure == TriageFailure.wrongCatalog) {
        _brokenSurfaceCreated = true;
      }

      // Werdykt liczymy z tego, co **realnie poszło na drut**, a nie z tego,
      // co wygenerował model: po drodze mogła siedzieć wymuszona awaria,
      // a host broni ekranu przed tym, co dostał, nie przed intencją.
      final snapshot = A2uiMessages.snapshot(delivered);
      safeEmit(
        state.copyWith(
          lastComponents: snapshot.componentNames,
          verdict: _verdictFor(snapshot, requireCompleteness: true),
          tokens: _agent.tally,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(error: 'Nie udało się złożyć paska: $e'));
    } finally {
      // Także po awarii: nieudana tura też mogła spalić tokeny wejściowe.
      safeEmit(state.copyWith(isWaiting: false, tokens: _agent.tally));
    }
  }

  ContractVerdict? _verdictFor(
    SurfaceSnapshot snapshot, {
    required bool requireCompleteness,
  }) {
    final order = state.activeCase;
    if (order == null) return null;
    return _contract.verify(
      snapshot,
      order,
      requireCompleteness: requireCompleteness,
    );
  }

  void _onEvent(ConversationEvent event) {
    switch (event) {
      case ConversationSurfaceAdded(:final surfaceId):
        // Także powierzchnia z zepsutym katalogiem — pasek ma na nią przejść,
        // bo bez tego „cisza w UI" byłaby niewidoczna: renderowałby się
        // poprzedni, poprawny pasek.
        safeEmit(state.copyWith(stripSurfaceId: surfaceId));
      case ConversationComponentsUpdated(:final surfaceId):
        safeEmit(
          state.copyWith(stripSurfaceId: surfaceId, hasStripContent: true),
        );
      case ConversationSurfaceRemoved():
        safeEmit(state.copyWith(hasStripContent: false));
      // Proza. Na tym ekranie objaw, nie treść — pasek znika, karta zostaje.
      case ConversationContentReceived(:final text):
        final buffered = '${state.latestText ?? ''}$text'.trimLeft();
        if (buffered.isNotEmpty) safeEmit(state.copyWith(latestText: buffered));
      case ConversationError(:final error):
        safeEmit(state.copyWith(error: error.toString()));
      case ConversationWaiting():
        break;
    }
  }

  /// Klik w akcję narysowaną przez model. **Zero requestów** — reklamację
  /// składa host, a licznik tur modelu stoi w miejscu.
  void _onAction(TriageAction action) {
    safeEmit(state.copyWith(userActions: state.userActions + 1));
    emitSideEffect(ActionExecuted(action));
  }

  /// Kolejność: pętla → parser → kontroler. `awaitIdle()` broni przed pułapką
  /// cyklu życia `Conversation` (opis w [ConversationIdle]) — ten ekran zamyka
  /// się cofnięciem, także w trakcie tury.
  @override
  Future<void> close() async {
    await _conversation.awaitIdle();
    await _eventsSub.cancel();
    await _actionsSub.cancel();
    _conversation.dispose();
    _transport.dispose();
    _controller.dispose();
    return super.close();
  }
}

/// Wymuszony błąd sieci. Własny typ, żeby w teście dało się odróżnić awarię
/// zasymulowaną od prawdziwej wpadki w kodzie.
class SocketFailure implements Exception {
  const SocketFailure(this.reason);

  final String reason;

  @override
  String toString() => 'Błąd sieci: $reason';
}
