// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:just_waveform/just_waveform.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
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
  AudioPlayer _audioPlayer = AudioPlayer();
  PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isPlaying = false;
  // AudioPlayer player = AudioPlayer();
  Duration position = Duration.zero;
  int _currentIndex = 0;

  Duration duration = Duration.zero;
  List<NoteModel> pinnedPosts = [];

  List<NoteModel> nonPinnedPosts = [];

  // final GlobalKey _popupKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  final double _autoplayThreshold = 200.0;

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
      // if (userPosts[i].publishedDate.compareTo(DateTime.now()) == 0) {
      //   newlyNote = userPosts[i];
      // }
      // if (userPosts[i].isNewlyCreated) {
      //   userPosts.insert(0, userPosts[i]);
      // }
    }
    pinnedPosts.removeWhere((element) => element.noteId == newPost!.noteId);
    nonPinnedPosts.removeWhere((element) => element.noteId == newPost!.noteId);
    userPosts = [
      if (userPosts.isNotEmpty) newPost!,
      ...pinnedPosts,
      ...nonPinnedPosts
    ];
    // if (pinnedPosts.isNotEmpty) {
    //   userPosts.insert(0, pinnedPosts[0]);
    // }
    Offset _tapPosition = Offset.zero;

    return Column(
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
                      color: whiteColor,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        if (userPosts.isNotEmpty)
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userPosts.length >= 3 ? 3 : userPosts.length,
              itemBuilder: (context, index) {
                final key = ValueKey<String>('post_${userPosts[index].noteId}');
                return index == 0
                    ? InkWell(
                        onLongPress: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NoteDetailsScreen(
                                  audioPlayer: _audioPlayer,
                                  changeIndex: currentIndex,
                                  currentIndex: index,
                                  duration: duration,
                                  isPlaying: _isPlaying,
                                  pageController: _controller,
                                  playPause: () {
                                    playPause(userPosts[index].noteUrl, index);
                                  },
                                  position: position,
                                  stopMainPlayer: stopMainPlayer,
                                  size: MediaQuery.of(context).size,
                                  note: userPosts[index]),
                            ),
                          );
                        },
                        child: CustomProgressPlayer(
                            mainWidth: size.width >= 412
                                ? MediaQuery.of(context).size.width * 0.45
                                : MediaQuery.of(context).size.width * 0.48,
                            mainHeight: 82,
                            height: 50,
                            isProfilePlayer: true,
                            width: 58,
                            isMainPlayer: true,
                            title: userPosts[index].title,
                            waveColor: primaryColor,
                            noteUrl: userPosts[index].noteUrl),
                      )
                    : KeyedSubtree(
                        key: key,
                        child: GestureDetector(
                          // key: _popupKey,
                          // onTapDown: (TapDownDetails details) {
                          //   _tapPosition = details.globalPosition;
                          // },
                          onLongPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NoteDetailsScreen(
                                    audioPlayer: _audioPlayer,
                                    changeIndex: currentIndex,
                                    currentIndex: index,
                                    duration: duration,
                                    isPlaying: _isPlaying,
                                    pageController: _controller,
                                    playPause: () {
                                      playPause(
                                          userPosts[index].noteUrl, index);
                                    },
                                    position: position,
                                    stopMainPlayer: stopMainPlayer,
                                    size: MediaQuery.of(context).size,
                                    note: userPosts[index]),
                              ),
                            );
                          },
                          onTap: () {
                            if (userPosts[index].userUid ==
                                FirebaseAuth.instance.currentUser!.uid) {
                              var isPinned = userPosts[index].isPinned;

                              Provider.of<UserProfileProvider>(context,
                                      listen: false)
                                  .pinPost(userPosts[index].noteId, !isPinned);
                            }
                          },
                          // onTap: () {

                          child: SinglePostNote(
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
            itemCount: userPosts.length >= 3 ? userPosts.length - 3 : 0,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              // crossAxisSpacing: 3,3
              crossAxisCount: 4,
              mainAxisExtent: 100,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (context, index) {
              final key =
                  ValueKey<String>('post_${userPosts[index + 3].noteId}');

              return
                  // index == 0
                  //     ? CustomWaveformPlayer(audioUrl: userPosts[index].noteUrl)
                  //     :
                  KeyedSubtree(
                key: key,
                child: GestureDetector(
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteDetailsScreen(
                            audioPlayer: _audioPlayer,
                            changeIndex: currentIndex,
                            currentIndex: index,
                            duration: duration,
                            isPlaying: _isPlaying,
                            pageController: _controller,
                            playPause: () {
                              playPause(userPosts[index + 3].noteUrl, index);
                            },
                            position: position,
                            stopMainPlayer: stopMainPlayer,
                            size: MediaQuery.of(context).size,
                            note: userPosts[index + 3]),
                      ),
                    );
                  },
                  onTap: () {
                    if (userPosts[index + 3].userUid ==
                        FirebaseAuth.instance.currentUser!.uid) {
                      var isPinned = userPosts[index + 3].isPinned;

                      Provider.of<UserProfileProvider>(context, listen: false)
                          .pinPost(userPosts[index + 3].noteId, !isPinned);
                    }
                  },
                  child: SinglePostNote(
                    isGridViewPost: true,
                    note: userPosts[index + 3],
                    isPinned: userPosts[index + 3].isPinned,
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}

// class CustomPlayer extends StatefulWidget {
//   const CustomPlayer({super.key, required this.audioSrc});
//   final String audioSrc;

//   @override
//   State<CustomPlayer> createState() => _CustomPlayerState();
// }

// class _CustomPlayerState extends State<CustomPlayer> {
//   @override
//   Widget build(BuildContext context) {
//     return VoiceMessageView(
//         innerPadding: 4,
//         controller: VoiceController(
//             audioSrc: widget.audioSrc,
//             maxDuration: const Duration(seconds: 1000),
//             isFile: false,
//             onComplete: () {},
//             onPause: () {},
//             onPlaying: () {}));
//   }
// }

// class CustomPlayer extends StatefulWidget {
//   CustomPlayer({Key? key, required this.note}) : super(key: key);

//   final NoteModel note;

//   @override
//   State<CustomPlayer> createState() => _CustomPlayerState();
// }

// class _CustomPlayerState extends State<CustomPlayer> {
//   late StreamSubscription<PlayerState> playerStateSubscription;
//   late final PlayerController playerController;

//   @override
//   void initState() {
//     super.initState();
//     _initialiseController();
//     preparePlayer();
//     playerStateSubscription =
//         playerController.onPlayerStateChanged.listen((event) {
//       setState(() {});
//     }, onError: (error) {
//       print('Player error: $error');
//     }, onDone: () {
//       print('Player finished playing');
//     });
//   }

//   void _initialiseController() {
//     playerController = PlayerController();
//   }

//   preparePlayer() async {
//     try {
//       playerController.preparePlayer(
//         path: widget.note.noteUrl,
//         shouldExtractWaveform: true,
//         noOfSamples: 100,
//       );
//     } catch (e) {
//       log('Error preparing player: $e');
//     }
//   }

//   @override
//   void dispose() {
//     playerController.dispose();
//     playerStateSubscription.cancel();
//     super.dispose();
//   }

//   void _playandPause() async {
//     if (playerController.playerState == PlayerState.playing) {
//       await playerController.pausePlayer();
//     } else {
//       await playerController.startPlayer(finishMode: FinishMode.loop);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.grey[300],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: _playandPause,
//             icon: Icon(playerController.playerState == PlayerState.playing
//                 ? Icons.pause
//                 : Icons.play_arrow),
//           ),
//           AudioFileWaveforms(
//             enableSeekGesture: true,
//             animationDuration: const Duration(seconds: 100),
//             waveformType: WaveformType.fitWidth,
//             playerController: playerController,
//             playerWaveStyle: PlayerWaveStyle(fixedWaveColor: primaryColor),
//             backgroundColor: Colors.grey[300],
//             size: const Size(54, 20),
//           ),
//         ],
//       ),
//     );
//   }
// }
