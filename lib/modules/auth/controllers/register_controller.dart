import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/user_model.dart';
import 'package:moodie/modules/auth/controllers/login_controller.dart';
import 'package:moodie/shared/widgets/alerts/custom_alert.dart';
import 'package:moodie/utils/services/api_service.dart';
import 'package:moodie/utils/services/auth_service.dart';

class RegisterController extends GetxController {
  static RegisterController get to => Get.find();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> register() async {
    isLoading.value = true;
    update();
    if (await validateForm()) {
      try {
        final response = await ApiService().register(
          name: fullNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          passwordConfirmation: passwordController.text,
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
          }
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

  Future<void> registerWithGoogle() async {
    final loginCtrl = Get.isRegistered<LoginController>()
        ? LoginController.to
        : Get.put(LoginController());
    await loginCtrl.loginWithGoogle();
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
