import 'package:moodie/utils/extensions/date_extension.dart';

class TargetDailyDrinkModel {
  final int targetAmount;
  final String userId;
  final DateTime createdAt;

  TargetDailyDrinkModel({
    required this.targetAmount,
    required this.userId,
    required this.createdAt,
  });

  factory TargetDailyDrinkModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['updated_at'] ?? json['created_at'];
    DateTime parsedDate = parseToLocal(rawDate);

    return TargetDailyDrinkModel(
      targetAmount: json['target_amount'] is int
          ? json['target_amount']
          : int.tryParse(json['target_amount']?.toString() ?? '2000') ?? 2000,
      userId: json['user_id']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_amount': targetAmount,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TargetDailyDrinkModel copyWith({
    int? targetAmount,
    String? userId,
    DateTime? createdAt,
  }) {
    return TargetDailyDrinkModel(
      targetAmount: targetAmount ?? this.targetAmount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
