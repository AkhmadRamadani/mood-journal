import 'package:moodie/models/mood_model.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class MenstrualLogModel {
  final dynamic id;
  final String? userId;
  final dynamic moodId;
  final DateTime? date;
  final String flow;
  final List<String> symptoms;
  final String? mood;
  final MoodModel? moodEntry;
  final bool isPeriodStart;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenstrualLogModel({
    this.id,
    this.userId,
    this.moodId,
    this.date,
    this.flow = 'none',
    this.symptoms = const [],
    this.mood,
    this.moodEntry,
    this.isPeriodStart = false,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory MenstrualLogModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      return parseToLocalOrNull(val);
    }

    List<String> parsedSymptoms = [];
    if (json['symptoms'] != null && json['symptoms'] is List) {
      parsedSymptoms =
          (json['symptoms'] as List).map((e) => e.toString()).toList();
    }

    MoodModel? parsedMoodEntry;
    if (json['mood_entry'] != null &&
        json['mood_entry'] is Map<String, dynamic>) {
      parsedMoodEntry = MoodModel.fromJson(json['mood_entry']);
    }

    return MenstrualLogModel(
      id: json['id'],
      userId: json['user_id']?.toString(),
      moodId: json['mood_id'],
      date: parseDate(json['date']),
      flow: json['flow']?.toString() ?? 'none',
      symptoms: parsedSymptoms,
      mood: json['mood']?.toString(),
      moodEntry: parsedMoodEntry,
      isPeriodStart:
          json['is_period_start'] == true || json['is_period_start'] == 1,
      note: json['note']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (moodId != null) 'mood_id': moodId,
      if (date != null) 'date': date!.toIso8601String().split('T')[0],
      'flow': flow,
      'symptoms': symptoms,
      if (mood != null) 'mood': mood,
      if (moodEntry != null) 'mood_entry': moodEntry!.toJson(),
      'is_period_start': isPeriodStart,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  MenstrualLogModel copyWith({
    dynamic id,
    String? userId,
    dynamic moodId,
    DateTime? date,
    String? flow,
    List<String>? symptoms,
    String? mood,
    MoodModel? moodEntry,
    bool? isPeriodStart,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenstrualLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodId: moodId ?? this.moodId,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      moodEntry: moodEntry ?? this.moodEntry,
      isPeriodStart: isPeriodStart ?? this.isPeriodStart,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
