import 'dart:developer';

import 'package:moodie/models/daily_drink_model.dart';
import 'package:moodie/models/target_daily_drink_model.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';

class HydrateRepository {
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

  Future<int> getTodayDrink() async {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final response =
          await ApiService().getDailyDrinks(from: dateStr, to: dateStr);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data['data'] != null) {
          final data = response.data['data'];
          if (data is Map) {
            final model =
                DailyDrinkModel.fromJson(Map<String, dynamic>.from(data));
            return model.drinkAmount;
          } else if (data is List && data.isNotEmpty) {
            final model =
                DailyDrinkModel.fromJson(Map<String, dynamic>.from(data.first));
            return model.drinkAmount;
          }
        }
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

  Future<int> getTarget() async {
    try {
      final response = await ApiService().getTargetDrink();
      if (response.statusCode == 200 && response.data != null) {
        final model = TargetDailyDrinkModel.fromJson(
            Map<String, dynamic>.from(response.data));
        return model.targetAmount;
      }
    } catch (e) {
      log(e.toString());
    }
    return 0;
  }
}
