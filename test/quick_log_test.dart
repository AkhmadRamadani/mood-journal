import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/modules/quick_log/data/moodie_agent.dart';
import 'package:moodie/modules/quick_log/domain/tool_call.dart';

void main() {
  group('Quick Log - Mood Parsing', () {
    final agent = MoodieAgent.instance;

    test('Parses English mood with explicit intensity', () async {
      final res =
          await agent.parseLogEntry('feeling pretty anxious today, like a 4');
      expect(res.isNotEmpty, isTrue);
      expect(res.toolCalls.length, 1);
      final call = res.toolCalls.first as MoodLogToolCall;
      expect(call.mood, 'anxious');
      expect(call.intensity, 4);
      expect(call.confidence, greaterThanOrEqualTo(0.85));
    });

    test('Parses Indonesian mood with explicit intensity', () async {
      final res =
          await agent.parseLogEntry('hari ini agak cemas, sekitar level 3');
      expect(res.isNotEmpty, isTrue);
      expect(res.toolCalls.length, 1);
      final call = res.toolCalls.first as MoodLogToolCall;
      expect(call.mood, 'anxious');
      expect(call.intensity, 3);
    });

    test('Parses happy with exclamation / intensifier', () async {
      final res = await agent.parseLogEntry("i'm so happy right now!!");
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as MoodLogToolCall;
      expect(call.mood, 'happy');
      expect(call.intensity, 5);
    });

    test('Parses Indonesian cape / tired with modifier', () async {
      final res = await agent.parseLogEntry('capek banget hari ini');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as MoodLogToolCall;
      expect(call.mood, 'tired');
      expect(call.intensity, 5);
    });

    test('Parses irritated / kesel', () async {
      final res = await agent
          .parseLogEntry('really irritated with everything today, a solid 5');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as MoodLogToolCall;
      expect(call.mood, 'irritated');
      expect(call.intensity, 5);
    });
  });

  group('Quick Log - Water Intake Parsing', () {
    final agent = MoodieAgent.instance;

    test('Parses glasses of water in English', () async {
      final res = await agent.parseLogEntry('just had 3 glasses of water');
      expect(res.isNotEmpty, isTrue);
      expect(res.toolCalls.length, 1);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 3);
      expect(call.ml, 750);
    });

    test('Parses Indonesian gelas air', () async {
      final res = await agent.parseLogEntry('minum 2 gelas air');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 2);
      expect(call.ml, 500);
    });

    test('Parses bottle / botol (500ml ≈ 2 glasses)', () async {
      final res = await agent.parseLogEntry('habis 1 botol air');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 2);
      expect(call.ml, 500);
    });

    test('Parses direct ml format (1000ml)', () async {
      final res = await agent.parseLogEntry('drank 1000ml');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 4);
      expect(call.ml, 1000);
    });

    test('Parses "log drink" defaults to 1 glass', () async {
      final res = await agent.parseLogEntry('log drink');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 1);
      expect(call.ml, 250);
    });

    test('Parses "log drink 2"', () async {
      final res = await agent.parseLogEntry('log drink 2');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 2);
      expect(call.ml, 500);
    });

    test('Parses "minum 3"', () async {
      final res = await agent.parseLogEntry('minum 3');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as WaterLogToolCall;
      expect(call.glasses, 3);
      expect(call.ml, 750);
    });
  });

  group('Quick Log - Cycle Symptom Parsing', () {
    final agent = MoodieAgent.instance;

    test('Parses cramps with explicit severity', () async {
      final res = await agent.parseLogEntry('bad cramps level 4');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'cramps');
      expect(call.severity, 4);
    });

    test('Parses headache / pusing', () async {
      final res = await agent.parseLogEntry('sakit kepala parah banget');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'headache');
      expect(call.severity, 5);
    });

    test('Parses bloating / kembung', () async {
      final res = await agent.parseLogEntry('feeling bloated today');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'bloating');
      expect(call.severity, 3);
    });

    test('Parses general "log mens"', () async {
      final res = await agent.parseLogEntry('log mens');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'cramps');
      expect(call.severity, 3);
    });

    test('Parses general "lagi haid parah"', () async {
      final res = await agent.parseLogEntry('lagi haid parah');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'cramps');
      expect(call.severity, 5);
    });

    test('Parses general "period 4"', () async {
      final res = await agent.parseLogEntry('period 4');
      expect(res.isNotEmpty, isTrue);
      final call = res.toolCalls.first as CycleSymptomToolCall;
      expect(call.symptom, 'cramps');
      expect(call.severity, 4);
    });
  });

  group('Quick Log - Multi-Tool Parsing', () {
    final agent = MoodieAgent.instance;

    test('Parses combined mood and water in single utterance', () async {
      final res = await agent.parseLogEntry(
          'feeling anxious today, like a 4, and drank 2 glasses');
      expect(res.toolCalls.length, 2);

      final mood = res.toolCalls.whereType<MoodLogToolCall>().first;
      final water = res.toolCalls.whereType<WaterLogToolCall>().first;

      expect(mood.mood, 'anxious');
      expect(mood.intensity, 4);
      expect(water.glasses, 2);
      expect(res.hasHighConfidence, isTrue);
    });

    test('Parses combined Indonesian mood and water', () async {
      final res = await agent.parseLogEntry('capek banget 4 dan minum 3 gelas');
      expect(res.toolCalls.length, 2);

      final mood = res.toolCalls.whereType<MoodLogToolCall>().first;
      final water = res.toolCalls.whereType<WaterLogToolCall>().first;

      expect(mood.mood, 'tired');
      expect(mood.intensity, 4);
      expect(water.glasses, 3);
    });

    test('Handles non-actionable text gracefully', () async {
      final res =
          await agent.parseLogEntry('the weather outside is cloudy and breezy');
      expect(res.isEmpty, isTrue);
      expect(res.summaryDescription, 'No actions detected');
    });
  });

  group('Domain ToolCall JSON Serialization', () {
    test('MoodLogToolCall toJson & fromJson', () {
      const call =
          MoodLogToolCall(mood: 'anxious', intensity: 4, confidence: 0.9);
      final json = call.toJson();
      expect(json['tool'], 'log_mood');
      expect(json['mood'], 'anxious');
      expect(json['intensity'], 4);

      final restored = MoodLogToolCall.fromJson(json, 0.9);
      expect(restored.mood, 'anxious');
      expect(restored.intensity, 4);
    });

    test('WaterLogToolCall toJson & fromJson', () {
      const call = WaterLogToolCall(glasses: 3, confidence: 0.95);
      final json = call.toJson();
      expect(json['tool'], 'log_water');
      expect(json['glasses'], 3);
      expect(json['ml'], 750);

      final restored = WaterLogToolCall.fromJson(json, 0.95);
      expect(restored.glasses, 3);
      expect(restored.ml, 750);
    });
  });
}
