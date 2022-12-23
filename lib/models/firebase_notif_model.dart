import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationModel {
  final String? title;
  final String? body;
  final DateTime? date;
  final String? topic;
  final bool? isRead;
  final String? id;

  FirebaseNotificationModel({
    this.title,
    this.body,
    this.date,
    this.topic,
    this.isRead,
    this.id,
  });

  factory FirebaseNotificationModel.fromJson(Map<String, dynamic> json) {
    return FirebaseNotificationModel(
      title: json['title'],
      body: json['body'],
      date: json['date'].toDate(),
      topic: json['topic'],
      isRead: json['is_read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'date': date,
      'topic': topic,
      'is_read': isRead,
    };
  }

  // copy with
  FirebaseNotificationModel copyWith({
    String? title,
    String? body,
    DateTime? date,
    String? topic,
    bool? isRead,
    String? id,
  }) {
    return FirebaseNotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      topic: topic ?? this.topic,
      isRead: isRead ?? this.isRead,
      id: id ?? this.id,
    );
  }

  factory FirebaseNotificationModel.fromDocument(DocumentSnapshot doc) {
    return FirebaseNotificationModel.fromJson(
            doc.data() as Map<String, dynamic>)
        .copyWith(id: doc.id);
  }
}
