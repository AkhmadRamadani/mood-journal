import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class RecordController extends GetxController {
  static RecordController get to => Get.put(RecordController());

  MoodConditions? mood;
  String? note;
  String emotions = '';
  String? title;

  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  CollectionReference moods = FirebaseFirestore.instance.collection('moods');

  User? user = FirebaseAuth.instance.currentUser;

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
    moods.add({
      'mood': mood!.name,
      'note': noteController.text,
      'emotions': emotions,
      'title': titleController.text,
      'created_at': DateTime.now(),
      'user_id': user!.uid,
    }).then((value) async {
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
    }).catchError((error) {
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
    });
    isLoadingInsert.value = false;
    isLoadingInsert = false.obs;
    update(['addMood']);
  }

  // get list mood based on date
  Future<void> getMoodByDate() async {
    isLoading.value = true;
    isLoading = true.obs;
    update([
      'record',
    ]);
    listMood.clear();
    await moods
        .where('user_id', isEqualTo: user!.uid)
        .where('created_at',
            isGreaterThanOrEqualTo: DateTime(selectedDate.year,
                selectedDate.month, selectedDate.day, 0, 0, 0, 0, 0))
        .where('created_at',
            isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day, 23, 59, 59, 999, 999))
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        listMood.add(MoodModel.fromDocument(
            doc as DocumentSnapshot<Map<String, dynamic>>));
      });
    }).catchError((error) {
      log(error.toString());
      AlertHelper.showMsg(
        title: "Failed to get mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    });
    isLoading.value = false;
    update(['record']);
  }

  // delete mood
  Future<void> deleteMood(MoodModel mood) async {
    isLoading.value = true;
    isLoading = true.obs;
    update(['record']);
    await moods.doc(mood.id).delete().then(
      (value) {
        listMood.remove(mood);
        AlertHelper.showMsg(
          title: "Success to delete mood",
          msg: "Your mood has been deleted.",
        );
      },
    ).catchError((error) {
      log(error.toString());
      AlertHelper.showMsg(
        title: "Failed to delete mood",
        msg: "Something went wrong, please try again later.",
        isError: true,
      );
    });
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
