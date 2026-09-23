/// Wszystkie ścieżki w jednym miejscu — konwencja projektu
/// (`conv-flutter-networking`: „Wszystkie paths → `Endpoints`").
abstract final class Endpoints {
  static const String anthropicBase = 'https://api.anthropic.com';

  /// Messages API. Bezstanowe — cała historia leci w każdym requeście.
  static const String messages = '/v1/messages';
}
