// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationSettingsModel {
  final String userId;
  final bool isLike;
  final bool isReply;
  final bool isFollows;

  NotificationSettingsModel(
      {required this.isLike,
      required this.userId,
      required this.isReply,
      required this.isFollows});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'isLike': isLike,
      'isReply': isReply,
      'isFollows': isFollows,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      userId: map['userId'] as String,
      isLike: map['isLike'] as bool,
      isReply: map['isReply'] as bool,
      isFollows: map['isFollows'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationSettingsModel.fromJson(String source) =>
      NotificationSettingsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
