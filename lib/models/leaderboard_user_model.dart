class LeaderboardUserModel {
  final int id;
  final String name;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int currentStreak;

  LeaderboardUserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.currentStreak,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return LeaderboardUserModel(
      id: parseInt(json['id']),
      name: json['name'] ?? 'User',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      level: parseInt(json['level']),
      xp: parseInt(json['xp']),
      currentStreak: parseInt(json['current_streak'] ?? json['currentStreak']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'level': level,
      'xp': xp,
      'current_streak': currentStreak,
    };
  }
}
