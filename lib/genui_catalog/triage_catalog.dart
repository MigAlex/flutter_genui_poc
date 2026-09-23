import 'package:genui/genui.dart';

import '../features/triage_panel/model/triage_action.dart';
import 'triage_items.dart';

export 'triage_items.dart' show TriageComponents;

/// Własny `catalogId` — trzeci w tym POC-u, obok czatu i doradcy.
///
/// Renderer rejestruje katalog **pod tym id**: gdyby powierzchnia przyszła
/// z innym, `SurfaceController` podstawiłby pusty stub i dostalibyśmy pasek bez
/// komponentów **bez jednego słowa w logu**. To jest jedna z czterech przyczyn
/// pustego ekranu i jedyna zupełnie cicha — dlatego wymuszona awaria „zły
/// catalogId" polega właśnie na podmianie tej wartości.
const triageCatalogId = 'com.poc.triage';

/// Powierzchnia paska jest **jedna i stała**, zakłada ją host: przy
/// `SurfaceOperations.updateOnly` model nie ma `createSurface`, a update do
/// nieistniejącej powierzchni ląduje w buforze i po minucie znika bez śladu.
const triageStripSurfaceId = 'triage_strip';

/// Powierzchnia z celowo zepsutym katalogiem — istnieje tylko na potrzeby
/// wymuszonej awarii („zły catalogId"). Nie ma prawa pojawić się inaczej.
const triageBrokenSurfaceId = 'triage_strip_broken';
const triageBrokenCatalogId = 'com.poc.triage.WRONG';

/// Reguły paska — **wszystkie w katalogu, żadna w kodzie ekranu**.
///
/// Tu siedzi cała „logika decyzji, co pokazać", która w wersji ręcznej byłaby
/// funkcją priorytetu nad kilkunastoma sygnałami. Zmiana reguły to zmiana
/// zdania, nie ticket → sprint → release.
///
/// ⚠️ To jest **prośba, nie gwarancja**. Reguły „musisz" i „nie wolno" powtarza
/// jeszcze kontrakt hosta (`SurfaceContract`) i dopiero on jest egzekucją —
/// prompt bywa zignorowany, walidator nie.
const triageStripRules = '''
You are composing a THREE-COMPONENT ASSIST STRIP shown above an untouched order
card. The consultant already sees every field of the order below your strip, so
never repeat plain data — your job is to answer ONE question: why is this person
calling, and what can be done right now.

HARD RULES:
- At most 3 components in total, ordered by importance, most important first.
- The last component MUST be `ActionRow`, with at most 3 actions taken ONLY
  from the available actions listed in the order state (same ids).
- When the account is over its credit limit you MUST include
  `CreditLimitBanner`. Silence about it is the one failure that costs money.
- Never use `OfferCard` for a customer in debt collection or over the credit
  limit.
- Never write prose outside components. Use `Text` only if a single short line
  genuinely adds something no component carries.''';

/// Katalog paska: rusztowanie (`Column`, `Text`) + siedem własnych komponentów.
///
/// Wąsko **dla trafności i powierzchni ataku**, nie dla kosztu — ~20k znaków to
/// nieredukowalna podłoga protokołu A2UI, więc dźwignią kosztową jest prompt
/// caching, nie długość listy.
///
/// [bus] wchodzi do katalogu, bo `ActionRow` musi mieć dokąd oddać kliknięcie
/// **z pominięciem `Conversation`** — inaczej każdy klik konsultanta kosztowałby
/// turę modelu.
Catalog triageCatalog(TriageActionBus bus) => Catalog(
  [BasicCatalogItems.column, BasicCatalogItems.text, ...triageItems(bus)],
  catalogId: triageCatalogId,
  systemPromptFragments: [triageStripRules],
);
