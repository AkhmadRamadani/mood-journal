import 'package:moodie/utils/extensions/date_extension.dart';

class DailyDrinkModel {
  final String userId;
  final DateTime createdAt;
  final int drinkAmount;
  final int targetAmount;

  DailyDrinkModel({
    required this.userId,
    required this.createdAt,
    required this.drinkAmount,
    required this.targetAmount,
  });

  factory DailyDrinkModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['entry_date'] ?? json['created_at'];
    DateTime parsedDate = parseToLocal(rawDate);

    return DailyDrinkModel(
      userId: json['user_id']?.toString() ?? '',
      createdAt: parsedDate,
      drinkAmount: json['drink_amount'] is int
          ? json['drink_amount']
          : int.tryParse(json['drink_amount']?.toString() ?? '0') ?? 0,
      targetAmount: json['target_amount'] is int
          ? json['target_amount']
          : int.tryParse(json['target_amount']?.toString() ?? '2000') ?? 2000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'drink_amount': drinkAmount,
      'target_amount': targetAmount,
    };
  }

  DailyDrinkModel copyWith({
    String? userId,
    DateTime? createdAt,
    int? drinkAmount,
    int? targetAmount,
  }) {
    return DailyDrinkModel(
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      drinkAmount: drinkAmount ?? this.drinkAmount,
      targetAmount: targetAmount ?? this.targetAmount,
    );
  }
}
