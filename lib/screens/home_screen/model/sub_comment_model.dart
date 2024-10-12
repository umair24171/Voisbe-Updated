import 'package:cloud_firestore/cloud_firestore.dart';

class SubCommentModel {
  final String comment;
  final String subCommentId;
  final String commentId;
  final String userId;
  final String userName;
  final String userImage;
  final DateTime createdAt;
  final String postId;
  final String replyingTo;
  List<double>? waveforms;

  SubCommentModel(
      {required this.comment,
      required this.subCommentId,
      required this.commentId,
      required this.userId,
      required this.userName,
      required this.userImage,
      required this.replyingTo,
      required this.postId,
      required this.createdAt,
      this.waveforms});

  factory SubCommentModel.fromMap(Map<String, dynamic> json) {
    return SubCommentModel(
        comment: json['comment'],
        subCommentId: json['subCommentId'],
        commentId: json['commentId'],
        userId: json['userId'],
        userName: json['userName'],
        postId: json['postId'],
        userImage: json['userImage'],
        replyingTo: json['replyingTo'],
        waveforms: json['waveforms'] != null
            ? List<double>.from(json['waveforms'] as List)
            : [],
        createdAt: (json['createdAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toMap() {
    return {
      'comment': comment,
      'subCommentId': subCommentId,
      'commentId': commentId,
      'userId': userId,
      'userName': userName,
      'postId': postId,
      'userImage': userImage,
      'createdAt': createdAt,
      'replyingTo': replyingTo,
      'waveforms': waveforms
    };
  }
}
