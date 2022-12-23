import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodie/models/firebase_notif_model.dart';

class NotificationRepository {
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');

  Future<List<FirebaseNotificationModel>?> getListNotifications() async {
    try {
      List<FirebaseNotificationModel> listNotifications = [];
      QuerySnapshot querySnapshot = await notifications
          .where('user_id', isEqualTo: user!.uid)
          .orderBy('date', descending: true)
          .get();

      querySnapshot.docs.forEach((element) {
        listNotifications.add(FirebaseNotificationModel.fromDocument(element));
      });
      return listNotifications;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> readNotification(
      FirebaseNotificationModel firebaseNotificationModel) async {
    try {
      await notifications
          .doc(firebaseNotificationModel.id)
          .update({'is_read': true});
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
