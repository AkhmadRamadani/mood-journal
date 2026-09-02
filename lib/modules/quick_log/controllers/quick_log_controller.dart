import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/hydrate/controllers/hydrate_controller.dart';
import 'package:moodie/modules/hydrate/repositories/hydrate_repository.dart';
import 'package:moodie/modules/quick_log/data/moodie_agent.dart';
import 'package:moodie/modules/quick_log/domain/tool_call.dart';
import 'package:moodie/modules/record/controllers/menstrual_log_controller.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/services/speech_service.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/utils/services/event_bus.dart';

class QuickLogController extends GetxController {
  static QuickLogController get to {
    if (!Get.isRegistered<QuickLogController>()) {
      return Get.put(QuickLogController());
    }
    return Get.find<QuickLogController>();
  }

  final MoodieAgent agent = MoodieAgent.instance;
  final TextEditingController textController = TextEditingController();

  final RxBool isParsing = false.obs;
  final RxBool isLogging = false.obs;
  final RxBool isListening = false.obs;
  final Rx<ParsedQuickLogResult?> lastResult = Rx<ParsedQuickLogResult?>(null);

  @override
  void onInit() {
    super.onInit();
    agent.init();
  }

  /// Toggles speech-to-text dictation into the text field.
  Future<void> toggleVoice() async {
    if (!Get.isRegistered<SpeechService>()) {
      Get.put(SpeechService());
    }
    final speech = SpeechService.to;

    if (speech.isListening.value) {
      await speech.stopListening();
      isListening.value = false;
      if (textController.text.trim().isNotEmpty) {
        processInput(textController.text);
      }
    } else {
      isListening.value = true;
      await speech.startListening(
        onResult: (text) {
          textController.text = text;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        },
      );
    }
  }

  /// Processes natural language text via the Needle on-device agent.
  Future<ParsedQuickLogResult> processInput(String input,
      {bool autoExecuteIfConfident = true}) async {
    final query = input.trim();
    if (query.isEmpty) {
      return ParsedQuickLogResult(rawQuery: query, toolCalls: const []);
    }

    isParsing.value = true;
    try {
      final result = await agent.parseLogEntry(query);
      lastResult.value = result;

      if (result.isEmpty) {
        Get.snackbar(
          'No Log Detected',
          'Try typing e.g. "feeling anxious 4", "drank 2 glasses", or "cramps level 3".',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF333333),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return result;
      }

      if (autoExecuteIfConfident &&
          result.hasHighConfidence &&
          result.toolCalls.length <= 2) {
        // High confidence: Log immediately & display toast with undo
        await executeToolCalls(result.toolCalls);
        textController.clear();
      }

      return result;
    } catch (e) {
      log('[QuickLogController] Error parsing input: $e');
      return ParsedQuickLogResult(rawQuery: query, toolCalls: const []);
    } finally {
      isParsing.value = false;
    }
  }

  /// Executes and records the tool calls into respective database repositories.
  Future<bool> executeToolCalls(List<ToolCall> toolCalls) async {
    if (toolCalls.isEmpty) return false;

    isLogging.value = true;
    final List<String> loggedSummaries = [];

    try {
      final moodCalls = toolCalls.whereType<MoodLogToolCall>().toList();
      final waterCalls = toolCalls.whereType<WaterLogToolCall>().toList();
      final cycleCalls = toolCalls.whereType<CycleSymptomToolCall>().toList();

      for (final call in moodCalls) {
        await _executeMoodLog(call);
        loggedSummaries.add(call.displayLabel);
      }

      for (final call in waterCalls) {
        await _executeWaterLog(call);
        loggedSummaries.add(call.displayLabel);
      }

      if (cycleCalls.isNotEmpty) {
        await _executeCycleSymptomsBatch(cycleCalls);
        loggedSummaries.addAll(cycleCalls.map((c) => c.displayLabel));
      }

      final summaryText = loggedSummaries.join(' • ');

      Get.snackbar(
        'Quick Logged ✨',
        summaryText,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1B5E20),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );

      return true;
    } catch (e) {
      log('[QuickLogController] Error executing tool calls: $e');
      Get.snackbar(
        'Error Logging',
        'Could not save log entry: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLogging.value = false;
    }
  }

  Future<void> _executeMoodLog(MoodLogToolCall call) async {
    try {
      final MoodConditions condition;
      switch (call.mood.toLowerCase()) {
        case 'happy':
          condition = MoodConditions.happy;
          break;
        case 'sad':
          condition = MoodConditions.sad;
          break;
        case 'tired':
          condition = MoodConditions.tired;
          break;
        case 'anxious':
          condition = MoodConditions.sad;
          break;
        case 'irritated':
          condition = MoodConditions.tired;
          break;
        case 'calm':
          condition = MoodConditions.cheerful;
          break;
        default:
          condition = MoodConditions.cheerful;
      }

      final intensityNormalized = (call.intensity / 5.0).clamp(0.1, 1.0);
      final emotions = call.mood[0].toUpperCase() + call.mood.substring(1);

      final repo = Get.isRegistered<RecordRepository>()
          ? Get.find<RecordRepository>()
          : RecordRepository();

      await repo.storeMood(
        mood: condition.name,
        emotions: emotions,
        intensity: intensityNormalized,
        title: 'Quick Log: $emotions',
        note: 'Logged via on-device Needle Quick Log',
        createdAt: DateTime.now().toUtc(),
      );

      if (Get.isRegistered<RecordController>()) {
        RecordController.to.getMoodByDate();
      }

      if (Get.isRegistered<DashboardController>()) {
        DashboardController.to.setLatestMood();
        DashboardController.to.setBiggestMood();
      }

      eventBus.fire(const MoodLoggedEvent());
    } catch (e) {
      log('Error storing mood in quick log: $e');
    }
  }

  Future<void> _executeWaterLog(WaterLogToolCall call) async {
    try {
      final repo = Get.isRegistered<HydrateRepository>()
          ? Get.find<HydrateRepository>()
          : HydrateRepository();

      int target = 2000;
      int currentToday = 0;

      if (Get.isRegistered<HydrateController>()) {
        final hc = HydrateController.to;
        target = hc.targetWater.value > 0 ? hc.targetWater.value : 2000;
        currentToday = hc.currentWater.value;
      } else {
        target = await repo.getTarget();
        if (target <= 0) target = 2000;
        currentToday = await repo.getTodayDrink();
      }

      final newTotal = currentToday + call.ml;

      if (Get.isRegistered<HydrateController>()) {
        final hc = HydrateController.to;
        hc.currentWater.value = newTotal;
        hc.targetWater.value = target;
        hc.setRemainingWater();
        hc.setPercentage();
        hc.setHeightPercentages();
        hc.update();
      }

      await repo.addDrink(newTotal, target);

      eventBus.fire(WaterIntakeUpdatedEvent(
        drinkAmount: newTotal,
        targetAmount: target,
      ));

      if (Get.isRegistered<DashboardController>()) {
        DashboardController.to.setWaterPercentage();
      }
    } catch (e) {
      log('Error storing water in quick log: $e');
    }
  }

  Future<void> _executeCycleSymptomsBatch(
      List<CycleSymptomToolCall> calls) async {
    try {
      final repo = Get.isRegistered<MenstrualLogRepository>()
          ? Get.find<MenstrualLogRepository>()
          : MenstrualLogRepository();

      final recordRepo = Get.isRegistered<RecordRepository>()
          ? Get.find<RecordRepository>()
          : RecordRepository();

      final now = DateTime.now();
      final todayStr =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final symptomsList = calls
          .map((c) => c.symptom[0].toUpperCase() + c.symptom.substring(1))
          .toSet()
          .toList();

      final maxSeverity = calls
          .map((c) => c.severity)
          .fold<int>(1, (max, v) => v > max ? v : max);

      String flow = 'light';
      if (maxSeverity >= 4) {
        flow = 'heavy';
      } else if (maxSeverity == 3) {
        flow = 'medium';
      }

      dynamic moodId;
      try {
        final todaysMoods = await recordRepo.getMoodsByDate(now);
        if (todaysMoods.isNotEmpty) {
          moodId = todaysMoods.first.id;
        }
      } catch (_) {}

      final result = await repo.storeMenstrualLog(
        date: todayStr,
        moodId: moodId,
        flow: flow,
        symptoms: symptomsList,
        isPeriodStart: true,
        note: 'Severity: $maxSeverity/5 (Logged via Needle Quick Log)',
      );

      log('[QuickLogController] Stored menstrual log: $result');

      if (Get.isRegistered<MenstrualLogController>()) {
        MenstrualLogController.to.resetForm();
      }

      if (Get.isRegistered<DashboardController>()) {
        DashboardController.to.refresh();
      }

      eventBus.fire(const MenstrualLogUpdatedEvent());
    } catch (e) {
      log('Error storing cycle symptoms batch in quick log: $e');
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
