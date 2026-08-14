import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/profile/controllers/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileController Deletion Tests', () {
    late ProfileController controller;

    setUp(() {
      Get.reset();
      controller = ProfileController();
    });

    test('ProfileController instantiation and user getter', () {
      expect(controller, isNotNull);
    });
  });
}
