import 'package:flutter/material.dart';

class ThemeColor {
  ThemeColor._();

  static const Color background = Color.fromRGBO(245, 246, 251, 1);

  static const Color appBar = Color.fromRGBO(249, 248, 244, 1);

  static const Color primary = Color.fromRGBO(142, 151, 253, 1);

  // Main Color249,248,244
  static const Color purple_400 = Color.fromRGBO(141, 66, 134, 1);
  static const Color purple_200 = Color.fromRGBO(212, 168, 215, 1);
  static const Color secondary_400 = Color.fromRGBO(220, 101, 103, 1);
  static const Color secondary_200 = Color.fromRGBO(229, 173, 167, 1);

  // Neutral Color
  static const Color black = Color.fromARGB(255, 33, 34, 38);
  static const Color neutral_900 = Color.fromRGBO(15, 23, 42, 1);
  static const Color neutral_700 = Color.fromRGBO(51, 65, 85, 1);
  static const Color neutral_600 = Color.fromRGBO(71, 85, 105, 1);
  static const Color neutral_500 = Color.fromRGBO(100, 116, 139, 1);
  static const Color neutral_400 = Color.fromRGBO(148, 163, 187, 1);
  static const Color neutral_300 = Color.fromRGBO(203, 213, 225, 1);
  static const Color neutral_200 = Color.fromARGB(255, 227, 228, 248);
  static const Color neutral_100 = Color.fromRGBO(241, 245, 249, 1);
  static const Color neutral_50 = Color.fromRGBO(248, 250, 252, 1);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  static const Color success_400 = Color.fromRGBO(39, 174, 96, 1);
  static const Color warning_400 = Color.fromRGBO(241, 196, 15, 1);

  static const primaryColor = Color(0xFF37CAEC);
  static const secodaryColor = Color(0xFF6ed9f1);
  static const pinkColor = Color(0xFFdbbbec);
  static const blueAccentColor = Color(0xFF7298D6);
  static const blueColor = Color(0xFF403FEA);
  static const blackColor = Color(0xFF092a45);
  static const redColor = Color(0xFFAD8164);

  static const secondaryColorDark = Colors.white;

  static const Color primaryColorDark = Color.fromRGBO(50, 48, 98, 1);
}

/// Generates a MaterialColor swatch from any single Color.
MaterialColor generateMaterialColor(Color color) {
  final int primaryValue = color.toARGB32();
  final int r = (color.r * 255).round();
  final int g = (color.g * 255).round();
  final int b = (color.b * 255).round();

  return MaterialColor(primaryValue, {
    50: _tintColor(r, g, b, 0.9),
    100: _tintColor(r, g, b, 0.8),
    200: _tintColor(r, g, b, 0.6),
    300: _tintColor(r, g, b, 0.4),
    400: _tintColor(r, g, b, 0.2),
    500: color,
    600: _shadeColor(r, g, b, 0.1),
    700: _shadeColor(r, g, b, 0.2),
    800: _shadeColor(r, g, b, 0.3),
    900: _shadeColor(r, g, b, 0.4),
  });
}

/// Lighten toward white
Color _tintColor(int r, int g, int b, double factor) => Color.fromRGBO(
      _tintValue(r, factor),
      _tintValue(g, factor),
      _tintValue(b, factor),
      1,
    );

int _tintValue(int value, double factor) =>
    (value + ((255 - value) * factor)).round().clamp(0, 255);

/// Darken toward black
Color _shadeColor(int r, int g, int b, double factor) => Color.fromRGBO(
      _shadeValue(r, factor),
      _shadeValue(g, factor),
      _shadeValue(b, factor),
      1,
    );

int _shadeValue(int value, double factor) =>
    (value - (value * factor)).round().clamp(0, 255);
