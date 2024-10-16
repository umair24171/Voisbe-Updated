// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

// import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart'
    as noti;
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart'
    as notiVi;
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:social_notes/firebase_options.dart';
import 'package:social_notes/resources/app_constants.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/player_provider.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
// import 'package:social_notes/screens/add_note_screen.dart/view/add_note_screen.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/users_screen.dart';

import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/controller/audio_handler.dart';
import 'package:social_notes/screens/home_screen/controller/video_download_methods.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/notifictaions_methods/notification_methods.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:social_notes/screens/profile_screen/provider.dart/update_profile_provider.dart';
import 'package:social_notes/screens/search_screen/view/provider/search_screen_provider.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/stirpe_screen.dart';
import 'package:social_notes/screens/stripe_controller.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/splash_screen.dart';
import "package:flutter_stripe/flutter_stripe.dart";
import 'package:video_thumbnail/video_thumbnail.dart';

flutterNotificationChannel() async {
  await noti.FlutterNotificationChannel().registerNotificationChannel(
    description: 'Channel for Voisbe Chats',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: notiVi.NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
}

void _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String title,
  String body,
  String? payload,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'chats',
    'Chats',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );
  const DarwinNotificationDetails initializationSettingsDarwin =
      DarwinNotificationDetails();
  NotificationDetails platformChannelSpecifics = const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: initializationSettingsDarwin);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

// void _handleNotificationClick(String? payload) {
//   if (payload == null) return;

//   if (payload == 'chat') {
//     navigatorKey.currentState?.pushNamed('/users');
//   } else if (payload == 'notification') {
//     navigatorKey.currentState?.pushNamed('/notifications');
//   } else {
//     // Handle other payloads or parse more complex payloads
//     final data = jsonDecode(payload);
//     if (data['screen'] == 'chat' && data['userId'] != null) {
//       navigatorKey.currentState?.pushNamed('/chat', arguments: data['userId']);
//     }
//   }
// }

Future<void> _initializeNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Stripe.publishableKey = 'pk_live_VQmRjrzGsFLF6U2yE0bXdThg';
  await Stripe.instance.applySettings();
  if (Platform.isIOS) {
    await Purchases.configure(
        PurchasesConfiguration(AppConstants().purchaseApiKeyIos));
  }
  flutterNotificationChannel();
  _initializeNotifications();
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.app.social_notes.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => DisplayNotesProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => FilterProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => UserProfileProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => UpdateProfileProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => SoundProvider(),
    ),
    // ChangeNotifierProvider(
    //   create: (context) => TracksProvider(),
    // ),
    ChangeNotifierProvider(
      create: (context) => SearchScreenProvider(),
    ),
    // ChangeNotifierProvider(
    //   create: (context) => AudioProvider(),
    // ),
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PaymentController(),
    ),
    ChangeNotifierProvider(
      create: (context) => PexelsProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PlayerProvider(),
    ),
    // ChangeNotifierProvider(create: (_) => VideoPlayerManager()),
    ChangeNotifierProvider(
      create: (context) => BottomProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CircleCommentsProvider(),
    ),
    // ChangeNotifierProvider(
    //   create: (context) => SearchPlayerProvider(),
    // ),
    // ChangeNotifierProvider(
    //   create: (context) => EditedInfo(),
    // ),
    // ChangeNotifierProvider(
    //   create: (context) => PlayerProvider(),
    // ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();

    // SpotifyClass().getToken(context);
    // SpotifyClass().getRefreshToken();
    // getALlPostsANdUpdate();

    _removeChatNotifications();
    CheckNotificationClickDataSourceImpl().checkNotificationClick(context);
    CheckNotificationClickDataSourceImpl().setupInteractedMessage();

    clearNotifications();
    checkUserData();
  }

  Future<void> _removeChatNotifications() async {
    final pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    await flutterLocalNotificationsPlugin
        .cancelAll(); // Cancel all pending notifications
  }

  Future<void> clearNotifications() async {
    await flutterLocalNotificationsPlugin
        .cancelAll(); // Cancel all pending notifications
  }

  checkUserData() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          if (value.exists) {
            UserModel user = UserModel.fromMap(value.data()!);
            if (user.name.isEmpty || user.photoUrl.isEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ));
            }
          }
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  getALlPostsANdUpdate() async {
    await FirebaseFirestore.instance
        .collection('notes')
        .get()
        .then((value) async {
      List<NoteModel> notes =
          value.docs.map((e) => NoteModel.fromMap(e.data())).toList();
      for (var note in notes) {
        if (note.backgroundType.contains('video')) {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: note.backgroundImage,
            imageFormat: ImageFormat.JPEG,
            maxHeight: (MediaQuery.of(context).size.height * 1.5)
                .toInt(), // Further reduced dimensions
            maxWidth: (MediaQuery.of(context).size.width * 1.5)
                .toInt(), // Further reduced dimensions
            quality: 100, // Reduced quality for faster generation
          );
          String videoThumbNail = await AddNoteController()
              .uploadUint('thumbnails', uint8list!, context);
          await FirebaseFirestore.instance
              .collection('notes')
              .doc(note.noteId)
              .update({'videoThumbnail': videoThumbNail});
          log('Update ${note.noteId}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: 'Voisbe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, background: whiteColor),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      // MyHomePage(),
      //  const Home(),
      //  AudioTesting(),
      //  CustomProgressPlayer(
      //   height: 80,
      //   width: 150,
      //   noteUrl:
      //       'https://firebasestorage.googleapis.com/v0/b/voisbe.appspot.com/o/voices%2Fd18e8809-8ae9-429a-a72c-601a775c97e5?alt=media&token=b3afd27c-2f2f-4f5d-8dbc-3e746b7c72bf',
      //   mainHeight: 150,
      //   mainWidth: 300,
      // ),
      // AuthScreen(),
      // CheckoutPage(),
      routes: {
        ProfileScreen.routeName: (context) => ProfileScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        SubscribeScreen.routeName: (context) => SubscribeScreen(
              price: 0.0,
            ),
        '/chat': (context) => const UsersScreen(),
        '/notifications': (context) => const NotificationScreen(),
        // AddHashtagsScreen.routeName: (context) => AddHashtagsScreen(),
        // SelectTopicScreen.routeName: (context) => SelectTopicScreen(
        //       title: '',
        //     ),
        BottomBar.routeName: (context) => const BottomBar(),
        // '/': (context) => const Home(),
        // '/editor': (context) => const Editor(),
      },
    );
  }
}
