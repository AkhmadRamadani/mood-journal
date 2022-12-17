import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class RecordController extends GetxController {
  static RecordController get to => Get.find();

  MoodConditions? mood;
  String? note;
  String emotions = '';
  String? title;

  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  CollectionReference moods = FirebaseFirestore.instance.collection('moods');

  User? user = FirebaseAuth.instance.currentUser;

  RxBool isLoading = false.obs;

  void setMood(MoodConditions mood) {
    this.mood = mood;
    update(['mood']);
  }

  void setEmotions(String emotions) {
    this.emotions = emotions;
    update(['emotions']);
  }

  Future<void> addMood() async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['addMood']);
    moods.add({
      'mood': mood!.name,
      'note': noteController.text,
      'emotions': emotions,
      'title': titleController.text,
      'created_at': DateTime.now(),
      'user_id': user!.uid,
    }).then((value) async {
      Get.back();
      AlertHelper.showMsg(
        title: "Success to add mood",
        msg: "Your mood has been added, thank you. Enjoy your day!",
      );

      DashboardController.to.refresh();
    }).catchError((error) {
      log(error.toString());
      AlertHelper.showMsg(
        title: "Failed to add mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    });
    isLoading.value = false;
    update(['addMood']);
  }
}
