import 'dart:async';

abstract class IPeriodDataProvider {
  Stream<void> get onDataChanged;
  DateTime? getFirstPreviousPeriodStart(DateTime date);
  List<DateTime> getPeriodStartDates();
  List<DateTime> getPeriodLoggedDates();
}

class CalculationsHelper {
  CalculationsHelper(this._data);

  final IPeriodDataProvider _data;

  /// Returns the average length of a period in days based on logged history.
  /// Falls back to 0.0 if not enough data (at least 2 period starts required).
  double averagePeriodLength() {
    final starts = _data.getPeriodStartDates();
    if (starts.length < 2) return 0.0;

    final loggedDates = _data.getPeriodLoggedDates();
    if (loggedDates.isEmpty) return 0.0;

    final sorted = loggedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int streakCount = 0;
    DateTime? lastDate;

    for (final d in sorted) {
      if (lastDate == null) {
        streakCount = 1;
      } else {
        final diff = d.difference(lastDate).inDays;
        if (diff > 1) {
          streakCount++;
        }
      }
      lastDate = d;
    }

    if (streakCount == 0) return 0.0;
    return sorted.length / streakCount;
  }

  /// Returns the average cycle length in days between period starts.
  /// Falls back to 0.0 if fewer than 2 period starts logged.
  double averageCycleLength() {
    final starts = _data.getPeriodStartDates();
    if (starts.length < 2) return 0.0;

    final sorted = starts.map((d) => DateTime(d.year, d.month, d.day)).toList()
      ..sort((a, b) => a.compareTo(b));

    int totalDays = 0;
    int intervals = 0;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff >= 15 && diff <= 45) {
        totalDays += diff;
        intervals++;
      }
    }

    if (intervals == 0) return 0.0;
    return totalDays / intervals;
  }

  /// Returns average follicular growth phase length in days (period start -> ovulation).
  /// Typically half of cycle length or 14.0.
  double averageFollicularGrowthInDays() {
    final avgCycle = averageCycleLength();
    if (avgCycle <= 0) return 0.0;
    return (avgCycle / 2).roundToDouble();
  }

  /// Calculates predicted next period start date from the most recent period start.
  DateTime? calculateNextPeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStart = _data.getFirstPreviousPeriodStart(today);
    if (lastStart == null) return null;

    final cycleLen = averageCycleLength();
    final daysToAdd = cycleLen > 0 ? cycleLen.round() : 28;

    var next = DateTime(lastStart.year, lastStart.month, lastStart.day)
        .add(Duration(days: daysToAdd));

    while (next.isBefore(today)) {
      next = next.add(Duration(days: daysToAdd));
    }
    return next;
  }
}
