import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';
import 'package:moodie/utils/services/api_service.dart';

import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/auth_service.dart';

class RecordController extends GetxController {
  static RecordController get to => Get.put(RecordController());

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
      final response = await ApiService().storeMood(
        mood: mood!.name,
        emotions: emotions,
        title: titleController.text,
        note: noteController.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      } else {
        throw Exception("Server returned ${response.statusCode}");
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

  // get list mood based on date
  Future<void> getMoodByDate() async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['record']);
    listMood.clear();

    final fromDate = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    final toDate = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    try {
      final response = await ApiService().getMoods(
        from: fromDate.toIso8601String(),
        to: toDate.toIso8601String(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          for (var item in data) {
            listMood.add(MoodModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
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
  }

  // delete mood
  Future<void> deleteMood(MoodModel moodModel) async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['record']);

    try {
      final response = await ApiService().deleteMood(moodModel.id);
      if (response.statusCode == 200) {
        listMood.remove(moodModel);
        AlertHelper.showMsg(
          title: "Success to delete mood",
          msg: "Your mood has been deleted.",
        );
      } else {
        throw Exception("Delete status ${response.statusCode}");
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
    update(['record']);
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
