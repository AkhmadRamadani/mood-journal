import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/modules/notification/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  List<FirebaseNotificationModel> todaysNotifList = [];
  List<FirebaseNotificationModel> yesterdayNotifList = [];

  RxBool isLoading = false.obs;

  User? user = FirebaseAuth.instance.currentUser;

  NotificationRepository notificationRepository = NotificationRepository();

  void setTodaysNotifList(List<FirebaseNotificationModel> list) {
    todaysNotifList = list;
    update();
  }

  void setYesterdayNotifList(List<FirebaseNotificationModel> list) {
    yesterdayNotifList = list;
    update();
  }

  Future<void> getNotifications() async {
    isLoading.value = true;
    isLoading = true.obs;
    update();
    var list = await notificationRepository.getListNotifications();
    if (list != null) {
      todaysNotifList = list
          .where((element) => element.date!
              .isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList();
      yesterdayNotifList = list
          .where((element) => element.date!
              .isBefore(DateTime.now().subtract(const Duration(days: 1))))
          .toList();
    } else {
      log('NotificationController getNotifications list is null');
    }
    isLoading.value = false;
    isLoading = false.obs;
    update();
  }

  Future<void> readNotification(
      FirebaseNotificationModel firebaseNotificationModel) async {
    isLoading.value = true;
    isLoading = true.obs;
    update();
    var result = await notificationRepository
        .readNotification(firebaseNotificationModel);
    if (result) {
      await getNotifications();
      log('NotificationController updateNotification result is true');
    } else {
      log('NotificationController updateNotification result is false');
    }
    isLoading.value = false;
    isLoading = false.obs;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getNotifications();

    log('NotificationController onInit');
  }
}
