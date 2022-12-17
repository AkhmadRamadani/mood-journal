import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodie/shared/enum/mood_enum.dart';

class MoodModel {
  final MoodConditions mood;
  final String emotions;
  final DateTime createdAt;
  final String note;
  final String title;
  final String userId;
  final String? id;

  MoodModel({
    required this.mood,
    required this.emotions,
    required this.createdAt,
    required this.note,
    required this.title,
    required this.userId,
    this.id,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      mood: MoodConditions.values.firstWhere(
          (element) => element.name.toString() == json['mood'].toString()),
      emotions: json['emotions'],
      createdAt: json['created_at'].toDate(),
      note: json['note'],
      title: json['title'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'emotions': emotions,
      'created_at': createdAt,
      'note': note,
      'title': title,
      'user_id': userId,
    };
  }

  MoodModel copyWith({
    MoodConditions? mood,
    String? emotions,
    DateTime? createdAt,
    String? note,
    String? title,
    String? userId,
    String? id,
  }) {
    return MoodModel(
      mood: mood ?? this.mood,
      emotions: emotions ?? this.emotions,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }

  factory MoodModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MoodModel.fromJson(doc.data()!).copyWith(id: doc.id);
  }
}
