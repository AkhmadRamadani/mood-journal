import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/controllers/year_in_pixels_controller.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class MenstrualLogController extends GetxController {
  static MenstrualLogController get to => Get.put(MenstrualLogController());

  final RecordRepository _recordRepository = Get.find<RecordRepository>();
  final MenstrualLogRepository _menstrualLogRepository =
      Get.find<MenstrualLogRepository>();

  DateTime selectedDate = DateTime.now();

  RxString flow = 'light'.obs;
  RxList<String> symptoms = <String>[].obs;
  RxBool isPeriodStart = false.obs;
  TextEditingController noteController = TextEditingController();

  RxBool isLoading = false.obs;
  RxList<MoodModel> existingMoods = <MoodModel>[].obs;

  final List<String> availableSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Acne',
    'Backache',
    'Mood Swings',
    'Nausea',
    'Breast Tenderness',
  ];

  final List<String> flowOptions = [
    'spotting',
    'light',
    'medium',
    'heavy',
    'none',
  ];

  void setFlow(String value) {
    flow.value = value;
    update(['flow']);
  }

  void toggleSymptom(String symptom) {
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
    update(['symptoms']);
  }

  void setPeriodStart(bool value) {
    isPeriodStart.value = value;
    update(['is_period_start']);
  }

  void resetForm() {
    flow.value = 'light';
    symptoms.clear();
    isPeriodStart.value = false;
    noteController.clear();
    selectedDate = DateTime.now();
  }

  // Fetch moods logged for a specific date via RecordRepository
  Future<List<MoodModel>> fetchMoodsForDate(DateTime date) async {
    try {
      return await _recordRepository.getMoodsByDate(date);
    } catch (e) {
      log('Error fetching moods for date: $e');
      return [];
    }
  }

  // Submit Menstrual Log via MenstrualLogRepository
  Future<MenstrualLogModel?> submitMenstrualLog({dynamic moodId}) async {
    isLoading.value = true;
    update(['menstrual_form']);

    final formattedDate =
        "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    try {
      final model = await _menstrualLogRepository.storeMenstrualLog(
        date: formattedDate,
        moodId: moodId,
        flow: flow.value,
        symptoms: symptoms.toList(),
        isPeriodStart: isPeriodStart.value,
        note: noteController.text.isNotEmpty ? noteController.text : null,
      );

      if (model != null) {
        resetForm();

        Get.back();
        AlertHelper.showMsg(
          title: "Success",
          msg: "Menstrual log entry created successfully.",
        );

        if (Get.isRegistered<DashboardController>()) {
          DashboardController.to.refresh();
        }
        if (Get.isRegistered<RecordController>()) {
          RecordController.to.refresh();
        }
        if (Get.isRegistered<YearInPixelsController>()) {
          YearInPixelsController.to
              .loadYear(YearInPixelsController.to.selectedYear.value);
        }

        isLoading.value = false;
        update(['menstrual_form']);
        return model;
      } else {
        throw Exception("Failed to store menstrual log");
      }
    } catch (e) {
      log('Error storing menstrual log: $e');
      AlertHelper.showMsg(
        title: "Failed to add menstrual log",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    }
    isLoading.value = false;
    update(['menstrual_form']);
    return null;
  }

  // Main flow when user taps "Save / Next" on Add Menstrual Log
  Future<void> handleSaveMenstrualLogFlow() async {
    isLoading.value = true;
    update(['menstrual_form']);

    // Check if mood exists for the selected date
    final moods = await fetchMoodsForDate(selectedDate);
    existingMoods.assignAll(moods);

    isLoading.value = false;
    update(['menstrual_form']);

    if (moods.isEmpty) {
      // SCENARIO 1: Mood for that day is empty
      _proceedWithEmptyMoodFlow();
    } else {
      // SCENARIO 2: Mood for that day already exists
      _showExistingMoodChoiceDialog(moods);
    }
  }

  void _proceedWithEmptyMoodFlow() {
    final draftDate = selectedDate;
    final draftFlow = flow.value;
    final draftSymptoms = List<String>.from(symptoms);
    final draftIsPeriodStart = isPeriodStart.value;
    final draftNote = noteController.text;

    Get.back(); // close Menstrual Log sheet

    Get.snackbar(
      'Notice',
      'No mood recorded for this date. Please add a mood first.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeColor.primary,
      colorText: ThemeColor.white,
      duration: const Duration(seconds: 3),
    );

    // Open Add Mood full-page wizard
    Get.toNamed(Routes.addMood)?.then((_) async {
      final recordCtrl = RecordController.to;
      if (recordCtrl.listMood.isNotEmpty) {
        final latestMood = recordCtrl.listMood.first;
        if (latestMood != null && latestMood.id != null) {
          final formattedDate =
              "${draftDate.year.toString().padLeft(4, '0')}-${draftDate.month.toString().padLeft(2, '0')}-${draftDate.day.toString().padLeft(2, '0')}";

          await _menstrualLogRepository.storeMenstrualLog(
            date: formattedDate,
            moodId: latestMood.id,
            flow: draftFlow,
            symptoms: draftSymptoms,
            isPeriodStart: draftIsPeriodStart,
            note: draftNote.isNotEmpty ? draftNote : null,
          );
          resetForm();
          if (Get.isRegistered<DashboardController>()) {
            DashboardController.to.refresh();
          }
          recordCtrl.refresh();
        }
      }
    });
  }

  void _showExistingMoodChoiceDialog(List<MoodModel> moods) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link to a Mood Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.neutral_900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mood entries exist for this date. Would you like to link to an existing mood or create a new one?',
              style: TextStyle(fontSize: 14, color: ThemeColor.neutral_600),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.3),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final m = moods[index];
                  return ListTile(
                    leading: const Icon(Icons.mood, color: ThemeColor.primary),
                    title: Text(
                      m.title.isNotEmpty ? m.title : m.mood.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(m.emotions.isNotEmpty ? m.emotions : m.note),
                    onTap: () {
                      Get.back(); // close choice dialog
                      Get.back(); // close menstrual log sheet
                      submitMenstrualLog(moodId: m.id);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline,
                  color: ThemeColor.primary),
              title: const Text('Create New Mood & Link'),
              onTap: () {
                Get.back(); // close choice dialog
                _proceedWithEmptyMoodFlow();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check, color: ThemeColor.neutral_500),
              title: const Text('Save Menstrual Log Without Mood'),
              onTap: () {
                Get.back(); // close choice dialog
                Get.back(); // close menstrual log sheet
                submitMenstrualLog(moodId: null);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
