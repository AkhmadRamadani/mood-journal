import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/utils/services/auth_service.dart';

class SplashController extends GetxController {
  static SplashController get to {
    if (!Get.isRegistered<SplashController>()) {
      return Get.put(SplashController());
    }
    return Get.find<SplashController>();
  }

  @override
  void onInit() {
    super.onInit();
    goToLogin();
  }

  Future<void> goToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final loggedIn = AuthService().isLoggedIn;
    if (loggedIn) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onBoarding);
    }
  }

  Future<bool> checkIsLoggedIn() async {
    return AuthService().isLoggedIn;
  }
}
