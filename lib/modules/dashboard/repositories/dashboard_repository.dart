import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:moodie/models/daily_drink_model.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/models/quore_response.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/services/api_service.dart';

class DashboardRepository {
  static final DashboardRepository _instance = DashboardRepository._internal();
  factory DashboardRepository() => _instance;
  DashboardRepository._internal();

  Future<QuoteResponse?> getQuote() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.quotable.io/random?tags=happiness'),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return QuoteResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return null;
    }
  }

  // get latest mood with offline-first caching
  Future<MoodConditions?> getLatestMood({
    void Function(MoodConditions? fresh)? onRefreshed,
  }) async {
    try {
      final result = await ApiService().getData<MoodConditions?>(
        uri: '/moods?per_page=1',
        dbKey: 'latest_mood',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final dataMap = jsonDecode(jsonStr);
          final data = dataMap is Map ? dataMap['data'] : null;
          if (data is List && data.isNotEmpty) {
            final moodModel =
                MoodModel.fromJson(Map<String, dynamic>.from(data.first));
            return moodModel.mood;
          }
          return null;
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // get weekly mood biggest percentage with offline-first caching
  Future<Map<MoodConditions, double>?> getWeeklyMood({
    void Function(Map<MoodConditions, double>? fresh)? onRefreshed,
  }) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final fromStr = sevenDaysAgo.toIso8601String();
      final result = await ApiService().getData<Map<MoodConditions, double>?>(
        uri: '/moods?from=$fromStr&per_page=100',
        dbKey: 'weekly_mood',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final dataMap = jsonDecode(jsonStr);
          final data = dataMap is Map ? dataMap['data'] : null;
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
          return null;
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// get weekly daily drink mean with offline-first caching
  Future<double?> getDailyDrinkMean({
    void Function(double? fresh)? onRefreshed,
  }) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final fromStr = sevenDaysAgo.toIso8601String();
      final result = await ApiService().getData<double?>(
        uri: '/daily-drinks?from=$fromStr&per_page=100',
        dbKey: 'daily_drink_mean',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final dataMap = jsonDecode(jsonStr);
          final data = dataMap is Map ? dataMap['data'] : null;
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
          return null;
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
}
