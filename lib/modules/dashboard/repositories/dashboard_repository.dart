import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodie/models/quore_response.dart';
import 'package:http/http.dart' as http;
import 'package:moodie/shared/enum/mood_enum.dart';

class DashboardRepository {
  CollectionReference moods = FirebaseFirestore.instance.collection('moods');
  User? user = FirebaseAuth.instance.currentUser;
  Future<QuoteResponse?> getQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=happiness'),
      );
      if (response.statusCode == 200) {
        return QuoteResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return null;
    }
  }

  // get latest mood
  Future<MoodConditions?> getLatestMood() async {
    final snapshot = await moods
        .where('user_id', isEqualTo: user!.uid)
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return MoodConditions.values.firstWhere(
        (element) => element.name == snapshot.docs.first['mood'],
      );
    } else {
      return null;
    }
  }

  // get weekly mood biggest percentage
  Future<Map<MoodConditions, double>?> getWeeklyMood() async {
    final snapshot = await moods
        .where('user_id', isEqualTo: user!.uid)
        .where('created_at',
            isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
        .get();
    if (snapshot.docs.isNotEmpty) {
      final moodMap = <MoodConditions, double>{};
      snapshot.docs.forEach((element) {
        final mood = MoodConditions.values.firstWhere(
          (e) => e.name == element['mood'],
        );
        if (moodMap.containsKey(mood)) {
          moodMap[mood] = moodMap[mood]! + 1;
        } else {
          moodMap[mood] = 1;
        }
      });

      // make it to range from 0 to 1
      moodMap.updateAll((key, value) => value / moodMap.length);
      final mood = moodMap.entries.reduce((value, element) {
        if (value.value > element.value) {
          return value;
        } else {
          return element;
        }
      });
      return {mood.key: mood.value.toDouble()};
    } else {
      return null;
    }
  }
}
