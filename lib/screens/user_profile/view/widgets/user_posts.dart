// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:just_waveform/just_waveform.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:social_notes/screens/user_profile/view/widgets/single_post_note.dart';
// import 'package:voice_message_package/voice_message_package.dart';

class UserPosts extends StatefulWidget {
  UserPosts({super.key});

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  List<NoteModel> pinnedPosts = [];

  List<NoteModel> nonPinnedPosts = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var userPosts = Provider.of<UserProfileProvider>(
      context,
    ).userPosts;
    pinnedPosts.clear();
    nonPinnedPosts.clear();
    NoteModel? newPost;
    if (userPosts.isNotEmpty) {
      newPost = userPosts[0];
    }

    for (int i = 0; i < userPosts.length; i++) {
      if (userPosts[i].isPinned) {
        pinnedPosts.add(userPosts[i]);
      } else {
        nonPinnedPosts.add(userPosts[i]);
      }
    }

// Remove the new post from both lists to ensure it's always at index 0
    pinnedPosts.removeWhere((element) => element.noteId == newPost?.noteId);
    nonPinnedPosts.removeWhere((element) => element.noteId == newPost?.noteId);

// Sort the posts: newPost (if exists), one pinned post (if exists), then the rest
    userPosts = [
      if (newPost != null) newPost,
      if (pinnedPosts.isNotEmpty) pinnedPosts.first,
      ...nonPinnedPosts,
      if (pinnedPosts.length > 1) ...pinnedPosts.skip(1),
    ];

    // pinnedPosts.clear();
    // nonPinnedPosts.clear();
    // NoteModel? newPost;
    // if (userPosts.isNotEmpty) {
    //   newPost = userPosts[0];
    // }

    // for (int i = 0; i < userPosts.length; i++) {
    //   if (userPosts[i].isPinned) {
    //     pinnedPosts.add(userPosts[i]);
    //   } else {
    //     nonPinnedPosts.add(userPosts[i]);
    //   }
    // }
    // pinnedPosts.removeWhere((element) => element.noteId == newPost!.noteId);
    // nonPinnedPosts.removeWhere((element) => element.noteId == newPost!.noteId);
    // userPosts = [
    //   if (userPosts.isNotEmpty) newPost!,
    //   ...pinnedPosts,
    //   ...nonPinnedPosts
    // ];

    return Container(
      color: userPosts.isNotEmpty ? whiteColor : null,
      child: Column(
        children: [
          if (userPosts.isEmpty)
            SizedBox(
              height: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/No posts.svg',
                    height: 94,
                    width: 94,
                  ),
                  const SizedBox(
                    height: 10,
                    // width: 94,
                  ),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14,
                        color: Color(0xffED6A5A),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          if (userPosts.isNotEmpty)
            SizedBox(
              height: size.height * 0.2,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: userPosts.length >= 2 ? 2 : userPosts.length,
                itemBuilder: (context, index) {
                  final key =
                      ValueKey<String>('post_${userPosts[index].noteId}');
                  return KeyedSubtree(
                    key: key,
                    child: GestureDetector(
                      onLongPress: () {
                        Provider.of<BottomProvider>(context, listen: false)
                            .setCurrentIndex(1);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    note: userPosts[index],
                                  )),
                        );
                      },
                      onTap: () {
                        if (index != 0) {
                          if (userPosts[index].userUid ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            var isPinned = userPosts[index].isPinned;

                            Provider.of<UserProfileProvider>(context,
                                    listen: false)
                                .pinPost(userPosts[index].noteId, !isPinned);
                          }
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  note: userPosts[index],
                                ),
                              ));
                        }
                      },
                      child: SinglePostNote(
                        isFirstPost: index == 0,
                        lockPosts: [],
                        index: index,
                        isThirdPost: index == 2 ? true : false,
                        isSecondPost: index == 1 ? true : false,
                        isGridViewPost: false,
                        note: userPosts[index],
                        isPinned: userPosts[index].isPinned,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (userPosts.isNotEmpty)
            GridView.builder(
              itemCount: userPosts.length >= 2 ? userPosts.length - 2 : 0,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // crossAxisSpacing: 3,3
                crossAxisCount: 3,
                mainAxisExtent: size.height * 0.2,
                mainAxisSpacing: 0,
              ),
              itemBuilder: (context, index) {
                final key =
                    ValueKey<String>('post_${userPosts[index + 2].noteId}');

                return KeyedSubtree(
                  key: key,
                  child: GestureDetector(
                    onLongPress: () {
                      Provider.of<BottomProvider>(context, listen: false)
                          .setCurrentIndex(1);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  note: userPosts[index + 2],
                                )),
                      );
                    },
                    onTap: () {
                      if (userPosts[index + 2].userUid ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        var isPinned = userPosts[index + 2].isPinned;

                        Provider.of<UserProfileProvider>(context, listen: false)
                            .pinPost(userPosts[index + 2].noteId, !isPinned);
                      }
                    },
                    child: SinglePostNote(
                      lockPosts: [],
                      index: index + 2,
                      isGridViewPost: true,
                      note: userPosts[index + 2],
                      isPinned: userPosts[index + 2].isPinned,
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
