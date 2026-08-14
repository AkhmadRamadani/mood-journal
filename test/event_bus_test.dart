import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/utils/services/event_bus.dart';

void main() {
  group('EventBus Tests', () {
    late EventBus testBus;

    setUp(() {
      testBus = EventBusImpl();
    });

    tearDown(() {
      testBus.dispose();
    });

    test('WaterIntakeUpdatedEvent is received by subscribed listeners',
        () async {
      WaterIntakeUpdatedEvent? receivedEvent;

      final sub = testBus.on<WaterIntakeUpdatedEvent>().listen((event) {
        receivedEvent = event;
      });

      testBus.fire(const WaterIntakeUpdatedEvent(
        drinkAmount: 500,
        targetAmount: 2000,
      ));

      await Future.delayed(Duration.zero);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent?.drinkAmount, 500);
      expect(receivedEvent?.targetAmount, 2000);

      await sub.cancel();
    });

    test(
        'MoodLoggedEvent is received independently without affecting other events',
        () async {
      int moodEventCount = 0;
      int waterEventCount = 0;

      final sub1 = testBus.on<MoodLoggedEvent>().listen((_) {
        moodEventCount++;
      });
      final sub2 = testBus.on<WaterIntakeUpdatedEvent>().listen((_) {
        waterEventCount++;
      });

      testBus.fire(const MoodLoggedEvent());
      await Future.delayed(Duration.zero);

      expect(moodEventCount, 1);
      expect(waterEventCount, 0);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('GamificationUpdatedEvent carries profile data', () async {
      GamificationUpdatedEvent? received;

      final sub = testBus.on<GamificationUpdatedEvent>().listen((event) {
        received = event;
      });

      testBus.fire(const GamificationUpdatedEvent({'level': 5, 'xp': 1200}));
      await Future.delayed(Duration.zero);

      expect(received, isNotNull);
      expect(received?.profileData, {'level': 5, 'xp': 1200});

      await sub.cancel();
    });
  });
}
