import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/cycle_stats_model.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/helpers/phase_predictor.dart';

void main() {
  group('CycleStats Model Tests', () {
    test(
        'Correctly computes dominantMoodFor, totalLogsFor, and hasEnoughDataForInsight',
        () {
      final moodCountsByPhase = <CyclePhase, Map<MoodConditions, int>>{
        CyclePhase.menstruation: {
          MoodConditions.sad: 3,
          MoodConditions.tired: 5,
        },
        CyclePhase.follicular: {
          MoodConditions.happy: 4,
          MoodConditions.cheerful: 1,
        },
        CyclePhase.ovulation: {},
        CyclePhase.luteal: {},
      };

      final stats = CycleStats(
        cycleDay: 14,
        phase: CyclePhase.ovulation,
        daysUntilNextPeriod: 14,
        avgCycleLengthDays: 28,
        lastPeriodStart: DateTime(2026, 1, 1),
        moodCountsByPhase: moodCountsByPhase,
      );

      expect(stats.dominantMoodFor(CyclePhase.menstruation),
          equals(MoodConditions.tired));
      expect(stats.dominantMoodFor(CyclePhase.follicular),
          equals(MoodConditions.happy));
      expect(stats.dominantMoodFor(CyclePhase.ovulation), isNull);

      expect(stats.totalLogsFor(CyclePhase.menstruation), equals(8));
      expect(stats.totalLogsFor(CyclePhase.follicular), equals(5));
      expect(stats.totalLogsFor(CyclePhase.ovulation), equals(0));

      expect(stats.hasEnoughDataForInsight, isTrue);
    });

    test('hasEnoughDataForInsight is false when no mood counts exist', () {
      final stats = CycleStats(
        cycleDay: 1,
        phase: CyclePhase.menstruation,
        daysUntilNextPeriod: 28,
        avgCycleLengthDays: 28,
        lastPeriodStart: DateTime(2026, 1, 1),
        moodCountsByPhase: {
          for (final p in CyclePhase.values) p: {},
        },
      );

      expect(stats.hasEnoughDataForInsight, isFalse);
    });
  });
}
