import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/enum/mood_enum.dart';

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

  void setMood(MoodConditions mood) {
    this.mood = mood;
    update(['mood']);
  }

  void setEmotions(String emotions) {
    this.emotions = emotions;
    update(['emotions']);
  }

  void addMood() {
    moods
        .add({
          'mood': mood!.name,
          'note': noteController.text,
          'emotions': emotions,
          'title': titleController.text,
          'created_at': DateTime.now(),
          'user_id': user!.uid,
        })
        .then((value) => log('Mood Added'))
        .catchError((error) => log('Failed to add mood: $error'));
  }
}
