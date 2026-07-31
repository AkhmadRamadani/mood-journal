import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // Stub or implementation for Google Login if needed
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
