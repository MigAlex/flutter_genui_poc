import '../../../commons/a2ui/surface_contract.dart';
import '../../../genui_catalog/triage_catalog.dart';
import '../model/support_case.dart';

/// Kontrakt paska BOK — **trzy listy nad jednym stanem zamówienia**.
///
/// Reguły są tu, a nie w prompcie, bo prompt jest prośbą. Podział, który z tego
/// wychodzi: **co jest regułą biznesową — należy do hosta; co jest oceną „co
/// teraz ważne" — do modelu.**
///
/// Zauważ, że `OfferCard` **zostaje w katalogu** mimo zakazu: blokada jest
/// warunkowa (windykacja / przekroczony limit), a ten sam katalog ma obsłużyć
/// klienta, u którego oferta jest w porządku.
SurfaceContract<SupportCase> triageContract() => SurfaceContract(
  surfaceId: triageStripSurfaceId,
  allowed: {...TriageComponents.domain, 'Column', 'Text'},
  requiredWhen: [
    ConditionalComponent(
      component: TriageComponents.creditLimitBanner,
      rule: 'przekroczony limit kupiecki musi być widoczny',
      when: (order) => order.overCreditLimit,
    ),
    ConditionalComponent(
      component: TriageComponents.actionRow,
      rule: 'pasek bez akcji informuje, zamiast skracać rozmowę',
      when: (order) => order.availableActions.isNotEmpty,
    ),
  ],
  forbiddenWhen: [
    ConditionalComponent(
      component: TriageComponents.offerCard,
      rule: 'nie proponujemy rabatu klientowi w windykacji',
      when: (order) => order.offerForbidden,
    ),
  ],
);
