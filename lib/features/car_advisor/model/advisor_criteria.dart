import 'package:freezed_annotation/freezed_annotation.dart';

import 'car_fuel.dart';

part 'advisor_criteria.freezed.dart';

/// Kryteria doboru auta — **to jest wejście do modelu na tym ekranie**.
///
/// Różnica wobec czatu jest cała tutaj: user nie pisze zdania, tylko przesuwa
/// suwaki. [describeForModel] zamienia stan aplikacji w tekst dla modelu, więc
/// prompt jest *funkcją stanu*, a nie tym, co user wpisał. To sedno L3 §8:
/// „GenUI poza czatem" zaczyna się w miejscu, w którym `sendRequest` dostaje
/// opis stanu zamiast wiadomości.
@freezed
abstract class AdvisorCriteria with _$AdvisorCriteria {
  const factory AdvisorCriteria({
    @Default(60000) int budgetPln,
    @Default(CarBody.wagon) CarBody body,

    /// `null` = paliwo bez znaczenia.
    CarFuel? fuel,
    @Default(150000) int maxMileageKm,
  }) = _AdvisorCriteria;

  const AdvisorCriteria._();

  /// Opis stanu panelu dla modelu.
  ///
  /// Po angielsku, bo cały system prompt A2UI jest po angielsku — mieszanie
  /// języków w jednym prompcie potrafi przełączyć model na polszczyznę także
  /// w polach technicznych. Treść dla usera (`highlight`) prosimy po polsku
  /// osobnym zdaniem.
  String describeForModel() =>
      '''
APPLICATION STATE (not a chat message — the user did not type this):
- max budget: $budgetPln PLN
- body type: ${body.wireName}
- fuel: ${fuel?.wireName ?? 'any'}
- max mileage: $maxMileageKm km

Rebuild the advisor panel from scratch so that it shows 2-3 concrete used-car
suggestions available on the Polish market that match this state. Write the
user-facing copy in Polish. Keep it dense: the whole panel must fit on a phone
screen without a wall of text.''';
}
