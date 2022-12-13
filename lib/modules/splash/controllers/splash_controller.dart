import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';

class SplashController extends GetxController {
  static SplashController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    goToLogin();
  }

  Future<void> goToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(Routes.onBoarding);
  }
}
