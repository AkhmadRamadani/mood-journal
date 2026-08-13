import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> login() async {
    isLoading.value = true;
    update();
    if (await validateForm()) {
      try {
        final response = await ApiService().login(
          email: emailController.text.trim(),
          password: passwordController.text,
          deviceName: 'Flutter Mobile App',
        );

        if (response.statusCode == 200 && response.data != null) {
          final token = response.data['token'];
          final userJson = response.data['user'];
          if (token != null && userJson != null) {
            final user =
                UserModel.fromJson(Map<String, dynamic>.from(userJson));
            await AuthService().saveToken(token.toString());
            await AuthService().saveUser(user);

            Get.offAllNamed(Routes.home);
          } else {
            AlertHelper.showMsg(
              title: 'Oops!!!',
              msg: 'Invalid response from server.',
              isError: true,
              isWarning: false,
              onTop: true,
            );
          }
        }
      } on DioException catch (e) {
        String errorMsg = 'Something went wrong. Please try again later.';
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMsg = e.response?.data['message'];
        }
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: errorMsg,
          isError: true,
          isWarning: false,
          onTop: true,
        );
        log(e.toString());
      } catch (e) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Something went wrong. Please try again later.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
        log(e.toString());
      }
    }
    isLoading.value = false;
    update();
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    update();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled Google sign in
        isLoading.value = false;
        update();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      final String email = firebaseUser?.email ?? googleUser.email;
      final String name =
          firebaseUser?.displayName ?? googleUser.displayName ?? 'Google User';
      final String? avatarUrl = firebaseUser?.photoURL ?? googleUser.photoUrl;
      final String googleId = googleUser.id;

      try {
        final response = await ApiService().googleLogin(
          email: email,
          name: name,
          googleId: googleId,
          avatarUrl: avatarUrl,
        );

        if ((response.statusCode == 200 || response.statusCode == 201) &&
            response.data != null) {
          final token = response.data['token'];
          final userJson = response.data['user'];
          if (token != null && userJson != null) {
            final user =
                UserModel.fromJson(Map<String, dynamic>.from(userJson));
            await AuthService().saveToken(token.toString());
            await AuthService().saveUser(user);
            Get.offAllNamed(Routes.home);
            isLoading.value = false;
            update();
            return;
          }
        }
      } catch (apiErr) {
        log('Backend googleLogin failed, falling back to local session: $apiErr');
      }

      final fallbackUser = UserModel(
        id: googleId.hashCode.abs(),
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
      await AuthService().saveToken('google_token_$googleId');
      await AuthService().saveUser(fallbackUser);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      log('Google Login Error: $e');
      AlertHelper.showMsg(
        title: 'Google Sign-In Failed',
        msg: 'Failed to sign in with Google. Please try again.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
    }

    isLoading.value = false;
    update();
  }

  Future<bool> validateForm() async {
    if (emailController.text.isEmpty) {
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: 'Please enter your email.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
      return false;
    }
    if (passwordController.text.isEmpty) {
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: 'Please enter your password.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
      return false;
    }
    return true;
  }
}
