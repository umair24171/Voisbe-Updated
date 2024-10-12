// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime time;
  List<double>? waveforms;

  CommentNotoficationModel(
      {required this.notificationId,
      required this.notification,
      required this.currentUserId,
      required this.notificationType,
      required this.postBackground,
      required this.postThumbnail,
      required this.isRead,
      required this.noteUrl,
      required this.time,
      required this.postType,
      this.waveforms,
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
      'time': time,
      'notificationType': notificationType,
      'toId': toId,
      'postType': postType,
      'waveforms': waveforms
    };
  }

  factory CommentNotoficationModel.fromMap(Map<String, dynamic> map) {
    return CommentNotoficationModel(
      postType: map['postType'] as String,
      postBackground: map['postBackground'] as String,
      postThumbnail: map['postThumbnail'] as String,
      time: (map['time'] as Timestamp).toDate(),
      notificationId: map['notificationId'] as String,
      notification: map['notification'] as String,
      currentUserId: map['currentUserId'] as String,
      toId: map['toId'] as String,
      noteUrl: map['noteUrl'] as String,
      isRead: map['isRead'] as String,
      notificationType: map['notificationType'] as String,
      waveforms: map['waveforms'] != null
          ? List<double>.from(map['waveforms'] as List)
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentNotoficationModel.fromJson(String source) =>
      CommentNotoficationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
