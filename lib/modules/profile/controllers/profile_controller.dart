import 'dart:developer';
import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/modules/auth/repositories/auth_repository.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';
import 'package:moodie/utils/services/local_db_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to {
    if (!Get.isRegistered<ProfileController>()) {
      return Get.put(ProfileController());
    }
    return Get.find<ProfileController>();
  }

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

  Future<bool> deleteAccount(String password) async {
    try {
      final message = await AuthRepository().deleteAccount(password);

      await AuthService().clearSession();
      await LocalDbService().clearWater();
      await LocalDbService().clearCache();

      await AlertHelper.showMsg(
        title: 'Account Deleted',
        msg: message,
        isError: false,
        isWarning: false,
        onTop: true,
      );

      Get.offAllNamed(Routes.login);
      return true;
    } catch (e) {
      log(e.toString());
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: cleanMsg,
        isError: true,
        isWarning: false,
        onTop: true,
      );
      return false;
    }
  }
}
