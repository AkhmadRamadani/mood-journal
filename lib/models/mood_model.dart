import 'package:moodie/shared/enum/mood_enum.dart';

class MoodModel {
  final MoodConditions mood;
  final String emotions;
  final DateTime createdAt;
  final String note;
  final String title;
  final String userId;
  final dynamic id;

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
    DateTime parsedDate;
    if (json['created_at'] != null) {
      if (json['created_at'] is DateTime) {
        parsedDate = json['created_at'];
      } else {
        parsedDate =
            DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    MoodConditions parsedMood;
    try {
      parsedMood = MoodConditions.values.firstWhere(
        (element) =>
            element.name.toString().toLowerCase() ==
            json['mood'].toString().toLowerCase(),
      );
    } catch (_) {
      parsedMood = MoodConditions.happy;
    }

    return MoodModel(
      id: json['id'],
      mood: parsedMood,
      emotions: json['emotions'] ?? '',
      createdAt: parsedDate,
      note: json['note'] ?? '',
      title: json['title'] ?? '',
      userId: json['user_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mood': mood.name,
      'emotions': emotions,
      'created_at': createdAt.toIso8601String(),
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
    dynamic id,
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
}
