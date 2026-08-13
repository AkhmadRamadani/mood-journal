import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  final String badgeName;
  final String? description;
  final int pointsReward;

  const BadgeUnlockedDialog({
    Key? key,
    required this.badgeName,
    this.description,
    this.pointsReward = 0,
  }) : super(key: key);

  static void show({
    required String badgeName,
    String? description,
    int pointsReward = 0,
  }) {
    Get.dialog(
      BadgeUnlockedDialog(
        badgeName: badgeName,
        description: description,
        pointsReward: pointsReward,
      ),
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
              height: 100,
              width: 100,
              child: Lottie.asset(
                'assets/animations/check_lottie.json',
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.emoji_events_rounded,
                    size: 70,
                    color: Colors.amber,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🏆 BADGE UNLOCKED!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              badgeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.neutral_900,
              ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeColor.neutral_600,
                ),
              ),
            ],
            if (pointsReward > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '+$pointsReward XP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                'Claim',
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
