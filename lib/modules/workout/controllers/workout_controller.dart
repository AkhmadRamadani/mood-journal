import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moodie/models/workout_log.dart';
import 'package:moodie/modules/gamification/controllers/gamification_controller.dart';
import 'package:moodie/modules/workout/exercise_types.dart';
import 'package:moodie/modules/workout/pushup_camera_screen.dart';
import 'package:moodie/services/workout_api_service.dart';

class WorkoutController extends GetxController {
  static WorkoutController get to => Get.find<WorkoutController>();

  final WorkoutApiService apiService = WorkoutApiService();

  final RxBool isLoading = false.obs;
  final RxBool isLogging = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<ExerciseType> selectedExercise = ExerciseType.pushUps.obs;
  final Rx<WorkoutSummary?> summary = Rx<WorkoutSummary?>(null);
  final RxList<WorkoutLog> recentLogs = <WorkoutLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWorkoutData();
  }

  void selectExercise(ExerciseType type) {
    selectedExercise.value = type;
    loadWorkoutData();
  }

  Future<void> loadWorkoutData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final summaryResult = await apiService.getSummary();
      summary.value = summaryResult;

      final logsResult = await apiService.getWorkoutLogs(
        exerciseType: selectedExercise.value.slug,
        page: 1,
      );
      recentLogs.assignAll(logsResult);
    } catch (e) {
      log('Error loading workout data: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  ExerciseStat? get currentExerciseStat {
    final list = summary.value?.byExercise ?? [];
    return list.firstWhereOrNull(
      (e) => e.exerciseType == selectedExercise.value.slug,
    );
  }

  Future<void> deleteLog(int id) async {
    try {
      await apiService.deleteWorkout(id);
      recentLogs.removeWhere((item) => item.id == id);
      // Reload summary to reflect updated totals
      final summaryResult = await apiService.getSummary();
      summary.value = summaryResult;
      Get.snackbar(
        'Deleted',
        'Workout log removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete workout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }
  }

  void startWorkoutSession(BuildContext context, [ExerciseType? type]) {
    final activeType = type ?? selectedExercise.value;
    final startTime = DateTime.now();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PushUpCameraScreen(
          exerciseType: activeType,
          onRepCompleted: (count) {
            HapticFeedback.mediumImpact();
          },
          onSessionEnded: (count, finalExerciseType) async {
            if (count <= 0) return;

            final duration = DateTime.now().difference(startTime).inSeconds;

            try {
              isLogging.value = true;
              final log = await apiService.logWorkout(
                exerciseType: finalExerciseType.slug,
                repsCount: count,
                durationSeconds: duration,
                entryDate: DateTime.now().toIso8601String().substring(0, 10),
              );

              if (finalExerciseType == selectedExercise.value) {
                recentLogs.insert(0, log);
              }
              final summaryResult = await apiService.getSummary();
              summary.value = summaryResult;

              // Refresh gamification profile if available
              if (Get.isRegistered<GamificationController>()) {
                GamificationController.to.loadGamificationData();
              }

              final xpGained = 10 + count;
              final unitLabel =
                  finalExerciseType == ExerciseType.plank ? 'seconds' : 'reps';
              Get.snackbar(
                'Great work! 🎉',
                'Completed $count $unitLabel of ${finalExerciseType.label} in ${duration}s (+$xpGained XP)',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF2E7D32),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
                margin: const EdgeInsets.all(16),
                borderRadius: 16,
                icon: Icon(finalExerciseType.icon, color: Colors.white),
              );
            } catch (e) {
              log('Error saving workout session: $e');
              Get.snackbar(
                'Error Saving Workout',
                e.toString().replaceFirst('Exception: ', ''),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade800,
                colorText: Colors.white,
              );
            } finally {
              isLogging.value = false;
            }
          },
        ),
      ),
    );
  }

  // Alias for backward compatibility
  void startPushUpSession(BuildContext context) =>
      startWorkoutSession(context, ExerciseType.pushUps);
}
