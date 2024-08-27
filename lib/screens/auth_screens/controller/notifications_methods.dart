import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';

class NotificationMethods {
  // for getting and updating the pushToken in firestore
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String> getFirebaseMessagingToken() async {
    String token = '';
    await messaging.requestPermission();
    await messaging.getToken().then((pushToken) {
      if (pushToken != null) {
        log('Push Token: $pushToken');
        token = pushToken;
      }
    });
    return token;
  }

  static Future<void> sendPushNotification(String? userUid, String pushToken,
      String msg, String userName, String screenName, String noteId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userUid)
          .get();
      UserModel user = UserModel.fromMap(userData.data()!);
      final body = {
        "to": user.token,
        "notification": {
          "title": userName,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "screen": screenName,
          "title": userName,
          "body": msg,
          "postId": noteId,
        }
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAA85SWX3k:APA91bE_OIa581mRQF-gHU5nj0jSnDXIKk-CM4nCRMeDHCGa0gJVZ0V2DBCGv5eDJIQ94XK6A8id3WzUbEMvF3eo8BzklIbz6IQgGDBO2_0v9_DyKW7QQ-67KD1aViOGAhYVVGiBdkwP'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
}
