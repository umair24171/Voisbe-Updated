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
    "private_key_id": "a576c067a746025525dc2bdc2f805f78f6e90f98",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4pzka9lM4QsFS\nsf4m/EanrJ4MWmipcPleTqQSyXao3oiYXvh6JIEnvHrOfnbEOzAjD2X7kR1jEVVR\nry+6ezCsVFMpE43i8dCSOPhDYmrmA21Ht34itKN72RWMiG2HOx+7+/QJJ6Ckob/2\nuZqovrWmcYSP6/dsKbWB5mRoiH3S8BpuWRChwk7GjQI1Sb0Aut/EdtxLhN1Y/3Mh\nO2s/Cg4eZc7xA0ptei2F5s2tfMTzUJqFm+odTo/9U7mNavjmbbYvjaM4uO8Kabh/\nR4HvpWAqwjD09TqDRDoBbmGuxu3yhzoA3Sj5syBrysIHqRxdsyvkWEnCS5TbEDWB\n4YMc76a5AgMBAAECggEAVu1CENNNMfsbD1cDkk7I5D562M3m331zp1XWH5H/7ld0\nbmanCrkMpCwyk+ss9gv3CUpCdD9IWk7an22dRmif7UB1Na0i6md0DKINHYvDTyzl\n0REsrCHlpHP5lQLUrQjEU7a0l2q0UUxkFj4h9LZyxTxDb41iGOU5sUFIm31F3nqk\nGIzJzpnJaFEXrv9uE4Ces+gxyvjySdUy0pmjNEq4oNKO0kRuWuEqpHKlIkj7yFVV\nWHEsnLKiu/ZsyOPLaVuetGWRj/INBeG3FwHatPbyYadS7Ng/c9Na6e8Ng7AvLl7m\n/xiM8LfsHgJBZeWEamlWAKh9Sta/S2kZT1Ge4hPv0QKBgQDF2Y0txHU2G3JglifM\n6ppgVRjwO22f79Gp+zK2ONipLjeKS/W5hkZMv7XK5bRzmHHgI4ipEZQ3eaTx5Bov\nz7YFDDIenK+f7tsCgPhjK2m7TO1DUSsNS6fJn0ac4SEZnPLuPuvqGf0W4clbx3Hd\nZCPt++nFlAPX8GQupZtB4Xx+RwKBgQDu7L6XINj+wx0FZGRxcIQeNw0nrifKpcGU\nHImjWcjNfiTpTAqsW4pCxeHN/9tzoUqd/YUF6uiVy8vqSPVGtL8gSy8gMe3JLwSH\npzVzFKxudkM3WuBpdTCUYniPPnLsm9OlSiCswf+MOmT5+0EmnQrfsjXo9BA5siUZ\nvhRq0pwy/wKBgDokG1vWvsceu7bsiVernaAvgbufCzET7Z4xJo7sF6dn4IRwnA5g\nCiqlr8unQycxJk3Cw3dDpjXDNpiq+pMQTCIhmlzqmKW8MHoE4nlqGZEkIxlEMg2f\nLPiQKNUTR4HaYH1o2jUaXAisY1roOmrf8bsO63zXaWW8zAP1QLHUjJwjAoGBAJ9J\nHldLAt/13Gc34u7uAGbUdOS7arPjhgbkb66DsSeurZULqSH3dVnG6x+XMAsKwOBL\noF+tmJolYDE1qrAU2EcDWMux/cFeozp881lhswOBvJYu8+XaxyRl8dIt5BhyWsub\ne+UxANnQJHm0VF8V26X+/YntDNQqPCnJW3tMJe6pAoGAFgqaMpk3yFt98Tx4asl9\nlnrZOED6/REx4muD0hjt5bKASNRG4Z2GDd3p18Grh3Eoy9XT3c3JlowCxoY7UPSb\n+9Gg655K5lIzIyWjO+s2IyRhJKfDpZVI07sJ0gZF12yeYUTHIK9Q8SZZx5aGA9/M\n+/0lfkZtji+EDtT6SRWCe58=\n-----END PRIVATE KEY-----\n",
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
