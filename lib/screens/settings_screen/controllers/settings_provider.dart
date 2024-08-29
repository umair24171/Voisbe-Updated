import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/profile_screen/model/report_user.dart';
import 'package:social_notes/screens/settings_screen/model/payment_info.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:social_notes/screens/user_profile/view/widgets/confirm_report.dart';

class SettingsProvider with ChangeNotifier {
  //  getting the user subscriptions

  List<UserModel> userSubscriptions = [];

  //  getting the close friend list

  List<UserModel> closeFriends = [];
  List<UserModel> blockedUsers = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  setIsloading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // fetchUserCloseFriends() {}

  getBlockedUsers(String userId) async {
    try {
      await _firestore
          .collection('users')
          .where('blockedByUsers', arrayContains: userId)
          .get()
          .then((value) {
        blockedUsers =
            value.docs.map((e) => UserModel.fromMap(e.data())).toList();
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  // unblock user function

  unblockUser(String currentId, String blockId, context) async {
    try {
      blockedUsers.removeWhere((element) => element.uid == blockId);
      notifyListeners();
      showWhiteOverlayPopup(context, Icons.check_box_outlined, null, null,
          title: 'Successful!',
          message: 'User unblocked ',
          isUsernameRes: false);

      await _firestore.collection('users').doc(currentId).update({
        'blockedUsers': FieldValue.arrayRemove([blockId])
      });
      await _firestore.collection('users').doc(blockId).update({
        'blockedByUsers': FieldValue.arrayRemove([currentId])
      });
    } catch (e) {
      log(e.toString());
    }
  }

  //  getting user subsriptions

  getUserSubscriptions(String userId) async {
    try {
      await _firestore
          .collection('users')
          .where('subscribedUsers', arrayContains: userId)
          .get()
          .then((value) {
        userSubscriptions =
            value.docs.map((e) => UserModel.fromMap(e.data())).toList();
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  //  removing the user subsriptions

  removeSubscription(String userId, String currentUserId, context) async {
    try {
      setIsloading(true);
      userSubscriptions.removeWhere((element) => element.uid == userId);
      notifyListeners();
      showWhiteOverlayPopup(context, Icons.subscriptions_outlined, null, null,
          title: 'Successful',
          message: 'You have successfully unsubscribed.',
          isUsernameRes: false);
      await _firestore.collection('users').doc(userId).update({
        'subscribedUsers': FieldValue.arrayRemove([currentUserId])
      });
      await _firestore.collection('users').doc(currentUserId).update({
        'subscribedSoundPacks': FieldValue.arrayRemove([userId])
      });

      setIsloading(false);
    } catch (e) {
      setIsloading(false);
      log(e.toString());
    }
  }

  //  adding payment info function

  addPaymentInfo(PaymentInfoModel paymentInfo, context) async {
    try {
      await _firestore
          .collection('paymentInfos')
          .doc(paymentInfo.userId)
          .set(paymentInfo.toMap());
      showWhiteOverlayPopup(context, Icons.check_box, null, null,
          title: 'Successful',
          message: 'You Card details has been updated.',
          isUsernameRes: false);
    } catch (e) {
      log(e.toString());
    }
  }

  //  removing the payment infooo

  removePaymentInfo(String userId, context) async {
    try {
      await _firestore.collection('paymentInfos').doc(userId).delete();
      showWhiteOverlayPopup(context, Icons.check_box, null, null,
          title: 'Successful',
          message: 'You Card details has been removed.',
          isUsernameRes: false);
    } catch (e) {
      log(e.toString());
    }
  }

  //  sending the custom message to the email

  Future<void> customMessage(
    String fromEmail,
    String username,
    String messageText,
  ) async {
    final Email email = Email(
      body: 'VOISBE username: $username\nEmail: $fromEmail\n\n$messageText',
      subject: 'VOISBE support',
      recipients: ['support@voisbe.com'],
      cc: [fromEmail],
      bcc: [fromEmail],
      // attachmentPaths: ['/path/to/attachment.zip'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  //  reporting the user function and sending data to firestore

  reportUser(ReportUserModel report, context) async {
    try {
      showModalBottomSheet(
        backgroundColor: whiteColor,
        elevation: 0,
        context: context,
        builder: (context) {
          return const ConfirmReport();
        },
      );
      await _firestore
          .collection('reports')
          .doc(report.reportId)
          .set(report.toMap());
    } catch (e) {
      log(e.toString());
    }
  }
}
