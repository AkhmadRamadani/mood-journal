import 'dart:convert';
import 'dart:developer';

import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/utils/services/api_service.dart';

class MenstrualLogRepository {
  static final MenstrualLogRepository _instance =
      MenstrualLogRepository._internal();
  factory MenstrualLogRepository() => _instance;
  MenstrualLogRepository._internal();

  final ApiService _apiService = ApiService();

  Future<MenstrualLogModel?> storeMenstrualLog({
    required String date,
    dynamic moodId,
    String? flow,
    List<String>? symptoms,
    bool? isPeriodStart,
    String? note,
  }) async {
    try {
      final response = await _apiService.storeMenstrualLog(
        date: date,
        moodId: moodId,
        flow: flow,
        symptoms: symptoms,
        isPeriodStart: isPeriodStart,
        note: note,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return MenstrualLogModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      log('MenstrualLogRepository storeMenstrualLog error: $e');
    }
    return null;
  }

  Future<List<MenstrualLogModel>> getMenstrualLogs({
    String? flow,
    dynamic moodId,
    bool? isPeriodStart,
    String? from,
    String? to,
    void Function(List<MenstrualLogModel> fresh)? onRefreshed,
  }) async {
    try {
      final result = await _apiService.getData<List<MenstrualLogModel>>(
        uri: '/menstrual-logs?from=$from&to=$to',
        dbKey: 'menstrual_logs_${from}_$to',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final responseData = jsonDecode(jsonStr);
          if (responseData is Map && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              return data
                  .map((item) => MenstrualLogModel.fromJson(
                      Map<String, dynamic>.from(item)))
                  .toList();
            }
          }
          return [];
        },
      );

      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log('MenstrualLogRepository getMenstrualLogs error: $e');
    }
    return [];
  }
}
