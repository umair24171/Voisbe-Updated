import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class NotificationMethods {
  // for getting and updating the pushToken in firestore
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String> getFirebaseMessagingToken() async {
    String token = '';
    await messaging.requestPermission();
    await messaging.getToken().then((pushToken) {
      if (pushToken != null) {
        debugPrint('Push Token: $pushToken');
        token = pushToken;
      }
    });
    return token;
  }

  static Future<void> sendPushNotification(
      String pushToken, String msg, String userName) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": userName,
          "body": msg,
          "android_channel_id": "chats",
        },
        // "data": {
        //   "screen": "chat",
        // },
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
