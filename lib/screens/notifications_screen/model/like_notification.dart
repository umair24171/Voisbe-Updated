// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LikeNotification {
  final String userId;
  final String postUserId;
  final String notificationId;

  LikeNotification(
      {required this.userId,
      required this.postUserId,
      required this.notificationId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'postUserId': postUserId,
      'notificationId': notificationId,
    };
  }

  factory LikeNotification.fromMap(Map<String, dynamic> map) {
    return LikeNotification(
      userId: map['userId'] as String,
      postUserId: map['postUserId'] as String,
      notificationId: map['notificationId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LikeNotification.fromJson(String source) =>
      LikeNotification.fromMap(json.decode(source) as Map<String, dynamic>);
}
