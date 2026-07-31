import 'dart:developer';

import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/utils/services/api_service.dart';

class NotificationRepository {
  Future<List<FirebaseNotificationModel>?> getListNotifications() async {
    try {
      final response = await ApiService().getNotifications(perPage: 50);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((e) => FirebaseNotificationModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> readNotification(
      FirebaseNotificationModel firebaseNotificationModel) async {
    try {
      if (firebaseNotificationModel.id == null) return false;
      final response = await ApiService()
          .markNotificationAsRead(firebaseNotificationModel.id);
      return response.statusCode == 200;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
