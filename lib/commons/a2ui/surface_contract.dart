import 'a2ui_messages.dart';

/// Kontrakt powierzchni — **host sprawdza, co model wygenerował, zanim to
/// pokaże**.
///
/// Sedno tezy z sesji 2026-08-17: whitelist typów to za mało. Model, który
/// narysuje kanciasty layout, jest nieprzyjemny; model, który uzna przekroczony
/// limit kupiecki za nieistotny, tworzy odpowiedzialność — a **brak komponentu
/// wygląda dokładnie tak samo jak brak sygnału w danych**. Dlatego listy są trzy:
///
/// | lista | pytanie | przykład |
/// | --- | --- | --- |
/// | [allowed] | „czy w ogóle wolno to narysować" | wszystko spoza katalogu kroku |
/// | [requiredWhen] | „czy czegoś nie przemilczał" | `CreditLimitBanner` przy limicie |
/// | [forbiddenWhen] | „czy nie zaproponował czegoś zakazanego" | `OfferCard` w windykacji |
///
/// Zakazany komponent **zostaje w katalogu celowo** — blokada jest regułą stanu,
/// nie wycięciem widgetu. Ten sam katalog ma obsłużyć klienta, u którego oferta
/// jest w porządku.
///
/// Generyczny po [T] (stanie domenowym), bo predykaty reguł są jedynym miejscem,
/// w którym kontrakt dotyka domeny. Dzięki temu ten plik jest reużywalny między
/// feature'ami, a jego testy nie potrzebują ani genui, ani BOK-u.
final class SurfaceContract<T> {
  const SurfaceContract({
    required this.surfaceId,
    required this.allowed,
    this.requiredWhen = const [],
    this.forbiddenWhen = const [],
  });

  /// Powierzchnia, której host się spodziewa. Model przy `updateOnly` jej nie
  /// tworzy, więc inny `surfaceId` w odpowiedzi to nie literówka, tylko sygnał,
  /// że renderujemy coś innego, niż myślimy.
  final String surfaceId;

  final Set<String> allowed;
  final List<ConditionalComponent<T>> requiredWhen;
  final List<ConditionalComponent<T>> forbiddenWhen;

  /// [requireCompleteness] rozróżnia dwa eventy genui, które łatwo pomylić:
  ///
  /// * `ConversationSurfaceAdded` — drzewo **może być w budowie**, więc listy
  ///   wymaganych nie wolno jeszcze egzekwować (`false`),
  /// * `ConversationComponentsUpdated` — drzewo dostarczone, wymagaj wszystkiego
  ///   (`true`).
  ///
  /// Bez tego rozróżnienia kontrakt odrzucałby poprawne powierzchnie w połowie
  /// ich powstawania — i wyglądałoby to na losowe.
  ContractVerdict verify(
    SurfaceSnapshot snapshot,
    T subject, {
    required bool requireCompleteness,
  }) {
    if (!snapshot.isA2ui) return const NoA2ui();

    if (snapshot.surfaceId != surfaceId) {
      return WrongSurface(expected: surfaceId, actual: snapshot.surfaceId);
    }

    for (final name in snapshot.componentNames) {
      if (!allowed.contains(name)) return ComponentNotAllowed(name);
    }

    for (final rule in forbiddenWhen) {
      if (rule.when(subject) && snapshot.componentNames.contains(rule.component)) {
        return ForbiddenComponentPresent(rule.component, because: rule.rule);
      }
    }

    if (!requireCompleteness) return const SurfaceAccepted();

    if (!snapshot.hasRoot) return const MissingRoot();

    for (final rule in requiredWhen) {
      if (rule.when(subject) &&
          !snapshot.componentNames.contains(rule.component)) {
        return RequiredComponentMissing(rule.component, because: rule.rule);
      }
    }

    return const SurfaceAccepted();
  }
}

/// Reguła warunkowa: **komponent + powód + predykat na stanie**.
///
/// [rule] nie jest ozdobą — werdykt musi umieć powiedzieć, KTÓRA reguła padła.
/// „Powierzchnia odrzucona" bez nazwy reguły jest w diagnostyce bezużyteczne
/// i nie do odróżnienia od zwykłej awarii.
final class ConditionalComponent<T> {
  const ConditionalComponent({
    required this.component,
    required this.rule,
    required this.when,
  });

  final String component;
  final String rule;
  final bool Function(T subject) when;
}

/// Werdykt jest **typem, nie boolem** — host pokazuje inny ekran przy prozie,
/// inny przy złamanej regule biznesowej i inny przy komponencie spoza katalogu.
/// `bool` sklejałby te trzy przypadki w jeden komunikat „coś poszło nie tak".
sealed class ContractVerdict {
  const ContractVerdict();

  /// Jednolinijkowy opis do paska diagnostycznego. Cztery wymuszone awarie mają
  /// dawać cztery **rozróżnialne** zdania i to jest kryterium odbioru modułu.
  String get message;
}

final class SurfaceAccepted extends ContractVerdict {
  const SurfaceAccepted();

  @override
  String get message => 'Powierzchnia zgodna z kontraktem.';
}

/// Wspólny nadtyp odrzuceń — ekran pyta o `is SurfaceRejected`, a nie wylicza
/// warianty, żeby dołożenie nowej reguły nie wymagało ruszania UI.
sealed class SurfaceRejected extends ContractVerdict {
  const SurfaceRejected();

  /// Nazwa złamanej reguły — to ona idzie na pasek diagnostyczny.
  String get rule;
}

/// Model odpowiedział prozą zamiast A2UI. Najczęstsza przyczyna „pustego
/// ekranu" i jedyna, która nie jest błędem drzewa.
final class NoA2ui extends SurfaceRejected {
  const NoA2ui();

  @override
  String get rule => 'brak A2UI';

  @override
  String get message =>
      'Model odpowiedział prozą zamiast A2UI — pasek zdjęty, karta bez zmian.';
}

final class WrongSurface extends SurfaceRejected {
  const WrongSurface({required this.expected, required this.actual});

  final String expected;
  final String? actual;

  @override
  String get rule => 'powierzchnia niezgodna';

  @override
  String get message =>
      'Update poszedł na powierzchnię "${actual ?? '—'}", host oczekiwał '
      '"$expected" — renderer nie zna tego katalogu, więc na ekranie byłaby cisza.';
}

final class MissingRoot extends SurfaceRejected {
  const MissingRoot();

  @override
  String get rule => 'brak komponentu root';

  @override
  String get message =>
      'Drzewo bez komponentu id: "root" — renderer nie ma od czego zacząć '
      '(warning w logu, SizedBox.shrink() na ekranie).';
}

final class ComponentNotAllowed extends SurfaceRejected {
  const ComponentNotAllowed(this.component);

  final String component;

  @override
  String get rule => 'komponent spoza whitelisty';

  @override
  String get message =>
      'Komponent "$component" nie jest dozwolony na tym pasku.';
}

/// Cichy tryb awarii, dla którego istnieje cały kontrakt: model **przemilczał**
/// sygnał, który musi być widoczny.
final class RequiredComponentMissing extends SurfaceRejected {
  const RequiredComponentMissing(this.component, {required this.because});

  final String component;
  final String because;

  @override
  String get rule => 'brak wymaganego: $component';

  @override
  String get message =>
      'Brakuje wymaganego "$component" — reguła: $because. Powierzchnia '
      'odrzucona, leci wersja zapasowa.';
}

final class ForbiddenComponentPresent extends SurfaceRejected {
  const ForbiddenComponentPresent(this.component, {required this.because});

  final String component;
  final String because;

  @override
  String get rule => 'zakazany: $component';

  @override
  String get message =>
      'Model wstawił zakazany "$component" — reguła: $because. Powierzchnia '
      'odrzucona, leci wersja zapasowa.';
}
