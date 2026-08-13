import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';
import 'package:moodie/utils/services/local_db_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  UserModel? get user => AuthService().getUser();

  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (_) {}
    await AuthService().clearSession();
    await LocalDbService().clearWater();
    await LocalDbService().clearCache();

    Get.offAllNamed(Routes.onBoarding);
  }
}
