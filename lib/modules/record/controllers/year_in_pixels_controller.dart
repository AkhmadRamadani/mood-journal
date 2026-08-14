import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:moodie/models/cycle_stats_model.dart';
import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/models/mood_model.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/extensions/get_extension.dart';
import 'package:moodie/utils/helpers/calculations_helper.dart';
import 'package:moodie/utils/helpers/cycle_data_segmenter.dart';
import 'package:moodie/utils/helpers/phase_predictor.dart';
import 'package:moodie/utils/services/event_bus.dart';
import 'package:moodie/utils/services/period_data_provider_impl.dart';

class YearInPixelsController extends GetxController {
  static YearInPixelsController get to {
    if (!Get.isRegistered<YearInPixelsController>()) {
      return Get.put(YearInPixelsController());
    }
    return Get.find<YearInPixelsController>();
  }

  final RecordRepository _repo = Get.find<RecordRepository>();
  final MenstrualLogRepository _menstrualRepo =
      Get.isRegistered<MenstrualLogRepository>()
          ? Get.find<MenstrualLogRepository>()
          : Get.put(MenstrualLogRepository());

  late final PeriodDataProviderImpl _dataProvider;
  late final SegmentedPeriodDataProvider segmentedProvider;
  late final PhasePredictor phasePredictor;

  RxBool isLoading = true.obs;
  RxInt selectedYear = DateTime.now().year.obs;

  // View modes & filters
  RxBool isCanvasView = false.obs;
  Rx<MoodConditions?> activeMoodFilter = Rx<MoodConditions?>(null);
  RxBool filterPeriodOnly = false.obs;

  // Data maps (yyyy-MM-dd -> model/list)
  final Map<String, MoodConditions> pixelMap = {};
  final Map<String, List<MoodModel>> dailyMoodsMap = {};
  final Map<String, MenstrualLogModel> periodMap = {};

  // Analytics & Stats
  int currentStreak = 0;
  int longestStreak = 0;
  int totalDaysLogged = 0;
  int totalEntriesLogged = 0;
  int totalPeriodDays = 0;
  CycleStats? cycleStats;

  final Map<MoodConditions, int> moodCounts = {};
  final Map<MoodConditions, double> moodRatios = {};
  String healthInsight = '';

  StreamSubscription? _moodSub;
  StreamSubscription? _menstrualSub;

  @override
  void onInit() {
    super.onInit();
    _dataProvider = PeriodDataProviderImpl(repository: _menstrualRepo);
    segmentedProvider = SegmentedPeriodDataProvider(_dataProvider);
    phasePredictor = PhasePredictor(
      CalculationsHelper(segmentedProvider),
      segmentedProvider,
    );

    loadYear(selectedYear.value);

    _moodSub = eventBus.on<MoodLoggedEvent>().listen((_) {
      loadYear(selectedYear.value);
    });
    _menstrualSub = eventBus.on<MenstrualLogUpdatedEvent>().listen((_) {
      loadYear(selectedYear.value);
    });
  }

  @override
  void onClose() {
    _moodSub?.cancel();
    _menstrualSub?.cancel();
    super.onClose();
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void toggleViewMode() {
    isCanvasView.value = !isCanvasView.value;
    safeUpdate();
  }

  void toggleMoodFilter(MoodConditions mood) {
    if (activeMoodFilter.value == mood) {
      activeMoodFilter.value = null;
    } else {
      activeMoodFilter.value = mood;
      filterPeriodOnly.value = false;
    }
    safeUpdate();
  }

  void togglePeriodFilter() {
    filterPeriodOnly.value = !filterPeriodOnly.value;
    if (filterPeriodOnly.value) {
      activeMoodFilter.value = null;
    }
    safeUpdate();
  }

  void clearFilters() {
    activeMoodFilter.value = null;
    filterPeriodOnly.value = false;
    safeUpdate();
  }

  Future<void> loadYear(int year) async {
    isLoading.value = true;
    pixelMap.clear();
    dailyMoodsMap.clear();
    periodMap.clear();
    moodCounts.clear();
    moodRatios.clear();
    cycleStats = null;

    final start = DateTime(year, 1, 1);
    final end =
        year == DateTime.now().year ? DateTime.now() : DateTime(year, 12, 31);

    final fromStr =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-01';
    final toStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-31';

    try {
      // 1. Fetch Moods
      final moods = await _repo.getMoodsByDateRange(start, end);
      totalEntriesLogged = moods.length;

      for (final mood in moods) {
        final key = _key(mood.createdAt);
        dailyMoodsMap.putIfAbsent(key, () => []).add(mood);

        // Use the latest logged mood of the day for primary pixel color
        pixelMap[key] = mood.mood;

        moodCounts[mood.mood] = (moodCounts[mood.mood] ?? 0) + 1;

        if (mood.menstrualLog != null) {
          periodMap.putIfAbsent(key, () => mood.menstrualLog!);
        }
      }

      // Sort daily entries chronologically for each day
      dailyMoodsMap.forEach((key, list) {
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });

      // 2. Fetch Standalone Menstrual Logs
      final menstrualLogs =
          await _menstrualRepo.getMenstrualLogs(from: fromStr, to: toStr);
      for (final log in menstrualLogs) {
        final logDate = log.date ?? log.createdAt;
        if (logDate != null) {
          final key = _key(logDate);
          periodMap.putIfAbsent(key, () => log);
        }
      }

      totalPeriodDays = periodMap.length;
      _dataProvider.updateLogs(periodMap.values.toList());
      _computeStats(year);
      _computeCycleStats();
      _computeAnalytics();
    } catch (e) {
      log('YearInPixelsController error loading data: $e');
    }
    isLoading.value = false;
    safeUpdate();
  }

  void _computeCycleStats() {
    if (periodMap.isEmpty) {
      cycleStats = null;
      return;
    }

    final starts = <DateTime>[];
    periodMap.forEach((key, log) {
      if (log.isPeriodStart) {
        final parts = key.split('-');
        if (parts.length == 3) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            starts.add(DateTime(y, m, d));
          }
        }
      }
    });

    if (starts.isEmpty) {
      cycleStats = null;
      return;
    }
    starts.sort();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pastOrToday = starts.where((d) => !d.isAfter(today)).toList();
    final lastStart = pastOrToday.isNotEmpty ? pastOrToday.last : starts.first;

    final cycleDay = today.difference(lastStart).inDays + 1;

    // Average cycle length from consecutive period starts.
    int? avgLength;
    if (starts.length >= 2) {
      final diffs = <int>[];
      for (int i = 1; i < starts.length; i++) {
        diffs.add(starts[i].difference(starts[i - 1]).inDays);
      }
      if (diffs.isNotEmpty) {
        avgLength = (diffs.reduce((a, b) => a + b) / diffs.length).round();
      }
    }

    int? daysUntilNext;
    if (avgLength != null) {
      final predictedNext = lastStart.add(Duration(days: avgLength));
      daysUntilNext = predictedNext.difference(today).inDays;
    }

    final phase = phasePredictor.getPrimaryPhase(today);

    // Mood dominance per cycle phase, built from all logged moods.
    final moodCountsByPhase = <CyclePhase, Map<MoodConditions, int>>{
      for (final p in CyclePhase.values) p: {},
    };
    dailyMoodsMap.forEach((key, moods) {
      final parts = key.split('-');
      if (parts.length != 3) return;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) return;
      final date = DateTime(y, m, d);
      final p = phasePredictor.getPrimaryPhase(date);
      if (p == null) return;
      for (final entry in moods) {
        moodCountsByPhase[p]!.update(
          entry.mood,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    });

    cycleStats = CycleStats(
      cycleDay: cycleDay,
      phase: phase,
      daysUntilNextPeriod: daysUntilNext,
      avgCycleLengthDays: avgLength,
      lastPeriodStart: lastStart,
      moodCountsByPhase: moodCountsByPhase,
    );
  }

  void _computeAnalytics() {
    totalDaysLogged = pixelMap.length;
    if (totalEntriesLogged > 0) {
      for (final m in MoodConditions.values) {
        final count = moodCounts[m] ?? 0;
        moodRatios[m] = count / totalEntriesLogged;
      }
    }

    // Compute smart health insight
    int tiredOrSadOnPeriod = 0;
    for (final entry in periodMap.entries) {
      final moods = dailyMoodsMap[entry.key] ?? [];
      final hasTiredOrSad = moods.any((m) =>
          m.mood == MoodConditions.tired || m.mood == MoodConditions.sad);
      if (hasTiredOrSad) {
        tiredOrSadOnPeriod++;
      }
    }

    if (tiredOrSadOnPeriod > 0) {
      healthInsight =
          '💡 $tiredOrSadOnPeriod of your low-energy logs occurred during your period cycle.';
    } else if (totalEntriesLogged > 0) {
      MoodConditions? topMood;
      int maxCount = 0;
      moodCounts.forEach((m, count) {
        if (count > maxCount) {
          maxCount = count;
          topMood = m;
        }
      });
      if (topMood != null) {
        final pct = ((maxCount / totalEntriesLogged) * 100).round();
        healthInsight =
            '🌟 ${topMood!.label} is your top mood ($pct% of total logs)!';
      }
    } else {
      healthInsight =
          'Log your moods daily to unlock personal health insights!';
    }
  }

  void _computeStats(int year) {
    final now = DateTime.now();
    final limit = year == now.year ? now : DateTime(year, 12, 31);
    final start = DateTime(year, 1, 1);
    final totalDays = limit.difference(start).inDays + 1;

    // Current streak: walk backwards from today
    int streak = 0;
    DateTime cursor = DateTime(now.year, now.month, now.day);
    while (true) {
      if (pixelMap.containsKey(_key(cursor))) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    currentStreak = streak;

    // Longest streak: iterate all days in year
    int longest = 0;
    int running = 0;
    for (int i = 0; i < totalDays; i++) {
      final d = start.add(Duration(days: i));
      if (pixelMap.containsKey(_key(d))) {
        running++;
        if (running > longest) longest = running;
      } else {
        running = 0;
      }
    }
    longestStreak = longest;
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadYear(year);
  }
}
