final _componentPattern = RegExp(r'"component"\s*:\s*"([A-Za-z0-9_]+)"');

/// Wyławia nazwy komponentów z surowej odpowiedzi modelu.
///
/// Świadomie po tekście, nie z `SurfaceController.registry`: interesuje nas,
/// co model **wygenerował**, także wtedy gdy renderer czegoś nie przyjął.
/// Pusty zbiór = model odpowiedział prozą, nie A2UI.
Set<String> componentNamesIn(String raw) =>
    _componentPattern.allMatches(raw).map((m) => m.group(1)!).toSet();
