import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:moodie/models/daily_drink_model.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/models/quore_response.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/services/api_service.dart';

class DashboardRepository {
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
    try {
      final response = await ApiService().getMoods(perPage: 1);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final moodModel =
              MoodModel.fromJson(Map<String, dynamic>.from(data.first));
          return moodModel.mood;
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // get weekly mood biggest percentage
  Future<Map<MoodConditions, double>?> getWeeklyMood() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final response = await ApiService().getMoods(
        from: sevenDaysAgo.toIso8601String(),
        perPage: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final moodMap = <MoodConditions, double>{};
          for (var item in data) {
            final moodModel =
                MoodModel.fromJson(Map<String, dynamic>.from(item));
            final mood = moodModel.mood;
            moodMap[mood] = (moodMap[mood] ?? 0) + 1;
          }
          moodMap.updateAll((key, value) => value / data.length);
          final topMood =
              moodMap.entries.reduce((v, e) => v.value > e.value ? v : e);
          return {topMood.key: topMood.value.toDouble()};
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// daily drink mean
  /// get weekly daily drink mean
  Future<double?> getDailyDrinkMean() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final response = await ApiService().getDailyDrinks(
        from: sevenDaysAgo.toIso8601String(),
        perPage: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        List items = [];
        if (data is List) {
          items = data;
        } else if (data is Map) {
          items = [data];
        }
        if (items.isNotEmpty) {
          double total = 0;
          for (var item in items) {
            final drink =
                DailyDrinkModel.fromJson(Map<String, dynamic>.from(item));
            total += drink.drinkAmount;
          }
          return total / items.length;
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
}
