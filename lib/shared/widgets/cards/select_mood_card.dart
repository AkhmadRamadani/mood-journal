import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class SelectMood extends StatelessWidget {
  SelectMood({
    Key? key,
    required MoodConditions? selectedMood,
    required Function(MoodConditions) onMoodSelected,
  }) : super(key: key);

  MoodConditions? selectedMood;
  Function(MoodConditions)? onMoodSelected;

  Widget menuMood(String text, bool isSelected, MoodConditions mood) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? ThemeColor.primary : Colors.transparent,
      ),
      child: Lottie.asset(text, width: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.spacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji 1
          GestureDetector(
            onTap: () {},
            child: menuMood('assets/lotties/crying-emoji.json',
                selectedMood == MoodConditions.tired, MoodConditions.tired),
          ),

          const SizedBox(
            width: 3,
          ),

          // Emoji 2
          menuMood('assets/lotties/sad-emoji.json',
              selectedMood == MoodConditions.sad, MoodConditions.sad),

          const SizedBox(
            width: 3,
          ),

          // Emoji 3
          menuMood('assets/lotties/winking-emoji.json',
              selectedMood == MoodConditions.excited, MoodConditions.excited),

          const SizedBox(
            width: 3,
          ),

          // Emoji 4
          menuMood('assets/lotties/blushing-emoji.json',
              selectedMood == MoodConditions.happy, MoodConditions.happy),

          const SizedBox(
            width: 3,
          ),

          // Emoji 5
          menuMood('assets/lotties/smiley-emoji.json',
              selectedMood == MoodConditions.cheerful, MoodConditions.cheerful),
        ],
      ),
    );
  }
}
