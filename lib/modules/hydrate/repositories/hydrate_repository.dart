import 'dart:convert';
import 'dart:developer';

import 'package:moodie/models/daily_drink_model.dart';
import 'package:moodie/models/target_daily_drink_model.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';

class HydrateRepository {
  static final HydrateRepository _instance = HydrateRepository._internal();
  factory HydrateRepository() => _instance;
  HydrateRepository._internal();
  UserModel? get user => AuthService().getUser();

  Future<bool> addDrink(int drink, int target) async {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final response = await ApiService().storeDailyDrink(
        drinkAmount: drink,
        entryDate: dateStr,
        action: 'set',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<int> getTodayDrink({
    void Function(int fresh)? onRefreshed,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final result = await ApiService().getData<int>(
        uri: '/daily-drinks?from=$dateStr&to=$dateStr',
        dbKey: 'today_drink_$dateStr',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final responseData = jsonDecode(jsonStr);
          if (responseData is Map && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map) {
              final model =
                  DailyDrinkModel.fromJson(Map<String, dynamic>.from(data));
              return model.drinkAmount;
            } else if (data is List && data.isNotEmpty) {
              final model = DailyDrinkModel.fromJson(
                  Map<String, dynamic>.from(data.first));
              return model.drinkAmount;
            }
          }
          return 0;
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log(e.toString());
    }
    return 0;
  }

  Future<bool> addTarget(int target) async {
    try {
      final response = await ApiService().updateTargetDrink(target);
      return response.statusCode == 200;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<int> getTarget({
    void Function(int fresh)? onRefreshed,
  }) async {
    try {
      final result = await ApiService().getData<int>(
        uri: '/target-drink',
        dbKey: 'target_drink',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final dataMap = jsonDecode(jsonStr);
          if (dataMap is Map<String, dynamic>) {
            final model = TargetDailyDrinkModel.fromJson(dataMap);
            return model.targetAmount;
          }
          return 0;
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
    } catch (e) {
      log(e.toString());
    }
    return 0;
  }
}
