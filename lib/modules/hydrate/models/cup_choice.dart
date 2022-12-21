import 'package:flutter/material.dart';

class CupChoice {
  final String name;
  final String image;
  final int ml;
  final int percentage;
  final Color color;

  CupChoice(
      {required this.name,
      required this.image,
      required this.ml,
      required this.percentage,
      required this.color});
}
