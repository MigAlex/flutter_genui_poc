import 'package:dio/dio.dart';

/// Nagłówki Anthropic w jednym miejscu.
///
/// Konwencja projektu: **nowe nagłówki wyłącznie przez `Interceptor`**, nie
/// wpisywane przy każdym requeście. Wcześniej te trzy linie były skopiowane
/// w trzech agentach.
class AnthropicHeadersInterceptor extends Interceptor {
  const AnthropicHeadersInterceptor(this.apiKey);

  /// ⚠️ POC: klucz w kliencie, wyciągalny z binarki.
  /// Produkcyjnie idzie się przez własny proxy backend (patrz README).
  final String apiKey;

  static const _version = '2023-06-01';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'content-type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': _version,
    });
    handler.next(options);
  }
}
