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
    DateTime parsedDate;
    if (json['updated_at'] != null || json['created_at'] != null) {
      final rawDate = json['updated_at'] ?? json['created_at'];
      if (rawDate is DateTime) {
        parsedDate = rawDate;
      } else {
        parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

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
