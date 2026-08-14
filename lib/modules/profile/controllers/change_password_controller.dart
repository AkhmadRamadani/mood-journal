import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/auth/repositories/auth_repository.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get to => Get.find();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> submitChangePassword() async {
    isLoading.value = true;
    update();

    if (await validateForm()) {
      try {
        final message = await AuthRepository().changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
        );

        await AlertHelper.showMsg(
          title: 'Success',
          msg: message,
          isError: false,
          isWarning: false,
          onTop: true,
          onWillPop: () async {
            Get.back();
            return true;
          },
        );

        Get.back();
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
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Please enter your current password.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    if (newPassword.isEmpty) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Please enter a new password.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    if (newPassword.length < 8) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'New password must be at least 8 characters long.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    if (confirmPassword.isEmpty) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Please confirm your new password.',
          isError: true,
          isWarning: false,
          onTop: true,
        );
      }
      return false;
    }

    if (newPassword != confirmPassword) {
      if (showDialog) {
        AlertHelper.showMsg(
          title: 'Oops!!!',
          msg: 'Passwords do not match.',
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
