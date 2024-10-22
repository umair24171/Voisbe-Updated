import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';

class NotificationProvider with ChangeNotifier {
  //  creating the instance of the firestore

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  getting all the notifications

  List<CommentNotoficationModel> allNotifications = [];

  //  show expand
  bool isExpand = false;

  //  expand for comments

  bool isExpandForComment = false;

  //  expand for the follow requests

  bool isFollowExpand = false;

  setIsFollowExpand() {
    isFollowExpand = !isFollowExpand;
    notifyListeners();
  }

  //  changing the value of the expand

  setIsExpand() {
    isExpand = !isExpand;
    notifyListeners();
  }

//  changing the value of the  for comment expand

  setIsExpandForCOmment() {
    isExpandForComment = !isExpandForComment;
    notifyListeners();
  }

  //  accept follow request function

  confirmFollowReq(String currentId, String otherId) async {
    try {
      log('confirm req');
      await _firestore.collection('users').doc(currentId).update({
        'followers': FieldValue.arrayUnion([otherId])
      });
      await _firestore.collection('users').doc(otherId).update({
        'following': FieldValue.arrayUnion([currentId])
      });
      await _firestore.collection('users').doc(currentId).update({
        'followReq': FieldValue.arrayRemove([otherId])
      });
      await _firestore.collection('users').doc(otherId).update({
        'followTo': FieldValue.arrayRemove([currentId])
      });
    } catch (e) {
      log(e.toString());
    }
  }

  //  canceling the follow request function

  cancelFollowReq(String currentId, String otherId) async {
    try {
      await _firestore.collection('users').doc(currentId).update({
        'followReq': FieldValue.arrayRemove([otherId])
      });
      await _firestore.collection('users').doc(otherId).update({
        'followTo': FieldValue.arrayRemove([currentId])
      });
    } catch (e) {
      log(e.toString());
    }
  }

  //  adding the notification to the database

  addCommentNotification(CommentNotoficationModel noti) async {
    try {
      await _firestore
          .collection('commentNotifications')
          .doc(noti.notificationId)
          .set(noti.toMap());
    } catch (e) {
      log(e.toString());
    }
  }

  //  getting all the notifications

  getAllNotifications(String userId) async {
    try {
      await _firestore
          .collection('commentNotifications')
          .where('toId', isEqualTo: userId)
          .get()
          .then((snapshot) {
        allNotifications = snapshot.docs
            .map((e) => CommentNotoficationModel.fromMap(e.data()))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  //  reading the notification

  readNotification(String notiId) async {
    try {
      // int index =
      //     allNotifications.indexWhere((noti) => noti.notificationId == notiId);
      // allNotifications[index].isRead = 'read';
      // notifyListeners();
      await _firestore
          .collection('commentNotifications')
          .doc(notiId)
          .update({'isRead': 'read'});
      log('noti read');
    } catch (e) {
      log(e.toString());
    }
  }
}
