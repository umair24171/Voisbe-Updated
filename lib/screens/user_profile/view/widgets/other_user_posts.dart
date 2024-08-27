import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';

import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:social_notes/screens/user_profile/view/widgets/single_post_note.dart';

class OtherUserPosts extends StatefulWidget {
  const OtherUserPosts({super.key, required this.id});
  final String id;

  @override
  State<OtherUserPosts> createState() => _OtherUserPostsState();
}

class _OtherUserPostsState extends State<OtherUserPosts> {
  late StreamSubscription<QuerySnapshot> _subscription;
  List<NoteModel> userPosts = [];
  List<NoteModel> pinnedPosts = [];
  List<NoteModel> nonPinnedPosts = [];
  List<int> lockPosts = [];

  @override
  void initState() {
    getUserDataSubscription();

    super.initState();
  }

  getUserDataSubscription() {
    var user = Provider.of<UserProvider>(context, listen: false).user;

    _subscription = FirebaseFirestore.instance
        .collection('notes')
        .where('userUid', isEqualTo: widget.id)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        log('snapshots are ${snapshot.docs.first.data()}');
        List<NoteModel> otherUserPosts =
            snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

        // Fetch the user data for the current user
        DocumentSnapshot userSnapshot1 = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        UserModel currentUser =
            UserModel.fromMap(userSnapshot1.data() as Map<String, dynamic>);

        // Fetch the user data for the post owner
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.id)
            .get();
        UserModel postOwner =
            UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

        bool isSubscriptionEnabled = postOwner.isSubscriptionEnable;
        bool isCurrentUserSubscriber =
            currentUser.subscribedSoundPacks.contains(widget.id);

        List<NoteModel> filteredPosts = [];
        List<int> indexOfLockPosts = [];

        for (int i = 0; i < otherUserPosts.length; i++) {
          NoteModel post = otherUserPosts[i];
          bool shouldIncludePost = true;
          bool shouldLockPost = false;

          if (post.isPostForSubscribers) {
            if (isSubscriptionEnabled) {
              if (!isCurrentUserSubscriber) {
                shouldLockPost = true;
              }
            } else {
              // If subscription is turned off and current user is not a subscriber, remove the post
              if (!isCurrentUserSubscriber) {
                shouldIncludePost = false;
              }
            }
          }

          if (shouldIncludePost) {
            filteredPosts.add(post);
            if (shouldLockPost) {
              indexOfLockPosts.add(filteredPosts.length - 1);
            }
          }
        }

        // Sort posts: new post first, then pinned, then non-pinned
        NoteModel newPost = filteredPosts[0];
        List<NoteModel> pinnedPosts = filteredPosts
            .where((post) => post.isPinned && post.noteId != newPost.noteId)
            .toList();
        List<NoteModel> nonPinnedPosts = filteredPosts
            .where((post) => !post.isPinned && post.noteId != newPost.noteId)
            .toList();

        filteredPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];

        // Adjust lock post indices after sorting
        indexOfLockPosts = [];
        for (int i = 0; i < filteredPosts.length; i++) {
          if (filteredPosts[i].isPostForSubscribers &&
              isSubscriptionEnabled &&
              !isCurrentUserSubscriber) {
            indexOfLockPosts.add(i);
          }
        }

        setState(() {
          userPosts = filteredPosts;
          lockPosts = indexOfLockPosts;
        });
      }
    });
  }

//   getUserDataSubscription() {
//     var user = Provider.of<UserProvider>(context, listen: false).user;

//     _subscription = FirebaseFirestore.instance
//         .collection('notes')
//         .where('userUid', isEqualTo: widget.id)
//         .orderBy('publishedDate', descending: true)
//         .snapshots()
//         .listen((snapshot) async {
//       if (snapshot.docs.isNotEmpty) {
//         log('snapshots are ${snapshot.docs.first.data()}');
//         List<NoteModel> otherUserPosts =
//             snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

//         // Fetch the user data for the post owner
//          DocumentSnapshot userSnapshot1 = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user!.uid)
//             .get();
// UserModel currentUser =
//             UserModel.fromMap(userSnapshot1.data() as Map<String, dynamic>);
//         DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.id)
//             .get();
//         UserModel postOwner =
//             UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

//         bool isSubscriptionEnabled = postOwner.isSubscriptionEnable;
//         bool isCurrentUserSubscriber =
//             currentUser!.subscribedSoundPacks.contains(widget.id);

//         NoteModel newPost = otherUserPosts[0];
//         pinnedPosts.clear();
//         nonPinnedPosts.clear();
//         List<int> indexOfLockPosts = [];

//         for (int i = 0; i < otherUserPosts.length; i++) {
//           if (otherUserPosts[i].isPinned) {
//             pinnedPosts.add(otherUserPosts[i]);
//           } else {
//             nonPinnedPosts.add(otherUserPosts[i]);
//           }
//         }

//         pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
//         nonPinnedPosts
//             .removeWhere((element) => element.noteId == newPost.noteId);

//         otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];

//         for (int i = 0; i < otherUserPosts.length; i++) {
//           if (otherUserPosts[i].isPostForSubscribers) {
//             if (isSubscriptionEnabled) {
//               if (!isCurrentUserSubscriber) {
//                 indexOfLockPosts.add(i);
//               }
//             }
//             // If subscription is turned off, we don't add to indexOfLockPosts
//           }
//         }

//         setState(() {
//           userPosts = otherUserPosts;
//           lockPosts = indexOfLockPosts;
//         });
//       }
//     });
//   }

  // getUserDataSubscription() {
  //   var currentUser = Provider.of<UserProvider>(context, listen: false).user;
  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .where('userUid', isEqualTo: widget.id)
  //       .orderBy('publishedDate', descending: true)
  //       .snapshots()
  //       .listen((snapshot) async {
  //     if (snapshot.docs.isNotEmpty) {
  //       log('snapshots are ${snapshot.docs.first.data()}');
  //       List<NoteModel> otherUserPosts =
  //           snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

  //       // Fetch the user data for the post owner
  //       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(widget.id)
  //           .get();
  //       UserModel postOwner =
  //           UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

  //       bool isSubscriptionEnabled = postOwner.isSubscriptionEnable;
  //       bool isCurrentUserSubscriber =
  //           currentUser!.subscribedSoundPacks.contains(widget.id);

  //       NoteModel newPost = otherUserPosts[0];
  //       pinnedPosts.clear();
  //       nonPinnedPosts.clear();
  //       List<int> indexOfLockPosts = [];

  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPinned) {
  //           pinnedPosts.add(otherUserPosts[i]);
  //         } else {
  //           nonPinnedPosts.add(otherUserPosts[i]);
  //         }
  //       }

  //       pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
  //       nonPinnedPosts
  //           .removeWhere((element) => element.noteId == newPost.noteId);

  //       otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];

  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPostForSubscribers &&
  //             isSubscriptionEnabled &&
  //             !isCurrentUserSubscriber) {
  //           indexOfLockPosts.add(i);
  //         }
  //       }

  //       log('Is subscription enabled: $isSubscriptionEnabled');
  //       log('Is current user subscriber: $isCurrentUserSubscriber');
  //       log('Number of locked posts: ${indexOfLockPosts.length}');

  //       setState(() {
  //         userPosts = otherUserPosts;
  //         lockPosts = indexOfLockPosts;
  //       });
  //     }
  //   });
  // }

  // getUserDataSubscription() {
  //   var currentUser = Provider.of<UserProvider>(context, listen: false).user;
  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .where('userUid', isEqualTo: widget.id)
  //       .orderBy('publishedDate', descending: true)
  //       .snapshots()
  //       .listen((snapshot) async {
  //     if (snapshot.docs.isNotEmpty) {
  //       log('snapshots are ${snapshot.docs.first.data()}');
  //       List<NoteModel> otherUserPosts =
  //           snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

  //       // Fetch the user data for the post owner
  //       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(widget.id)
  //           .get();
  //       UserModel postOwner =
  //           UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

  //       List<NoteModel> secondList = List.from(otherUserPosts);

  //       NoteModel newPost = otherUserPosts[0];
  //       pinnedPosts.clear();
  //       nonPinnedPosts.clear();
  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPinned) {
  //           pinnedPosts.add(otherUserPosts[i]);
  //         } else {
  //           nonPinnedPosts.add(otherUserPosts[i]);
  //         }
  //       }
  //       List<int> indexOfLockPosts = [];
  //       pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
  //       nonPinnedPosts
  //           .removeWhere((element) => element.noteId == newPost.noteId);

  //       otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];
  //       indexOfLockPosts.clear();

  //       bool isSubscribed =
  //           currentUser!.subscribedSoundPacks.contains(widget.id);
  //       bool hasSubscriptionTurnedOff = !postOwner.isSubscriptionEnable;

  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPostForSubscribers &&
  //             (!isSubscribed || hasSubscriptionTurnedOff)) {
  //           indexOfLockPosts.add(i);
  //         }
  //       }

  //       // Remove locked posts if conditions are met
  //       if (hasSubscriptionTurnedOff && !isSubscribed) {
  //         otherUserPosts.removeWhere((post) => post.isPostForSubscribers);
  //         indexOfLockPosts.clear();
  //       }

  //       setState(() {
  //         userPosts = otherUserPosts;
  //         lockPosts = indexOfLockPosts;
  //       });
  //     }
  //   });
  // }

  // getUserDataSubscription() {
  //   var currentUser = Provider.of<UserProvider>(context, listen: false).user;
  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .where('userUid', isEqualTo: widget.id)
  //       .orderBy('publishedDate', descending: true)
  //       .snapshots()
  //       .listen((snapshot) async {
  //     if (snapshot.docs.isNotEmpty) {
  //       log('snapshots are ${snapshot.docs.first.data()}');
  //       List<NoteModel> otherUserPosts =
  //           snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

  //       // Fetch the user data for the post owner
  //       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(widget.id)
  //           .get();
  //       UserModel postOwner =
  //           UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

  //       bool isSubscriptionEnabled = postOwner.isSubscriptionEnable;
  //       bool isCurrentUserSubscriber =
  //           currentUser!.subscribedSoundPacks.contains(widget.id);

  //       NoteModel newPost = otherUserPosts[0];
  //       pinnedPosts.clear();
  //       nonPinnedPosts.clear();
  //       List<int> indexOfLockPosts = [];

  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPinned) {
  //           pinnedPosts.add(otherUserPosts[i]);
  //         } else {
  //           nonPinnedPosts.add(otherUserPosts[i]);
  //         }
  //       }

  //       pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
  //       nonPinnedPosts
  //           .removeWhere((element) => element.noteId == newPost.noteId);

  //       otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];

  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPostForSubscribers &&
  //             isSubscriptionEnabled &&
  //             !isCurrentUserSubscriber) {
  //           indexOfLockPosts.add(i);
  //         }
  //       }

  //       log('Is subscription enabled: $isSubscriptionEnabled');
  //       log('Is current user subscriber: $isCurrentUserSubscriber');
  //       log('Number of locked posts: ${indexOfLockPosts.length}');

  //       setState(() {
  //         userPosts = otherUserPosts;
  //         lockPosts = indexOfLockPosts;
  //       });
  //     }
  //   });
  // }

//   getUserDataSubscription() {
//     var currentUser = Provider.of<UserProvider>(context, listen: false).user;
//     _subscription = FirebaseFirestore.instance
//         .collection('notes')
//         .where('userUid', isEqualTo: widget.id)
//         .orderBy('publishedDate', descending: true)
//         .snapshots()
//         .listen((snapshot) async {
//       if (snapshot.docs.isNotEmpty) {
//         log('snapshots are ${snapshot.docs.first.data()}');
//         List<NoteModel> otherUserPosts =
//             snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

//         // Fetch the user data for the post owner
//         DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.id)
//             .get();
//         UserModel postOwner =
//             UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

//         List<NoteModel> secondList = List.from(otherUserPosts);

//         NoteModel newPost = otherUserPosts[0];
//         pinnedPosts.clear();
//         nonPinnedPosts.clear();
//         for (int i = 0; i < otherUserPosts.length; i++) {
//           if (otherUserPosts[i].isPinned) {
//             pinnedPosts.add(otherUserPosts[i]);
//           } else {
//             nonPinnedPosts.add(otherUserPosts[i]);
//           }
//         }
//         List<int> indexOfLockPosts = [];
//         pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
//         nonPinnedPosts
//             .removeWhere((element) => element.noteId == newPost.noteId);

//         otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];
//         indexOfLockPosts.clear();

//         bool isSubscribed =
//             currentUser!.subscribedSoundPacks.contains(widget.id);
//         bool hasSubscriptionTurnedOff = !postOwner.isSubscriptionEnable;

//         for (int i = 0; i < otherUserPosts.length; i++) {
//           if (otherUserPosts[i].isPostForSubscribers &&
//               (!isSubscribed && !hasSubscriptionTurnedOff)) {
//             indexOfLockPosts.add(i);
//           }
//         }

// // Remove locked posts if subscription is turned off
//         if (hasSubscriptionTurnedOff) {
//           otherUserPosts.removeWhere((post) => post.isPostForSubscribers);
//           indexOfLockPosts.clear();
//         }

//         // bool isSubscribed =
//         //     currentUser!.subscribedSoundPacks.contains(widget.id);
//         // bool hasSubscriptionTurnedOff = !postOwner.isSubscriptionEnable;

//         // for (int i = 0; i < otherUserPosts.length; i++) {
//         //   if (otherUserPosts[i].isPostForSubscribers &&
//         //       (!isSubscribed || hasSubscriptionTurnedOff)) {
//         //     indexOfLockPosts.add(i);
//         //   }
//         // }

//         // // Remove locked posts if conditions are met
//         // if (hasSubscriptionTurnedOff && !isSubscribed) {
//         //   otherUserPosts.removeWhere((post) => post.isPostForSubscribers);
//         //   indexOfLockPosts.clear();
//         // }

//         setState(() {
//           userPosts = otherUserPosts;
//           lockPosts = indexOfLockPosts;
//         });
//       }
//     });
//   }

  // getUserDataSubscription() {
  //   var currentUser = Provider.of<UserProvider>(context, listen: false).user;
  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .where('userUid', isEqualTo: widget.id)
  //       .orderBy('publishedDate', descending: true)
  //       .snapshots()
  //       .listen((snapshot) {
  //     if (snapshot.docs.isNotEmpty) {
  //       log('snapshots are ${snapshot.docs.first.data()}');
  //       List<NoteModel> otherUserPosts =
  //           snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

  //       List<NoteModel> secondList = List.from(otherUserPosts);

  //       NoteModel newPost = otherUserPosts[0];
  //       pinnedPosts.clear();
  //       nonPinnedPosts.clear();
  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPinned) {
  //           pinnedPosts.add(otherUserPosts[i]);
  //         } else {
  //           nonPinnedPosts.add(otherUserPosts[i]);
  //         }
  //       }
  //       List<int> indexOfLockPosts = [];
  //       pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
  //       nonPinnedPosts
  //           .removeWhere((element) => element.noteId == newPost.noteId);

  //       otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];
  //       indexOfLockPosts.clear();
  //       for (int i = 0; i < otherUserPosts.length; i++) {
  //         if (otherUserPosts[i].isPostForSubscribers &&
  //             !currentUser!.subscribedSoundPacks
  //                 .contains(otherUserPosts[i].userUid)) {
  //           indexOfLockPosts.add(i);
  //         }
  //       }
  //       setState(() {
  //         userPosts = otherUserPosts;
  //         lockPosts = indexOfLockPosts;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    log('otherUserPosts $userPosts');
    log('IndexOfLockPosts $lockPosts');
    var size = MediaQuery.of(context).size;

    return Container(
      color: userPosts.isEmpty ? null : whiteColor,
      child: Column(
        children: [
          userPosts.isEmpty
              ? SizedBox(
                  height: 125,
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
                )
              : SizedBox(
                  height: size.height * 0.2,
                  // width: double.infinity,
                  child: RefreshIndicator(
                    onRefresh: () {
                      return getUserDataSubscription();
                    },
                    child: ListView.builder(
                      // itemExtent: double.infinity,
                      // ignore: prefer_const_constructors
                      padding: EdgeInsets.all(0),
                      // dragStartBehavior: ,
                      shrinkWrap: true,

                      scrollDirection: Axis.horizontal,
                      itemCount: userPosts.length >= 2 ? 2 : userPosts.length,
                      itemBuilder: (context, index) {
                        NoteModel not = userPosts[index];

                        return GestureDetector(
                          onTap: () {
                            if (lockPosts.contains(index)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SubscribeScreen(
                                      // note: noteModel,
                                      )));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        note: not,
                                      )));
                            }
                          },
                          onLongPress: () {
                            if (!lockPosts.contains(index)) {
                              Provider.of<BottomProvider>(context,
                                      listen: false)
                                  .setCurrentIndex(1);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        note: not,
                                      )));
                            }
                          },
                          child: SinglePostNote(
                            isFirstPost: index == 0,
                            lockPosts: lockPosts,
                            index: index,
                            isSecondPost: index == 1 ? true : false,
                            isThirdPost: index == 2 ? true : false,
                            isGridViewPost: false,
                            note: not,
                            isPinned: not.isPinned,
                          ),
                        );
                      },
                    ),
                  ),
                ),
          RefreshIndicator(
            onRefresh: () {
              return getUserDataSubscription();
            },
            child: GridView.builder(
              itemCount: userPosts.length >= 2 ? userPosts.length - 2 : 0,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // crossAxisSpacing: 3,
                  crossAxisCount: 3,
                  mainAxisExtent: size.height * 0.2,
                  mainAxisSpacing: 0),
              itemBuilder: (context, index) {
                NoteModel noteModel = userPosts[index + 2];
                //  NoteModel.fromMap(
                //     snapshot.data!.docs[index + 3].data());
                return GestureDetector(
                  onTap: () {
                    if (lockPosts.contains(index + 2)) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SubscribeScreen(
                              // note: noteModel,
                              )));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                note: noteModel,
                              )));
                    }
                  },
                  child: SinglePostNote(
                    lockPosts: lockPosts,
                    index: index + 2,
                    isGridViewPost: true,
                    note: noteModel,
                    isPinned: noteModel.isPinned,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
