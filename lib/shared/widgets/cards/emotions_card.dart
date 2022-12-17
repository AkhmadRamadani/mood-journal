import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class Emotions extends StatelessWidget {
  const Emotions({Key? key, this.selectedEmotion, this.onEmotionSelected})
      : super(key: key);
  final String? selectedEmotion;
  final Function(String)? onEmotionSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.spacing,
      ),
      child: Wrap(
        children: [
          "Excited",
          "Relaxed",
          "Proud",
          "Hopeful",
          "Happy",
          "Enthusiastic",
          "Refreshed",
          "Gloomy",
          "Lonely",
          "Anxious",
          "Sad",
          "Angry",
          "Tired",
          "Annoyed",
          "Hopeless",
          "Bored",
          "Stressed",
        ]
            .map((f) => GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: f == selectedEmotion
                          ? ThemeColor.primary
                          : ThemeColor.neutral_200,
                      borderRadius: const BorderRadius.all(Radius.circular(
                        50,
                      )),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: f == selectedEmotion
                            ? ThemeColor.white
                            : ThemeColor.black,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  onTap: () => onEmotionSelected!(f),
                ))
            .toList(),
      ),
    );
  }
}
