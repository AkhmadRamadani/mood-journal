/// Predicts the four menstrual-cycle phases (menstruation, follicular,
/// ovulation, luteal) from the same historical-average math used by
/// [CalculationsHelper]. No fixed "28-day textbook cycle" assumption —
/// every window is derived from the user's own logged data, falling back
/// to typical averages only when there isn't enough history yet.
///
/// Biological note: menstruation and the follicular phase genuinely
/// overlap (bleeding happens *during* the early follicular phase), so
/// [predictPhasesFor] returns overlapping windows on purpose. Use
/// [getPrimaryPhase] if you want a single label to show in a UI.
library phase_predictor;

import 'dart:developer';

import 'package:flutter/material.dart';

import 'calculations_helper.dart';

enum CyclePhase { menstruation, follicular, ovulation, luteal }

extension CyclePhaseLabel on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstruation:
        return 'Menstruation';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  String get icon {
    switch (this) {
      case CyclePhase.menstruation:
        return '🔴';
      case CyclePhase.follicular:
        return '🌸';
      case CyclePhase.ovulation:
        return '🥚';
      case CyclePhase.luteal:
        return '🌙';
    }
  }

  Color get color {
    switch (this) {
      case CyclePhase.menstruation:
        return const Color(0xFFE53935); // Vibrant Red
      case CyclePhase.follicular:
        return const Color(0xFFF48FB1); // Soft Rose Pink
      case CyclePhase.ovulation:
        return const Color(0xFFFFB300); // Warm Gold
      case CyclePhase.luteal:
        return const Color(0xFF7E57C2); // Soft Purple
    }
  }

  Color get textColor {
    switch (this) {
      case CyclePhase.menstruation:
      case CyclePhase.luteal:
        return Colors.white;
      case CyclePhase.follicular:
      case CyclePhase.ovulation:
        return const Color(0xFF2D3748);
    }
  }
}

/// A date range during which [phase] is active. `end` is inclusive.
class PhaseWindow {
  const PhaseWindow(this.phase, this.start, this.end);

  final CyclePhase phase;
  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    final d = _dateOnly(date);
    return !d.isBefore(_dateOnly(start)) && !d.isAfter(_dateOnly(end));
  }
}

/// Full phase breakdown for one cycle, starting at [cycleStart] (a period
/// start date, actual or predicted) and running through the predicted
/// start of the next cycle.
class CyclePrediction {
  const CyclePrediction({
    required this.cycleStart,
    required this.nextCycleStart,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.phases,
  });

  final DateTime cycleStart;
  final DateTime nextCycleStart;
  final DateTime ovulationDate;

  /// Start of the estimated fertile window (inclusive) — the earliest
  /// day pregnancy is realistically possible this cycle, based on sperm
  /// viability of up to ~5 days.
  final DateTime fertileWindowStart;

  /// End of the estimated fertile window (inclusive). Set to
  /// [ovulationDate]: the egg itself is viable only ~24h after release,
  /// so the window doesn't meaningfully extend past ovulation day.
  final DateTime fertileWindowEnd;

  final List<PhaseWindow> phases;

  /// Total predicted cycle length in days.
  int get cycleLengthDays => nextCycleStart.difference(cycleStart).inDays;

  /// Whether [date] falls within this cycle's estimated fertile window.
  bool isInFertileWindow(DateTime date) {
    final d = _dateOnly(date);
    return !d.isBefore(fertileWindowStart) && !d.isAfter(fertileWindowEnd);
  }

  List<PhaseWindow> windowsFor(CyclePhase phase) =>
      phases.where((w) => w.phase == phase).toList();
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class PhasePredictor {
  PhasePredictor(this._calc, this._data);

  final CalculationsHelper _calc;
  final IPeriodDataProvider _data;

  // Fallback typical-cycle values, used only when there isn't enough
  // logged history yet to compute a personalized average.
  static const _fallbackPeriodLength = 5;
  static const _fallbackCycleLength = 28;
  static const _fallbackFollicularLength = 14; // period start -> ovulation

  /// Days before ovulation the fertile window opens, based on typical
  /// sperm viability (~5 days). Not derived from user data — this is a
  /// fixed physiological estimate, same convention used by mainstream
  /// fertility-awareness apps.
  static const _fertileWindowLeadDays = 5;

  /// Phase breakdown for the cycle currently in progress, i.e. starting
  /// at the most recent logged period start. Null if no period has been
  /// logged yet.
  CyclePrediction? predictCurrentCycle() {
    final lastStart = _data.getFirstPreviousPeriodStart(DateTime.now());
    if (lastStart == null) return null;
    return predictPhasesFor(lastStart);
  }

  /// Phase breakdown for the *next*, not-yet-started cycle, projecting
  /// forward from [CalculationsHelper.calculateNextPeriod].
  CyclePrediction? predictUpcomingCycle() {
    final nextStart = _calc.calculateNextPeriod();
    if (nextStart == null) return null;
    return predictPhasesFor(nextStart);
  }

  /// Builds the four phase windows for a cycle beginning at [cycleStart],
  /// using personalized averages where available.
  CyclePrediction predictPhasesFor(DateTime cycleStart) {
    final start = _dateOnly(cycleStart);

    final periodLen = _resolveDays(
      _calc.averagePeriodLength(),
      _fallbackPeriodLength,
    );
    final cycleLen = _resolveDays(
      _calc.averageCycleLength(),
      _fallbackCycleLength,
    );
    final follicularLen = _resolveDays(
      _calc.averageFollicularGrowthInDays(),
      _fallbackFollicularLength,
    );

    final menstruationEnd = start.add(Duration(days: periodLen - 1));
    final ovulationDate = start.add(Duration(days: follicularLen));
    final follicularEnd = ovulationDate.subtract(const Duration(days: 1));
    final nextCycleStart = start.add(Duration(days: cycleLen));
    final lutealStart = ovulationDate.add(const Duration(days: 1));
    final lutealEnd = nextCycleStart.subtract(const Duration(days: 1));

    // Clamp to cycleStart: with a short follicular phase, a naive
    // "ovulation minus 5 days" could land before this cycle even began
    // (i.e. still within the previous cycle), which isn't meaningful.
    var fertileWindowStart =
        ovulationDate.subtract(const Duration(days: _fertileWindowLeadDays));
    if (fertileWindowStart.isBefore(start)) fertileWindowStart = start;
    final fertileWindowEnd = ovulationDate;

    final phases = <PhaseWindow>[
      PhaseWindow(CyclePhase.menstruation, start, menstruationEnd),
      PhaseWindow(
        CyclePhase.follicular,
        start,
        follicularEnd.isBefore(start) ? start : follicularEnd,
      ),
      PhaseWindow(CyclePhase.ovulation, ovulationDate, ovulationDate),
      PhaseWindow(
        CyclePhase.luteal,
        lutealStart,
        lutealEnd.isBefore(lutealStart) ? lutealStart : lutealEnd,
      ),
    ];

    final result = CyclePrediction(
      cycleStart: start,
      nextCycleStart: nextCycleStart,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      phases: phases,
    );

    log('🔮 [PhasePredictor] Cycle Phase Prediction Calculated 🔮');
    log('  📥 INPUTS:');
    log('     • cycleStart: ${_fmt(start)}');
    log('     • averagePeriodLength: $periodLen days (hist: ${_calc.averagePeriodLength().toStringAsFixed(1)})');
    log('     • averageCycleLength: $cycleLen days (hist: ${_calc.averageCycleLength().toStringAsFixed(1)})');
    log('     • averageFollicularGrowth: $follicularLen days (hist: ${_calc.averageFollicularGrowthInDays().toStringAsFixed(1)})');
    log('  📤 OUTPUTS:');
    log('     • nextCycleStart: ${_fmt(nextCycleStart)}');
    log('     • ovulationDate: ${_fmt(ovulationDate)}');
    log('     • fertileWindow: ${_fmt(fertileWindowStart)} ➔ ${_fmt(fertileWindowEnd)}');
    for (final p in phases) {
      log('     • Phase [${p.phase.label}]: ${_fmt(p.start)} ➔ ${_fmt(p.end)}');
    }

    return result;
  }

  /// Estimated fertile window for the cycle covering [date] (defaults to
  /// today). Returns null if no cycle — logged or predicted — covers it.
  PhaseWindow? getFertileWindow([DateTime? date]) {
    final prediction = _predictionCovering(date ?? DateTime.now());
    if (prediction == null) return null;
    // Reuses PhaseWindow purely as a (start, end) pair; `phase` field is
    // arbitrary here since "fertile window" isn't itself a CyclePhase.
    return PhaseWindow(
      CyclePhase.ovulation,
      prediction.fertileWindowStart,
      prediction.fertileWindowEnd,
    );
  }

  /// Whether [date] falls within the estimated fertile window of the
  /// cycle that covers it.
  bool isInFertileWindow(DateTime date) {
    final prediction = _predictionCovering(date);
    return prediction?.isInFertileWindow(date) ?? false;
  }

  /// Reactive stream of [isInFertileWindow] for [date].
  Stream<bool> fertileWindowStream(DateTime date) {
    return _data.onDataChanged.map((_) => isInFertileWindow(date));
  }

  /// All phases active on [date] (can be >1, since menstruation overlaps
  /// the early follicular phase). Empty if [date] falls outside any
  /// known or predicted cycle.
  List<CyclePhase> getActivePhases(DateTime date) {
    final prediction = _predictionCovering(date);
    if (prediction == null) return [];
    return prediction.phases
        .where((w) => w.contains(date))
        .map((w) => w.phase)
        .toList();
  }

  /// A single "best" phase label for [date], for simple UI display.
  /// Priority: logged period dates > menstruation > ovulation > luteal > follicular.
  CyclePhase? getPrimaryPhase(DateTime date) {
    final d = _dateOnly(date);
    final loggedDates =
        _data.getPeriodLoggedDates().map((x) => _dateOnly(x)).toSet();
    if (loggedDates.contains(d)) {
      return CyclePhase.menstruation;
    }

    final active = getActivePhases(date);
    if (active.isEmpty) return null;
    for (final p in [
      CyclePhase.menstruation,
      CyclePhase.ovulation,
      CyclePhase.luteal,
      CyclePhase.follicular,
    ]) {
      if (active.contains(p)) return p;
    }
    return active.first;
  }

  /// Reactive stream of the primary phase for [date], re-emitting
  /// whenever underlying period/ovulation data changes.
  Stream<CyclePhase?> primaryPhaseStream(DateTime date) {
    return _data.onDataChanged.map((_) => getPrimaryPhase(date));
  }

  // ---------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------

  /// Finds (or predicts) the cycle that contains [date] — looks
  /// backward through logged period starts first, and if [date] is in
  /// the future beyond any logged cycle, falls back to the predicted
  /// upcoming cycle.
  CyclePrediction? _predictionCovering(DateTime date) {
    final d = _dateOnly(date);
    final priorStart = _data.getFirstPreviousPeriodStart(d);

    if (priorStart != null) {
      final prediction = predictPhasesFor(priorStart);
      if (!d.isBefore(prediction.cycleStart) &&
          d.isBefore(prediction.nextCycleStart)) {
        return prediction;
      }
      // date falls after this cycle's predicted end (irregular gap) —
      // fall through to the upcoming-cycle prediction below.
    }

    final upcoming = predictUpcomingCycle();
    if (upcoming != null &&
        !d.isBefore(upcoming.cycleStart) &&
        d.isBefore(upcoming.nextCycleStart)) {
      return upcoming;
    }

    // No logged cycle covers this date and it doesn't fall in the
    // predicted upcoming cycle either — best-effort: use whichever
    // prediction is closest.
    return upcoming ??
        (priorStart != null ? predictPhasesFor(priorStart) : null);
  }

  int _resolveDays(double average, int fallback) {
    if (average <= 0) return fallback;
    return average.round();
  }
}

String _fmt(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
