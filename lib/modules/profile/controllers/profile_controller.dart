import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  UserModel? get user => AuthService().getUser();

  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (_) {}
    await AuthService().clearSession();
    await Hive.box('water').clear();

    Get.offAllNamed(Routes.onBoarding);
  }
}
