import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../commons/a2ui/surface_contract.dart';
import '../failure/failure_injector.dart';
import '../model/support_case.dart';
import '../../../commons/logging/token_tally.dart';

part 'triage_panel_state.freezed.dart';

@freezed
abstract class TriagePanelState with _$TriagePanelState {
  const factory TriagePanelState({
    /// `null` = nikt jeszcze nie zadzwonił. Ekran startowy pokazuje wtedy same
    /// przyciski „telefon przychodzący".
    SupportCase? activeCase,

    /// Powierzchnia, którą renderuje pasek. Zwykle stała; przy wymuszonej
    /// awarii „zły catalogId" przeskakuje na tę z zepsutym katalogiem — i to
    /// jest cały sens tamtej awarii.
    String? stripSurfaceId,

    /// Czy na powierzchni są już komponenty. Osobno od [stripSurfaceId], bo
    /// powierzchnia istnieje od startu (założył ją host), a komponenty dopiero
    /// po odpowiedzi.
    @Default(false) bool hasStripContent,
    @Default(false) bool isWaiting,

    /// Czy host **egzekwuje** kontrakt. Wyłączony = werdykt nadal się liczy
    /// i widać go na pasku diagnostycznym, ale powierzchnia idzie na ekran
    /// mimo złamanej reguły. Ta para (widzę / egzekwuję) jest sednem demo:
    /// przy wyłączonym kontrakcie brak wymaganego komponentu **wygląda
    /// dokładnie jak jego brak w danych**.
    @Default(true) bool contractEnforced,
    @Default(TriageFailure.none) TriageFailure failure,

    /// Komponenty, które host **realnie dostarczył** do renderera (czyli już
    /// po ewentualnej awarii) — nie to, co wygenerował model.
    @Default(<String>{}) Set<String> lastComponents,
    ContractVerdict? verdict,

    /// Tury modelu vs kliknięcia konsultanta. Te dwie liczby obok siebie są
    /// jedynym uczciwym argumentem w sporze „każde kliknięcie kosztuje".
    @Default(0) int modelTurns,
    @Default(0) int userActions,

    /// Bilans tokenów narastająco. Obok liczby tur odpowiada na drugie pytanie
    /// z tego samego sporu: nie „ile razy", tylko „za ile".
    @Default(TokenTally()) TokenTally tokens,
    String? error,

    /// Proza od modelu. Na tym ekranie to **objaw**, nie treść.
    String? latestText,
  }) = _TriagePanelState;

  const TriagePanelState._();

  bool get rejected => verdict is SurfaceRejected;

  /// Czy pokazać pasek zapasowy złożony przez hosta ze stanu zamówienia.
  /// Odrzucona powierzchnia nie może zostawiać pustki: konsultant ma dostać
  /// deterministyczną wersję tego samego, a nie stan sprzed sekundy.
  bool get showFallbackStrip =>
      activeCase != null && contractEnforced && rejected && !isWaiting;

  bool get showGeneratedStrip =>
      hasStripContent && stripSurfaceId != null && !(contractEnforced && rejected);

  /// Jedna linia dla paska diagnostycznego. Cztery wymuszone awarie mają dać
  /// **cztery różne zdania** — to jest kryterium odbioru modułu.
  String? get diagnosis => error ?? verdict?.message;
}
