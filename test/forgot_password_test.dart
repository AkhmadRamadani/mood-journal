import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/auth/controllers/forgot_password_controller.dart';
import 'package:moodie/modules/auth/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForgotPasswordController Validation Tests', () {
    late ForgotPasswordController controller;

    setUp(() {
      Get.reset();
      controller = ForgotPasswordController();
    });

    test('validateForm returns false when email is empty', () async {
      controller.emailController.text = '';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test('validateForm returns false when email is invalid format', () async {
      controller.emailController.text = 'invalid-email-format';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test('validateForm returns true when email is valid format', () async {
      controller.emailController.text = 'user@example.com';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isTrue);
    });
  });

  group('AuthRepository Instantiation Test', () {
    test('AuthRepository is a singleton instance', () {
      final repo1 = AuthRepository();
      final repo2 = AuthRepository();
      expect(repo1, same(repo2));
    });
  });
}
