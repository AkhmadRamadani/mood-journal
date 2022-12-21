import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:moodie/constants/routes.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  User? user = FirebaseAuth.instance.currentUser;
  GoogleSignInAccount? googleUser;
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await Hive.box('water').clear();
    Get.offAllNamed(Routes.login);
  }
}
