/// Handles inconsistent / gappy logging — e.g. a user logs a period
/// start on Jan 1, then nothing again until Aug 11.
///
/// Without this, `CalculationsHelper.averageCycleLength()` would happily
/// diff Jan 1 -> Aug 11 as a single 223-day "cycle" and blend that into
/// the average, corrupting every prediction downstream. A 7-month gap
/// isn't a long cycle — it's a logging gap. This file decides which
/// period starts represent one continuous, trustworthy tracking history
/// before any math runs on them.
///
/// Usage: wrap your real [IPeriodDataProvider] with
/// [SegmentedPeriodDataProvider], and hand *that* to
/// [CalculationsHelper] / [PhasePredictor] instead of your raw provider.
/// No changes needed to either of those files.
library cycle_data_segmenter;

import 'calculations_helper.dart';

class CycleGapConfig {
  const CycleGapConfig({
    this.minPlausibleCycleDays = 21,
    this.maxPlausibleCycleDays = 45,
    this.staleAfterDays = 45,
  });

  /// Below this, a gap between two period starts is almost certainly a
  /// logging error (duplicate entry, mislabeled day) rather than a real
  /// short cycle.
  final int minPlausibleCycleDays;

  /// Above this, a gap is treated as the user having stopped logging,
  /// not one very long cycle. Everything before a gap this size is
  /// excluded from the "current" tracking segment.
  final int maxPlausibleCycleDays;

  /// If the most recent period start is older than this many days
  /// (from "today"), predictions built from it should be flagged
  /// low-confidence / stale rather than shown as current.
  final int staleAfterDays;
}

enum TrackingConfidence {
  /// 3+ consistent, contiguous cycles logged recently.
  high,

  /// Some contiguous data, but fewer than 3 cycles — predictions will
  /// lean heavily on fallback defaults.
  low,

  /// The most recent period start is older than [CycleGapConfig.staleAfterDays]
  /// — the user has likely stopped logging, or this cycle is unusually
  /// overdue. Don't present predictions as current without a caveat.
  stale,

  /// No usable period starts at all.
  none,
}

class SegmentedHistory {
  const SegmentedHistory({
    required this.periodStarts,
    required this.confidence,
    required this.excludedGapDays,
    required this.excludedEntryCount,
  });

  /// The most recent *contiguous* run of period starts — safe to feed
  /// into [CalculationsHelper] for averaging. Oldest first.
  final List<DateTime> periodStarts;

  final TrackingConfidence confidence;

  /// Size of the gap (in days) that was excluded just before this
  /// segment, if any. Null if no gap was found in the input.
  final int? excludedGapDays;

  /// How many older period starts were dropped because they fell before
  /// that gap. 0 if nothing was excluded.
  final int excludedEntryCount;
}

class CycleDataSegmenter {
  const CycleDataSegmenter([this.config = const CycleGapConfig()]);

  final CycleGapConfig config;

  /// [allPeriodStarts] should be ALL known period starts for the user,
  /// sorted oldest-first, already deduplicated to one date per real
  /// period. This function decides how much of the history is actually usable.
  SegmentedHistory segment(List<DateTime> allPeriodStarts, {DateTime? now}) {
    final today = now ?? DateTime.now();

    if (allPeriodStarts.isEmpty) {
      return const SegmentedHistory(
        periodStarts: [],
        confidence: TrackingConfidence.none,
        excludedGapDays: null,
        excludedEntryCount: 0,
      );
    }

    // Walk backward from the most recent entry. Stop the first time a
    // gap to the next-older entry falls outside the plausible range —
    // everything before that point belongs to a different tracking era.
    final segment = <DateTime>[allPeriodStarts.last];
    int? excludedGapDays;
    var excludedCount = 0;

    for (var i = allPeriodStarts.length - 2; i >= 0; i--) {
      final gap = segment.first.difference(allPeriodStarts[i]).inDays;
      if (gap < config.minPlausibleCycleDays ||
          gap > config.maxPlausibleCycleDays) {
        excludedGapDays = gap;
        excludedCount = i + 1; // everything from index 0..i is excluded
        break;
      }
      segment.insert(0, allPeriodStarts[i]);
    }

    final daysSinceLast = today.difference(segment.last).inDays;
    final confidence = daysSinceLast > config.staleAfterDays
        ? TrackingConfidence.stale
        : segment.length >= 3
            ? TrackingConfidence.high
            : TrackingConfidence.low;

    return SegmentedHistory(
      periodStarts: segment,
      confidence: confidence,
      excludedGapDays: excludedGapDays,
      excludedEntryCount: excludedCount,
    );
  }
}

/// Decorator over a raw [IPeriodDataProvider] that transparently applies
/// [CycleDataSegmenter] before serving period-start data to
/// [CalculationsHelper]. Everything else passes through unchanged.
class SegmentedPeriodDataProvider implements IPeriodDataProvider {
  SegmentedPeriodDataProvider(
    this._inner, {
    CycleDataSegmenter? segmenter,
  }) : _segmenter = segmenter ?? const CycleDataSegmenter();

  final IPeriodDataProvider _inner;
  final CycleDataSegmenter _segmenter;

  /// Exposes the last computed segmentation result.
  SegmentedHistory? lastSegmentation;

  SegmentedHistory _currentSegment() {
    final all = _inner
        .getPeriodStartDates()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toList()
      ..sort((a, b) => a.compareTo(b));
    final result = _segmenter.segment(all);
    lastSegmentation = result;
    return result;
  }

  @override
  List<DateTime> getPeriodStartDates() {
    return _currentSegment().periodStarts;
  }

  @override
  DateTime? getFirstPreviousPeriodStart(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final starts = getPeriodStartDates();
    DateTime? latest;
    for (final s in starts) {
      if (!s.isAfter(target)) {
        latest = s;
      }
    }
    return latest ?? _inner.getFirstPreviousPeriodStart(date);
  }

  @override
  List<DateTime> getPeriodLoggedDates() => _inner.getPeriodLoggedDates();

  @override
  Stream<void> get onDataChanged => _inner.onDataChanged;
}
