# Eksperymenty ④ i ⑤ na żywym Haiku 4.5 — przebieg z 2026-08-11

> Wariant A/B odpalony pierwszy, warianty C i D dopisane tego samego dnia.
> Macierz 2×2 wywróciła wniosek z pierwszego podejścia — patrz „Odkrycie uboczne".

Odtworzenie: `flutter test test/advisor_ab_e2e_test.dart --dart-define-from-file=secrets.json`

Model: `claude-haiku-4-5`. Kryteria w obu wariantach identyczne: budżet 60 000 PLN,
nadwozie `wagon`, paliwo `diesel`, przebieg do 180 000 km.

---

## ④ CarCard bez i z regułą użycia — **hipoteza się NIE potwierdziła**

Pierwsze podejście (A/B):

| | Wariant A (reguła WŁ.) | Wariant B (reguła WYŁ.) |
| --- | --- | --- |
| system prompt | 30 209 zn. | 29 886 zn. |
| prompt wspomina `CarCard` | TAK | TAK |
| komponenty użyte | `{CarCard, Column, Text}` | `{CarCard, Column, Text}` |
| **`CarCard` użyty** | **TAK** | **TAK** |
| proza zamiast UI | — | — |
| czas tury | 5 734 ms (1. chunk po 1 547 ms) | 6 276 ms (1. chunk po 2 643 ms) |
| delty SSE | 14 | 17 |

Różnica promptów: **323 znaki** — dokładnie długość `carCardUsageRule`.

Kurs (L2 §4) zakłada, że bez reguły użycia model **widzi** własny widget i mimo to
składa ofertę z `Card` + `Text`. **Tutaj sięgnął po `CarCard` w obu wariantach**,
i to od razu po trzy karty.

### Wariant C i D (dopisane tego samego dnia) — pełna macierz

Pierwsze podejrzenie brzmiało: „reguła (warstwa 4) była mierzona przy włączonym
`exampleData` (warstwa 3)". Żeby to rozdzielić, doszły dwie komórki — i **całe
podejrzenie okazało się fałszywe**.

| wariant | reguła | `exampleData` | prompt | wynik |
| --- | --- | --- | --- | --- |
| A | WŁ | WŁ | 30 209 zn. | `CarCard` UŻYTY · `{CarCard, Column, Text}` |
| B | WYŁ | WŁ | 29 886 zn. | `CarCard` UŻYTY · `{CarCard, Column, Text}` |
| C | WYŁ | WYŁ | 29 886 zn. | `CarCard` UŻYTY · `{CarCard, Column, Divider, Text}` |
| D | WŁ | WYŁ | 30 209 zn. | `CarCard` UŻYTY · `{CarCard, Column, Text}` |

**Cztery komórki na cztery — `CarCard` użyty zawsze.**

### ⚠️ Odkrycie uboczne ważniejsze od samego eksperymentu

Zwróć uwagę na kolumnę „prompt": **C ma dokładnie tyle znaków co B, a D tyle co A.**
Zdjęcie `exampleData` nie zmieniło promptu ani o znak.

Zmierzone wprost (genui 0.10.1):

```
custom  z przykładem 29 098 zn. · bez 29 098 zn. · identyczne: true
chat    z przykładem 24 630 zn. · bez 24 630 zn. · identyczne: true
markery występujące WYŁĄCZNIE w exampleData ("show_similar", "128000"):
  nieobecne w obu wariantach, w obu builderach
```

`CatalogItem.exampleData` **nie trafia do system promptu** — ani przez
`PromptBuilder.chat`, ani przez `PromptBuilder.custom`. W całej paczce czyta to
jedno miejsce:

```
genui-0.10.1/lib/test/validation.dart:54
  for (var i = 0; i < item.exampleData.length; i++) { … }
```

czyli **helper testowy**, który renderuje każdy przykład, żeby sprawdzić, że
`widgetBuilder` się nie wywala. To jest darmowy smoke-test buildera i w tej roli
`exampleData` warto mieć — ale **nie jest to żadna „warstwa wpływu na model"**.

Konsekwencja dla kursu: teza o czterech warstwach rosnącej siły (`name` →
`dataSchema` → `exampleData` → `systemPromptFragments`) **jest nieprawdziwa dla
0.10.1**. Warstwy są trzy; `exampleData` w prompcie nie istnieje.

### Co zatem sprawiło, że model użył `CarCard` bez reguły

Wariant C (ani reguły, ani przykładu) i tak trafił w widget. Zostają dwa
kandydaci, oba niesprawdzone osobno:

1. **Wąski katalog** — 7 pozycji, 30k zn. promptu wobec ~51k czatu. `CarCard`
   jest jedyną pozycją pasującą do „pokaż oferty aut", a konkurencja to
   kontenery i `Text`.
2. **Mocny `description` w schemacie** — *„A rich card presenting ONE concrete
   used-car offer… Renders as a native Material card in the host app."* To jest
   opis mówiący nie tylko CO widget przyjmuje, ale i DO CZEGO służy, czyli
   część roboty, którą kurs przypisuje regule użycia.

Różnica wobec przebiegu z 2026-07-22 (gdzie model `CarCard` pominął) leży więc
gdzieś w tych dwóch, plus w tym, że tamten test szedł na **szerokim katalogu
w trybie czatu**, a nie na wąskim panelu z `updateOnly`.

**Uprawniony wniosek:** przy wąskim katalogu i opisowym `description` reguła
użycia nie była potrzebna. **Nieuprawniony:** że reguła jest zbędna w ogóle —
przy 18-pozycyjnym katalogu czatu nikt tego nie sprawdzał.

### Co model faktycznie wygenerował

**Wariant A** — `Column(root)` → `Text` nagłówek (`variant: h3`) + `Text` podtytuł
(`variant: caption`) + 3× `CarCard`:

```json
{"id": "car1", "component": "CarCard",
 "title": "Skoda Octavia III 1.6 TDI Ambition",
 "pricePln": 54900, "year": 2016, "mileageKm": 165000, "fuel": "diesel",
 "highlight": "Niskoemisyjny diesel, zadbane, idealny do pracy i rodziny."}
```

Pozostałe: VW Golf VI Variant 1.6 TDI (48 500 / 2014 / 172 tys.),
Ford Focus C-Max 1.6 TDCI (42 800 / 2013 / 178 tys.).

**Wariant B** — ten sam kształt, o jeden `Text` mniej:

```json
{"id": "car2", "component": "CarCard",
 "title": "Volkswagen Passat B7 2.0 TDI Comfortline",
 "pricePln": 59500, "year": 2015, "mileageKm": 178000, "fuel": "diesel",
 "highlight": "Przestronny wagon, wszechstronna konstrukcja, warte każdej złotówki."}
```

Pozostałe: Skoda Octavia III 1.6 TDI (54 900 / 2016 / 165 tys.),
Peugeot 508 SW 2.0 HDi Active (48 700 / 2014 / 172 tys.).

### Trzy obserwacje poboczne

- **Model owija A2UI w ` ```json ` fences.** Parser genui to przełyka bez mrugnięcia,
  ale gdybyś kiedyś parsował odpowiedź sam — to jest pierwsza rzecz, o którą się
  rozbijesz.
- **Nie wypełnia pól opcjonalnych.** Ani razu nie pojawiło się `actionLabel`/`action`,
  choć schemat je oferuje. Widget bez `onPressed` renderuje się poprawnie, ale
  jeśli akcja jest istotna dla flow — musi być w `required` albo w regule.
- **Polszczyzna bywa krzywa** („komfortable wnętrze", „pojazdów po serwisie",
  „ekonomiczny paliw"). Prośba o polski tekst w angielskim prompcie działa, ale
  Haiku nie pilnuje fleksji. Do produkcji: albo większy model, albo copy z kodu.

---

## ⑤ Prompt caching — **realnie trafia**

Dwie tury na tym samym agencie (identyczny system prompt, różne kryteria):

| | tura 1 | tura 2 |
| --- | --- | --- |
| input tokens | 117 | 875 |
| output tokens | 643 | 638 |
| **cache zapis** | 0 | 0 |
| **cache odczyt** | **7 723** | **7 723** |
| czas | 5 715 ms | 6 016 ms |

A w pierwszym uruchomieniu (A/B powyżej), gdy cache był zimny:

| | wariant A | wariant B |
| --- | --- | --- |
| cache zapis | 7 723 | 7 650 |
| cache odczyt | 0 | 0 |

Czyli pełny cykl: **pierwszy request zapisuje 7 723 tokeny, każdy następny z tym
samym system promptem czyta je zamiast płacić pełną stawkę.** Do 2026-08-04
potwierdzone było tylko tyle, że API przyjmuje formę `system` z `cache_control` —
teraz wiadomo, że cache faktycznie trafia.

⚠️ **Przełączenie A/B unieważnia cache.** Warianty różnią się system promptem
o 323 znaki, więc pierwszy request po przełączeniu zapisuje go od nowa (widać
to w tabeli: 7 723 vs 7 650 — dwa osobne wpisy). Przy porównywaniu kosztu
wariantów trzeba to wliczyć.

Rząd wielkości: ~7,7 tys. tokenów na turę to cały narzut protokołu A2UI
i katalogu. Bez cache'u pięć kliknięć w wygenerowany panel = pięciokrotna
opłata za tę samą treść.

---

## Jak podejrzeć to samemu

Inspektor „drutu" (`lib/commons/logging/genui_wire_log.dart`) loguje każdy
request i response w debug console — rozmiar promptu, wariant A/B, treść
wiadomości, liczniki tokenów, użyte komponenty i werdykt. Jest debug-only.

Surowy A2UI od modelu (domyślnie wyciszony, bo to kilka kB na turę):

```dart
GenUiWire.dumpRawBody = true;
```
