// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// class CommentNotification{
//   final String
// }
class CommentNotoficationModel {
  final String notificationId;
  final String notification;
  final String currentUserId;
  final String toId;
  String isRead;
  final String notificationType;

  CommentNotoficationModel(
      {required this.notificationId,
      required this.notification,
      required this.currentUserId,
      required this.notificationType,
      required this.isRead,
      required this.toId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationId': notificationId,
      'notification': notification,
      'currentUserId': currentUserId,
      'isRead': isRead,
      'notificationType': notificationType,
      'toId': toId,
    };
  }

  factory CommentNotoficationModel.fromMap(Map<String, dynamic> map) {
    return CommentNotoficationModel(
        notificationId: map['notificationId'] as String,
        notification: map['notification'] as String,
        currentUserId: map['currentUserId'] as String,
        toId: map['toId'] as String,
        isRead: map['isRead'] as String,
        notificationType: map['notificationType'] as String);
  }

  String toJson() => json.encode(toMap());

  factory CommentNotoficationModel.fromJson(String source) =>
      CommentNotoficationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
