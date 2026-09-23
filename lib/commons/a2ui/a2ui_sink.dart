import 'package:genui/genui.dart';

/// Wyjście agenta na „drut", **jedna metoda zamiast całego transportu**.
///
/// Istnieje po to, żeby dało się wstawić coś MIĘDZY agenta a
/// `A2uiTransportAdapter` — u nas przechwytywacz awarii. Gdyby agenci pisali
/// wprost do transportu (jak w module doradcy), psucie odpowiedzi wymagałoby
/// osobnej ścieżki dla mocka i dla Claude'a, czyli dwóch różnych demonstracji
/// tej samej rzeczy.
abstract interface class A2uiSink {
  void addChunk(String chunk);
}

/// Przejście domyślne: prosto do genui.
class TransportSink implements A2uiSink {
  const TransportSink(this._transport);

  final A2uiTransportAdapter _transport;

  @override
  void addChunk(String chunk) => _transport.addChunk(chunk);
}
