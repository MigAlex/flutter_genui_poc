// Test E2E na ŻYWYM Anthropic API — kosztuje ułamek centa za run.
// Pomija się sam, gdy brak klucza:
//   flutter test --dart-define-from-file=secrets.json
//
// Pilnuje regresji, która realnie wystąpiła: bez fragmentu wymuszającego UI
// Haiku odpowiadał zwykłą prozą i ekran zostawał pusty.
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/data/anthropic/anthropic_stream_api.dart';
import 'package:flutter_genui_poc/app/di.dart';
import 'package:flutter_genui_poc/features/genui_chat/cubit/genui_chat_cubit.dart';
import 'package:flutter_genui_poc/genui_agent/claude_genui_agent.dart';

void main() {
  test(
    'E2E: "siema" → realny Claude → surface w stanie (nie proza)',
    () async {
      // Jeden katalog do agenta (prompt) i do cubita (renderer) — dokładnie
      // ta niezmienniczość, którą trzyma DI. Test też jej pilnuje.
      final catalog = BasicCatalogItems.asCatalog();
      final cubit = GenUiChatCubit(
        ClaudeGenUiAgent(
          api: AnthropicStreamApi.withKey(anthropicApiKey),
          catalog: catalog,
        ),
        catalog,
      );
      addTearDown(cubit.close);

      cubit.sendPrompt('siema');

      final state = await cubit.stream
          .firstWhere((s) => s.surfaceIds.isNotEmpty || s.error != null)
          .timeout(const Duration(seconds: 90));

      expect(state.error, isNull);
      expect(
        state.surfaceIds,
        isNotEmpty,
        reason: 'Model odpowiedział prozą zamiast A2UI: ${state.latestText}',
      );
    },
    timeout: const Timeout(Duration(seconds: 120)),
    skip: anthropicApiKey.isEmpty
        ? 'Brak ANTHROPIC_API_KEY — pomijam test na żywym API'
        : null,
  );
}
