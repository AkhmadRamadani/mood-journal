import 'package:flutter/material.dart';

enum MoodConditions {
  tired,
  sad,
  excited,
  cheerful,
  happy,
}

extension MoodConditionsX on MoodConditions {
  /// Single source of truth for unified mood colors across Moodie
  Color get color {
    switch (this) {
      case MoodConditions.tired:
        return const Color(0xFFB39DDB); // Pastel Purple
      case MoodConditions.sad:
        return const Color(0xFF90CAF9); // Pastel Sky Blue
      case MoodConditions.excited:
        return const Color(0xFFFFCC80); // Pastel Orange
      case MoodConditions.cheerful:
        return const Color(0xFFF48FB1); // Pastel Rose Pink
      case MoodConditions.happy:
        return const Color(0xFFA5D6A7); // Pastel Green
    }
  }

  String get label {
    switch (this) {
      case MoodConditions.tired:
        return 'Tired';
      case MoodConditions.sad:
        return 'Sad';
      case MoodConditions.excited:
        return 'Excited';
      case MoodConditions.cheerful:
        return 'Cheerful';
      case MoodConditions.happy:
        return 'Happy';
    }
  }
}
