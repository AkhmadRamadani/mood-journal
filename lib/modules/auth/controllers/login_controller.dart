import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Firebase Auth login user
  Future<void> login() async {
    isLoading.value = true;
    update();
    if (await validateForm()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (userCredential.user != null) {
          Get.offAllNamed(Routes.home);
          messaging.getToken().then((value) {
            users.doc(userCredential.user!.uid).set({
              'fcmToken': value,
              'lastLogin': DateTime.now().toString(),
            });
          });
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
        if (e.code == 'user-not-found') {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'No user found for that email.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
          log('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          AlertHelper.showMsg(
            title: 'Oops!!!',
            msg: 'Wrong password provided for that user.',
            isError: true,
            isWarning: false,
            onTop: true,
          );
          log('Wrong password provided for that user.');
        }
      }
    }
    isLoading.value = false;
    update();
  }

  /// login using firebase google sign in
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    update();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await messaging.getToken().then((value) {
          users.doc(userCredential.user!.uid).set({
            'fcmToken': value,
            'lastLogin': DateTime.now().toString(),
          });
        });
        // subscribe to topic
        await messaging.subscribeToTopic('drinkReminder');
        await messaging.subscribeToTopic('fillJournal');

        Get.offAllNamed(Routes.home);
      } else {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Something went wrong. Please try again later.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
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
