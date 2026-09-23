import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/advisor_criteria.dart';

part 'car_advisor_state.freezed.dart';

@freezed
abstract class CarAdvisorState with _$CarAdvisorState {
  const factory CarAdvisorState({
    @Default(AdvisorCriteria()) AdvisorCriteria criteria,

    /// Id powierzchni panelu — jedna na cały ekran, założona przez hosta.
    String? panelSurfaceId,

    /// Czy powierzchnia ma już jakąkolwiek treść. Osobno od [panelSurfaceId],
    /// bo powierzchnia istnieje od startu (bootstrap), a komponenty dopiero
    /// po pierwszej odpowiedzi — renderowanie pustego `Surface` pokazałoby
    /// user'owi nic, zamiast podpowiedzi „ustaw kryteria".
    @Default(false) bool hasContent,
    @Default(false) bool isWaiting,

    /// Czy `CarCard` jest w katalogu **idącym do promptu**.
    ///
    /// Wyłączony = model o widgecie nie wie i musi złożyć ofertę z `Card`
    /// i `Text`. To jest przełącznik demonstracyjny („katalog jest sufitem
    /// tego, co model umie narysować"), a nie dawne A/B na regule użycia —
    /// tamto zmieniało prompt o 323 znaki i na żywym Haiku nie zmieniało
    /// wyniku, więc jako przełącznik w UI wyglądało po prostu na zepsute.
    @Default(true) bool carCardInCatalog,

    /// Czy panel kryteriów jest zwinięty do jednej linii podsumowania.
    ///
    /// Zwija się **sam po pierwszym wyniku**: suwaki i chipy zajmują ~2/3
    /// ekranu telefonu, więc wygenerowany panel — czyli to, po co ten ekran
    /// istnieje — lądował pod zgięciem i trzeba go było scrollować w okienku
    /// wysokości kilku centymetrów.
    @Default(false) bool criteriaCollapsed,

    /// Komponenty użyte w ostatniej odpowiedzi modelu — wynik eksperymentu.
    @Default(<String>{}) Set<String> lastComponents,
    @Default(0) int requestCount,
    String? error,

    /// Proza od modelu. Na tym ekranie to **objaw błędu**, nie treść:
    /// dyscyplina panelu mówi „zawsze updateComponents".
    String? latestText,
  }) = _CarAdvisorState;

  const CarAdvisorState._();

  /// Werdykt eksperymentu ④ w jednym gettterze.
  bool get carCardUsed => lastComponents.contains('CarCard');

  bool get hasResult => lastComponents.isNotEmpty;
}
