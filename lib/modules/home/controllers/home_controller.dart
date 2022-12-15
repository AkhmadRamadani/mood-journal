import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/dashboard/views/dashboard_view.dart';
import 'package:moodie/modules/notification/views/notification_view.dart';
import 'package:moodie/modules/profile/views/profile_view.dart';
import 'package:moodie/modules/record/views/record_view.dart';

class HomeController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  final pages = [
    const DashboardView(),
    const RecordView(),
    const NotificationView(),
    const ProfileView(),
  ];

  void setPageIndex(int index) {
    currentPageIndex.value = index;
    update();
  }
}
