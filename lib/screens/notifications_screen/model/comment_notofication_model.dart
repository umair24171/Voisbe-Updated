// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

//  creating the notification model with required fields

class CommentNotoficationModel {
  final String notificationId;
  final String notification;
  final String currentUserId;
  final String toId;
  String isRead;
  final String notificationType;
  final String noteUrl;
  final String postBackground;
  final String postThumbnail;
  final String postType;

  CommentNotoficationModel(
      {required this.notificationId,
      required this.notification,
      required this.currentUserId,
      required this.notificationType,
      required this.postBackground,
      required this.postThumbnail,
      required this.isRead,
      required this.noteUrl,
      required this.postType,
      required this.toId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationId': notificationId,
      'notification': notification,
      'currentUserId': currentUserId,
      'postBackground': postBackground,
      'postThumbnail': postThumbnail,
      'noteUrl': noteUrl,
      'isRead': isRead,
      'notificationType': notificationType,
      'toId': toId,
      'postType': postType
    };
  }

  factory CommentNotoficationModel.fromMap(Map<String, dynamic> map) {
    return CommentNotoficationModel(
        postType: map['postType'] as String,
        postBackground: map['postBackground'] as String,
        postThumbnail: map['postThumbnail'] as String,
        notificationId: map['notificationId'] as String,
        notification: map['notification'] as String,
        currentUserId: map['currentUserId'] as String,
        toId: map['toId'] as String,
        noteUrl: map['noteUrl'] as String,
        isRead: map['isRead'] as String,
        notificationType: map['notificationType'] as String);
  }

  String toJson() => json.encode(toMap());

  factory CommentNotoficationModel.fromJson(String source) =>
      CommentNotoficationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
