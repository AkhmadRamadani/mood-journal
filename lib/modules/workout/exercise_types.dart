import 'package:flutter/material.dart';

enum ExerciseType {
  pushUps('push_ups', 'Push-ups', Icons.fitness_center_rounded, 'reps',
      'Elbow angle (95° / 145°)'),
  squats('squats', 'Squats', Icons.airline_seat_recline_extra_rounded, 'reps',
      'Knee angle (100° / 160°)'),
  bicepCurls('bicep_curls', 'Bicep Curls', Icons.sports_gymnastics_rounded,
      'reps', 'Elbow flexion (55° / 155°)'),
  jumpingJacks('jumping_jacks', 'Jumping Jacks',
      Icons.accessibility_new_rounded, 'reps', 'Overhead arms & wide stance'),
  plank('plank', 'Plank', Icons.horizontal_rule_rounded, 'seconds',
      'Straight torso line hold'),
  general('general', 'General', Icons.timer_outlined, 'reps',
      'Free workout tracking');

  final String slug;
  final String label;
  final IconData icon;
  final String unit;
  final String description;

  const ExerciseType(
    this.slug,
    this.label,
    this.icon,
    this.unit,
    this.description,
  );

  static ExerciseType fromSlug(String? slug) {
    if (slug == null) return ExerciseType.pushUps;
    return ExerciseType.values.firstWhere(
      (e) => e.slug == slug || e.name == slug,
      orElse: () => ExerciseType.pushUps,
    );
  }
}
