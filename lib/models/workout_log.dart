class WorkoutLog {
  final int id;
  final int userId;
  final String exerciseType;
  final int repsCount;
  final int? durationSeconds;
  final int? formAccuracyScore;
  final String entryDate;
  final String? notes;
  final DateTime? createdAt;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.repsCount,
    this.durationSeconds,
    this.formAccuracyScore,
    required this.entryDate,
    this.notes,
    this.createdAt,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}') ?? 0,
      exerciseType: json['exercise_type'] ?? 'push_ups',
      repsCount: json['reps_count'] is int
          ? json['reps_count']
          : int.tryParse('${json['reps_count']}') ?? 0,
      durationSeconds: json['duration_seconds'] != null
          ? (json['duration_seconds'] is int
              ? json['duration_seconds']
              : int.tryParse('${json['duration_seconds']}'))
          : null,
      formAccuracyScore: json['form_accuracy_score'] != null
          ? (json['form_accuracy_score'] is int
              ? json['form_accuracy_score']
              : int.tryParse('${json['form_accuracy_score']}'))
          : null,
      entryDate: json['entry_date'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_type': exerciseType,
      'reps_count': repsCount,
      'duration_seconds': durationSeconds,
      'form_accuracy_score': formAccuracyScore,
      'entry_date': entryDate,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class WorkoutSummary {
  final int totalSessions;
  final int totalReps;
  final int totalDurationSeconds;
  final int todaySessions;
  final int todayReps;
  final List<ExerciseStat> byExercise;

  WorkoutSummary({
    required this.totalSessions,
    required this.totalReps,
    required this.totalDurationSeconds,
    required this.todaySessions,
    required this.todayReps,
    required this.byExercise,
  });

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSummary(
      totalSessions: json['total_sessions'] is int
          ? json['total_sessions']
          : int.tryParse('${json['total_sessions']}') ?? 0,
      totalReps: json['total_reps'] is int
          ? json['total_reps']
          : int.tryParse('${json['total_reps']}') ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] is int
          ? json['total_duration_seconds']
          : int.tryParse('${json['total_duration_seconds']}') ?? 0,
      todaySessions: json['today_sessions'] is int
          ? json['today_sessions']
          : int.tryParse('${json['today_sessions']}') ?? 0,
      todayReps: json['today_reps'] is int
          ? json['today_reps']
          : int.tryParse('${json['today_reps']}') ?? 0,
      byExercise: (json['by_exercise'] as List? ?? [])
          .map((e) => ExerciseStat.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'total_reps': totalReps,
      'total_duration_seconds': totalDurationSeconds,
      'today_sessions': todaySessions,
      'today_reps': todayReps,
      'by_exercise': byExercise.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseStat {
  final String exerciseType;
  final int sessionsCount;
  final int totalReps;
  final int totalDurationSeconds;

  ExerciseStat({
    required this.exerciseType,
    required this.sessionsCount,
    required this.totalReps,
    required this.totalDurationSeconds,
  });

  factory ExerciseStat.fromJson(Map<String, dynamic> json) {
    return ExerciseStat(
      exerciseType: json['exercise_type'] ?? 'push_ups',
      sessionsCount: json['sessions_count'] is int
          ? json['sessions_count']
          : int.tryParse('${json['sessions_count']}') ?? 0,
      totalReps: json['total_reps'] is int
          ? json['total_reps']
          : int.tryParse('${json['total_reps']}') ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] is int
          ? json['total_duration_seconds']
          : int.tryParse('${json['total_duration_seconds']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_type': exerciseType,
      'sessions_count': sessionsCount,
      'total_reps': totalReps,
      'total_duration_seconds': totalDurationSeconds,
    };
  }
}
