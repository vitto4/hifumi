import "package:flutter/material.dart";

/// (not that there is a dark theme anyway)
///
/// As you'll see, most of these colors are snatched directly from Duolingo's CSS.
/// At first they were supposed to be placeholders, but I have to admit they look rather good when used together.
///
/// To the folks at Duolingo : please hmu if this isn't fine
class LightTheme {
  const LightTheme._();

  // dart format off

  /* ---------------------------------- BASE ---------------------------------- */

  static const Color base                       = Color.fromARGB(255, 255, 255, 255); // Duolingo `snow`
  static const Color baseAccent                 = Color.fromARGB(255, 229, 229, 229); // Duolingo `swan`
  static const Color lightAccent                = Color.fromARGB(255, 247, 247, 247); // Duolingo `polar`
  static const Color darkAccent                 = Color.fromARGB(255, 138, 138, 138);

  /* ---------------------------------- TEXT ---------------------------------- */

  static const Color textColor                  = Color.fromARGB(255, 75, 75, 75);    // Duolingo `eel`
  static const Color textColorDim               = Color.fromARGB(255, 119, 119, 119); // Duolingo `wolf`
  static const Color textColorDimmer            = Color.fromARGB(255, 175, 175, 175); // Duolingo `hare`
  static const Color textColorSuperExtraLight   = Color.fromARGB(255, 243, 248, 252); //  Homemade. /!\ Bright, use parsimoniously.

  /* ----------------------------- (MAIN) ACCENTS ----------------------------- */

  static const Color green                      = Color.fromARGB(255, 88, 204, 2);    // Duolingo `owl`
  static const Color greenLighter               = Color.fromARGB(255, 215, 255, 184); // Duolingo `sea-sponge`
  static const Color greenBorder                = Color.fromARGB(255, 88, 167, 0);    // Duolingo `tree-frog`

  static const Color blue                       = Color.fromARGB(255, 28, 176, 246);  // Duolingo `macaw`
  static const Color blueLight                  = Color.fromARGB(255, 132, 216, 255); // Duolingo `blue-jay`
  static const Color blueLighter                = Color.fromARGB(255, 221, 244, 255); // Duolingo `iguana`
  static const Color blueBorder                 = Color.fromARGB(255, 24, 154, 214);  // Duolingo `whale`

  /* ----------------------------- (OTHER) ACCENTS ---------------------------- */

  static const Color red                        = Color.fromARGB(255, 234, 43, 43);   // Duolingo `fire-ant`
  static const Color redLight                   = Color.fromARGB(255, 255, 75, 75);   // Duolingo `cardinal`
  static const Color redLighter                 = Color.fromARGB(255, 255, 178, 178); // Duolingo `flamingo`

  static const Color orange                     = Color.fromARGB(255, 255, 200, 0);   // Duolingo `bee`
  static const Color orangeBorder               = Color.fromARGB(255, 231, 166, 1);   // Duolingo `camel`
  static const Color orangeTextAccent           = Color.fromARGB(255, 174, 104, 2);   // Duolingo `cowbird`

  static const Color purple                     = Color.fromARGB(255, 206, 130, 255); // Duolingo `beetle`
  static const Color purpleLight                = Color.fromARGB(255, 240, 218, 255); // Duolingo, from the SVG XP bottle

  static const Color brownLight                 = Color.fromARGB(255, 224, 140, 19);  // Duolingo, from the SVG december 23 badge

  static const Color forestGreen                = Color.fromARGB(255, 1, 134, 106);   // Duolingo, from the SVG august 24 badge
  static const Color forestGreenLight           = Color.fromARGB(255, 0, 181, 147);   // Duolingo, from the SVG august 24 badge
  static const Color forestGreenLighter         = Color.fromARGB(255, 0, 211, 172);   // Duolingo, from the SVG august 24 badge

  // dart format on
}
