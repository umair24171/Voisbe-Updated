import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CommentModel {
  String commentid;
  String comment;
  String username;
  DateTime time;
  String userId;
  String postId;
  int playedComment;

  List likes;
  String userImage;
  CommentModel(
      {required this.commentid,
      required this.comment,
      required this.username,
      required this.time,
      required this.userId,
      required this.postId,
      required this.likes,
      required this.userImage,
      required this.playedComment});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commentid': commentid,
      'comment': comment,
      'username': username,
      'time': time,
      'userId': userId,
      'postId': postId,
      'likes': likes,
      'userImage': userImage,
      'playedComment': playedComment
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
        commentid: map['commentid'] as String,
        comment: map['comment'] as String,
        username: map['username'] as String,
        time: (map['time'] as Timestamp).toDate(),
        userId: map['userId'] as String,
        postId: map['postId'] as String,
        likes: List.from((map['likes'] as List)),
        userImage: map['userImage'] as String,
        playedComment: map['playedComment'] as int);
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
