import 'package:flutter/widgets.dart';

/// Spacing, paddingi i promienie — jedyne źródło liczb w UI.
///
/// Wzorzec z konwencji projektu (`conv-flutter-theming`). Zasada, dla której to
/// istnieje: **w widoku nie piszesz `EdgeInsets.*` ani `Radius.circular(...)`**.
/// Widok składa nazwane stałe; gdy potrzebujesz asymetrii — składasz operatorem
/// `+` (`hPadding16 + vPadding8`), zamiast mnożyć nazwy na każdą kombinację.
abstract final class AppSizes {
  static const double p2 = 2;
  static const double p4 = 4;
  static const double p6 = 6;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p32 = 32;
  static const double p48 = 48;
}

// ---------------------------------------------------------------------------
// Gaps — zamiast `SizedBox(height: X)` w drzewie.
// ---------------------------------------------------------------------------

const emptyWidgetShrink = SizedBox.shrink();
const emptyPadding = EdgeInsets.zero;

const vGap2 = SizedBox(height: AppSizes.p2);
const vGap4 = SizedBox(height: AppSizes.p4);
const vGap8 = SizedBox(height: AppSizes.p8);
const vGap12 = SizedBox(height: AppSizes.p12);
const vGap16 = SizedBox(height: AppSizes.p16);
const vGap24 = SizedBox(height: AppSizes.p24);
const vGap32 = SizedBox(height: AppSizes.p32);

const hGap4 = SizedBox(width: AppSizes.p4);
const hGap8 = SizedBox(width: AppSizes.p8);
const hGap12 = SizedBox(width: AppSizes.p12);
const hGap16 = SizedBox(width: AppSizes.p16);

// ---------------------------------------------------------------------------
// Padding kierunkowy (const)
// ---------------------------------------------------------------------------

const vPadding2 = EdgeInsets.symmetric(vertical: AppSizes.p2);
const vPadding4 = EdgeInsets.symmetric(vertical: AppSizes.p4);
const vPadding6 = EdgeInsets.symmetric(vertical: AppSizes.p6);
const vPadding8 = EdgeInsets.symmetric(vertical: AppSizes.p8);
const vPadding12 = EdgeInsets.symmetric(vertical: AppSizes.p12);
const vPadding16 = EdgeInsets.symmetric(vertical: AppSizes.p16);

const hPadding6 = EdgeInsets.symmetric(horizontal: AppSizes.p6);
const hPadding8 = EdgeInsets.symmetric(horizontal: AppSizes.p8);
const hPadding12 = EdgeInsets.symmetric(horizontal: AppSizes.p12);
const hPadding16 = EdgeInsets.symmetric(horizontal: AppSizes.p16);
const hPadding24 = EdgeInsets.symmetric(horizontal: AppSizes.p24);

const allPadding4 = EdgeInsets.all(AppSizes.p4);
const allPadding8 = EdgeInsets.all(AppSizes.p8);
const allPadding12 = EdgeInsets.all(AppSizes.p12);
const allPadding16 = EdgeInsets.all(AppSizes.p16);
const allPadding24 = EdgeInsets.all(AppSizes.p24);

const tPadding8 = EdgeInsets.only(top: AppSizes.p8);
const tPadding16 = EdgeInsets.only(top: AppSizes.p16);

const bPadding8 = EdgeInsets.only(bottom: AppSizes.p8);
const bPadding12 = EdgeInsets.only(bottom: AppSizes.p12);
const bPadding16 = EdgeInsets.only(bottom: AppSizes.p16);

// ---------------------------------------------------------------------------
// Radius / BorderRadius (const)
// ---------------------------------------------------------------------------

const radiusFull = Radius.circular(999);
const radiusXL = Radius.circular(AppSizes.p20);
const radiusL = Radius.circular(AppSizes.p12);
const radiusM = Radius.circular(AppSizes.p8);
const radiusS = Radius.circular(AppSizes.p4);

const borderRadiusFull = BorderRadius.all(radiusFull);
const borderRadiusXL = BorderRadius.all(radiusXL);
const borderRadiusL = BorderRadius.all(radiusL);
const borderRadiusM = BorderRadius.all(radiusM);
const borderRadiusS = BorderRadius.all(radiusS);
