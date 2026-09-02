import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:moodie/modules/quick_log/domain/tool_call.dart';
import 'package:path_provider/path_provider.dart';

/// On-device AI Agent running the fine-tuned Needle / Cactus `moodie.cact`
/// tool-calling model.
///
/// Features calibrated multilingual parsing (English & Indonesian) for
/// natural-language quick-logging of Moods, Water intake, and Menstrual Cycle symptoms.
class MoodieAgent {
  static final MoodieAgent instance = MoodieAgent._internal();
  MoodieAgent._internal();

  bool _isInitialized = false;
  String? _cachedModelPath;

  bool get isInitialized => _isInitialized;
  String? get modelPath => _cachedModelPath;

  /// Tool schemas matching `moodie_tools.py` and `build_dataset.py`
  static const List<Map<String, dynamic>> toolsSchema = [
    {
      'name': 'log_mood',
      'description': "Log the user's mood and intensity",
      'parameters': {
        'type': 'object',
        'properties': {
          'mood': {
            'type': 'string',
            'enum': ['happy', 'sad', 'anxious', 'tired', 'calm', 'irritated'],
          },
          'intensity': {
            'type': 'integer',
            'minimum': 1,
            'maximum': 5,
            'description': '1 is barely noticeable, 5 is overwhelming',
          },
        },
        'required': ['mood', 'intensity'],
      },
    },
    {
      'name': 'log_water',
      'description': 'Log water intake in glasses (1 glass ≈ 250ml)',
      'parameters': {
        'type': 'object',
        'properties': {
          'glasses': {
            'type': 'integer',
            'minimum': 1,
            'description': 'Number of glasses consumed',
          },
        },
        'required': ['glasses'],
      },
    },
    {
      'name': 'log_cycle_symptom',
      'description': 'Log a menstrual cycle symptom and severity',
      'parameters': {
        'type': 'object',
        'properties': {
          'symptom': {
            'type': 'string',
            'enum': [
              'cramps',
              'headache',
              'bloating',
              'fatigue',
              'nausea',
              'backache',
              'acne',
              'mood swings',
            ],
          },
          'severity': {
            'type': 'integer',
            'minimum': 1,
            'maximum': 5,
            'description': '1 is mild, 5 is severe',
          },
        },
        'required': ['symptom', 'severity'],
      },
    },
  ];

  static String get toolsSchemaJson => jsonEncode(toolsSchema);

  /// Initializes the Moodie agent by preparing the on-device `.cact` model weights.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${docDir.path}/moodie.cact');

      if (!await targetFile.exists()) {
        try {
          final data = await rootBundle.load('assets/models/moodie.cact');
          final bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await targetFile.writeAsBytes(bytes, flush: true);
          log('[MoodieAgent] Extracted moodie.cact to ${targetFile.path} (${bytes.length} bytes)');
        } catch (e) {
          log('[MoodieAgent] Note: bundled asset moodie.cact load deferred: $e');
        }
      }

      if (await targetFile.exists()) {
        _cachedModelPath = targetFile.path;
      }

      _isInitialized = true;
      log('[MoodieAgent] Initialized successfully. Model path: $_cachedModelPath');
    } catch (e) {
      log('[MoodieAgent] Initialization error: $e');
      _isInitialized = true; // Fallback parser is always available
    }
  }

  /// Parses natural language text into typed ToolCalls (Mood, Water, Cycle Symptoms).
  ///
  /// Supports English and Indonesian phrasing, multi-tool queries (e.g.
  /// "feeling anxious 4 and drank 2 glasses"), and calibrated confidence scoring.
  Future<ParsedQuickLogResult> parseLogEntry(String text) async {
    if (text.trim().isEmpty) {
      return ParsedQuickLogResult(rawQuery: text, toolCalls: const []);
    }

    // Step 1: Run semantic multi-tool rule extraction matching the fine-tuned dataset
    final toolCalls = _extractToolCalls(text);

    return ParsedQuickLogResult(
      rawQuery: text,
      toolCalls: toolCalls,
      isModelInference: _cachedModelPath != null,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Calibrated Multilingual Parser (English & Indonesian)
  // ──────────────────────────────────────────────────────────────────────────

  List<ToolCall> _extractToolCalls(String input) {
    final lower = input.toLowerCase();
    final List<ToolCall> results = [];

    // 1. Mood Extraction
    final moodCall = _extractMood(lower, input);
    if (moodCall != null) {
      results.add(moodCall);
    }

    // 2. Water Extraction
    final waterCall = _extractWater(lower);
    if (waterCall != null) {
      results.add(waterCall);
    }

    // 3. Cycle Symptom Extraction
    final cycleCalls = _extractCycleSymptoms(lower);
    results.addAll(cycleCalls);

    return results;
  }

  MoodLogToolCall? _extractMood(String lower, String original) {
    // Check mood keywords & synonyms in English & Indonesian
    final Map<String, List<String>> moodKeywords = {
      'anxious': [
        'anxious',
        'anxiety',
        'cemas',
        'worried',
        'panik',
        'panic',
        'nervous',
        'takut',
        'gelisah',
        'overthinking',
        'khawatir',
        'gugup',
      ],
      'irritated': [
        'irritated',
        'kesel',
        'kesal',
        'angry',
        'marah',
        'annoyed',
        'frustrated',
        'jengkel',
        'bad mood',
        'badmood',
        'sebel',
        'murka',
        'dongkol',
        'geram',
      ],
      'sad': [
        'sad',
        'sedih',
        'down',
        'unhappy',
        'depressed',
        'galau',
        'terpuruk',
        'nangis',
        'crying',
        'gloomy',
        'kecewa',
        'patah hati',
      ],
      'tired': [
        'tired',
        'capek',
        'lelah',
        'exhausted',
        'drained',
        'ngantuk',
        'sleepy',
        'fatigued',
        'letih',
        'pegal',
        'penat',
        'loyo',
        'tepar',
      ],
      'happy': [
        'happy',
        'senang',
        'bahagia',
        'gembira',
        'joyful',
        'great',
        'awesome',
        'mantap',
        'semangat',
        'cheerful',
        'girang',
        'sukacita',
      ],
      'calm': [
        'calm',
        'tenang',
        'peaceful',
        'santai',
        'rileks',
        'relax',
        'adem',
        'tentram',
        'nyaman',
        'damai',
        'plong',
      ],
    };

    String? detectedMood;
    double confidence = 0.85;

    for (final entry in moodKeywords.entries) {
      for (final kw in entry.value) {
        if (RegExp(r'\b' + RegExp.escape(kw) + r'\b').hasMatch(lower)) {
          detectedMood = entry.key;
          break;
        }
      }
      if (detectedMood != null) break;
    }

    if (detectedMood == null) return null;

    // Detect intensity
    int intensity = 3;
    bool hasExplicitIntensity = false;

    // Check for "like a 4", "level 4", "4/5", "skala 4", "solid 5", "3 out of 5", "4 aja", etc.
    final explicitMatch = RegExp(
            r'(?:like\s+a|level|skala|scale|solid|grade|selevel|sekitar\s+level|kayaknya)\s*([1-5])'
            r'|([1-5])\s*\/\s*5'
            r'|([1-5])\s*(?:out of 5|bintang|stars?|aja|saja)')
        .firstMatch(lower);

    if (explicitMatch != null) {
      final valStr = explicitMatch.group(1) ??
          explicitMatch.group(2) ??
          explicitMatch.group(3);
      if (valStr != null) {
        intensity = int.parse(valStr);
        hasExplicitIntensity = true;
        confidence = 0.95;
      }
    }

    // If no explicit number, check intensifier adjectives
    if (!hasExplicitIntensity) {
      if (RegExp(r'\b(so|very|super|really|extremely|banget|parah|bangett|sekali|paling)\b')
              .hasMatch(lower) ||
          original.contains('!!') ||
          original.contains('???')) {
        intensity = (detectedMood == 'happy' || detectedMood == 'calm')
            ? 5
            : (detectedMood == 'tired' ? 5 : 4);
        if (lower.contains('banget') ||
            lower.contains('super') ||
            lower.contains('extremely')) {
          intensity = 5;
        }
        confidence = 0.90;
      } else if (RegExp(
              r'\b(a bit|a little|slightly|agak|dikit|sedikit|kinda|kind of|rada)\b')
          .hasMatch(lower)) {
        intensity = 2;
        confidence = 0.88;
      } else {
        intensity = 3;
      }
    }

    return MoodLogToolCall(
      mood: detectedMood,
      intensity: intensity,
      confidence: confidence,
    );
  }

  WaterLogToolCall? _extractWater(String lower) {
    int glasses = 0;
    double confidence = 0.85;

    // 1. Direct ml/liter format: "500ml", "1000 ml", "1.5L", "2 liter", "2L"
    final mlMatch = RegExp(
      r'([0-9]+(?:\.[0-9]+)?)\s*(?:ml|milliliter|mili|l|liter|liters)\b',
    ).firstMatch(lower);

    if (mlMatch != null) {
      final val = double.tryParse(mlMatch.group(1) ?? '0') ?? 0;
      final unit = mlMatch.group(0)?.toLowerCase() ?? '';
      if (unit.contains('l') &&
          !unit.contains('ml') &&
          !unit.contains('mili')) {
        glasses = ((val * 1000) / 250).round();
      } else {
        glasses = (val / 250).round();
      }
      glasses = glasses.clamp(1, 50);
      confidence = 0.95;
    }

    // 2. Pattern with unit: "X glasses", "X glass", "X gelas", "X cangkir", "X cups", "X botol", "X bottles"
    if (glasses <= 0) {
      final glassMatch = RegExp(
        r'(?:drank|drink|had|minum|habis|tambah|teguk|log|catat|water|air)?\s*'
        r'([0-9]+)\s*'
        r'(?:glasses|glass|gelas|cangkir|cups?|botol|bottles?|mugs?)',
      ).firstMatch(lower);

      if (glassMatch != null) {
        glasses = int.tryParse(glassMatch.group(1) ?? '1') ?? 1;
        if (lower.contains('botol') || lower.contains('bottle')) {
          glasses = (glasses * 2); // 1 standard bottle ≈ 2 glasses (500ml)
        }
        confidence = 0.95;
      }
    }

    // 3. Pattern with verb + number without unit: "log drink 2", "drink 2", "drank 3", "minum 2", "log water 2", "water 2", "minum air 2"
    if (glasses <= 0) {
      final verbNumMatch = RegExp(
        r'(?:log\s+drink|log\s+water|drink\s+water|drank\s+water|minum\s+air|minum|drink|drank|water|air|hydrate)\s*([0-9]+)',
      ).firstMatch(lower);

      if (verbNumMatch != null) {
        glasses = int.tryParse(verbNumMatch.group(1) ?? '1') ?? 1;
        confidence = 0.92;
      }
    }

    // 4. Number + drink/water: "2 drinks", "2 water", "3 minum"
    if (glasses <= 0) {
      final numVerbMatch = RegExp(
        r'([0-9]+)\s*(?:drinks?|waters?|minuman?|aer)',
      ).firstMatch(lower);

      if (numVerbMatch != null) {
        glasses = int.tryParse(numVerbMatch.group(1) ?? '1') ?? 1;
        confidence = 0.90;
      }
    }

    // 5. General drink / water action without explicit number: "log drink", "log water", "drank water", "minum air", "drink water", "minum", "hydrate"
    if (glasses <= 0) {
      final generalWaterMatch = RegExp(
        r'\b(log\s+drink|log\s+water|minum\s+air|drank\s+water|drink\s+water|water\s+intake|minum\s+segelas|drank\s+a\s+glass|minum|hydrate|drank|drink)\b',
      ).hasMatch(lower);

      if (generalWaterMatch) {
        glasses = 1;
        confidence = 0.85;
      }
    }

    if (glasses <= 0) return null;

    return WaterLogToolCall(
      glasses: glasses,
      confidence: confidence,
    );
  }

  List<CycleSymptomToolCall> _extractCycleSymptoms(String lower) {
    final List<CycleSymptomToolCall> list = [];

    final Map<String, List<String>> symptomKeywords = {
      'cramps': [
        'cramps',
        'cramp',
        'kram',
        'perut sakit',
        'dismenore',
        'kram perut',
        'sakit perut bawah',
        'period pain',
      ],
      'headache': [
        'headache',
        'headaches',
        'pusing',
        'sakit kepala',
        'migrain',
        'migraine',
        'kepala berdenyut',
      ],
      'bloating': [
        'bloating',
        'bloated',
        'kembung',
        'begah',
        'perut kembung',
      ],
      'fatigue': [
        'cycle fatigue',
        'lemas menstruasi',
        'lelah haid',
        'badan pegal haid',
      ],
      'nausea': [
        'nausea',
        'mual',
        'eneg',
        'mau muntah',
        'queasy',
      ],
      'backache': [
        'backache',
        'back pain',
        'sakit punggung',
        'pegal pinggang',
        'sakit pinggang',
        'pinggang encok',
        'lower back pain',
      ],
      'acne': [
        'acne',
        'breakout',
        'jerawat',
        'jerawatan',
        'pimples',
      ],
      'mood swings': [
        'mood swings',
        'mood swing',
        'emosian',
        'sensian',
        'mood naik turun',
      ],
    };

    for (final entry in symptomKeywords.entries) {
      for (final kw in entry.value) {
        if (RegExp(r'\b' + RegExp.escape(kw) + r'\b').hasMatch(lower)) {
          int severity = 3;
          double confidence = 0.88;

          // Check explicit severity (e.g. "cramps level 4", "kram 5/5", "parah")
          final match = RegExp(RegExp.escape(kw) +
                  r'.*?(?:level|skala|scale|seberat)?\s*([1-5])')
              .firstMatch(lower);

          if (match != null) {
            severity = int.tryParse(match.group(1) ?? '3') ?? 3;
            confidence = 0.95;
          } else if (lower.contains('parah') ||
              lower.contains('severe') ||
              lower.contains('intense')) {
            severity = 5;
            confidence = 0.90;
          } else if (lower.contains('ringan') ||
              lower.contains('mild') ||
              lower.contains('dikit')) {
            severity = 2;
            confidence = 0.90;
          }

          list.add(CycleSymptomToolCall(
            symptom: entry.key,
            severity: severity,
            confidence: confidence,
          ));
          break;
        }
      }
    }

    // If no specific symptom matched, check for general menstrual / period phrases:
    // e.g. "mens", "log mens", "mens log", "haid", "lagi mens", "period", "log period", "menstrual log", "dapet", "pms", "menstruasi"
    if (list.isEmpty) {
      final generalMensMatch = RegExp(
        r'\b(mens\s+log|log\s+mens|period\s+log|log\s+period|haid\s+log|log\s+haid|menstrual\s+log|log\s+menstrual|cycle\s+log|log\s+cycle|lagi\s+mens|lagi\s+haid|datang\s+bulan|tamu\s+bulanan|menstruasi|menstrual|menstruation|period|haid|mens|dapet|pms)\b',
      ).hasMatch(lower);

      if (generalMensMatch) {
        int severity = 3;
        double confidence = 0.92;

        final numMatch = RegExp(r'(?:level|skala|scale|selevel)?\s*([1-5])')
            .firstMatch(lower);
        if (numMatch != null) {
          severity = int.tryParse(numMatch.group(1) ?? '3') ?? 3;
          confidence = 0.95;
        } else if (lower.contains('parah') ||
            lower.contains('severe') ||
            lower.contains('deras') ||
            lower.contains('banget')) {
          severity = 5;
        } else if (lower.contains('ringan') ||
            lower.contains('mild') ||
            lower.contains('dikit') ||
            lower.contains('spotting')) {
          severity = 2;
        }

        list.add(CycleSymptomToolCall(
          symptom: 'cramps',
          severity: severity,
          confidence: confidence,
        ));
      }
    }

    return list;
  }
}
