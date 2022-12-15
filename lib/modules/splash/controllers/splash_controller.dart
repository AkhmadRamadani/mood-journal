import 'package:firebase_auth/firebase_auth.dart';
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
    if (await checkIsLoggedIn()) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onBoarding);
    }
  }

  Future<bool> checkIsLoggedIn() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return false;
    } else {
      return true;
    }
  }
}
