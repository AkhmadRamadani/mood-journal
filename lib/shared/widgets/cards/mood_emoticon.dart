import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';

class MoodEmoticon extends StatelessWidget {
  const MoodEmoticon(
      {super.key, required this.location, required this.isSelected});

  final String location;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? ThemeColor.primary : Colors.transparent,
      ),
      child: Lottie.asset(location, width: 60),
    );
  }
}
