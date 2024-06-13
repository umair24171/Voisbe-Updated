import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CommentNotoficationModel> allNotifications = [];

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

  readNotification(String notiId) async {
    try {
      int index =
          allNotifications.indexWhere((noti) => noti.notificationId == notiId);
      allNotifications[index].isRead = 'read';
      notifyListeners();
      await _firestore
          .collection('commentNotifications')
          .doc(notiId)
          .update({'isRead': 'read'});
    } catch (e) {
      log(e.toString());
    }
  }
}
