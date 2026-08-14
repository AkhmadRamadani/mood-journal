import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/helpers/phase_predictor.dart';

class CycleStats {
  final int cycleDay;
  final CyclePhase? phase;
  final int? daysUntilNextPeriod;
  final int? avgCycleLengthDays;
  final DateTime lastPeriodStart;
  final Map<CyclePhase, Map<MoodConditions, int>> moodCountsByPhase;

  CycleStats({
    required this.cycleDay,
    required this.phase,
    required this.daysUntilNextPeriod,
    required this.avgCycleLengthDays,
    required this.lastPeriodStart,
    required this.moodCountsByPhase,
  });

  MoodConditions? dominantMoodFor(CyclePhase phase) {
    final counts = moodCountsByPhase[phase];
    if (counts == null || counts.isEmpty) return null;
    MoodConditions? best;
    int bestCount = 0;
    counts.forEach((mood, count) {
      if (count > bestCount) {
        best = mood;
        bestCount = count;
      }
    });
    return best;
  }

  int totalLogsFor(CyclePhase phase) {
    final counts = moodCountsByPhase[phase];
    if (counts == null) return 0;
    return counts.values.fold(0, (a, b) => a + b);
  }

  bool get hasEnoughDataForInsight =>
      moodCountsByPhase.values.any((m) => m.isNotEmpty);
}
