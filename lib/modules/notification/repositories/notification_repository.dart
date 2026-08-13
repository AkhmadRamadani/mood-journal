import 'dart:convert';
import 'dart:developer';

import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/utils/services/api_service.dart';

class NotificationRepository {
  static final NotificationRepository _instance =
      NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();
  Future<List<FirebaseNotificationModel>?> getListNotifications({
    void Function(List<FirebaseNotificationModel> fresh)? onRefreshed,
  }) async {
    try {
      final result =
          await ApiService().getData<List<FirebaseNotificationModel>>(
        uri: '/notifications?per_page=50',
        dbKey: 'list_notifications',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final responseData = jsonDecode(jsonStr);
          if (responseData is Map && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              return data
                  .map((e) => FirebaseNotificationModel.fromJson(
                      Map<String, dynamic>.from(e)))
                  .toList();
            }
          }
          return [];
        },
      );
      if (result.isSuccess) {
        return result.data;
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

  Future<bool> markAllAsRead() async {
    try {
      final response = await ApiService().markAllNotificationsAsRead();
      return response.statusCode == 200;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
