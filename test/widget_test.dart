import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/auth/controllers/forgot_password_controller.dart';
import 'package:moodie/modules/auth/views/forgot_password_view.dart';

void main() {
  testWidgets('ForgotPasswordView renders title and email field',
      (WidgetTester tester) async {
    Get.put(ForgotPasswordController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: ForgotPasswordView(),
      ),
    );

    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
  });
}
