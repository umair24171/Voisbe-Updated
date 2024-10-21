import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:http/http.dart' as http;

class NotificationMethods {
  // for getting and updating the pushToken in firestore
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String> getFirebaseMessagingToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedToken = prefs.getString('fcm_token');

      if (storedToken != null) {
        log('Using stored FCM token: $storedToken');
        return storedToken;
      }

      await messaging.requestPermission();
      String? newToken = await messaging.getToken();

      if (newToken != null) {
        log('New FCM Token: $newToken');
        await prefs.setString('fcm_token', newToken);
        return newToken;
      }

      throw Exception('Failed to get FCM token');
    } catch (e) {
      log('Error getting FCM token: $e');
      rethrow;
    }
  }

  static Map firebaseJson = {};

  static Future<String> setToken(BuildContext context) async {
    String scope = 'https://www.googleapis.com/auth/firebase.messaging';
    try {
      final client = await clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(firebaseJson), [scope]);
      return client.credentials.accessToken.data;
    } catch (error) {
      // Log the error for debugging
      print(error);
      // WarningHelper.showErrorToast(
      //     "An error occurred while fetching token", context);
      rethrow; // Re-throw to propagate the error
    }
  }

  static Future<void> sendPushNotification(
      String? userUid,
      String pushToken,
      String msg,
      String userName,
      String screenName,
      String noteId,
      context) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userUid)
          .get();
      UserModel user = UserModel.fromMap(userData.data()!);
      String bearer = await setToken(context);

      const String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/voisbe/messages:send';
      const String serverKey =
          'AAAA85SWX3k:APA91bE_OIa581mRQF-gHU5nj0jSnDXIKk-CM4nCRMeDHCGa0gJVZ0V2DBCGv5eDJIQ94XK6A8id3WzUbEMvF3eo8BzklIbz6IQgGDBO2_0v9_DyKW7QQ-67KD1aViOGAhYVVGiBdkwP'; // Get this from Firebase Console

      final body = {
        "message": {
          "token": user.token,
          "notification": {"title": userName, "body": msg},
          "android": {
            "notification": {"channel_id": "chats"}
          },
          "data": {
            "screen": screenName,
            "title": userName,
            "body": msg,
            "postId": noteId
          }
        }
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearer',
        },
        body: jsonEncode(body),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // static Future<void> sendPushNotification(String? userUid, String pushToken,
  //     String msg, String userName, String screenName, String noteId) async {
  //   try {
  //     DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
  //         .instance
  //         .collection('users')
  //         .doc(userUid)
  //         .get();
  //     UserModel user = UserModel.fromMap(userData.data()!);
  //     final body = {
  //       "to": user.token,
  //       "notification": {
  //         "title": userName,
  //         "body": msg,
  //         "android_channel_id": "chats",
  //       },
  //       "data": {
  //         "screen": screenName,
  //         "title": userName,
  //         "body": msg,
  //         "postId": noteId,
  //       }
  //     };
  //     var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //         headers: {
  //           HttpHeaders.contentTypeHeader: 'application/json',
  //           HttpHeaders.authorizationHeader:
  //               'key=AAAA85SWX3k:APA91bE_OIa581mRQF-gHU5nj0jSnDXIKk-CM4nCRMeDHCGa0gJVZ0V2DBCGv5eDJIQ94XK6A8id3WzUbEMvF3eo8BzklIbz6IQgGDBO2_0v9_DyKW7QQ-67KD1aViOGAhYVVGiBdkwP'
  //         },
  //         body: jsonEncode(body));
  //     log('Response status: ${res.statusCode}');
  //     log('Response body: ${res.body}');
  //   } catch (e) {
  //     log('\nsendPushNotificationE: $e');
  //   }
  // }
}
