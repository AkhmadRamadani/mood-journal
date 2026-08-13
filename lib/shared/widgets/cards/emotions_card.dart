import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class Emotions extends StatelessWidget {
  const Emotions({
    Key? key,
    this.selectedEmotion,
    this.selectedEmotions,
    this.onEmotionSelected,
    this.onEmotionToggled,
  }) : super(key: key);

  final String? selectedEmotion;
  final List<String>? selectedEmotions;
  final Function(String)? onEmotionSelected;
  final Function(String)? onEmotionToggled;

  bool _isSelected(String emotion) {
    if (selectedEmotions != null) {
      return selectedEmotions!.contains(emotion);
    }
    if (selectedEmotion != null && selectedEmotion!.isNotEmpty) {
      final list = selectedEmotion!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      return list.contains(emotion);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> emotionsList = [
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
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.spacing,
      ),
      child: Wrap(
        children: emotionsList.map((f) {
          final isSelected = _isSelected(f);

          return GestureDetector(
            onTap: () {
              if (onEmotionToggled != null) {
                onEmotionToggled!(f);
              } else if (onEmotionSelected != null) {
                onEmotionSelected!(f);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? ThemeColor.primary : ThemeColor.neutral_200,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: ThemeColor.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check_rounded,
                      color: ThemeColor.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? ThemeColor.white : ThemeColor.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
