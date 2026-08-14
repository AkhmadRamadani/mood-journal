import 'dart:async';
import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';

import 'package:moodie/utils/helpers/calculations_helper.dart';
import 'package:moodie/utils/services/event_bus.dart';

class PeriodDataProviderImpl implements IPeriodDataProvider {
  PeriodDataProviderImpl({MenstrualLogRepository? repository})
      : _repository = repository ?? MenstrualLogRepository();

  final MenstrualLogRepository _repository;
  final StreamController<void> _changeController =
      StreamController<void>.broadcast();

  List<MenstrualLogModel> _cachedLogs = [];

  @override
  Stream<void> get onDataChanged => _changeController.stream;

  void init() {
    eventBus.on<MenstrualLogUpdatedEvent>().listen((_) {
      refreshLogs();
    });
    refreshLogs();
  }

  Future<void> refreshLogs() async {
    final now = DateTime.now();
    final from = '${now.year - 2}-01-01';
    final to = '${now.year + 1}-12-31';

    _cachedLogs = await _repository.getMenstrualLogs(
      from: from,
      to: to,
      onRefreshed: (logs) {
        _cachedLogs = logs;
        _changeController.add(null);
      },
    );
    _changeController.add(null);
  }

  void updateLogs(List<MenstrualLogModel> logs) {
    _cachedLogs = List.from(logs);
    _changeController.add(null);
  }

  /// Normalizes raw logs:
  /// 1. Deduplicates multiple logs on the exact same date (COUNT DISTINCT date).
  /// 2. Collapses consecutive `isPeriodStart = true` runs so only the FIRST day of a run
  ///    is recognized as a true logical period start date.
  _NormalizedData _normalize() {
    final dateMap = <DateTime, bool>{};

    for (final log in _cachedLogs) {
      final logDate = log.date ?? log.createdAt;
      if (logDate != null) {
        final d = DateTime(logDate.year, logDate.month, logDate.day);
        dateMap[d] = (dateMap[d] ?? false) || log.isPeriodStart;
      }
    }

    final sortedDates = dateMap.keys.toList()..sort((a, b) => a.compareTo(b));
    final starts = <DateTime>[];

    DateTime? prevStart;
    for (final date in sortedDates) {
      final isStart = dateMap[date] ?? false;
      if (isStart) {
        if (prevStart == null || date.difference(prevStart).inDays > 1) {
          starts.add(date);
        }
        prevStart = date;
      }
    }

    return _NormalizedData(
      loggedDates: sortedDates,
      periodStarts: starts,
    );
  }

  @override
  DateTime? getFirstPreviousPeriodStart(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final norm = _normalize();

    DateTime? latestStart;
    for (final start in norm.periodStarts) {
      if (!start.isAfter(target)) {
        latestStart = start;
      }
    }

    // Fallback: if no explicit period start flag exists, use earliest logged date
    if (latestStart == null && norm.loggedDates.isNotEmpty) {
      for (final d in norm.loggedDates) {
        if (!d.isAfter(target)) {
          latestStart = d;
        }
      }
    }

    return latestStart;
  }

  @override
  List<DateTime> getPeriodStartDates() {
    return _normalize().periodStarts;
  }

  @override
  List<DateTime> getPeriodLoggedDates() {
    return _normalize().loggedDates;
  }
}

class _NormalizedData {
  final List<DateTime> loggedDates;
  final List<DateTime> periodStarts;

  _NormalizedData({
    required this.loggedDates,
    required this.periodStarts,
  });
}
