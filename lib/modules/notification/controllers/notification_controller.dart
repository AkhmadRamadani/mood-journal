import 'dart:developer';

import 'package:get/get.dart';
import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/modules/notification/repositories/notification_repository.dart';

import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/auth_service.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  UserModel? get user => AuthService().getUser();

  List<FirebaseNotificationModel> todaysNotifList = [];
  List<FirebaseNotificationModel> yesterdayNotifList = [];

  RxBool isLoading = false.obs;

  final NotificationRepository notificationRepository =
      Get.find<NotificationRepository>();

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

    void applyList(List<FirebaseNotificationModel> list) {
      todaysNotifList = list
          .where((element) => element.date!.day == DateTime.now().day)
          .toList();
      yesterdayNotifList = list
          .where((element) => element.date!.day < DateTime.now().day)
          .toList();
    }

    var list = await notificationRepository.getListNotifications(
      onRefreshed: (fresh) {
        // Called in background when SWR network response arrives
        applyList(fresh);
        update();
        log('NotificationController SWR background refresh done');
      },
    );
    if (list != null) {
      applyList(list);
    } else {
      log('NotificationController getNotifications list is null');
    }
    isLoading.value = false;
    isLoading = false.obs;
    update();
  }

  Future<void> readNotification(
      FirebaseNotificationModel firebaseNotificationModel) async {
    // Optimistically mark as read in the local list for instant UI update
    for (final notif in todaysNotifList) {
      if (notif.id == firebaseNotificationModel.id) {
        notif.isRead = true;
        break;
      }
    }
    for (final notif in yesterdayNotifList) {
      if (notif.id == firebaseNotificationModel.id) {
        notif.isRead = true;
        break;
      }
    }
    update();

    // Sync with backend in background
    final result = await notificationRepository
        .readNotification(firebaseNotificationModel);
    if (result) {
      log('NotificationController updateNotification result is true');
    } else {
      log('NotificationController updateNotification result is false');
    }
  }

  void markAllAsRead() {
    // Optimistically mark all as read locally
    for (final notif in todaysNotifList) {
      notif.isRead = true;
    }
    for (final notif in yesterdayNotifList) {
      notif.isRead = true;
    }
    update();

    // Sync with backend in background
    notificationRepository.markAllAsRead().then((result) {
      log('NotificationController markAllAsRead result: $result');
    });
  }

  @override
  void onInit() {
    super.onInit();
    getNotifications();

    log('NotificationController onInit');
  }
}
