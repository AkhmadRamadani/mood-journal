class BadgeModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? icon;
  final String? category;
  final int pointsReward;
  final String? ruleType;
  final int requiredCount;
  final bool isUnlocked;
  final String? unlockedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.icon,
    this.category,
    required this.pointsReward,
    this.ruleType,
    required this.requiredCount,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val.toString().toLowerCase() == 'true' || val.toString() == '1';
    }

    return BadgeModel(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      category: json['category'],
      pointsReward: parseInt(json['points_reward'] ??
          json['pointsReward'] ??
          json['xp_reward'] ??
          json['xpReward']),
      ruleType: json['rule_type'] ?? json['ruleType'],
      requiredCount: parseInt(json['required_count'] ?? json['requiredCount']),
      isUnlocked: parseBool(
          json['is_unlocked'] ?? json['isUnlocked'] ?? json['unlocked']),
      unlockedAt: json['unlocked_at'] ?? json['unlockedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'category': category,
      'points_reward': pointsReward,
      'rule_type': ruleType,
      'required_count': requiredCount,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt,
    };
  }
}
