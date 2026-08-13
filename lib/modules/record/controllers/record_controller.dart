import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/controllers/gamification_controller.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';
import 'package:moodie/utils/services/auth_service.dart';

class RecordController extends GetxController {
  static RecordController get to => Get.put(RecordController());

  final RecordRepository _recordRepository = Get.find<RecordRepository>();

  UserModel? get user => AuthService().getUser();

  MoodConditions? mood;
  String? note;
  String emotions = '';
  String? title;

  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  RxBool isLoadingInsert = false.obs;
  RxBool isLoading = false.obs;

  DateTime selectedDate = DateTime.now();

  List<MoodModel?> listMood = [];
  List<MoodModel> weeklyMoods = [];

  void setMood(MoodConditions mood) {
    this.mood = mood;
    update(['mood']);
  }

  void setEmotions(String emotions) {
    this.emotions = emotions;
    update(['emotions']);
  }

  Future<void> addMood() async {
    isLoadingInsert.value = true;
    isLoadingInsert = true.obs;
    update(['addMood']);

    try {
      final success = await _recordRepository.storeMood(
        mood: mood!.name,
        emotions: emotions,
        title: titleController.text,
        note: noteController.text,
      );

      if (success) {
        // reset form
        noteController.clear();
        titleController.clear();
        mood = null;
        emotions = '';
        note = null;
        title = null;

        Get.close(2);
        AlertHelper.showMsg(
          title: "Success to add mood",
          msg: "Your mood has been added, thank you. Enjoy your day!",
        );

        DashboardController.to.refresh();
        GamificationController.to.refreshProfile();
      } else {
        throw Exception("Failed to store mood");
      }
    } catch (error) {
      log(error.toString());
      // reset form
      noteController.clear();
      titleController.clear();
      mood = null;
      emotions = '';
      note = null;
      title = null;
      Get.close(2);
      AlertHelper.showMsg(
        title: "Failed to add mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    }
    isLoadingInsert.value = false;
    isLoadingInsert = false.obs;
    update(['addMood']);
  }

  // get list mood based on date via repository
  Future<void> getMoodByDate() async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['record']);
    listMood.clear();

    try {
      final moods = await _recordRepository.getMoodsByDate(
        selectedDate,
        onRefreshed: (fresh) {
          listMood.assignAll(fresh);
          update(['record']);
        },
      );
      listMood.assignAll(moods);
    } catch (error) {
      log(error.toString());
      AlertHelper.showMsg(
        title: "Failed to get mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    }
    isLoading.value = false;
    update(['record']);
    fetchWeeklyMoods();
  }

  // Fetch moods for the visible calendar week so water drop markers stay visible for all days
  Future<void> fetchWeeklyMoods() async {
    try {
      final monday =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final moods = await _recordRepository.getMoodsByDateRange(
        monday,
        sunday,
        onRefreshed: (fresh) {
          weeklyMoods.assignAll(fresh);
          update(['calendar']);
        },
      );
      weeklyMoods.assignAll(moods);
      update(['calendar']);
    } catch (e) {
      log('Error fetching weekly moods: $e');
    }
  }

  // delete mood via repository
  Future<void> deleteMood(MoodModel moodModel) async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['record']);

    try {
      final success = await _recordRepository.deleteMood(moodModel.id);
      if (success) {
        listMood.remove(moodModel);
        weeklyMoods.removeWhere((m) => m.id == moodModel.id);
        AlertHelper.showMsg(
          title: "Success to delete mood",
          msg: "Your mood has been deleted.",
        );
      } else {
        throw Exception("Failed to delete mood");
      }
    } catch (error) {
      log(error.toString());
      AlertHelper.showMsg(
        title: "Failed to delete mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    }
    isLoading.value = false;
    update(['record', 'calendar']);
  }

  @override
  void refresh() async {
    super.refresh();
    await getMoodByDate();
  }

  @override
  void onInit() {
    super.onInit();
    getMoodByDate();
  }
}
