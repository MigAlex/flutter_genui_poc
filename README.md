# flutter_genui_poc

POC Flutter GenUI SDK (`genui` 0.10.3): **model odpowiada interaktywnym UI zamiast tekstem**.
Prompt → model emituje A2UI JSON → genui renderuje widgety z katalogu → klik wraca w pętli.

**Trzy tryby pracy genui, każdy na własnym ekranie** (`go_router`, enum `AppRoutes`):

| Ekran | Tryb genui | Wejście | Powierzchnie |
| --- | --- | --- | --- |
| **Czat** (`/`) | `createOnly` | tekst usera | nowa powierzchnia per odpowiedź (bąbelki) |
| **Doradca aut** (`/advisor`) | `updateOnly` | **stan apki**: suwaki i chipy | jedna, `advisor_panel`, przebudowywana w miejscu |
| **Panel BOK** (`/triage`) | `updateOnly` | **stan zamówienia**: dzwoni telefon | jedna, `triage_strip`, **pasek nad nietkniętą kartą** |

**Kreatora krokowego, czyli czwartego trybu, tu nie ma.** Na żywym modelu nie zachowuje się
zgodnie z projektem, a utrzymanie trzech torów naraz już się nie zwraca. To świadoma
decyzja, nie luka: wnioski żyją poza repo, kodu nie ma.

## Panel BOK: po co istnieje trzeci moduł

Dwa pierwsze tory odpowiadają na pytanie „czy model umie narysować UI". Trzeci odpowiada
na trudniejsze: **czy wolno wpuścić generatywny ekran tam, gdzie pominięcie czegoś kosztuje.**

Odpowiedź jest kształtem, nie ustawieniem: **nie oddawaj ekranu, dołóż pasek nad nim.**
Karta zamówienia (15 sekcji, zwykły Flutter, zero AI) zostaje bez zmian; generatywny jest
wyłącznie trzyelementowy pasek u góry. Dzięki temu awaria degraduje do stanu sprzed
wdrożenia. Nie ma stanu „zepsuty ekran", jest tylko „brak asysty".

Trzy rzeczy, których nie ma w dwóch poprzednich modułach:

1. **`SurfaceContract`, czyli kontrakt powierzchni z trzema listami.** Whitelist typów to
   za mało. Model, który narysuje kanciasty layout, jest nieprzyjemny; model, który uzna
   przekroczony limit kupiecki za nieistotny, tworzy odpowiedzialność. A brak komponentu
   wygląda tak samo jak brak sygnału w danych. Stąd `allowed` + `requiredWhen` +
   `forbiddenWhen`, a werdykt jest **typem, nie boolem** (host musi wiedzieć, KTÓRA
   reguła padła). Odrzucona powierzchnia → **pasek zapasowy złożony przez host**.
2. **Przechwytywacz awarii** między agentem a `SurfaceController`. Cztery wymuszane
   z UI awarie (proza · zły `catalogId` · wycięcie wymaganego komponentu · błąd sieci)
   działają **identycznie na atrapie i na żywym Haiku**, bo psują odpowiedź po drodze.
3. **Klik bez tury modelu.** Akcje z `ActionRow` **nie** idą przez `UserActionEvent`, bo
   ten wróciłby do `Conversation` i kosztował pełną turę. Lecą własną magistralą
   (`TriageActionBus`) prosto do hosta. Licznik na pasku laboratoryjnym pokazuje różnicę:
   tury modelu kontra kliknięcia konsultanta.

Plus **bramka przed promptem**: zamówienie bez sygnałów nie generuje requestu. Zwykły `if`,
który wycina z rachunku za tokeny większość ruchu.

## Dwa tryby agenta

| Tryb | Kiedy | Klucz API |
| --- | --- | --- |
| **Mock** | brak `ANTHROPIC_API_KEY` | ❌ nie trzeba |
| **Claude Haiku 4.5** | podany `ANTHROPIC_API_KEY` | ✅ |

Wybór jest automatyczny w `lib/app/di.dart`. Aktywny agent widać na **każdym** ekranie
(`AgentBanner`), a tap rozwija rozpiskę „co dowodzi mock, a co dopiero model".

Mocki są **trzy, po jednym na tor**, bo każdy tor ma własny `catalogId`, a mock czatu ma
basicowy zaszyty na sztywno i o cudzy katalog rozbiłby się ciszą. Żaden z nich **nie udaje
decyzji modelu**: `MockAdvisorAgent` zawsze rysuje `CarCard`, `MockTriageAgent` odgrywa
zaprojektowany pasek odczytany po `CASE-ID`. Dowodzą renderera, kontraktu i awarii, ale nie
tego, po jakie komponenty sięgnie model.

## Setup klucza: raz i z głowy

> **Klonujesz to repo pierwszy raz?** Pełny onboarding krok po kroku (klucz, kredyty, koszty,
> co robić gdy nie działa) jest w [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).

1. Skopiuj szablon i wklej swój klucz. `secrets.json` jest w `.gitignore`, więc
   **po klonie go nie ma**:

   ```bash
   cp secrets.example.json secrets.json
   ```

   Klucz zdobędziesz na [console.anthropic.com](https://console.anthropic.com) → **API Keys**.

   ⚠️ Doładuj konto w *Plans & Billing*. Świeży klucz bez środków przechodzi walidację,
   ale każdy request wraca błędem o saldzie.

2. Uruchamiaj jak zwykle, konfiguracje są gotowe:

| Gdzie | Jak |
| --- | --- |
| **VS Code / Cursor** | Run and Debug (⇧⌘D) → wybierz **genui_poc (Claude)** → F5 |
| **Terminal** | `flutter run --dart-define-from-file=secrets.json` |

Jest też wariant **genui_poc (Mock)**, bez klucza, do szybkiego sprawdzenia że apka żyje.

> Pusty `ANTHROPIC_API_KEY` daje automatyczny fallback na mocka. Nic nie wybucha,
> jeśli zapomnisz wypełnić plik; po prostu zobaczysz chip „Mock" na ekranie.

**Platformy:** `android` + `ios`. macOS **nie jest** skonfigurowany (`macos/` zawiera tylko
efemeryczny katalog `Flutter/`), więc `flutter build macos` mówi „No macOS desktop project
configured". Do demo na laptopie trzeba najpierw `flutter create --platforms=macos .`.

## ⚠️ Klucz w kliencie = tylko POC

Aplikacja woła Anthropic API **bezpośrednio z urządzenia**, więc klucz ląduje w binarce
i da się go wyciągnąć. Dla POC-a na własnym sprzęcie to w porządku. **Do produkcji** postaw
własny proxy backend (on trzyma klucz, apka gada z Twoim endpointem) albo licz lokalnie przez
[flutter_gemma](https://pub.dev/packages/flutter_gemma).

## Jak to działa

```
prompt → Conversation.sendRequest
       → A2uiTransportAdapter.onSend → Claude*Agent.respond
       → POST /v1/messages (stream: true, SSE)
       → text_delta → sink.addChunk(...)         # w triage'u: przez FailureInjector
       → A2uiParserTransformer wyławia JSON A2UI
       → SurfaceController → Surface (widgety)
       → klik → onSubmit → pętla od nowa         # w triage'u: klik → host, ZERO requestów
```

**System prompt generuje sam genui** (`PromptBuilder.chat(catalog:).systemPromptJoined()`
albo `PromptBuilder.custom(...)` w panelach). Zawiera instrukcje protokołu A2UI v0.9 plus
schemat widgetów z katalogu. Nie piszemy go ręcznie; własne reguły dokładamy przez
`systemPromptFragments`.

**Katalog czatu jest przycięty do 13 widgetów** (`asNoAssetCatalog()` minus `tabs`/`modal`)
dla trafności modelu i powierzchni ataku, **nie dla kosztu**. Zmierzone na 0.10.1: pełny
katalog (18) to 57 337 znaków promptu, ten wariant 51 361, czyli o 10% mniej. Około 20 000
znaków samego protokołu jest nieredukowalne. Realną dźwignią kosztową jest **prompt
caching**: `system` jako blok z `cache_control: {type: ephemeral}` (zmierzony hit
2026-08-11: zapis 7 723 tok., odczyt 7 723 w kolejnej turze).

**Katalog doradcy** jest osobny i wąski: własny `catalogId` `com.poc.car_advisor` plus własny
widget `CarCard`. Przełącznik w UI wyjmuje `CarCard` z katalogu **idącego do promptu**
(renderer zna go zawsze). To demonstracja tezy „katalog jest sufitem tego, co model umie
narysować".

**Katalog triage'u** (`com.poc.triage`) to `Column` + `Text` + **siedem własnych
komponentów**. Siódmy (`OfferCard`) istnieje po to, żeby dało się go **zakazać**. Zakaz jest
warunkowy (windykacja albo przekroczony limit), więc komponent **zostaje w katalogu**: ten sam
katalog ma obsłużyć klienta, u którego oferta jest w porządku. Reguła „max 3 komponenty"
siedzi w `systemPromptFragments` katalogu, nie w kodzie ekranu.

## Uwagi o modelu

Kod celuje w `claude-haiku-4-5`. Haiku to najtańszy i najszybszy tier. Jeśli będzie
gubił schemat A2UI (niepoprawny JSON daje pusty ekran), podnieś model w
`lib/genui_agent/claude_genui_agent.dart`, `claude_advisor_agent.dart` i
`claude_triage_agent.dart` (stała `_model`) na `claude-sonnet-5` albo `claude-opus-5`.

Świadomie **nie** wysyłamy `output_config.effort` ani adaptive thinking. Oba są
odrzucane błędem na modelach 4.5.

## ⚠️ Pułapka zależności: `analyze` przechodzi, build nie

`pubspec.yaml` wymusza `json_schema_builder: ^0.1.7`, mimo że genui 0.10.3 deklaruje `^0.1.3`.
Paczka używa w kodzie `SchemaRegistry`, który istnieje dopiero od 0.1.6. Gdy pub zejdzie
poniżej, `flutter analyze` jest **czysty**, a `flutter test` albo `build` sypie
`Error: 'SchemaRegistry' isn't a type` **w plikach samej paczki**.

> [!info] **Nie usuwaj tej linijki, choć wygląda na zbędną.** Pub i tak wybiera dziś 0.1.7,
> bo nic w grafie nie ciągnie w dół. Pin jest więc **dolną granicą**, nie ratunkiem: broni
> przed `pub downgrade` i przed paczką, która zacapowałaby `json_schema_builder`.
> Wypada dopiero wtedy, gdy genui zaciśnie własny constraint.

## Struktura

```
lib/
  app/di.dart                       # GetIt: agent + katalog per tor (pod nazwą)
  app/routes.dart                   # go_router, enum AppRoutes (czat, doradca, triage)
  data/anthropic/                   # Endpoints, interceptor nagłówków, Api ze streamem SSE
  commons/
    a2ui/a2ui_sink.dart             # wyjście agenta na drut, miejsce na przechwytywacz
    a2ui/a2ui_messages.dart         # czytanie surowej odpowiedzi PO fakcie (snapshot tury)
    a2ui/surface_contract.dart      # KONTRAKT: allowed + requiredWhen + forbiddenWhen
    a2ui/component_names.dart       # nazwy komponentów z surowej odpowiedzi
    architecture/side_effect_mixin.dart
    resources/app_sizes.dart        # jedyne źródło odstępów i paddingów
    widgets/agent_banner.dart       # trwały sygnał „mock czy model" na każdym ekranie
  genui_agent/
    genui_agent.dart / claude_genui_agent.dart / mock_genui_agent.dart       # czat
    advisor_agent.dart / claude_advisor_agent.dart / mock_advisor_agent.dart # doradca
    triage_agent.dart / claude_triage_agent.dart / mock_triage_agent.dart    # panel BOK
  genui_catalog/
    car_card_item.dart              # CatalogItem: name + dataSchema + builder
    advisor_catalog.dart            # wąski katalog doradcy, własny catalogId
    triage_items.dart               # 7 mostów widget ↔ genui + nazwy komponentów
    triage_catalog.dart             # katalog paska + reguły w systemPromptFragments
  features/genui_chat/              # Cubit + freezed state + part-widgety
  features/car_advisor/             # panel generatywny: prompt = stan suwaków
  features/triage_panel/
    model/support_case.dart         # freezed + describeForModel() + 4 scenariusze demo
    model/triage_action.dart        # magistrala akcji: klik BEZ tury modelu
    contract/triage_contract.dart   # trzy listy nad stanem zamówienia
    failure/failure_injector.dart   # cztery wymuszone awarie
    cubit/, page/, widget/
```

## Czego POC dowiódł (i czego nie)

- **Domyślny prompt NIE wymusza generowania UI.** Na „siema" Haiku odpowiada prozą, parser
  nie znajduje A2UI i widać pusty ekran wyglądający jak zepsuta apka. Stąd fragment
  `_alwaysRespondWithUi` w agencie czatu.
- **Przy `updateOnly` powierzchnię musi założyć HOST.** Model nie ma `createSurface`,
  a `SurfaceController` update do nieistniejącego `surfaceId` **buforuje przez minutę
  i gubi bez śladu, bez logu**.
- **`exampleData` NIE trafia do system promptu** (zmierzone 2026-08-11: prompt z nim i bez
  jest identyczny co do bajtu). W paczce czyta to wyłącznie helper testowy.
- **Reguła w prompcie to prośba, kontrakt hosta to gwarancja.** Test dowodzi odrzucenia
  powierzchni **w obie strony**: brak wymaganego `CreditLimitBanner` oraz obecny zakazany
  `OfferCard`. Werdykt niesie nazwę złamanej reguły, nie samo „odrzucono".
- **Awaria degraduje do stanu sprzed wdrożenia.** Test widgetowy: agent rzuca wyjątkiem,
  a karta zamówienia nadal renderuje się z kompletem danych.
- **Cztery wymuszone awarie dają cztery rozróżnialne komunikaty.** Jeden generyczny
  „coś poszło nie tak" znaczyłby, że host nie wie, co się stało.
- **Klik w akcję z wygenerowanego paska kosztuje zero requestów.** Licznik tur modelu stoi.
- ⚠️ **Panel BOK zweryfikowany na atrapie.** Na żywym Haiku **nie sprawdzone**: czy model
  trzyma limit trzech komponentów, czy sam sięga po zakazany `OfferCard`, gdy kontekst go
  kusi, i jaka jest realna latencja przy trzech komponentach. E2E świadomie poza zakresem
  tej iteracji (decyzja 2026-08-17).

## Weryfikacja

`flutter analyze` czysty. `flutter test` daje **64 zielone i 11 pominiętych** (E2E pomijają
się same bez klucza; z kluczem: `flutter test --dart-define-from-file=secrets.json`).

| Plik | Co pilnuje |
| --- | --- |
| `widget_test.dart` | build appki, wysłanie promptu, pipeline mock A2UI → stan, `resetChat` |
| `car_card_test.dart` | `CarCard` jako czysty widget: render + formatowanie PLN/km |
| `advisor_catalog_test.dart` | warianty promptu doradcy, `catalogId` różny od basicowego |
| `advisor_flow_test.dart` | pełny pipeline doradcy → `CarCard`, jedna powierzchnia, layout 375×812 |
| `agent_banner_test.dart` | baner widoczny od startu i nie znika po wysłaniu wiadomości |
| `client_data_model_test.dart` | most DataModelu: wartości z wygenerowanego UI wracają do modelu |
| `prose_streaming_test.dart` | proza ze strumienia sklejana, nie podmieniana (regres 0.10.2) |
| `conversation_idle_test.dart` | `close()` w trakcie tury na **wszystkich trzech** torach |
| `surface_contract_test.dart` | kontrakt w obie strony + parser snapshotu tury |
| `triage_flow_test.dart` | pasek na powierzchni hosta, update w miejscu, bramka przed promptem, klik bez tury, **agent rzuca → karta żyje**, layout 375×812 |
| `triage_failures_test.dart` | cztery awarie dają cztery **różne** komunikaty; wyłączony kontrakt = ciche pominięcie |
| `advisor_ab_e2e_test.dart`, `claude_e2e_test.dart` | realne requesty do API (auto-skip bez klucza) |

## Licencja

MIT, patrz [LICENSE](LICENSE). Bierzcie, co się przyda: katalog, kontrakt powierzchni,
przechwytywacz awarii. **Klucz do modelu każdy podpina swój**, szczegóły w
[docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).
