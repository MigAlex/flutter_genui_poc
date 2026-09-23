import 'package:flutter/material.dart';

/// Skróty do theme'u — `context.textTheme` zamiast pełnego `Theme.of(...)`.
///
/// Konwencja projektu (`conv-flutter-theming`): widok nie sięga po `Theme.of`
/// wprost, żeby podmiana źródła tokenów była zmianą w jednym pliku.
///
/// ⚠️ Docelowa konwencja ma warstwy semantyczne oparte na `ThemeExtension`.
/// Ten POC stoi na gołym `ColorScheme.fromSeed` — świadome uproszczenie,
/// nie wzorzec do kopiowania.
extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Wysokość systemowej nawigacji / notcha u dołu — do ręcznego odsunięcia
  /// treści tam, gdzie `SafeArea` nie pasuje (np. scrollowana lista, której
  /// tło ma sięgać krawędzi).
  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;
}
