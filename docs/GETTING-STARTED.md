# Start — sklonowałeś repo, co dalej

Onboarding dla kogoś, kto widzi ten POC pierwszy raz. Architektura i „dlaczego tak" siedzą
w [`README.md`](../README.md) — tutaj jest wyłącznie **jak to odpalić u siebie**.

> **Najkrótsza wersja:** `flutter pub get` → `flutter run` → działa na atrapie, zero kosztów.
> Chcesz zobaczyć **prawdziwy model**? Potrzebujesz **własnego klucza Anthropic** (↓ krok 3).

---

## Czego potrzebujesz

| | |
| --- | --- |
| Flutter SDK | Dart `^3.11.0` (sprawdzone na Flutter 3.41) |
| Platformy | **iOS + Android**. macOS/web **nie są skonfigurowane** — `flutter build macos` powie „No macOS desktop project configured" |
| Klucz API | **opcjonalny** — bez niego apka jedzie na atrapie |

---

## Krok 1 — pobierz zależności

```bash
flutter pub get
```

## Krok 2 — odpal bez klucza (nic nie kosztuje)

```bash
flutter run
```

Apka wstaje na **atrapie**: renderuje prawdziwe UI z prawdziwego protokołu A2UI, tylko odpowiedzi
są zaszyte w kodzie zamiast przychodzić z modelu. Na każdym ekranie jest baner z nazwą aktywnego
agenta — na atrapie napisze **„Mock (bez klucza API)"**.

**Co zobaczysz na atrapie:** że renderer działa, że kontrakt hosta odrzuca złe powierzchnie i że
cztery wymuszone awarie degradują ekran tak, jak powinny.
**Czego atrapa NIE pokaże:** po jakie komponenty sięgnie prawdziwy model. Atrapy są celowo
napisane tak, żeby **nie udawać decyzji modelu**.

## Krok 3 — własny klucz Anthropic

Klucz **nie jedzie w repo** — każdy używa swojego, bo rachunek idzie na właściciela klucza.

**3.1. Załóż klucz.** [console.anthropic.com](https://console.anthropic.com) → **API Keys** →
*Create Key*. Skopiuj od razu — po zamknięciu okna nie pokażą go drugi raz.

**3.2. Doładuj konto.** *Plans & Billing* → dorzuć minimalne kredyty.
⚠️ **To jest najczęstszy pierwszy błąd:** świeży klucz na koncie bez środków przechodzi
walidację, ale każdy request wraca błędem o zerowym saldzie — a w apce zobaczysz to jako
komunikat o błędzie zamiast paska. Klucz jest dobry, brakuje kredytów.

**3.3. Wklej klucz do pliku.**

```bash
cp secrets.example.json secrets.json
```

I podmień wartość w `secrets.json`:

```json
{ "ANTHROPIC_API_KEY": "sk-ant-tu-wklej-swoj-klucz" }
```



## Krok 4 — odpal z modelem

| Gdzie | Jak |
| --- | --- |
| **VS Code / Cursor** | Run and Debug (⇧⌘D) → **genui_poc (Claude)** → F5 |
| **Terminal** | `flutter run --dart-define-from-file=secrets.json` |

Baner na ekranie powinien teraz pokazywać **„Claude Haiku 4.5"**. Jeśli dalej widzisz „Mock",
to `secrets.json` nie doszedł — sprawdź, czy odpalasz z `--dart-define-from-file`.

Trzy tryby są pod trasami: `/` (czat), `/advisor` (panel), `/triage` (pasek nad ekranem).

---

## Ile to kosztuje

Kod celuje w **Haiku 4.5** — najtańszy i najszybszy tier. Rzędy wielkości, żebyś wiedział,
czego się spodziewać (zmierzone w tym repo):

| | wielkość |
| --- | --- |
| system prompt czatu (katalog 13 pozycji) | 52 497 znaków ≈ **13,4k tokenów** |
| system prompt paska triage'u (7 komponentów) | 32 214 znaków ≈ **8,2k tokenów** |
| odpowiedź modelu (jeden pasek) | ~4k znaków |

W praktyce: **jedna tura to setne części centa**, a przeklikanie całego POC-a to grosze.
Aktualne stawki: [anthropic.com/pricing](https://www.anthropic.com/pricing).

Dwie rzeczy, które warto wiedzieć, zanim zaczniesz klikać:

- **Każda interakcja z wygenerowanym UI to nowy request.** Pięć kliknięć w czacie to sześć
  requestów — model dostaje całą rozmowę od nowa.
- **Prompt caching jest włączony** (`cache_control: ephemeral` na bloku `system`), więc powtarzane
  requesty są tanie. Ale cache żyje **5 minut od ostatniego użycia** — jak poklikasz, pójdziesz na
  obiad i wrócisz, pierwszy request po przerwie zapłacisz drożej niż bez cache'u. Przy zabawie
  z POC-em to grosze; wspominamy, żeby liczby w logu nie zaskoczyły.

---

## Testy

```bash
flutter test                                          # atrapy — darmowe
flutter test --dart-define-from-file=secrets.json     # + testy na żywym API
```

Bez klucza testy uderzające w prawdziwe API **pomijają się same**. Z kluczem dochodzi kilkanaście
realnych requestów (dalej: grosze).

---

## Kiedy coś nie działa

| Objaw | Co to jest |
| --- | --- |
| Baner mówi „Mock", choć masz klucz | apka odpalona bez `--dart-define-from-file=secrets.json` |
| Błąd o saldzie / kredytach | konto bez środków (↑ krok 3.2) — klucz jest dobry |
| 401 / „invalid x-api-key" | literówka albo klucz odwołany |
| **Pusty ekran, a w logach widać tokeny** | najczęstszy przypadek: model odpowiedział prozą zamiast A2UI. Cztery możliwe przyczyny i ich objawy są rozpisane w [`README.md`](../README.md), sekcja „Czego POC dowiódł" |
| `flutter build macos` → „No macOS desktop project configured" | macOS nie jest skonfigurowany; `flutter create --platforms=macos .` dorobi scaffolding |
| Symulator iOS się nie odpala | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |

---
