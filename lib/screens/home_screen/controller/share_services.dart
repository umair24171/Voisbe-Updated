import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class DeepLinkPostService {
  final dynamicLink = FirebaseDynamicLinks.instance;

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

  Future<String> createReferLink(NoteModel postData) async {
    FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;
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

    final shortLink = await links.buildShortLink(dynamicLinkParameters);
    return shortLink.shortUrl.toString();
  }

  AudioPlayer _audioPlayer = AudioPlayer();
  PageController controller = PageController();

  void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;

      final queryParams = deepLink.queryParameters;
      final profileCode = queryParams['noteId'];
      if (profileCode != null) {
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(profileCode)
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            final postData = NoteModel.fromMap(snapshot.data()!);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailsScreen(
                      audioPlayer: _audioPlayer,
                      changeIndex: 0,
                      currentIndex: 0,
                      duration: Duration.zero,
                      isPlaying: true,
                      pageController: controller,
                      playPause: () {
                        // playPause(userPosts[index].noteUrl, index);
                      },
                      position: Duration.zero,
                      stopMainPlayer: () {},
                      size: MediaQuery.of(context).size,
                      note: postData,
                    )));

            // if (postData.postType == PostType.video) {
            //   Provider.of<BottomNavigationProvider>(context, listen: false)
            //       .setcurrentIndex = 3;
            //   navPush(context, BottomNavigationBarSet(postData: postData));
            // } else {
            //   Provider.of<BottomNavigationProvider>(context, listen: false)
            //       .setcurrentIndex = 0;
            //   navPush(context, BottomNavigationBarSet(postData: postData));
            // }
          }
        });
      }
    }).onError((error) {
      debugPrint('Dynamic Link Error: $error');
    });
  }
}
