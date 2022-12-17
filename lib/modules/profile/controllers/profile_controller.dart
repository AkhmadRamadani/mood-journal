import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodie/constants/routes.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  User? user = FirebaseAuth.instance.currentUser;
  GoogleSignInAccount? googleUser;
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Get.offAllNamed(Routes.login);
  }
}
