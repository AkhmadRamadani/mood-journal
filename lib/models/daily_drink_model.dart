import 'package:cloud_firestore/cloud_firestore.dart';

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
    return DailyDrinkModel(
      userId: json['user_id'],
      createdAt: json['created_at'].toDate(),
      drinkAmount: json['drink_amount'],
      targetAmount: json['target_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt,
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

  factory DailyDrinkModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return DailyDrinkModel.fromJson(documentSnapshot.data()!);
  }
}
