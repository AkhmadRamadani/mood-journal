import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/utils/helpers/calculations_helper.dart';
import 'package:moodie/utils/helpers/cycle_data_segmenter.dart';
import 'package:moodie/utils/helpers/phase_predictor.dart';
import 'package:moodie/utils/services/period_data_provider_impl.dart';

class MockPeriodDataProvider implements IPeriodDataProvider {
  final List<DateTime> starts;
  final List<DateTime> logs;

  MockPeriodDataProvider({
    required this.starts,
    required this.logs,
  });

  final StreamController<void> _ctrl = StreamController<void>.broadcast();

  @override
  Stream<void> get onDataChanged => _ctrl.stream;

  @override
  DateTime? getFirstPreviousPeriodStart(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    DateTime? latest;
    for (final d in starts) {
      final cur = DateTime(d.year, d.month, d.day);
      if (!cur.isAfter(target)) {
        if (latest == null || cur.isAfter(latest)) {
          latest = cur;
        }
      }
    }
    return latest;
  }

  @override
  List<DateTime> getPeriodStartDates() => starts;

  @override
  List<DateTime> getPeriodLoggedDates() => logs;
}

void main() {
  group('PhasePredictor & CalculationsHelper Tests', () {
    test('Calculates fallback averages when no logs exist', () {
      final mock = MockPeriodDataProvider(starts: [], logs: []);
      final calc = CalculationsHelper(mock);
      final predictor = PhasePredictor(calc, mock);

      expect(calc.averageCycleLength(), equals(0.0));
      expect(calc.averagePeriodLength(), equals(0.0));

      final cycleStart = DateTime(2026, 1, 1);
      final prediction = predictor.predictPhasesFor(cycleStart);

      expect(prediction.cycleStart, equals(DateTime(2026, 1, 1)));
      expect(prediction.ovulationDate, equals(DateTime(2026, 1, 15)));
      expect(prediction.nextCycleStart, equals(DateTime(2026, 1, 29)));
      expect(prediction.isInFertileWindow(DateTime(2026, 1, 12)), isTrue);
      expect(prediction.isInFertileWindow(DateTime(2026, 1, 20)), isFalse);
    });

    test('Primary phase prioritization works correctly', () {
      final mock = MockPeriodDataProvider(
        starts: [DateTime(2026, 8, 1)],
        logs: [
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 2),
          DateTime(2026, 8, 3),
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 5),
        ],
      );
      final calc = CalculationsHelper(mock);
      final predictor = PhasePredictor(calc, mock);

      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 2)),
          equals(CyclePhase.menstruation));
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 15)),
          equals(CyclePhase.ovulation));
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 20)),
          equals(CyclePhase.luteal));
    });

    test(
        'Single cycle data falls back to 5-day period and prioritizes logged days',
        () {
      final mock = MockPeriodDataProvider(
        starts: [DateTime(2026, 8, 11)],
        logs: [
          DateTime(2026, 8, 11),
          DateTime(2026, 8, 12),
          DateTime(2026, 8, 13),
          DateTime(2026, 8, 14),
        ],
      );
      final calc = CalculationsHelper(mock);
      final predictor = PhasePredictor(calc, mock);

      // Only 1 cycle start logged -> must fall back to 0.0 for averages
      expect(calc.averagePeriodLength(), equals(0.0));
      expect(calc.averageCycleLength(), equals(0.0));

      final prediction = predictor.predictPhasesFor(DateTime(2026, 8, 11));
      // Fallback period length is 5 days (Aug 11 ➔ Aug 15)
      final menstruationWindow =
          prediction.windowsFor(CyclePhase.menstruation).first;
      expect(menstruationWindow.start, equals(DateTime(2026, 8, 11)));
      expect(menstruationWindow.end, equals(DateTime(2026, 8, 15)));

      // All logged days are recognized as menstruation
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 11)),
          equals(CyclePhase.menstruation));
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 12)),
          equals(CyclePhase.menstruation));
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 13)),
          equals(CyclePhase.menstruation));
      expect(predictor.getPrimaryPhase(DateTime(2026, 8, 14)),
          equals(CyclePhase.menstruation));
    });

    test(
        'PeriodDataProviderImpl normalizes duplicate logs and consecutive period starts',
        () {
      final provider = PeriodDataProviderImpl();
      provider.updateLogs([
        // Duplicate logs on Aug 12
        MenstrualLogModel(
            id: 1, date: DateTime(2026, 8, 12), isPeriodStart: true),
        MenstrualLogModel(
            id: 2, date: DateTime(2026, 8, 12), isPeriodStart: true),
        // Consecutive period start on Aug 13 (user tapped start again)
        MenstrualLogModel(
            id: 3, date: DateTime(2026, 8, 13), isPeriodStart: true),
        // Flow continuation
        MenstrualLogModel(
            id: 4, date: DateTime(2026, 8, 14), isPeriodStart: false),
        // Duplicate log on Aug 14
        MenstrualLogModel(
            id: 5, date: DateTime(2026, 8, 14), isPeriodStart: false),
      ]);

      final starts = provider.getPeriodStartDates();
      final loggedDates = provider.getPeriodLoggedDates();

      // Consecutive period starts on Aug 12 & 13 must be collapsed into single start date Aug 12
      expect(starts, equals([DateTime(2026, 8, 12)]));

      // Duplicate entries on Aug 12 and Aug 14 must be deduplicated
      expect(
          loggedDates,
          equals([
            DateTime(2026, 8, 12),
            DateTime(2026, 8, 13),
            DateTime(2026, 8, 14),
          ]));
    });

    test(
        'CycleDataSegmenter excludes outlier gap and computes correct confidence',
        () {
      const segmenter = CycleDataSegmenter();

      // Scenario: Jan 1 start, then big 223-day gap to Aug 12
      final starts = [
        DateTime(2026, 1, 1),
        DateTime(2026, 8, 12),
      ];

      final segmented = segmenter.segment(starts, now: DateTime(2026, 8, 14));

      // Jan 1 should be excluded from current tracking era
      expect(segmented.periodStarts, equals([DateTime(2026, 8, 12)]));
      expect(segmented.excludedGapDays, equals(223));
      expect(segmented.excludedEntryCount, equals(1));
      expect(segmented.confidence, equals(TrackingConfidence.low));
    });

    test(
        'CycleDataSegmenter identifies 3+ contiguous cycles as high confidence',
        () {
      const segmenter = CycleDataSegmenter();

      final starts = [
        DateTime(2026, 5, 20),
        DateTime(2026, 6, 17),
        DateTime(2026, 7, 15),
        DateTime(2026, 8, 12),
      ];

      final segmented = segmenter.segment(starts, now: DateTime(2026, 8, 14));

      expect(segmented.periodStarts.length, equals(4));
      expect(segmented.excludedEntryCount, equals(0));
      expect(segmented.confidence, equals(TrackingConfidence.high));
    });

    test('SegmentedPeriodDataProvider transparently decorates raw provider',
        () {
      final raw = MockPeriodDataProvider(
        starts: [
          DateTime(2026, 1, 1),
          DateTime(2026, 8, 12),
        ],
        logs: [
          DateTime(2026, 1, 1),
          DateTime(2026, 8, 12),
        ],
      );

      final segmented = SegmentedPeriodDataProvider(raw);
      final calc = CalculationsHelper(segmented);

      // Only 1 period start retained in active segment, so cycle length should not be poisoned by 223-day gap
      expect(segmented.getPeriodStartDates(), equals([DateTime(2026, 8, 12)]));
      expect(calc.averageCycleLength(), equals(0.0)); // Fallback, not 223!
    });
  });
}
