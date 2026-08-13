import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/views/mood_wizard_view.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class MoodDetailView extends StatelessWidget {
  final MoodModel record;

  const MoodDetailView({Key? key, required this.record}) : super(key: key);

  String _getLottiePath(MoodConditions mood) {
    switch (mood) {
      case MoodConditions.tired:
        return AssetConst.cryingAnimation;
      case MoodConditions.sad:
        return AssetConst.sadAnimation;
      case MoodConditions.excited:
        return AssetConst.winkingAnimation;
      case MoodConditions.cheerful:
        return AssetConst.blushingAnimation;
      case MoodConditions.happy:
        return AssetConst.smileyAnimation;
    }
  }

  LinearGradient _getMoodGradient(MoodConditions mood) {
    switch (mood) {
      case MoodConditions.tired:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9), ThemeColor.background],
        );
      case MoodConditions.sad:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), ThemeColor.background],
        );
      case MoodConditions.excited:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), ThemeColor.background],
        );
      case MoodConditions.cheerful:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), ThemeColor.background],
        );
      case MoodConditions.happy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), ThemeColor.background],
        );
    }
  }

  Color _getMoodAuraColor(MoodConditions mood) {
    switch (mood) {
      case MoodConditions.tired:
        return const Color(0xFF7E57C2);
      case MoodConditions.sad:
        return const Color(0xFF42A5F5);
      case MoodConditions.excited:
        return const Color(0xFFFFA726);
      case MoodConditions.cheerful:
        return const Color(0xFFEC407A);
      case MoodConditions.happy:
        return const Color(0xFF66BB6A);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ThemeColor.secondary_400),
            SizedBox(width: 8),
            Text('Delete Entry', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
            'Are you sure you want to delete this mood record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: ThemeColor.neutral_600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.secondary_400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Get.back(); // close dialog
              Get.back(); // close detail view
              final controller = RecordController.to;
              await controller.deleteMood(record);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: ThemeColor.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = _getMoodAuraColor(record.mood);
    final emotionList = record.emotions
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getMoodGradient(record.mood),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.spacing * 2,
                  vertical: Spacing.spacing * 1.5,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: ThemeColor.neutral_900,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Mood Detail',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(context),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: ThemeColor.secondary_400,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.spacing * 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: Spacing.spacing * 2),

                      // Hero Animated Lottie Emoji
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: auraColor.withOpacity(0.12),
                          boxShadow: [
                            BoxShadow(
                              color: auraColor.withOpacity(0.35),
                              blurRadius: 35,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Lottie.asset(
                            _getLottiePath(record.mood),
                            width: 110,
                            height: 110,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Mood Name
                      Text(
                        record.mood.name.capitalizeFirst!,
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),

                      const SizedBox(height: 4),

                      // Date & Time
                      Text(
                        '${record.createdAt.toHumanDateShort()} at ${record.createdAt.toTimeString()}',
                        style: const TextStyle(
                          color: ThemeColor.neutral_600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: Spacing.spacing * 3),

                      // Intensity Card
                      Container(
                        padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                        decoration: BoxDecoration(
                          color: ThemeColor.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Feeling Intensity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.neutral_900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  record.intensity < 0.35
                                      ? 'Mild 🍃'
                                      : record.intensity < 0.7
                                          ? 'Moderate ⚡'
                                          : 'Intense 🔥',
                                  style: TextStyle(
                                    color: auraColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: record.intensity,
                                minHeight: 8,
                                backgroundColor: ThemeColor.neutral_200,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(auraColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Spacing.spacing * 2.5),

                      // Emotions Card
                      if (emotionList.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                          decoration: BoxDecoration(
                            color: ThemeColor.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emotions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.neutral_900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: emotionList
                                    .map(
                                      (emotion) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: auraColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          emotion,
                                          style: TextStyle(
                                            color: auraColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 2.5),
                      ],

                      // Title & Journal Note Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                        decoration: BoxDecoration(
                          color: ThemeColor.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (record.title.isNotEmpty) ...[
                              Text(
                                record.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.neutral_900,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              record.note.isNotEmpty
                                  ? record.note
                                  : 'No journal note added.',
                              style: TextStyle(
                                fontSize: 14,
                                color: record.note.isNotEmpty
                                    ? ThemeColor.neutral_700
                                    : ThemeColor.neutral_400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Linked Menstrual Log Card (if present)
                      if (record.menstrualLog != null) ...[
                        const SizedBox(height: Spacing.spacing * 2.5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                          decoration: BoxDecoration(
                            color: ThemeColor.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ThemeColor.purple_400.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: ThemeColor.purple_400,
                                    child: Icon(Icons.water_drop,
                                        size: 14, color: ThemeColor.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Linked Menstrual Log',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.purple_400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Flow Intensity:',
                                      style: TextStyle(
                                          color: ThemeColor.neutral_600)),
                                  Text(
                                    record.menstrualLog!.flow.capitalizeFirst!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.neutral_900),
                                  ),
                                ],
                              ),
                              if (record.menstrualLog!.symptoms.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: record.menstrualLog!.symptoms
                                      .map((s) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: ThemeColor.purple_400
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              s,
                                              style: const TextStyle(
                                                color: ThemeColor.purple_400,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: Spacing.spacing * 4),
                    ],
                  ),
                ),
              ),

              // Bottom Actions (Edit & Delete)
              Container(
                padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                decoration: BoxDecoration(
                  color: ThemeColor.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side:
                              const BorderSide(color: ThemeColor.secondary_400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: ThemeColor.secondary_400, size: 18),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            color: ThemeColor.secondary_400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: auraColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shadowColor: auraColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Get.back(); // close detail view
                          final controller = RecordController.to;
                          controller.initEditMood(record);
                          Get.to(() => const MoodWizardView());
                        },
                        icon: const Icon(Icons.edit_rounded,
                            color: ThemeColor.white, size: 18),
                        label: const Text(
                          'Edit Record ✏️',
                          style: TextStyle(
                            color: ThemeColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
