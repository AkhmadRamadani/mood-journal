class GamificationProfileModel {
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int xpInLevel;
  final int xpNeeded;
  final double levelPercentage;
  final int unlockedBadgesCount;
  final int totalBadgesCount;

  GamificationProfileModel({
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.levelPercentage,
    required this.unlockedBadgesCount,
    required this.totalBadgesCount,
  });

  factory GamificationProfileModel.fromJson(Map<String, dynamic> json) {
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

    final xp = parseInt(
        json['xp'] ?? json['user_xp'] ?? json['points'] ?? json['total_xp']);
    int level =
        parseInt(json['level'] ?? json['user_level'] ?? json['current_level']);
    if (level < 1) level = 1;

    int xpInLevel = parseInt(
        json['xp_in_level'] ?? json['xpInLevel'] ?? json['current_level_xp']);
    int xpNeeded = parseInt(json['xp_needed'] ??
        json['xpNeeded'] ??
        json['next_level_xp'] ??
        json['xp_to_next_level']);

    // Fallback XP calculations if backend returns raw XP only
    if (xpNeeded == 0 && xpInLevel == 0 && xp > 0) {
      xpInLevel = xp % 100;
      xpNeeded = 100;
    } else if (xpNeeded == 0) {
      xpNeeded = 100;
    }

    double levelPercentage = parseDouble(json['level_percentage'] ??
        json['levelPercentage'] ??
        json['progress'] ??
        json['level_progress']);
    if (levelPercentage == 0.0 && xpNeeded > 0) {
      levelPercentage = (xpInLevel / xpNeeded).clamp(0.0, 1.0);
    } else if (levelPercentage > 1.0) {
      levelPercentage = (levelPercentage / 100.0).clamp(0.0, 1.0);
    }

    final unlockedBadgesCount = parseInt(json['unlocked_badges_count'] ??
        json['unlockedBadgesCount'] ??
        json['unlocked_badges'] ??
        json['badges_unlocked']);
    final totalBadgesCount = parseInt(json['total_badges_count'] ??
        json['totalBadgesCount'] ??
        json['total_badges'] ??
        json['badges_total']);

    return GamificationProfileModel(
      xp: xp,
      level: level,
      currentStreak: parseInt(json['current_streak'] ?? json['currentStreak']),
      longestStreak: parseInt(json['longest_streak'] ?? json['longestStreak']),
      lastActivityDate: json['last_activity_date'] ?? json['lastActivityDate'],
      xpInLevel: xpInLevel,
      xpNeeded: xpNeeded,
      levelPercentage: levelPercentage,
      unlockedBadgesCount: unlockedBadgesCount,
      totalBadgesCount: totalBadgesCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'level': level,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate,
      'xp_in_level': xpInLevel,
      'xp_needed': xpNeeded,
      'level_percentage': levelPercentage,
      'unlocked_badges_count': unlockedBadgesCount,
      'total_badges_count': totalBadgesCount,
    };
  }
}
