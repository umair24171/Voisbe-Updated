import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:social_notes/screens/user_profile/view/widgets/single_post_note.dart';

class OtherUserPosts extends StatefulWidget {
  const OtherUserPosts({super.key, required this.id});
  final String id;

  @override
  State<OtherUserPosts> createState() => _OtherUserPostsState();
}

class _OtherUserPostsState extends State<OtherUserPosts> {
  AudioPlayer _audioPlayer = AudioPlayer();
  PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isPlaying = false;
  AudioPlayer player = AudioPlayer();
  Duration position = Duration.zero;
  int _currentIndex = 0;

  Duration duration = Duration.zero;

  late StreamSubscription<QuerySnapshot> _subscription;
  List<NoteModel> userPosts = [];
  List<NoteModel> pinnedPosts = [];
  List<NoteModel> nonPinnedPosts = [];

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _subscription = FirebaseFirestore.instance
        .collection('notes')
        .where('userUid',
            isEqualTo:
                // 'ysGnuGm48ySdv4i20ZKA0XB5g7o1'
                widget.id)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        log('snapshots are ${snapshot.docs.first.data()}');
        List<NoteModel> otherUserPosts =
            snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

        List<NoteModel> secondList = List.from(otherUserPosts);

        NoteModel newPost = otherUserPosts[0];
        pinnedPosts.clear();
        nonPinnedPosts.clear();
        for (int i = 0; i < otherUserPosts.length; i++) {
          if (otherUserPosts[i].isPinned) {
            pinnedPosts.add(otherUserPosts[i]);
          } else {
            nonPinnedPosts.add(otherUserPosts[i]);
          }
        }
        pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
        nonPinnedPosts
            .removeWhere((element) => element.noteId == newPost.noteId);

        otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];
        setState(() {
          userPosts = otherUserPosts;
          // Update the local list with the sorted list
        });
      }
    });
    // Provider.of<UserProfileProvider>(context, listen: false).getUserPosts(
    //     Provider.of<UserProfileProvider>(context, listen: false)
    //         .otherUser!
    //         .uid);
    super.initState();
  }

  stopMainPlayer() {
    _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      currentIndex = -1;
    });
  }

  void playPause(String url, int index) async {
    // Check if the file is already cached
    final cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);

    if (fileInfo == null) {
      // File is not cached, download and cache it
      try {
        fileInfo = await cacheManager.downloadFile(url, key: url);
      } catch (e) {
        print('Error downloading file: $e');
        return;
      }
    }

    // Use the cached file for playback
    if (_isPlaying && _currentIndex != index) {
      await _audioPlayer.stop();
    }

    if (_currentIndex == index && _isPlaying) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
        setState(() {
          _currentIndex = -1;
          _isPlaying = false;
        });
      } else {
        _audioPlayer.resume();
        setState(() {
          _currentIndex = index;
          _isPlaying = true;
        });
      }
    } else {
      await _audioPlayer
          .play(
        UrlSource(fileInfo.file.path),
      )
          .then((value) async {
        setState(() {
          _currentIndex = index;
          _isPlaying = true;
        });
        duration = (await _audioPlayer.getDuration())!;
        setState(() {});
      });
    }

    _audioPlayer.onPositionChanged.listen((event) {
      if (_currentIndex == index) {
        setState(() {
          position = event;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentIndex = -1;
        position = Duration.zero;
      });
    });
  }

  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    log('otherUserPosts $userPosts');
    var size = MediaQuery.of(context).size;
    // var otherUser = Provider.of<UserProfileProvider>(
    //   context,
    // ).otherUser;
    // var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    // var userPosts = Provider.of<UserProfileProvider>(
    //   context,
    // ).userPosts;

    // Offset _tapPosition = Offset.zero;
    return
        // otherUser!.isPrivate
        //     ? !otherUser.followers.contains(currentUser!.uid)
        //         ? Column(
        //             children: [
        //               SvgPicture.asset(
        //                 'assets/icons/private lock.svg',
        //                 height: 94,
        //                 width: 94,
        //               ),
        //               const SizedBox(
        //                 height: 10,
        //               ),
        //               Text(
        //                 'This account is private',
        //                 style: TextStyle(
        //                     fontFamily: fontFamily,
        //                     fontSize: 14,
        //                     color: whiteColor,
        //                     fontWeight: FontWeight.w500),
        //               )
        //             ],
        //           )
        //         :
        Column(
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
                          color: whiteColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 105,
                // width: double.infinity,
                child: ListView.builder(
                  // itemExtent: double.infinity,
                  // ignore: prefer_const_constructors
                  padding: EdgeInsets.all(0),
                  // dragStartBehavior: ,
                  shrinkWrap: true,

                  scrollDirection: Axis.horizontal,
                  itemCount: userPosts.length >= 3 ? 3 : userPosts.length,
                  itemBuilder: (context, index) {
                    NoteModel not = userPosts[index];

                    return index == 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: InkWell(
                              onLongPress: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => NoteDetailsScreen(
                                      audioPlayer: _audioPlayer,
                                      changeIndex: currentIndex,
                                      currentIndex: index,
                                      duration: duration,
                                      isPlaying: _isPlaying,
                                      pageController: _controller,
                                      playPause: () {
                                        playPause(not.noteUrl, index);
                                      },
                                      position: position,
                                      stopMainPlayer: stopMainPlayer,
                                      size: MediaQuery.of(context).size,
                                      note: not),
                                ));
                              },
                              child: CustomProgressPlayer(
                                  mainWidth: size.width >= 412
                                      ? MediaQuery.of(context).size.width * 0.45
                                      : MediaQuery.of(context).size.width *
                                          0.48,
                                  mainHeight: 82,
                                  height: 50,
                                  width: 58,
                                  isProfilePlayer: true,
                                  isMainPlayer: true,
                                  waveColor: primaryColor,
                                  title: not.title,
                                  noteUrl: not.noteUrl),
                            ),
                          )
                        : GestureDetector(
                            // key: _popupKey,
                            // onTapDown: (TapDownDetails details) {
                            //   _tapPosition = details.globalPosition;
                            // },
                            onLongPress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NoteDetailsScreen(
                                    audioPlayer: _audioPlayer,
                                    changeIndex: currentIndex,
                                    currentIndex: index,
                                    duration: duration,
                                    isPlaying: _isPlaying,
                                    pageController: _controller,
                                    playPause: () {
                                      playPause(not.noteUrl, index);
                                    },
                                    position: position,
                                    stopMainPlayer: stopMainPlayer,
                                    size: MediaQuery.of(context).size,
                                    note: not),
                              ));
                            },

                            child: SinglePostNote(
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
        GridView.builder(
          itemCount: userPosts.length >= 3 ? userPosts.length - 3 : 0,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              // crossAxisSpacing: 3,
              crossAxisCount: 4,
              mainAxisExtent: 100,
              mainAxisSpacing: 0),
          itemBuilder: (context, index) {
            NoteModel noteModel = userPosts[index + 3];
            //  NoteModel.fromMap(
            //     snapshot.data!.docs[index + 3].data());
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoteDetailsScreen(
                      audioPlayer: _audioPlayer,
                      changeIndex: currentIndex,
                      currentIndex: index,
                      duration: duration,
                      isPlaying: _isPlaying,
                      pageController: _controller,
                      playPause: () {
                        playPause(noteModel.noteUrl, index);
                      },
                      position: position,
                      stopMainPlayer: stopMainPlayer,
                      size: MediaQuery.of(context).size,
                      note: noteModel),
                ));
              },
              child: SinglePostNote(
                isGridViewPost: true,
                note: noteModel,
                isPinned: noteModel.isPinned,
              ),
            );
          },
        )
        // StreamBuilder(
        //     stream: FirebaseFirestore.instance
        //         .collection('notes')
        //         .where('userUid',
        //             isEqualTo:
        //                 Provider.of<UserProfileProvider>(context, listen: false)
        //                     .otherUser!
        //                     .uid)
        //         .orderBy('publishedDate', descending: true)
        //         .snapshots(),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         // List<NoteModel> pinnedPosts = [];
        //         // List<NoteModel> nonPinnedPosts = [];
        //         // // NoteModel latestNote = userPosts[0];
        //         // for (int i = 0; i < userPosts.length; i++) {
        //         //   if (userPosts[i].isPinned) {
        //         //     pinnedPosts.add(userPosts[i]);
        //         //   } else {
        //         //     nonPinnedPosts.add(userPosts[i]);
        //         //   }
        //         // }
        //         // userPosts = [
        //         //   // latestNote,
        //         //   ...pinnedPosts,
        //         //   ...nonPinnedPosts
        //         // ];
        // return GridView.builder(
        //   itemCount: userPosts.length >= 3 ? userPosts.length - 3 : 0,
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       // crossAxisSpacing: 3,
        //       crossAxisCount: 4,
        //       mainAxisExtent: 120,
        //       mainAxisSpacing: 0),
        //   itemBuilder: (context, index) {
        //     NoteModel noteModel = userPosts[index];
        //     //  NoteModel.fromMap(
        //     //     snapshot.data!.docs[index + 3].data());
        //     return GestureDetector(
        //       onTap: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //           builder: (context) => NoteDetailsScreen(
        //               size: MediaQuery.of(context).size,
        //               note: noteModel),
        //         ));
        //         // if (userPosts[index].userUid ==
        //         //     FirebaseAuth.instance.currentUser!.uid) {
        //         //   var isPinned = userPosts[index].isPinned;

        //         //   Provider.of<UserProfileProvider>(context, listen: false)
        //         //       .pinPost(userPosts[index].noteId, !isPinned);
        //         // }
        //       },
        //       child: SinglePostNote(
        //         isGridViewPost: true,
        //         note: noteModel,
        //         isPinned: noteModel.isPinned,
        //       ),
        //     );
        //   },
        // );
        //       } else {
        //         return Center(
        //             child: SpinKitThreeBounce(
        //           color: whiteColor,
        //           size: 12,
        //         ));
        //       }
        //     })
      ],
    );
    // : Column(
    //     children: [
    //       SizedBox(
    //         height: 110,
    //         child: StreamBuilder(
    //             stream: FirebaseFirestore.instance
    //                 .collection('notes')
    //                 .where('userUid',
    //                     isEqualTo: Provider.of<UserProfileProvider>(context,
    //                             listen: false)
    //                         .otherUser!
    //                         .uid)
    //                 .orderBy('publishedDate', descending: true)
    //                 .snapshots(),
    //             builder: (context, snapshot) {
    //               if (snapshot.hasData) {
    //                 if (snapshot.data!.docs.isEmpty) {
    //                   return SizedBox(
    //                     height: 110,
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         SvgPicture.asset(
    //                           'assets/icons/No posts.svg',
    //                           height: 94,
    //                           width: 94,
    //                         ),
    //                         const SizedBox(
    //                           height: 10,
    //                         ),
    //                         Text(
    //                           'No posts yet',
    //                           style: TextStyle(
    //                               fontFamily: fontFamily,
    //                               fontSize: 14,
    //                               color: whiteColor,
    //                               fontWeight: FontWeight.w500),
    //                         ),
    //                       ],
    //                     ),
    //                   );
    //                 }
    //                 return ListView.builder(
    //                   scrollDirection: Axis.horizontal,
    //                   itemCount:
    //                       userPosts.length >= 3 ? 3 : userPosts.length,
    //                   itemBuilder: (context, index) {
    //                     NoteModel not = userPosts[index];
    //                     // NoteModel.fromMap(
    //                     //     snapshot.data!.docs[index].data());
    //                     return index == 0
    //                         ? CustomProgressPlayer(
    //                             mainWidth: 180,
    //                             mainHeight: 100,
    //                             height: 50,
    //                             width: 55,
    //                             isMainPlayer: true,
    //                             waveColor: primaryColor,
    //                             noteUrl: not.noteUrl)
    //                         : GestureDetector(
    //                             // key: _popupKey,
    //                             // onTapDown: (TapDownDetails details) {
    //                             //   _tapPosition = details.globalPosition;
    //                             // },
    //                             onLongPress: () {
    //                               Navigator.of(context).push(
    //                                 MaterialPageRoute(
    //                                   builder: (context) =>
    //                                       NoteDetailsScreen(
    //                                           size: MediaQuery.of(context)
    //                                               .size,
    //                                           note: not),
    //                                 ),
    //                               );
    //                             },

    //                             child: SinglePostNote(
    //                               isGridViewPost: false,
    //                               note: not,
    //                               isPinned: not.isPinned,
    //                             ),
    //                           );
    //                   },
    //                 );
    //               } else {
    //                 return Center(
    //                     child: SpinKitThreeBounce(
    //                   color: whiteColor,
    //                   size: 12,
    //                 ));
    //               }
    //             }),
    //       ),
    //       StreamBuilder(
    //           stream: FirebaseFirestore.instance
    //               .collection('notes')
    //               .where('userUid',
    //                   isEqualTo: Provider.of<UserProfileProvider>(context,
    //                           listen: false)
    //                       .otherUser!
    //                       .uid)
    //               .snapshots(),
    //           builder: (context, snapshot) {
    //             if (snapshot.hasData) {
    //               return GridView.builder(
    //                 itemCount:
    //                     userPosts.length >= 3 ? userPosts.length - 3 : 0,
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 shrinkWrap: true,
    //                 gridDelegate:
    //                     const SliverGridDelegateWithFixedCrossAxisCount(
    //                         // crossAxisSpacing: 3,
    //                         crossAxisCount: 4,
    //                         mainAxisExtent: 90,
    //                         mainAxisSpacing: 2),
    //                 itemBuilder: (context, index) {
    //                   NoteModel noteModel = userPosts[index];
    //                   // NoteModel.fromMap(
    //                   //     snapshot.data!.docs[index + 3].data());
    //                   return GestureDetector(
    //                     onLongPress: () {
    //                       Navigator.of(context).push(
    //                         MaterialPageRoute(
    //                           builder: (context) => NoteDetailsScreen(
    //                               size: MediaQuery.of(context).size,
    //                               note: noteModel),
    //                         ),
    //                       );
    //                     },
    //                     child: SinglePostNote(
    //                       isGridViewPost: true,
    //                       note: noteModel,
    //                       isPinned: noteModel.isPinned,
    //                     ),
    //                   );
    //                 },
    //               );
    //             } else {
    //               return Center(
    //                   child: SpinKitThreeBounce(
    //                 color: whiteColor,
    //                 size: 12,
    //               ));
    //             }
    //           })
    //     ],
    //   );
  }
}
