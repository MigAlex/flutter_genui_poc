import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/features/genui_chat/cubit/genui_chat_cubit.dart';
import 'package:flutter_genui_poc/genui_agent/genui_agent.dart';

/// Regresja na prozę lecącą **strumieniem**.
///
/// `ConversationContentReceived` emituje się RAZ NA CHUNK (parser opróżnia
/// bufor przy każdym `addChunk`, a `incomingText` mapuje `TextEvent` 1:1), więc
/// podmiana `latestText` zamiast doklejania pokazuje ostatni strzęp zdania
/// zamiast całej odpowiedzi. Objaw wygląda jak halucynacja modelu („uciął w
/// pół zdania"), a jest błędem konsumenta.
///
/// Druga połowa tej samej pułapki mieszka w paczce: do genui 0.10.1
/// `incomingText` robiło `.trim()` na każdym chunku, więc sklejanie zlepiało
/// słowa. 0.10.2 to naprawiło — dlatego test sprawdza dokładnie spacje na
/// granicach chunków.
void main() {
  test('Proza ze strumienia skleja się w całość, ze spacjami', () async {
    final cubit = GenUiChatCubit(
      _ProseAgent(const ['Cześć! ', 'W czym ', 'mogę pomóc?']),
      BasicCatalogItems.asCatalog(),
    )..sendPrompt('siema');

    await _settle();

    expect(cubit.state.latestText, 'Cześć! W czym mogę pomóc?');
    await cubit.close();
  });

  test('Nowa tura zaczyna bufor od zera, nie dokleja do poprzedniej', () async {
    final cubit = GenUiChatCubit(
      _ProseAgent(const ['Pierwsza.']),
      BasicCatalogItems.asCatalog(),
    )..sendPrompt('raz');
    await _settle();
    expect(cubit.state.latestText, 'Pierwsza.');

    cubit.sendPrompt('dwa');
    await _settle();

    expect(
      cubit.state.latestText,
      'Pierwsza.',
      reason: 'ta sama treść z nowej tury, a nie „Pierwsza.Pierwsza."',
    );
    await cubit.close();
  });
}

/// Agent, który odpowiada wyłącznie prozą — chunk po chunku, tak jak `text_delta`
/// z SSE. Zero A2UI: to jest właśnie ścieżka, na której model „nie narysował UI".
class _ProseAgent implements GenUiAgent {
  const _ProseAgent(this.chunks);

  final List<String> chunks;

  @override
  String get label => 'proza (test)';

  @override
  bool get isMock => true;

  @override
  Future<void> respond(
    ChatMessage message,
    A2uiTransportAdapter transport,
  ) async {
    for (final chunk in chunks) {
      transport.addChunk(chunk);
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  @override
  void reset() {}
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 300));
