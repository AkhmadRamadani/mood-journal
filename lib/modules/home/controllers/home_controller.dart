import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/dashboard/views/dashboard_view.dart';

class HomeController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  final pages = [
    const DashboardView(),
    Container(color: Colors.red),
    Container(color: Colors.green),
    Container(color: Colors.blue),
  ];

  void setPageIndex(int index) {
    currentPageIndex.value = index;
    update();
  }
}
