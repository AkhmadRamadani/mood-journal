import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({
    Key? key,
    required this.newLevel,
  }) : super(key: key);

  static void show(int newLevel) {
    Get.dialog(
      LevelUpDialog(newLevel: newLevel),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.spacing * 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/animations/check_lottie.json',
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.stars_rounded,
                    size: 80,
                    color: Colors.amber,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🎉 LEVEL UP!',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations! You reached Level $newLevel!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: ThemeColor.neutral_700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
