import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/profile/controllers/change_password_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChangePasswordController Validation Tests', () {
    late ChangePasswordController controller;

    setUp(() {
      Get.reset();
      controller = ChangePasswordController();
    });

    test('validateForm returns false when current password is empty', () async {
      controller.currentPasswordController.text = '';
      controller.newPasswordController.text = 'newpassword123';
      controller.confirmPasswordController.text = 'newpassword123';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test('validateForm returns false when new password is empty', () async {
      controller.currentPasswordController.text = 'oldpassword123';
      controller.newPasswordController.text = '';
      controller.confirmPasswordController.text = '';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test(
        'validateForm returns false when new password is too short (< 8 chars)',
        () async {
      controller.currentPasswordController.text = 'oldpassword123';
      controller.newPasswordController.text = 'short';
      controller.confirmPasswordController.text = 'short';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test('validateForm returns false when passwords do not match', () async {
      controller.currentPasswordController.text = 'oldpassword123';
      controller.newPasswordController.text = 'newpassword123';
      controller.confirmPasswordController.text = 'mismatch123';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isFalse);
    });

    test('validateForm returns true when all inputs are valid', () async {
      controller.currentPasswordController.text = 'oldpassword123';
      controller.newPasswordController.text = 'newpassword123';
      controller.confirmPasswordController.text = 'newpassword123';
      final isValid = await controller.validateForm(showDialog: false);
      expect(isValid, isTrue);
    });
  });
}
