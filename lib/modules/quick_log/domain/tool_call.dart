import 'package:flutter/foundation.dart';

/// Base class for all structured on-device Needle / Cactus tool calls.
abstract class ToolCall {
  final String toolName;
  final double confidence;

  const ToolCall({
    required this.toolName,
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson();
}

/// Represents a parsed mood entry (log_mood tool call).
class MoodLogToolCall extends ToolCall {
  /// Valid moods: happy, sad, anxious, tired, calm, irritated
  final String mood;

  /// Intensity on a scale from 1 (barely noticeable) to 5 (overwhelming)
  final int intensity;

  const MoodLogToolCall({
    required this.mood,
    required this.intensity,
    double confidence = 1.0,
  }) : super(toolName: 'log_mood', confidence: confidence);

  @override
  Map<String, dynamic> toJson() => {
        'tool': toolName,
        'mood': mood,
        'intensity': intensity,
        'confidence': confidence,
      };

  factory MoodLogToolCall.fromJson(Map<String, dynamic> json,
      [double confidence = 1.0]) {
    final intensityVal = json['intensity'];
    int parsedIntensity = 3;
    if (intensityVal is num) {
      parsedIntensity = intensityVal.toInt().clamp(1, 5);
    } else if (intensityVal is String) {
      parsedIntensity = (int.tryParse(intensityVal) ?? 3).clamp(1, 5);
    }

    return MoodLogToolCall(
      mood: json['mood']?.toString().toLowerCase().trim() ?? 'calm',
      intensity: parsedIntensity,
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : confidence,
    );
  }

  String get displayLabel {
    final emojiMap = {
      'happy': '😊 Happy',
      'sad': '😢 Sad',
      'anxious': '😰 Anxious',
      'tired': '😴 Tired',
      'calm': '😌 Calm',
      'irritated': '😤 Irritated',
    };
    return '${emojiMap[mood.toLowerCase()] ?? mood} ($intensity/5)';
  }

  @override
  String toString() =>
      'MoodLogToolCall(mood: $mood, intensity: $intensity, conf: $confidence)';
}

/// Represents a parsed hydration entry (log_water tool call).
class WaterLogToolCall extends ToolCall {
  /// Number of glasses of water
  final int glasses;

  /// Milliliters (standard conversion: 1 glass ≈ 250ml)
  int get ml => glasses * 250;

  const WaterLogToolCall({
    required this.glasses,
    double confidence = 1.0,
  }) : super(toolName: 'log_water', confidence: confidence);

  @override
  Map<String, dynamic> toJson() => {
        'tool': toolName,
        'glasses': glasses,
        'ml': ml,
        'confidence': confidence,
      };

  factory WaterLogToolCall.fromJson(Map<String, dynamic> json,
      [double confidence = 1.0]) {
    final glassesVal = json['glasses'];
    int parsedGlasses = 1;
    if (glassesVal is num) {
      parsedGlasses = glassesVal.toInt().clamp(1, 50);
    } else if (glassesVal is String) {
      parsedGlasses = (int.tryParse(glassesVal) ?? 1).clamp(1, 50);
    }

    return WaterLogToolCall(
      glasses: parsedGlasses,
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : confidence,
    );
  }

  String get displayLabel =>
      '💧 $glasses ${glasses == 1 ? 'glass' : 'glasses'} ($ml ml)';

  @override
  String toString() =>
      'WaterLogToolCall(glasses: $glasses, ml: $ml, conf: $confidence)';
}

/// Represents a parsed menstrual cycle symptom entry (log_cycle_symptom tool call).
class CycleSymptomToolCall extends ToolCall {
  /// Valid symptoms: cramps, headache, bloating, fatigue, nausea, backache, acne, mood swings
  final String symptom;

  /// Severity on a scale from 1 (mild) to 5 (severe)
  final int severity;

  const CycleSymptomToolCall({
    required this.symptom,
    required this.severity,
    double confidence = 1.0,
  }) : super(toolName: 'log_cycle_symptom', confidence: confidence);

  @override
  Map<String, dynamic> toJson() => {
        'tool': toolName,
        'symptom': symptom,
        'severity': severity,
        'confidence': confidence,
      };

  factory CycleSymptomToolCall.fromJson(Map<String, dynamic> json,
      [double confidence = 1.0]) {
    final severityVal = json['severity'];
    int parsedSeverity = 3;
    if (severityVal is num) {
      parsedSeverity = severityVal.toInt().clamp(1, 5);
    } else if (severityVal is String) {
      parsedSeverity = (int.tryParse(severityVal) ?? 3).clamp(1, 5);
    }

    return CycleSymptomToolCall(
      symptom: json['symptom']?.toString().toLowerCase().trim() ?? 'cramps',
      severity: parsedSeverity,
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : confidence,
    );
  }

  String get displayLabel =>
      '🩸 ${symptom[0].toUpperCase()}${symptom.substring(1)} ($severity/5)';

  @override
  String toString() =>
      'CycleSymptomToolCall(symptom: $symptom, severity: $severity, conf: $confidence)';
}

/// Complete aggregated result from parsing a user query.
@immutable
class ParsedQuickLogResult {
  final String rawQuery;
  final List<ToolCall> toolCalls;
  final bool isModelInference;

  const ParsedQuickLogResult({
    required this.rawQuery,
    required this.toolCalls,
    this.isModelInference = false,
  });

  bool get isEmpty => toolCalls.isEmpty;
  bool get isNotEmpty => toolCalls.isNotEmpty;

  /// Returns true if all detected tool calls have high confidence (>= 0.75).
  bool get hasHighConfidence =>
      toolCalls.isNotEmpty && toolCalls.every((t) => t.confidence >= 0.75);

  /// Human-friendly summary string of all extracted actions.
  String get summaryDescription {
    if (isEmpty) return 'No actions detected';
    return toolCalls.map((t) {
      if (t is MoodLogToolCall) return t.displayLabel;
      if (t is WaterLogToolCall) return t.displayLabel;
      if (t is CycleSymptomToolCall) return t.displayLabel;
      return t.toolName;
    }).join(' • ');
  }
}
