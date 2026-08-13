class ChallengeModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String? type;
  final String? targetType;
  final int targetCount;
  final int xpReward;
  final int progress;
  final double progressPercentage;
  final bool isCompleted;
  final String? completedAt;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.type,
    this.targetType,
    required this.targetCount,
    required this.xpReward,
    required this.progress,
    required this.progressPercentage,
    required this.isCompleted,
    this.completedAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val.toString().toLowerCase() == 'true' || val.toString() == '1';
    }

    return ChallengeModel(
      id: parseInt(json['id']),
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      type: json['type'],
      targetType: json['target_type'] ?? json['targetType'],
      targetCount: parseInt(json['target_count'] ?? json['targetCount']),
      xpReward: parseInt(
          json['xp_reward'] ?? json['xpReward'] ?? json['points_reward']),
      progress: parseInt(json['progress']),
      progressPercentage: parseDouble(
          json['progress_percentage'] ?? json['progressPercentage']),
      isCompleted: parseBool(
          json['is_completed'] ?? json['isCompleted'] ?? json['completed']),
      completedAt: json['completed_at'] ?? json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'type': type,
      'target_type': targetType,
      'target_count': targetCount,
      'xp_reward': xpReward,
      'progress': progress,
      'progress_percentage': progressPercentage,
      'is_completed': isCompleted,
      'completed_at': completedAt,
    };
  }
}
