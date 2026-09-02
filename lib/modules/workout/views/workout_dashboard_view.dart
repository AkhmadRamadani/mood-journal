import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/workout/controllers/workout_controller.dart';
import 'package:moodie/modules/workout/exercise_types.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class WorkoutDashboardView extends StatelessWidget {
  const WorkoutDashboardView({super.key});

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final mins = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    if (mins == 0) return '${remainingSecs}s';
    if (remainingSecs == 0) return '${mins}m';
    return '${mins}m ${remainingSecs}s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutController());

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: const Text(
          'AI Workout Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeColor.neutral_900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadWorkoutData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = controller.summary.value;
        final selected = controller.selectedExercise.value;
        final currentStat = controller.currentExerciseStat;

        return RefreshIndicator(
          onRefresh: () => controller.loadWorkoutData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.spacing * 3,
              vertical: Spacing.spacing * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Exercise Selection Dropdown Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeColor.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(selected.icon,
                            color: ThemeColor.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Exercise Type',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<ExerciseType>(
                                value: selected,
                                isDense: true,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: ThemeColor.primary),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.neutral_900,
                                ),
                                onChanged: (ExerciseType? newType) {
                                  if (newType != null) {
                                    controller.selectExercise(newType);
                                  }
                                },
                                items: ExerciseType.values
                                    .map((ExerciseType type) {
                                  return DropdownMenuItem<ExerciseType>(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(type.icon,
                                            size: 18,
                                            color: ThemeColor.primary),
                                        const SizedBox(width: 8),
                                        Text(type.label),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Hero Exercise Stats Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColor.primary,
                        ThemeColor.primary.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${selected.label.toUpperCase()} STATS",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selected.description,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selected == ExerciseType.plank
                            ? _formatDuration(
                                currentStat?.totalDurationSeconds ?? 0)
                            : '${currentStat?.totalReps ?? 0}',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected == ExerciseType.plank
                            ? 'Total Plank Time'
                            : 'Total ${selected.label} Completed',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.18)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatMiniItem(
                            label: 'Sessions',
                            value: '${currentStat?.sessionsCount ?? 0}',
                            icon: Icons.event_available_rounded,
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _StatMiniItem(
                            label: "Today's All Reps",
                            value: '${summary?.todayReps ?? 0}',
                            icon: Icons.today_rounded,
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _StatMiniItem(
                            label: 'Total Time',
                            value: _formatDuration(
                                summary?.totalDurationSeconds ?? 0),
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Start AI Camera Training Button for selected exercise
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () =>
                      controller.startWorkoutSession(context, selected),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_rounded, size: 24),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Start ${selected.label} AI Tracking',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 4. Recent Logs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent ${selected.label} Sessions',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: ThemeColor.neutral_700,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    if (controller.recentLogs.isNotEmpty)
                      Text(
                        '${controller.recentLogs.length} logged',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (controller.recentLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(selected.icon,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No ${selected.label} sessions yet',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.neutral_700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap "Start ${selected.label} AI Tracking" above to count your reps with real-time pose detection!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = controller.recentLogs[index];
                      final exType = ExerciseType.fromSlug(item.exerciseType);
                      final isPlank = exType == ExerciseType.plank;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    ThemeColor.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                exType.icon,
                                color: ThemeColor.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPlank
                                        ? '${item.durationSeconds ?? item.repsCount}s Plank Hold'
                                        : '${item.repsCount} ${exType.label}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: ThemeColor.neutral_900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${item.entryDate}${item.durationSeconds != null ? " · ${_formatDuration(item.durationSeconds!)}" : ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: Colors.grey.shade400, size: 20),
                              onPressed: () =>
                                  _confirmDelete(context, controller, item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkoutController controller, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log?'),
        content:
            const Text('Are you sure you want to delete this workout entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteLog(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatMiniItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatMiniItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
