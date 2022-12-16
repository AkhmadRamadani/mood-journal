import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class RegisterController extends GetxController {
  static RegisterController get to => Get.find();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  // Firebase Auth register new user
  Future<void> register() async {
    isLoading.value = true;
    update();
    if (await validateForm()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (userCredential.user != null) {
          AlertHelper.showMsg(
            title: 'Hooray!!!',
            msg:
                'Your account has been created successfully. Enjoy your day with Moodie!',
            isError: false,
            isWarning: false,
            onTop: true,
          );
        } else {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'Something went wrong. Please try again later.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'The password provided is too weak.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
          log('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'The account already exists for that email.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
          log('The account already exists for that email.');
        }
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

  /// register with google
  Future<void> registerWithGoogle() async {
    isLoading.value = true;
    update();
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // / Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          AlertHelper.showMsg(
            title: 'Hooray!!!',
            msg:
                'Your account has been created successfully. Enjoy your day with Moodie!',
            isError: false,
            isWarning: false,
            onTop: true,
          );
        } else {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'Something went wrong. Please try again later.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
        }
      }
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

    isLoading.value = false;
    update();
  }

  Future<bool> validateForm() async {
    if (fullNameController.text.isEmpty) {
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: 'Please enter your full name.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
      isLoading.value = false;
      update();
      return false;
    } else if (emailController.text.isEmpty) {
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: 'Please enter your email address.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
      isLoading.value = false;
      update();
      return false;
    } else if (passwordController.text.isEmpty) {
      AlertHelper.showMsg(
        title: 'Oops!!!',
        msg: 'Please enter your password.',
        isError: true,
        isWarning: false,
        onTop: true,
      );
      isLoading.value = false;
      update();
      return false;
    } else {
      return true;
    }
  }
}
