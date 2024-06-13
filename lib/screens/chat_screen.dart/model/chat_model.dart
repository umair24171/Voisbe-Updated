// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String name;
  final String message;
  final bool isShare;
  final String postOwner;
  final DateTime time;
  String messageRead;
  final String avatarUrl;

  ChatModel(
      {required this.name,
      required this.message,
      required this.senderId,
      required this.chatId,
      required this.time,
      required this.messageRead,
      required this.isShare,
      required this.postOwner,
      required this.receiverId,
      required this.avatarUrl});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'chatId': chatId,
      'messageRead': messageRead,
      'postOwner': postOwner,
      'isShare': isShare,
      'name': name,
      'message': message,
      'time': time,
      'avatarUrl': avatarUrl,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      senderId: map['senderId'] as String,
      name: map['name'] as String,
      message: map['message'] as String,
      receiverId: map['receiverId'] as String,
      messageRead: map['messageRead'] as String,
      isShare: map['isShare'] as bool,
      chatId: map['chatId'] as String,
      postOwner: map['postOwner'] as String,
      time: (map['time'] as Timestamp).toDate(),
      avatarUrl: map['avatarUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
