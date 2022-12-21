import 'package:cloud_firestore/cloud_firestore.dart';

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
    return TargetDailyDrinkModel(
      targetAmount: json['target_amount'],
      userId: json['user_id'],
      createdAt: json['created_at'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_amount': targetAmount,
      'user_id': userId,
    };
  }

  TargetDailyDrinkModel copyWith({
    int? targetDailyDrink,
    String? userId,
    DateTime? createdAt,
  }) {
    return TargetDailyDrinkModel(
      targetAmount: targetAmount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TargetDailyDrinkModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return TargetDailyDrinkModel.fromJson(documentSnapshot.data()!);
  }
}
