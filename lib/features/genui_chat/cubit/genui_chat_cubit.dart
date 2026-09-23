import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../../../commons/a2ui/client_data_model.dart';
import '../../../commons/extensions/conversation_ext.dart';
import '../../../genui_agent/genui_agent.dart';
import 'genui_chat_state.dart';

/// Owinięcie imperatywnego pipeline'u GenUI (Conversation / SurfaceController /
/// transport) w Cubit zgodnie z konwencjami. Stan niesie listę aktywnych
/// surface'ów; UI renderuje `Surface` per id przez [contextFor].
///
/// **Świadoma duplikacja stanu.** `Conversation` wystawia własny
/// `ConversationState` (`surfaces`, `latestText`, `isWaiting`) jako
/// `ValueListenable` — odtwarzamy te pola z eventów zamiast go czytać, bo:
/// (1) konwencje trzymają stan w Cubicie, (2) potrzebujemy `turns`, czyli
/// pogrupowania surface'ów pod prompt usera, czego płaska lista `surfaces`
/// nie daje. Zanim dołożysz tu kolejne pole — sprawdź, czy genui już go nie
/// ma; do „ile jest surface'ów" i „czy czekamy" wystarczy `conversation.state`.
class GenUiChatCubit extends Cubit<GenUiChatState> {
  /// [catalog] musi być **tym samym** obiektem, który poszedł do
  /// `PromptBuilder` w agencie — inaczej model generuje widgety, których
  /// renderer nie zna (surface bez komponentów, bez żadnego komunikatu).
  /// Dlatego katalog przychodzi z DI, a nie powstaje tutaj.
  GenUiChatCubit(this._agent, this._catalog) : super(const GenUiChatState()) {
    _buildPipeline();
  }

  final GenUiAgent _agent;
  final Catalog _catalog;

  /// Kto aktualnie generuje UI (Claude vs mock) — do pokazania w UI.
  String get agentLabel => _agent.label;

  /// Czy to atrapa. Musi być widoczne **przez cały czas**, nie tylko na pustym
  /// ekranie: mock i model rysują to samo tym samym pipeline'em, więc bez tej
  /// informacji łatwo wziąć render atrapy za dowód na zachowanie modelu.
  bool get isMock => _agent.isMock;

  // Niefinalne, bo „wyczyść czat" **odbudowuje cały pipeline** zamiast
  // kasować powierzchnie po jednej: `SurfaceController` trzyma je razem
  // z ich DataModelami i buforami pending-update, a selektywne czyszczenie
  // zostawiłoby stan, o którym nikt już nie pamięta.
  late SurfaceController _controller;
  late A2uiTransportAdapter _transport;
  late Conversation _conversation;
  late StreamSubscription<ConversationEvent> _eventsSub;

  void _buildPipeline() {
    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _handleSend);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );
    _eventsSub = _conversation.events.listen(_onEvent);
  }

  /// Kolejność ma znaczenie: najpierw pętla, potem parser, na końcu kontroler.
  /// Odwrotnie parsowalibyśmy do już zamkniętego kontrolera.
  ///
  /// `awaitIdle()` broni przed pułapką cyklu życia `Conversation` — opis
  /// w [ConversationIdle]. Czat długo uchodził bez tego tylko dlatego, że jest
  /// trasą korzeniową i nikt go nie popuje w trakcie tury; to była maskowana
  /// wersja tego samego błędu, który wywalał ekrany wypychane przez `pushNamed`.
  Future<void> _disposePipeline() async {
    await _conversation.awaitIdle();
    await _eventsSub.cancel();
    _conversation.dispose();
    _transport.dispose();
    _controller.dispose();
  }

  /// Czyści rozmowę: ekran, powierzchnie **i pamięć modelu**.
  ///
  /// Bez `_agent.reset()` wyczyszczenie samego ekranu byłoby kłamstwem —
  /// historia leci w każdym requeście, więc model dalej odpowiadałby
  /// w kontekście tur, których user już nie widzi.
  Future<void> resetChat() async {
    // Decyzja produktowa, nie zabezpieczenie: `_disposePipeline` i tak czeka
    // na koniec tury, ale kasowanie rozmowy w połowie odpowiedzi to zły UX —
    // przycisk jest w tym stanie wyszarzony (`canReset` na ekranie).
    if (state.isWaiting) return;

    await _disposePipeline();
    _agent.reset();
    _buildPipeline();
    _safeEmit(const GenUiChatState());
  }

  /// Most do widgetu `Surface` — daje kontekst renderowania danej powierzchni.
  SurfaceContext contextFor(String surfaceId) =>
      _controller.contextFor(surfaceId);

  /// Wysyła prompt użytkownika; reszta pętli (klik → nowy ekran) idzie
  /// automatycznie przez Conversation.onSubmit → onSend.
  void sendPrompt(String text) {
    final prompt = text.trim();
    if (prompt.isEmpty) return;

    // Nowa tura — prompt widoczny od razu, surface'y dokleją się do niej.
    _safeEmit(
      state.copyWith(
        turns: [
          ...state.turns,
          ChatTurn(prompt: prompt),
        ],
      ),
    );
    _conversation.sendRequest(ChatMessage.user(prompt));
  }

  Future<void> _handleSend(ChatMessage message) async {
    // Czyścimy poprzednią prozę/błąd, żeby nie wisiały nad nową odpowiedzią.
    _safeEmit(state.copyWith(isWaiting: true, error: null, latestText: null));
    try {
      // Bez tego model dostaje samo „user nacisnął przycisk" i nie widzi
      // wartości, które user wpisał w wygenerowanym formularzu — patrz
      // [withClientDataModel]. Łata siedzi tu, a nie w agencie, bo dotyczy
      // tak samo Claude'a jak atrapy.
      await _agent.respond(
        withClientDataModel(message, dataModelFor: _dataModelFor),
        _transport,
      );
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
    } finally {
      _safeEmit(state.copyWith(isWaiting: false));
    }
  }

  /// `contextFor` jest leniwe i nie rzuca, ale sięgnięcie po `dataModel`
  /// powierzchni, której kontroler już nie zna, kończy się `StateError`.
  /// Brak danych to nie jest powód, żeby wywalić całą turę.
  DataModel? _dataModelFor(String surfaceId) {
    try {
      return _controller.contextFor(surfaceId).dataModel;
    } on StateError {
      return null;
    }
  }

  void _onEvent(ConversationEvent event) {
    switch (event) {
      case ConversationSurfaceAdded(:final surfaceId):
        _safeEmit(state.copyWith(turns: _addSurface(surfaceId)));
      case ConversationSurfaceRemoved(:final surfaceId):
        _safeEmit(
          state.copyWith(
            turns: [
              for (final turn in state.turns)
                turn.copyWith(
                  surfaceIds: turn.surfaceIds
                      .where((id) => id != surfaceId)
                      .toList(),
                ),
            ],
          ),
        );
      case ConversationContentReceived(:final text):
        // Model odpowiedział prozą zamiast A2UI — pokaż to, zamiast milczeć.
        // Event leci RAZ NA CHUNK streamu → doklejamy, nie podmieniamy
        // (podmiana pokazywała ostatni strzęp odpowiedzi). Od genui 0.10.2
        // `incomingText` nie trymuje chunków właśnie po to, żeby dało się je
        // skleić bez zlepiania słów — własny `trim()` per chunk przywracałby
        // naprawiony błąd. Bufor zeruje `latestText: null` na starcie tury.
        final buffered = '${state.latestText ?? ''}$text'.trimLeft();
        if (buffered.isNotEmpty) {
          _safeEmit(state.copyWith(latestText: buffered));
        }
      case ConversationError(:final error):
        _safeEmit(state.copyWith(error: error.toString()));

      // Świadome nic-nierobienie, nie przeoczenie. `isWaiting` prowadzimy
      // sami w `_handleSend` (obejmuje też czas agenta, nie tylko transportu),
      // a drzewo komponentów renderuje `Surface` po swojemu — czat nie ma
      // czego z tym zrobić.
      case ConversationWaiting():
      case ConversationComponentsUpdated():
        break;
    }
    // Bez `default` — `ConversationEvent` jest `sealed`, więc nowy typ eventu
    // w genui zepsuje kompilację zamiast po cichu wpaść do gałęzi-śmietnika.
    // Wcześniej stał tu `debugPrint`, który przy każdej turze wypluwał dwa
    // znane, nieszkodliwe eventy — czyli szum udający czujność.
  }

  /// Dokleja surface do ostatniej tury. Gdy surface przyszedł bez promptu
  /// (np. klik w wygenerowany przycisk), zakłada turę bez tekstu.
  List<ChatTurn> _addSurface(String surfaceId) {
    final turns = [...state.turns];
    if (turns.isEmpty) {
      return [
        ChatTurn(prompt: '', surfaceIds: [surfaceId]),
      ];
    }
    final last = turns.last;
    turns[turns.length - 1] = last.copyWith(
      surfaceIds: [...last.surfaceIds, surfaceId],
    );
    return turns;
  }

  void _safeEmit(GenUiChatState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() async {
    await _disposePipeline();
    return super.close();
  }
}
