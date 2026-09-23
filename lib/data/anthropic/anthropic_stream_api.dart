import 'dart:convert';

import 'package:dio/dio.dart';

import '../../commons/logging/genui_wire_log.dart';
import 'anthropic_headers_interceptor.dart';
import 'endpoints.dart';

/// Cienki wrapper na Anthropic Messages API ze streamingiem SSE.
///
/// Konwencja projektu (`conv-flutter-networking`): **Dio dla REST, `SSE:
/// ResponseType.stream`**, Api jest cienkie i nie zna domeny. Wcześniej ten
/// sam blok HTTP + pętla SSE był **skopiowany w trzech agentach** i różnił się
/// wyłącznie wartością `max_tokens`.
///
/// Api **nie wie nic o genui** — zwraca strumień tekstu. Co z nim zrobić
/// (`transport.addChunk`, licznik chunków, historia) należy do agenta.
class AnthropicStreamApi {
  const AnthropicStreamApi(this._dio);

  /// Gotowa instancja z samego klucza — dla testów i skryptów, które nie
  /// stawiają DI. Produkcyjnie Dio przychodzi z `setupDI()`.
  factory AnthropicStreamApi.withKey(String apiKey) => AnthropicStreamApi(
    Dio(
      BaseOptions(
        baseUrl: Endpoints.anthropicBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 2),
      ),
    )..interceptors.add(AnthropicHeadersInterceptor(apiKey)),
  );

  final Dio _dio;

  /// Zamyka klienta. Woła to ten, kto instancję stworzył — przy DI robi to
  /// `dispose` rejestracji, w testach sam test.
  void close() => _dio.close();

  /// Strumień **tekstowych delt** odpowiedzi modelu.
  ///
  /// [usage] jest wypełniane po drodze — liczniki tokenów lecą w osobnych
  /// eventach (`message_start`, `message_delta`), nie w deltach tekstu,
  /// więc trzeba je wyłapać w tej samej pętli.
  Stream<String> streamText({
    required String model,
    required int maxTokens,
    required String systemPrompt,
    required List<Map<String, Object?>> messages,
    required TokenUsage usage,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      Endpoints.messages,
      data: {
        'model': model,
        'max_tokens': maxTokens,
        'stream': true,
        // System prompt jest IDENTYCZNY w każdym requeście, a każdy klik
        // w wygenerowane UI to nowy request — stąd `cache_control`:
        // pierwszy zapisuje, kolejne czytają za ułamek ceny.
        'system': [
          {
            'type': 'text',
            'text': systemPrompt,
            'cache_control': {'type': 'ephemeral'},
          },
        ],
        'messages': messages,
        // UWAGA: NIE wysyłamy output_config.effort ani adaptive thinking —
        // oba są odrzucane błędem na modelach 4.5.
      },
      options: Options(
        responseType: ResponseType.stream,
        // Przy `ResponseType.stream` Dio nie ma jak zbudować sensownej
        // wiadomości błędu — ciało odpowiedzi jest strumieniem. Wyłączamy
        // walidację i czytamy je sami, żeby w logu wylądowała treść
        // odpowiedzi API, a nie samo „status 400".
        validateStatus: (_) => true,
      ),
    );

    final body = response.data!;

    if (response.statusCode != 200) {
      final error = await utf8.decodeStream(body.stream.cast<List<int>>());
      throw Exception('Anthropic API ${response.statusCode}: $error');
    }

    final lines = body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;

      final event = jsonDecode(line.substring(6)) as Map<String, Object?>;

      if (usage.absorb(event)) continue;
      if (event['type'] != 'content_block_delta') continue;

      final delta = event['delta'] as Map<String, Object?>?;
      if (delta?['type'] != 'text_delta') continue;

      final text = delta!['text'] as String? ?? '';
      if (text.isEmpty) continue;

      yield text;
    }
  }
}
