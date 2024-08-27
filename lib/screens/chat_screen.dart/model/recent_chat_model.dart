// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

//  creating model to show the recent chat user

class RecentChatModel {
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final String? message;
  final DateTime? time;
  final String? senderName;
  final String? receiverName;
  final String? senderImage;
  final String? receiverImage;
  final String? senderToken;
  final String? receiverToken;
  final bool? seen;
  final String? usersId;
  final List? deletedChat;

  RecentChatModel({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.time,
    required this.senderImage,
    required this.senderName,
    required this.usersId,
    required this.receiverName,
    required this.receiverImage,
    required this.senderToken,
    required this.receiverToken,
    required this.deletedChat,
    required this.seen,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'time': time,
      'senderImage': senderImage,
      'senderToken': senderToken,
      'receiverToken': receiverToken,
      'senderName': senderName,
      'deletedChat': deletedChat,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'usersId': usersId,
      'seen': seen,
    };
  }

  factory RecentChatModel.fromMap(Map<String, dynamic> map) {
    return RecentChatModel(
      deletedChat: List.from(
        (map['deletedChat'] as List),
      ),
      chatId: map['chatId'] as String?,
      senderId: map['senderId'] as String?,
      receiverId: map['receiverId'] as String?,
      message: map['message'] as String?,
      senderToken: map['senderToken'] as String?,
      receiverToken: map['receiverToken'] as String?,
      time: (map['time'] as Timestamp?)?.toDate(),
      senderImage: map['senderImage'] as String?,
      senderName: map['senderName'] as String?,
      receiverName: map['receiverName'] as String?,
      usersId: map['usersId'] as String?,
      receiverImage: map['receiverImage'] as String?,
      seen: map['seen'] as bool?,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecentChatModel.fromJson(String source) =>
      RecentChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
