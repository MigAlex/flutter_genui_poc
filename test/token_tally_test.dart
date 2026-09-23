import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_genui_poc/commons/logging/genui_wire_log.dart';
import 'package:flutter_genui_poc/commons/logging/token_tally.dart';

void main() {
  group('TokenTally', () {
    test('pusty bilans mówi „brak tury", a nie „zero"', () {
      const tally = TokenTally();

      expect(tally.turns, 0);
      expect(tally.cacheShare, isNull, reason: 'zero i brak danych to co innego');
      expect(tally.describe(), 'tokeny: brak tury modelu');
    });

    test('sumuje tury i liczy udział cache w całym wejściu', () {
      // Tura 1: cache zapisany (pierwszy raz z tym system promptem).
      final t1 = const TokenTally().add(
        TokenUsage(input: 200, output: 300, cacheCreation: 8000),
      );
      // Tura 2: ten sam prompt — cache odczytany.
      final t2 = t1.add(TokenUsage(input: 200, output: 250, cacheRead: 8000));

      expect(t2.turns, 2);
      expect(t2.output, 550);
      expect(t2.inputTotal, 200 + 8000 + 200 + 8000);
      expect(t2.cacheRead, 8000);
      // 8000 z 16400 wejścia obsłużył cache.
      expect(t2.cacheShare, closeTo(8000 / 16400, 0.0001));
      expect(t2.inputPerTurn, 8200);
    });

    test('to jest właściwy licznik: prompt leci w KAŻDEJ turze', () {
      // Sedno pomiaru — nie „ile kosztowała ostatnia tura", tylko czy wejście
      // na turę zostaje płaskie mimo krótkich wiadomości usera.
      var tally = const TokenTally();
      for (var i = 0; i < 5; i++) {
        tally = tally.add(TokenUsage(input: 30, output: 200, cacheRead: 8000));
      }

      expect(tally.turns, 5);
      expect(tally.inputPerTurn, 8030, reason: 'każda tura niesie cały prompt');
      expect(tally.describe(), contains('in/turę'));
    });

    test('jest wartością — inaczej copyWith w stanie nic by nie zmieniał', () {
      final a = const TokenTally().add(TokenUsage(input: 10, output: 20));
      final b = const TokenTally().add(TokenUsage(input: 10, output: 20));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(b.add(TokenUsage(input: 1))));
    });
  });
}
