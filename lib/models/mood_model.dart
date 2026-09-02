import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class MoodModel {
  final MoodConditions mood;
  final String emotions;
  final double intensity;
  final DateTime createdAt;
  final String note;
  final String title;
  final String userId;
  final dynamic id;
  final MenstrualLogModel? menstrualLog;

  MoodModel({
    required this.mood,
    required this.emotions,
    this.intensity = 0.5,
    required this.createdAt,
    required this.note,
    required this.title,
    required this.userId,
    this.id,
    this.menstrualLog,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = parseToLocal(json['created_at']);

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

    MenstrualLogModel? parsedMenstrualLog;
    if (json['menstrual_log'] != null &&
        json['menstrual_log'] is Map<String, dynamic>) {
      parsedMenstrualLog = MenstrualLogModel.fromJson(
          Map<String, dynamic>.from(json['menstrual_log']));
    }

    double parsedIntensity = 0.5;
    if (json['intensity'] != null) {
      if (json['intensity'] is num) {
        parsedIntensity = (json['intensity'] as num).toDouble();
      } else {
        parsedIntensity = double.tryParse(json['intensity'].toString()) ?? 0.5;
      }
    }

    return MoodModel(
      id: json['id'],
      mood: parsedMood,
      emotions: json['emotions'] ?? '',
      intensity: parsedIntensity,
      createdAt: parsedDate,
      note: json['note'] ?? '',
      title: json['title'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      menstrualLog: parsedMenstrualLog,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mood': mood.name,
      'emotions': emotions,
      'intensity': intensity,
      'created_at': createdAt.toUtc().toIso8601String(),
      'note': note,
      'title': title,
      'user_id': userId,
      if (menstrualLog != null) 'menstrual_log': menstrualLog!.toJson(),
    };
  }

  MoodModel copyWith({
    MoodConditions? mood,
    String? emotions,
    double? intensity,
    DateTime? createdAt,
    String? note,
    String? title,
    String? userId,
    dynamic id,
    MenstrualLogModel? menstrualLog,
  }) {
    return MoodModel(
      mood: mood ?? this.mood,
      emotions: emotions ?? this.emotions,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      menstrualLog: menstrualLog ?? this.menstrualLog,
    );
  }
}
