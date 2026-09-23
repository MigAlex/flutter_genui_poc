import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

import 'package:flutter_genui_poc/commons/a2ui/client_data_model.dart';

/// Wiadomość taka, jaką buduje `SurfaceController.handleUiEvent` po kliknięciu
/// przycisku w wygenerowanym UI — **sam event, zero wartości pól**. To właśnie
/// jest dziura, którą łata [withClientDataModel].
ChatMessage _submit({required String surfaceId}) => ChatMessage.user(
  '',
  parts: [
    UiInteractionPart.create(
      jsonEncode({
        'version': 'v0.9',
        'action': {
          'surfaceId': surfaceId,
          'name': 'plan_trip',
          'sourceComponentId': 'submit_btn',
          'timestamp': '2026-08-12T10:00:00.000',
          'context': <String, Object?>{},
        },
      }),
    ),
  ],
);

String _payloads(ChatMessage message) =>
    message.parts.uiInteractionParts.map((p) => p.interaction).join('\n');

void main() {
  test('dokleja wypełnione pola powierzchni, która wysłała akcję', () {
    final dataModel = InMemoryDataModel()
      ..update(DataPath('/trip/budget'), 5000)
      ..update(DataPath('/trip/destination'), 'Kreta');
    addTearDown(dataModel.dispose);

    final enriched = withClientDataModel(
      _submit(surfaceId: 's1'),
      dataModelFor: (id) => id == 's1' ? dataModel : null,
    );

    final payloads = _payloads(enriched);
    expect(payloads, contains('5000'), reason: 'model ma zobaczyć budżet');
    expect(payloads, contains('Kreta'));
    expect(
      payloads,
      contains('plan_trip'),
      reason: 'oryginalna akcja nie może zniknąć',
    );
  });

  test('zachowuje kształt, który wysłałby sam framework', () {
    final dataModel = InMemoryDataModel()
      ..update(DataPath('/trip/budget'), 5000);
    addTearDown(dataModel.dispose);

    final enriched = withClientDataModel(
      _submit(surfaceId: 's1'),
      dataModelFor: (_) => dataModel,
    );

    // Ta sama struktura co martwe `MessageProcessor.getClientDataModel()`
    // w a2ui_core — żeby dało się to skasować bez zmiany kontraktu, gdy
    // paczka w końcu zacznie wołać własną funkcję.
    final added = jsonDecode(_payloads(enriched).split('\n').last)
        as Map<String, Object?>;
    expect(added['version'], 'v0.9');
    expect(
      (added['surfaces']! as Map<String, Object?>)['s1'],
      {
        'trip': {'budget': 5000},
      },
    );
  });

  test('zwykły prompt (bez interakcji) przechodzi bez zmian', () {
    final message = ChatMessage.user('Zaplanuj mi wyjazd');

    final enriched = withClientDataModel(
      message,
      dataModelFor: (_) => InMemoryDataModel(),
    );

    expect(enriched.parts, hasLength(message.parts.length));
    expect(enriched.text, 'Zaplanuj mi wyjazd');
  });

  test('pusty DataModel nie dokłada szumu', () {
    final dataModel = InMemoryDataModel();
    addTearDown(dataModel.dispose);

    final message = _submit(surfaceId: 's1');
    final enriched = withClientDataModel(
      message,
      dataModelFor: (_) => dataModel,
    );

    expect(enriched.parts, hasLength(message.parts.length));
  });

  test('nieznana powierzchnia nie wywraca wysyłki', () {
    final message = _submit(surfaceId: 'zniknieta');

    expect(
      () => withClientDataModel(message, dataModelFor: (_) => null),
      returnsNormally,
    );
    expect(
      withClientDataModel(message, dataModelFor: (_) => null).parts,
      hasLength(message.parts.length),
    );
  });

  test('uszkodzony payload interakcji nie wywraca wysyłki', () {
    final message = ChatMessage.user(
      '',
      parts: [UiInteractionPart.create('to nie jest JSON')],
    );

    expect(
      () => withClientDataModel(message, dataModelFor: (_) => null),
      returnsNormally,
    );
  });
}
