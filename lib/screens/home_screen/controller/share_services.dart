import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class DeepLinkPostService {
  final dynamicLink = FirebaseDynamicLinks.instance;
  Future<String> createReferLink(NoteModel postData) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://voisbe.page.link',
      link: Uri.parse('https://voisbe.page.link?noteId=${postData.noteId}'),
      androidParameters: const AndroidParameters(
        packageName: 'com.app.voisbe',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: postData.title,
        description: 'Voisbe post',
        imageUrl: Uri.parse(postData.photoUrl),
      ),
    );

    final shortLink = await dynamicLink.buildShortLink(dynamicLinkParameters);
    return shortLink.shortUrl.toString();
  }

  void initDynamicLinks(BuildContext context) async {
    // Handle links when the app is already running
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData.link, context);
    }).onError((error) {
      debugPrint('Dynamic Link Error: $error');
    });

    // Handle links when the app is started from a terminated state
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      _handleDynamicLink(data.link, context);
    }
  }

  void _handleDynamicLink(Uri deepLink, BuildContext context) async {
    final queryParams = deepLink.queryParameters;
    final noteId = queryParams['noteId'];
    if (noteId != null) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(noteId)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          final postData = NoteModel.fromMap(snapshot.data()!);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(note: postData),
          ));
        }
      });
    }
  }

  Future<String> shareProfileLink(String userId) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://voisbe.page.link',
      link: Uri.parse('https://voisbe.page.link?userId=$userId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.app.voisbe',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Voisbe Profile',
        description: 'Voisbe Profile',
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/voisbe-1f7b6.appspot.com/o/voisbe_logo.png?alt=media&token=3b3b3b3b-3b3b-3b3b-3b3b-3b3b3b3b3b3b'),
      ),
    );

    final shortLink = await dynamicLink.buildShortLink(dynamicLinkParameters);
    return shortLink.shortUrl.toString();
  }

  void initDynamicLinksForProfile(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;

      final queryParams = deepLink.queryParameters;
      final userId = queryParams['userId'];
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            final user = UserModel.fromMap(snapshot.data()!);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtherUserProfile(userId: userId),
            ));
          }
        });
      }
    }).onError((error) {
      debugPrint('Dynamic Link Error: $error');
    });
  }
}
