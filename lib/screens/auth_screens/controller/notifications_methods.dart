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

  static Map firebaseJson = {
    "type": "service_account",
    "project_id": "voisbe",
    "private_key_id": "d97133ec43473c5ca9f3a29388cc71fedddad288",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+ZxM3eaaZ1AYf\n2JqewevVjGZMefaso7ObTyqaj306ceGcd0ZZhi4/wMw1EMZDlw18dxm6cVNRghcJ\nLIlnAhbDHVNOOneH5a2wG43JAUcPMOigN28687wu+pyzeHc+VXckjDyWDqjR0G3n\nIWiasqQqOdiprNTAZ9xCzF/T4VuL5YHRemf/zubcQDqbSITg9Dx42Ia49G1FOSQk\nFin8f8E69v76J5dcCMC0tBhJ3MnFzazhiGO+v+URa2IvDB7nhx+99pXWHU7dfcxM\ni0XTNvspvi18rcUD9sQpT3bARr5Fjaqr67lJhinyN6ekBORRYZP38khwoGV9JTcM\n2ix4mU2PAgMBAAECggEAB+0x70ZLju3fuhBXZ4flMdpgITZBSbCgTTU/gyMOxecb\nIFtq0gFJsvJreJi+gu5/65A9waBEJV7dZ06zravNl3PaFaX4zJndiuOqxGp0MzKz\nDIXM8KRYT5Berliz23l4C00h8eahqpJwcNsth/srOxggvUzqUn7rEYYr8HMvpM7n\nv33mutRNw/7WFuV/KbSXbgfWt2wkSlf+1b7q9BsWWKqQfrtYKCBH+Ff82f+n5P0w\nAFn65Vgp6VZ+4g/jaOsoLqbSy2g+dgUHEFx94ojL99LzI7KPaB7G2U8MUlraoON3\nPHW4V8lt7XIotSIrum/SgDG1B+LV3rMXR7kzX/eSMQKBgQDN1M6pFOXPw4Qj6Y+j\nuYeLgWTJm71hz+7C5IN+izsAgaLh/07NMZj8TstNw7I9JFSZ8ojSdJoT6lP5p2WF\nY7HGCxJmamtrNZYUWnkWXjryVMGJ+R/ifEA4qOQhFequcUh5SVWJkkvUqJbMLrXw\nOBeycxGlf+zbMz0QaBHejlSvWQKBgQDsz5JMCD6zi8bPAHQIqzdqEQLifx/dR4mC\nxR3RGPBzblXZfPkb6QbzKSSC5tOEKCSQrZGzUc4P0MLAtY4g1hG8fRhIG49vSB8K\nCrI8jzlqM2NC1t9R17ulXAXYVUU7O/GcG7e7ybPWuO8g5Xpo7ELRePkK4TNcGvbS\nVsu0TKNvJwKBgQCdxcB/VHhvkCOqz23+BsmCQrW53/oDjroqg7TTe+/HDJeI+gUy\nPhFRXShzPE1UlpOOyZzdDOnJ2DV0ST8FRwzOjFAXVv1t2U5n3Y2xepteg18y3lX1\nal5jz/nF7qHMAyOVbIP3hr8/i9bDPg7Ryn1HmPJu1Kb+wsDM4ajI2nrJSQKBgQDW\nMOUlSivUYDABGWraUGr9z8cpMEyU69iP5FSUxRbvgTO7VNNIkFwN4f+5OqjEFz8D\ncUqgw/Q6z9rnTQ/x2U4Pi6JDzlHNGJGilowiRHVs/m/gi9NQBm4eIf7TbkUBT7W4\nOkXUX5r/MyRvP8CZWGETcHTph0naHDV1iLYVLWCB7wKBgGTV06I7xVhYwonU/F9n\nrtIoEydtFy0bN1s2Kaj/vxZtY5mipmsuqgnRIpd9+8gTWqjPwXZXlmEr676OGfkr\nlZ4ra6MWekLjkLWp/0jzLLEjlgKROV5G+ChGwmfCTDzENyw4Tqoo842gc/TrTvEM\nEdAGS+nF9HHhj2IwSkvFXh33\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-rd1kl@voisbe.iam.gserviceaccount.com",
    "client_id": "101314687151559877402",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-rd1kl%40voisbe.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

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
