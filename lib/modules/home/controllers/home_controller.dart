import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/notification_model.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/dashboard/views/dashboard_view.dart';
import 'package:moodie/modules/notification/views/notification_view.dart';
import 'package:moodie/modules/profile/views/profile_view.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/views/record_view.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';
import 'package:moodie/utils/services/notifcation_service.dart';

class HomeController extends GetxController {
  List<NotifcationModel> timeToDrinkWater = [
    NotifcationModel(
        id: 1,
        title: "Good Morning! Have a Nice Day",
        time: "08:00",
        body: "Start your day with a glass of water",
        path: Routes.hydrate),
    NotifcationModel(
        id: 2,
        title: "Afternoon",
        time: "12:00",
        body: "Huft! Isn't it hot day? Don't forget to drink water",
        path: Routes.hydrate),
    NotifcationModel(
        id: 3,
        title: "Evening",
        time: "15:41",
        body: "What a tough day! Drink water to refresh yourself",
        path: Routes.hydrate),
    NotifcationModel(
        id: 4,
        title: "Night",
        time: "21:00",
        body: "Drink water before sleep",
        path: Routes.hydrate),
    NotifcationModel(
        id: 5,
        title: "How was your day?",
        time: "20:00",
        body:
            "You can tell us about your day, thank you for being a good human today! You mean a lot to someone there",
        path: Routes.home),
  ];

  void setDrinkWaterReminder() {
    for (int i = 0; i < timeToDrinkWater.length; i++) {
      NotificationService().scheduledNotification(
        hour: int.parse(timeToDrinkWater[i].time!.split(":")[0]),
        minutes: int.parse(timeToDrinkWater[i].time!.split(":")[1]),
        id: timeToDrinkWater[i].id ?? 0,
        sound: 'sound0',
        title: timeToDrinkWater[i].title ?? '',
        body: timeToDrinkWater[i].body ?? '',
        route: timeToDrinkWater[i].path ?? '',
      );
    }
  }

  // func to test show Notif
  void showNotif() {
    NotificationService().showNotification();
  }

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

    if (index == 0) {
      DashboardController.to.refresh();
    } else if (index == 1) {
      RecordController.to.refresh();
    } else if (index == 2) {
      // NotificationController.to.refresh();
    } else if (index == 3) {
      // ProfileController.to.refresh();
    }

    update();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void onInit() {
    super.onInit();
    log("initialize");
    // setDrinkWaterReminder();
  }
}
