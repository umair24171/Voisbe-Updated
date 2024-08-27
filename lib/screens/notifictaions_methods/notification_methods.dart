import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:social_notes/main.dart';
import 'package:social_notes/screens/chat_screen.dart/view/users_screen.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/settings_screen/view/edit_subscriptions_screen.dart';

class CheckNotificationClickDataSourceImpl {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void checkNotificationClick(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Map<String, dynamic> data = message.data;
      String screen = data['screen'];
      debugPrint('dataof $data $screen');
      if (Platform.isAndroid) {
        initializeNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  // Future<void> initializeNotification(
  //     BuildContext context, RemoteMessage message) async {
  //   var androidIntialization =
  //       const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iOSInitialization = const DarwinInitializationSettings();
  //   var initializationSettings = InitializationSettings(
  //       android: androidIntialization, iOS: iOSInitialization);
  //   await flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (details) {
  //       if (details.payload != null) {
  //         final data = jsonDecode(details.payload!);
  //         handleMessage(RemoteMessage(data: data));
  //       }
  //     },
  //   );
  // }
  Future<void> initializeNotification(
      BuildContext context, RemoteMessage message) async {
    var androidIntialization =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iOSInitialization = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: androidIntialization, iOS: iOSInitialization);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          handleMessage(RemoteMessage(data: data));
          flutterLocalNotificationsPlugin.cancel(0); // Cancel the notification
        }
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000000).toString(),
      'chats',
      importance: Importance.max,
    );
    AndroidNotificationDetails androidDetais = AndroidNotificationDetails(
      channel.id.toString(), channel.name.toString(),
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      icon: '@mipmap/launcher_icon',

      //   const AndroidNotificationAction('cancel', 'done',
      //       cancelNotification: true,
      //       allowGeneratedReplies: true,
      //       // titleColor: ,
      //       showsUserInterface: true),
      //   const AndroidNotificationAction('reply', 'Reply',
      //       allowGeneratedReplies: true,
      //       inputs: [
      //         AndroidNotificationActionInput(
      //             label: 'Reply',
      //             allowFreeFormInput: true,
      //             choices: [
      //               'Yes',
      //               'No',
      //               'thanks',
      //             ])
      //       ]),
      // ],
    );
    DarwinNotificationDetails iOSInitialization =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetais, iOS: iOSInitialization);
    Future.delayed(
      Duration.zero,
      () {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails,
          payload: jsonEncode(message.data), // Encode the entire data payload
        );
      },
    );
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
    });
  }

  Future<void> handleMessage(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;
    String screen = data['screen'];
    if (screen == 'notification') {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ));
      await flutterLocalNotificationsPlugin
          .cancel(0); // Cancel the notification
    } else if (screen == 'chat') {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const UsersScreen(),
      ));
      await flutterLocalNotificationsPlugin
          .cancel(0); // Cancel the notification
    } else if (screen == 'subscription') {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const EditSubscriptionsScreen(),
      ));
      await flutterLocalNotificationsPlugin
          .cancel(0); // Cancel the notification
    } else if (screen == 'home') {
      String postId = data['postId'];
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => HomeScreen(noteId: postId),
      ));
      await flutterLocalNotificationsPlugin
          .cancel(0); // Cancel the notification
    }
  }

  // Future<void> handleMessage(RemoteMessage message) async {
  //   Map<String, dynamic> data = message.data;
  //   String screen = data['screen'];
  //   if (screen == 'notification') {
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (context) => const NotificationScreen(),
  //     ));
  //   } else if (screen == 'chat') {
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (context) => const UsersScreen(),
  //     ));
  //   } else if (screen == 'subscription') {
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (context) => const EditSubscriptionsScreen(),
  //     ));
  //   } else if (screen == 'home') {
  //     // Add this condition
  //     String postId = data['postId'];
  //     // Navigate to the post screen with the post ID
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (context) => HomeScreen(noteId: postId),
  //     ));
  //   }
  // }
}
