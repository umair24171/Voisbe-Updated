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
    "private_key_id": "77679c29de9b9953f4d7ecef60fceac271153507",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCjcmK+R9gvdnjO\nfvBJKGP7sJvRV8UeOZckP4majs86JYA+uLPPjnCODrgc5ISsLxguPFb3H1Jfyu36\nGVja+P5f+c9jPQ6bjlbHhy2dJBsmiVgCAMxTO4oE1i8AHKWH3ZomOHc/2xzj94n1\naCJjYm6pKAqSOMJhzwZLGdy04roPtLraElYkx69ncPr96nzzFCZajELt4x99hCwc\nfl3qBH1BG2cJZPXeZFASK+l7QTguuqtg5fPmxu77omtm3vG67rrxKBt3lnzpMiMK\n2cHFagTmi5WxdeVYZhOcAODaezzYPXvrHqiv9T49aXlkWw0xH8gKPXguGKz1jnW4\nH2EDmTSNAgMBAAECggEAAJrOlDuA0LqnS9rNJawHvcFDGzxNVsjnKYXXg55gPnFj\nDDWdyhBFHsPxxqOIX+ZspgHFvnuaxPk/KRjSXib503Ep5SoVripP85+/FPxIioSh\nXhzCGcw4EQGSX3zcjy29nNkhhPWiKOqAuiajsdE1kgg32a4Z79ZGQu3e7GL5gF5P\nvKPU3/f1TEM18qElhn2TmIKG3jcPK6rycz/6Qdt2iYBJotLWiUEODnBZeolo+6Gt\nifDHzx9ouAorDnoCbDWSa9LPLrs/Twq18W+JKFB4WpJEf6qI9GZ5R8zFQmExI6VW\nsEcou9Uo6eTD6gwB+QCNnAfK0JjOVegdi7Zbycc9kQKBgQDAFt4u1l04ZIV9ov/P\n+OgfehwV5ozJw7HOeiGVweiyprIzZMQvkRA7oHVaGatNylnhuFWsf9c39stCr/65\ncIW2R6W5HUVoYanncvjNqThg7b/bVI5kbXycRpKpmEyZI3sX6P8nci7eUASYplIQ\n69yMK8ziBrDN+JE9Cu3ue/ui1QKBgQDZ0+dOYrpF6P+hHoQhXKz0MDuAAAIkkp44\ngOy9SlrvEOAHplwZmPKmKl2F5L4D1okmfRMZjA0RPOL5CSDChQcNt3V3i9y/4Znd\niIgbrgAJZ61K2blX5oXlFrkKE+31q9avle3ew2KNoc5rPA8HLhkvlCPjWA5OLh7J\nGFJTyEZ22QKBgQCG5YhSzCfbGnzEpluP6fTZZh+jIa1tZAjSP+KmEO8hxv8OKI29\n+dm0hhLjm3M5xgkpAxLneT/jBWXpBz+Tavn78ITpYy0DCNMQvyULCPOW3mAF33PA\nA0OnW8hTYakpQkmHmRDW2tEfPoJ70RGA4KKZrYjMknZHr3APtkUxXdBxoQKBgENx\nI2WWlbu9dyAodZpqujXklRd9aSxvpMMzz5iP4/Wu0N4teMiIHWCrL0ecWeSQUOh0\nwyweu5EBu/iFBfqT+2oYyirYR+G09NGtSw7e4a4HxpStMoBvpDcYwPPI1d1Bdffp\nQLu+3M2jMmjrMG/1quCbSj1CbzNvfiKfACZmlMKJAoGAOhJjKDYIP1MS/siaX22x\nswf2u3YLv2LwC2h3X6uBSwWbrJjWtKfDKzJyC++ztmwTLN19iCY/fPXEgTsREf16\nGjCqJQjYW77iS4cUrJ9+fxBxXFwHOy3fW1C1GoM/5YzVHcxnagr5djuebkfqsNK3\n0pBwPf7G1XGMyif9p6MntBA=\n-----END PRIVATE KEY-----\n",
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
