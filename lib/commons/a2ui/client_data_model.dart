import 'dart:convert';

import 'package:genui/genui.dart';

/// Dokleja do wychodzącej wiadomości **wartości, które user wpisał
/// w wygenerowanym UI**. Bez tego model ich nie widzi.
///
/// Powód: pętla formularza w genui jest **otwarta**. `handleUiEvent` wysyła
/// „user nacisnął przycisk X" bez wartości pól, więc model uczciwie generuje
/// kolejny ekran z placeholderami „[Czekam na dane]". Paczka ma na to własny
/// mechanizm (`MessageProcessor.getClientDataModel()`) i **nikt go nie woła**.
///
/// Kształt doklejanej wiadomości jest **celowo identyczny** z tym, co zwracałoby
/// tamto martwe API — gdy paczka zacznie je wołać, ten plik kasuje się bez
/// zmiany kontraktu wobec modelu.
///
/// Pełna anatomia tej łaty, czyli co dokładnie gubi się po drodze i dlaczego
/// naprawa siedzi w hoście, jest opisana w notatkach do POC-a (poza repo).
ChatMessage withClientDataModel(
  ChatMessage message, {
  required DataModel? Function(String surfaceId) dataModelFor,
}) {
  final surfaces = <String, Object?>{};

  for (final surfaceId in _surfaceIdsIn(message)) {
    final data = dataModelFor(surfaceId)?.getValue<Object?>(DataPath('/'));
    // Pusty DataModel to normalny przypadek (klik w zwykły przycisk, bez
    // żadnego pola) — wtedy nie dokładamy nic, żeby nie zaśmiecać promptu.
    if (data is Map && data.isNotEmpty) surfaces[surfaceId] = data;
  }

  if (surfaces.isEmpty) return message;

  return ChatMessage(
    role: message.role,
    parts: [
      ...message.parts,
      UiInteractionPart.create(
        jsonEncode({'version': 'v0.9', 'surfaces': surfaces}),
      ),
    ],
    metadata: message.metadata,
    finishStatus: message.finishStatus,
  );
}

/// Wyławia `surfaceId` z payloadów interakcji.
///
/// Payload przychodzi jako **string z JSON-em**, więc może być wszystkim —
/// parsujemy defensywnie. To leci w ścieżce wysyłki: wyjątek tutaj zabiłby
/// turę przez coś, co jest tylko wzbogaceniem promptu.
Set<String> _surfaceIdsIn(ChatMessage message) {
  final ids = <String>{};

  for (final part in message.parts.uiInteractionParts) {
    final Object? decoded = switch (part.interaction) {
      final raw => _tryDecode(raw),
    };
    if (decoded case {'action': {'surfaceId': final String id}}) ids.add(id);
  }

  return ids;
}

Object? _tryDecode(String raw) {
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}
