import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class SelectMood extends StatelessWidget {
  const SelectMood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget menuMood(String text, bool isSelected) {
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

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.spacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji 1
          menuMood('assets/lotties/crying-emoji.json', true),

          const SizedBox(
            width: 3,
          ),

          // Emoji 2
          menuMood('assets/lotties/sad-emoji.json', false),

          const SizedBox(
            width: 3,
          ),

          // Emoji 3
          menuMood('assets/lotties/winking-emoji.json', false),

          const SizedBox(
            width: 3,
          ),

          // Emoji 4
          menuMood('assets/lotties/blushing-emoji.json', false),

          const SizedBox(
            width: 3,
          ),

          // Emoji 5
          menuMood('assets/lotties/smiley-emoji.json', false),
        ],
      ),
    );
  }
}
