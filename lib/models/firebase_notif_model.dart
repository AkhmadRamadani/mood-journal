class FirebaseNotificationModel {
  final String? title;
  final String? body;
  final DateTime? date;
  final String? topic;
  final bool? isRead;
  final dynamic id;

  FirebaseNotificationModel({
    this.title,
    this.body,
    this.date,
    this.topic,
    this.isRead,
    this.id,
  });

  factory FirebaseNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['sent_at'] ?? json['created_at'] ?? json['date'];
    if (rawDate != null) {
      if (rawDate is DateTime) {
        parsedDate = rawDate;
      } else {
        parsedDate = DateTime.tryParse(rawDate.toString());
      }
    }

    return FirebaseNotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      date: parsedDate,
      topic: json['topic'],
      isRead: json['is_read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'date': date?.toIso8601String(),
      'topic': topic,
      'is_read': isRead,
    };
  }

  FirebaseNotificationModel copyWith({
    String? title,
    String? body,
    DateTime? date,
    String? topic,
    bool? isRead,
    dynamic id,
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
}
