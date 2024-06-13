// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/widgets.dart';

// import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// import 'package:social_notes/screens/add_note_screen.dart/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/users_screen.dart';
// import 'package:social_notes/screens/home_screen/controller/share_services.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/single_post_note.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isPlaying = false;
  AudioPlayer player = AudioPlayer();
  Duration position = Duration.zero;
  int _currentIndex = 0;

  Duration duration = Duration.zero;

  // ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    Future.delayed(Duration.zero, () {
      Provider.of<DisplayNotesProvider>(context, listen: false).getAllNotes();
      Provider.of<FilterProvider>(context, listen: false)
          .setSelectedFilter('For you');
      Provider.of<UserProvider>(context, listen: false).getUserData();
      Provider.of<DisplayNotesProvider>(context, listen: false).getAllUsers();

      // getSoundsOfUnsubscribedUsers();
    });
  }

  // getSoundsOfUnsubscribedUsers() {
  //   var soundPro = Provider.of<SoundProvider>(context, listen: false);
  //   log('sounds of unsubscribed users ${soundPro.soundPacksMap}');
  // }

  List<String> topics = [
    'Need support',
    'Relationship & love',
    'Confession & secret',
    'Inspiration & motivation',
    'Food & Cooking',
    'Personal Story',
    'Business',
    'Something I learned',
    'Education & Learning',
    'Books & Literature',
    'Spirit & Mind',
    'Travel & Adventure',
    'Fashion & Style',
    'Creativity & Art',
    'Humor & Comedy',
    'Sports & Fitness',
    'Technology & Innovation',
    'Current Events & News',
    'Health & Wellness',
    'Hobbies & Interests'
  ];
  List<Color> topicColors = [
    const Color(0xff503e3b), // color1
    const Color(0xffcd3826), // color2
    const Color(0xffcf4736), // color3
    const Color(0xffe6b619), // color4
    const Color(0xff8ab756), // color5
    const Color(0xffeb6447), // color6
    const Color(0xff3694de), // color7
    const Color(0xffe69319), // color8
    const Color(0xff7c69de), // color9
    const Color(0xff885341), // color10
    const Color(0xff9235a2), // color11
    const Color(0xff56a559), // color12
    const Color(0xffd53269), // color13
    const Color(0xff6a46ab), // color14
    const Color(0xffe154a1), // color15
    const Color(0xff15acbf), // color16
    const Color(0xff45897a), // color17
    const Color(0xff472861), // color18
    const Color(0xff37728c), // color19
    const Color(0xff6cb57f), // color20
  ];

  Color _getColor(int index) {
    return topicColors[index % topicColors.length];
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

  // void playPause(
  //   String url,
  //   int index,
  // ) async {
  //   File? cachedFile = await DefaultCacheManager().getSingleFile(url);

  //   if (cachedFile != null && await cachedFile.exists()) {
  //     // File is already cached, use the cached file URL
  //     url = cachedFile.path;
  //   } else {
  //     // File is not cached, download and cache it
  //     FileInfo? fileInfo = await DefaultCacheManager().downloadFile(url);
  //     if (fileInfo != null) {
  //       url = fileInfo.file!.path;
  //     }
  //   }

  //   _audioPlayer.setSourceUrl(url).then((value) async {
  //     await _audioPlayer.getDuration().then(
  //           (value) => setState(() {
  //             duration = value!;
  //             // if (widget.currentIndex == widget.changeIndex) {
  //             //   widget.playPause();
  //             // }
  //           }),
  //         );
  //     if (_isPlaying && _currentIndex != index) {
  //       await _audioPlayer.stop();
  //     }

  //     if (_currentIndex == index && _isPlaying) {
  //       if (_audioPlayer.state == PlayerState.playing) {
  //         _audioPlayer.pause();
  //         setState(() {
  //           _isPlaying = false;
  //           currentIndex = -1;
  //         });
  //       } else {
  //         _audioPlayer.resume();
  //         setState(() {
  //           _isPlaying = true;
  //           currentIndex = index;
  //         });
  //       }
  //     } else {
  //       await _audioPlayer.play(UrlSource(url));
  //       setState(() {
  //         _currentIndex = index;
  //         _isPlaying = true;
  //       });
  //     }
  //     _audioPlayer.onPositionChanged.listen((event) {
  //       if (_currentIndex == index) {
  //         setState(() {
  //           position = event;
  //         });
  //       }
  //     });
  //     _audioPlayer.onDurationChanged.listen((event) {
  //       if (_currentIndex == index) {
  //         setState(() {
  //           duration = event;
  //         });
  //       }
  //     });
  //     _audioPlayer.onPlayerComplete.listen((event) {
  //       // _updatePlayedComment(commentId, commentsList[index].playedComment);
  //       setState(() {
  //         _isPlaying = false;
  //         _currentIndex = -1;
  //         position = Duration.zero;
  //       });
  //     });
  //   });
  // }

  @override
  void dispose() {
    duration = Duration.zero;
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<DisplayNotesProvider>(
      context,
    );
    var filterProvider = Provider.of<FilterProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    // userProvider.getUserData();
    Provider.of<ChatProvider>(context, listen: false).getAllUsersForChat();

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          bottomOpacity: 0,
          foregroundColor: whiteColor,
          shadowColor: whiteColor,
          scrolledUnderElevation: 0,
          surfaceTintColor: whiteColor,
          backgroundColor: whiteColor,
          forceMaterialTransparency: false,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Consumer<FilterProvider>(builder: (context, filterPro, _) {
                return Text(
                  filterPro.selectedFilter,
                  style: TextStyle(
                      color: blackColor,
                      fontFamily: fontFamilyMedium,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                ),
                child: Consumer<FilterProvider>(builder: (context, filPro, _) {
                  return IconButton(
                    onPressed: () {
                      showMenu(
                          elevation: 0,
                          color: whiteColor,
                          surfaceTintColor: whiteColor,
                          shadowColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          context: context,
                          position: const RelativeRect.fromLTRB(0, 80, 0, 0),
                          items: [
                            if (!filPro.selectedFilter
                                .contains('Close Friends'))
                              PopupMenuItem(
                                onTap: () {
                                  filterProvider
                                      .setSelectedFilter('Close Friends');
                                },
                                value: 'Close Friends',
                                child: Row(
                                  children: [
                                    Icon(Icons.group_outlined,
                                        color: blackColor),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'Close Friends',
                                      style: TextStyle(fontFamily: fontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            if (!filPro.selectedFilter
                                .contains('Filter Topics'))
                              PopupMenuItem(
                                onTap: () {
                                  filterProvider
                                      .setSelectedFilter('Filter Topics');
                                },
                                value: 'Filter Topics',
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list, color: blackColor),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'Filter Topics',
                                      style: TextStyle(fontFamily: fontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            if (filPro.selectedFilter
                                    .contains('Filter Topics') ||
                                filPro.selectedFilter.contains('Close Friends'))
                              PopupMenuItem(
                                onTap: () {
                                  filterProvider.setSelectedFilter('For you');
                                },
                                value: 'For you',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        color: blackColor),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'For you',
                                      style: TextStyle(fontFamily: fontFamily),
                                    ),
                                  ],
                                ),
                              ),
                          ]);
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: blackColor,
                    ),
                  );
                }),
              ),
              // Consumer<FilterProvider>(builder: (context, filterPro, _) {
              //   return filterPro.selectedFilter.contains('Filter Topics') ||
              //           filterPro.selectedFilter.contains('Close Friends')
              //       ? const Text('')
              //       : Expanded(
              //           child: Padding(
              //             padding: const EdgeInsets.only(left: 8),
              //             child: Row(
              //               children: [
              //                 Text(
              //                   '#Trends2024',
              //                   overflow: TextOverflow.ellipsis,
              //                   style: TextStyle(
              //                       fontFamily: fontFamily,
              //                       fontSize: 12,
              //                       fontWeight: FontWeight.w600),
              //                 ),
              //                 const SizedBox(
              //                   width: 6,
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     '#Trends2024',
              //                     overflow: TextOverflow.ellipsis,
              //                     style: TextStyle(
              //                         fontFamily: fontFamily,
              //                         fontSize: 12,
              //                         fontWeight: FontWeight.w600),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         );
              // })
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const NotificationScreen();
                    },
                  ));
                },
                icon: Stack(
                  children: [
                    Icon(
                      Icons.favorite_border_outlined,
                      color: blackColor,
                    ),
                    Consumer<NotificationProvider>(
                        builder: (context, notiPro, _) {
                      List<CommentNotoficationModel> unreadNotifications = [];
                      unreadNotifications.clear();
                      for (var noti in notiPro.allNotifications) {
                        if (noti.isRead.isEmpty) {
                          unreadNotifications.add(noti);
                        }
                      }
                      return unreadNotifications.isNotEmpty
                          ? Positioned(
                              left: 13,
                              top: 2,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            )
                          : SizedBox();
                    })
                  ],
                )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14).copyWith(left: 2),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const UsersScreen();
                    },
                  ));
                },
                child: SvgPicture.asset(
                  'assets/icons/Subtract.svg',
                  height: 22,
                  width: 22,
                  // color: _page == 3 ? primaryColor : null,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
        body: provider.notes.isEmpty
            ? Center(
                child: SpinKitThreeBounce(
                  color: whiteColor,
                  size: 20,
                ),
              )
            : RefreshIndicator(
                onRefresh: () {
                  return Provider.of<DisplayNotesProvider>(context,
                          listen: false)
                      .getAllNotes();
                },
                child: Stack(
                  children: [
                    Consumer<FilterProvider>(builder: (context, filterpro, _) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [
                                  0.25,
                                  0.75,
                                ],
                                colors: filterpro.selectedFilter
                                        .contains('Close Friends')
                                    ? [greenColor, greenColor]
                                    : [
                                        const Color(0xffee856d),
                                        const Color(0xffed6a5a)
                                      ])),
                      );
                    }),
                    SizedBox(
                      height: size.height,
                      child: Column(
                        children: [
                          Consumer<FilterProvider>(
                              builder: (context, filterPro, _) {
                            return !filterProvider.selectedFilter
                                    .contains('Filter Topics')
                                ? const SizedBox()
                                : SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: ListView.builder(
                                      itemCount: topics.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => Stack(
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 50,
                                            color: _getColor(
                                                index + 1 < topics.length
                                                    ? index + 1
                                                    : index),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 50,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            decoration: BoxDecoration(
                                              color: _getColor(index),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(40),
                                                bottomRight:
                                                    Radius.circular(40),
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                filterPro.searchValue = '';
                                                filterPro.setSearchingValue(
                                                    topics[index]);
                                              },
                                              child: Text(
                                                topics[index],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          }),
                          Expanded(
                            child: Consumer<FilterProvider>(
                                builder: (context, filPro, _) {
                              List<NoteModel> filteredNotes =
                                  provider.notes.where((note) {
                                return !userProvider.user!.blockedUsers
                                    .contains(note.userUid);
                              }).toList();
                              if (filPro.selectedFilter
                                  .contains('Close Friends')) {
                                filPro.closeFriendsPosts.clear();

                                for (var element
                                    in userProvider.user!.closeFriends) {
                                  for (var note in filteredNotes) {
                                    if (element.contains(note.userUid)) {
                                      filPro.closeFriendsPosts.add(note);
                                    }
                                  }
                                }
                              } else if (filPro.selectedFilter
                                  .contains('Filter Topics')) {
                                filPro.searcheNote.clear();
                                for (var note in filteredNotes) {
                                  if (note.topic.contains(filPro.searchValue)) {
                                    filPro.searcheNote.add(note);
                                  }
                                }
                              }
                              return PageView.builder(
                                  controller: _pageController,

                                  // physics: const BouncingScrollPhysics(),
                                  // reverse: true,
                                  onPageChanged: (value) {
                                    playPause(
                                        filPro.selectedFilter
                                                .contains('Close Friends')
                                            ? filPro.closeFriendsPosts[value]
                                                .noteUrl
                                            : filPro.selectedFilter
                                                    .contains('Filter Topics')
                                                ? filPro
                                                    .searcheNote[value].noteUrl
                                                : filteredNotes[value].noteUrl,
                                        value);
                                  },
                                  itemCount: filPro.selectedFilter
                                          .contains('Close Friends')
                                      ? filPro.closeFriendsPosts.length
                                      : filPro.selectedFilter
                                              .contains('Filter Topics')
                                          ? filPro.searcheNote.length
                                          : provider.notes.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    final note = filPro.selectedFilter
                                            .contains('Close Friends')
                                        ? filPro.closeFriendsPosts[index]
                                        : filPro.selectedFilter
                                                .contains('Filter Topics')
                                            ? filPro.searcheNote[index]
                                            : filteredNotes[index];
                                    // Check if the current user has blocked the user who created the post

                                    if (userProvider.user!.blockedUsers
                                        .contains(note.userUid)) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            'You have blocked the user. Try removing the user from the blocked list to see the post..',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: fontFamily,
                                                color: whiteColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ); // Return an empty widget if blocked
                                    }
                                    // final key = ValueKey<String>(
                                    //     'comment_${filPro.selectedFilter.contains('Close Friends') ? filPro.closeFriendsPosts[index].noteId : filPro.selectedFilter.contains('Filter Topics') ? filPro.searcheNote[index].noteId : provider.notes[index].noteId}');
                                    final key = ValueKey<String>(
                                        'comment_${note.noteId}');
                                    return KeyedSubtree(
                                      key: key,
                                      child: SingleNotePost(
                                        duration: duration,
                                        stopMainPlayer: stopMainPlayer,
                                        playPause: () {
                                          playPause(
                                            note.noteUrl,
                                            // filPro.selectedFilter
                                            //         .contains('Close Friends')
                                            //     ? filPro.closeFriendsPosts[index]
                                            //         .noteUrl
                                            //     : filPro.selectedFilter
                                            //             .contains('Filter Topics')
                                            //         ? filPro
                                            //             .searcheNote[index].noteUrl
                                            //         : provider.notes[index].noteUrl,
                                            index,
                                          );
                                        },
                                        audioPlayer: _audioPlayer,
                                        position: position,
                                        changeIndex: _currentIndex,
                                        isPlaying: _isPlaying,
                                        postIndex: currentIndex,
                                        pageController: _pageController,
                                        currentIndex: index,
                                        size: size,
                                        note: note,
                                        // filPro.selectedFilter
                                        //         .contains('Close Friends')
                                        //     ? filPro.closeFriendsPosts[index]
                                        //     : filPro.selectedFilter
                                        //             .contains('Filter Topics')
                                        //         ? filPro.searcheNote[index]
                                        //         : provider.notes[index],
                                      ),
                                    );
                                  });
                            }),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }
}
