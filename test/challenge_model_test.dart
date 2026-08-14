import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/models/challenge_model.dart';

void main() {
  group('ChallengeModel Parsing & Fallback Tests', () {
    test('Calculates fallback progressPercentage when progress_percentage is 0',
        () {
      final json = {
        'id': 1,
        'title': 'Stay Hydrated',
        'slug': 'stay-hydrated',
        'description': 'Drink 2,000ml of water today',
        'target_count': 1,
        'progress': 1,
        'progress_percentage': 0,
        'is_completed': false,
        'xp_reward': 50,
      };

      final challenge = ChallengeModel.fromJson(json);

      expect(challenge.progress, 1);
      expect(challenge.targetCount, 1);
      expect(challenge.progressPercentage, 1.0);
      expect(challenge.isCompleted, isTrue);
    });

    test('Normalizes progress_percentage when backend returns 0-100 scale', () {
      final json = {
        'id': 2,
        'title': 'Stay Hydrated',
        'slug': 'stay-hydrated',
        'description': 'Drink water daily',
        'target_count': 5,
        'progress': 3,
        'progress_percentage': 60,
        'is_completed': false,
        'xp_reward': 50,
      };

      final challenge = ChallengeModel.fromJson(json);

      expect(challenge.progressPercentage, 0.6);
    });
  });
}
