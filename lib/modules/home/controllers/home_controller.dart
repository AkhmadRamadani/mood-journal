import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/dashboard/views/dashboard_view.dart';
import 'package:moodie/modules/notification/views/notification_view.dart';
import 'package:moodie/modules/profile/views/profile_view.dart';
import 'package:moodie/modules/record/views/record_view.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';

class HomeController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  final pages = [
    const DashboardView(),
    const RecordView(),
    const NotificationView(),
    const ProfileView(),
    Container(color: Colors.green),
    Container(
        color: Colors.blue,
        child: Center(
          child: CustomTextButton(
            title: 'Logout',
            onPressed: () async {
              /// logout from firebase
              /// clear all named routes
              /// navigate to login page
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
          ),
        )),
  ];

  void setPageIndex(int index) {
    currentPageIndex.value = index;
    update();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
