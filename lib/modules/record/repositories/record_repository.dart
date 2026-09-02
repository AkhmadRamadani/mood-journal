import 'dart:convert';
import 'dart:developer';

import 'package:moodie/models/mood_model.dart';
import 'package:moodie/utils/services/api_service.dart';

class RecordRepository {
  static final RecordRepository _instance = RecordRepository._internal();
  factory RecordRepository() => _instance;
  RecordRepository._internal();

  final ApiService _apiService = ApiService();

  Future<List<MoodModel>> getMoodsByDate(
    DateTime date, {
    void Function(List<MoodModel> fresh)? onRefreshed,
  }) async {
    final fromDate = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc();
    final toDate =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc();

    final fromStr = fromDate.toIso8601String();
    final toStr = toDate.toIso8601String();

    try {
      final result = await _apiService.getData<List<MoodModel>>(
        uri: '/moods?from=$fromStr&to=$toStr',
        dbKey: 'moods_${date.year}_${date.month}_${date.day}',
        dataSource: DataSource.networkFirst,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final responseData = jsonDecode(jsonStr);
          if (responseData is Map && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              return data
                  .map((item) =>
                      MoodModel.fromJson(Map<String, dynamic>.from(item)))
                  .toList();
            }
          }
          return [];
        },
      );

      if (result.isSuccess) {
        return result.data;
      }
    } catch (error) {
      log('RecordRepository getMoodsByDate error: $error');
    }
    return [];
  }

  Future<List<MoodModel>> getMoodsByDateRange(
    DateTime start,
    DateTime end, {
    void Function(List<MoodModel> fresh)? onRefreshed,
  }) async {
    final fromDate =
        DateTime(start.year, start.month, start.day, 0, 0, 0).toUtc();
    final toDate = DateTime(end.year, end.month, end.day, 23, 59, 59).toUtc();

    final fromStr = fromDate.toIso8601String();
    final toStr = toDate.toIso8601String();

    try {
      final result = await _apiService.getData<List<MoodModel>>(
        uri: '/moods?from=$fromStr&to=$toStr&per_page=100',
        dbKey:
            'moods_range_${start.year}_${start.month}_${start.day}_to_${end.year}_${end.month}_${end.day}',
        dataSource: DataSource.networkFirst,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final responseData = jsonDecode(jsonStr);
          if (responseData is Map && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              return data
                  .map((item) =>
                      MoodModel.fromJson(Map<String, dynamic>.from(item)))
                  .toList();
            }
          }
          return [];
        },
      );

      if (result.isSuccess) {
        return result.data;
      }
    } catch (error) {
      log('RecordRepository getMoodsByDateRange error: $error');
    }
    return [];
  }

  Future<bool> storeMood({
    required String mood,
    required String emotions,
    double? intensity,
    String? title,
    String? note,
    DateTime? createdAt,
  }) async {
    try {
      final response = await _apiService.storeMood(
        mood: mood,
        emotions: emotions,
        intensity: intensity,
        title: title,
        note: note,
        createdAt: createdAt,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (error) {
      log('RecordRepository storeMood error: $error');
      return false;
    }
  }

  Future<bool> updateMood({
    required dynamic id,
    String? mood,
    String? emotions,
    double? intensity,
    String? title,
    String? note,
  }) async {
    try {
      final response = await _apiService.updateMood(
        id: id,
        mood: mood,
        emotions: emotions,
        intensity: intensity,
        title: title,
        note: note,
      );
      return response.statusCode == 200;
    } catch (error) {
      log('RecordRepository updateMood error: $error');
      return false;
    }
  }

  Future<bool> deleteMood(dynamic id) async {
    try {
      final response = await _apiService.deleteMood(id);
      return response.statusCode == 200;
    } catch (error) {
      log('RecordRepository deleteMood error: $error');
      return false;
    }
  }
}
