import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/auth/repositories/auth_repository.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class ForgotPasswordController extends GetxController {
  static ForgotPasswordController get to {
    if (!Get.isRegistered<ForgotPasswordController>()) {
      return Get.put(ForgotPasswordController());
    }
    return Get.find<ForgotPasswordController>();
  }

  TextEditingController emailController = TextEditingController();
  RxBool isLoading = false.obs;

  Future<void> sendForgotPasswordLink() async {
    isLoading.value = true;
    update();

    if (await validateForm()) {
      try {
        final email = emailController.text.trim();
        await AuthRepository().sendForgotPasswordLink(email);

        await AlertHelper.showMsg(
          title: 'Reset Link Sent!',
          msg:
              'Reset Link Sent! Check your email inbox to reset your password, then return here to log in.',
          isError: false,
          isWarning: false,
          onTop: true,
          onWillPop: () async {
            Get.offAllNamed(Routes.login);
            return true;
          },
        );

        Get.offAllNamed(Routes.login);
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
      }
    }

    isLoading.value = false;
    update();
  }

  Future<bool> validateForm({bool showDialog = true}) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Please enter your email address.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Please enter a valid email address.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    return true;
  }
}
