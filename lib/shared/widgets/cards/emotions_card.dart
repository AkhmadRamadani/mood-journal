import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class Emotions extends StatelessWidget {
  const Emotions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.spacing,
      ),
      child: Wrap(
        children: [
          "Exited",
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
                    decoration: const BoxDecoration(
                      color: ThemeColor.neutral_200,
                      borderRadius: BorderRadius.all(Radius.circular(
                              50) //                 <--- border radius here
                          ),
                    ),
                    child: Text(
                      f,
                      style: const TextStyle(
                        color: ThemeColor.black,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}
