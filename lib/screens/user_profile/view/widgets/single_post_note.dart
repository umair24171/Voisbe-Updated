// import 'dart:developer';

import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/search_screen/view/widgets/search_player.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_video_thumbnail.dart';
import 'package:social_notes/screens/user_profile/view/widgets/thumbnail_video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SinglePostNote extends StatefulWidget {
  const SinglePostNote(
      {super.key,
      required this.note,
      required this.isPinned,
      this.isThirdPost = false,
      required this.index,
      required this.lockPosts,
      this.isSecondPost = false,
      this.isFirstPost = false,
      required this.isGridViewPost});
  final NoteModel note;
  final bool isPinned;
  final bool isGridViewPost;
  final bool isThirdPost;
  final bool isSecondPost;
  final List<int> lockPosts;
  final int index;
  final bool isFirstPost;
  @override
  State<SinglePostNote> createState() => _SinglePostNoteState();
}

class _SinglePostNoteState extends State<SinglePostNote> {
  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;
  // static final Map<String, Uint8List?> _thumbnailCache = {};
  // static const int maxCacheSize = 100;
  // void preloadThumbnails() {
  //   if (widget.note.backgroundType.contains('video')) {
  //     _getVideoThumbnail(widget.note.backgroundImage);
  //   }
  // }

  // Future<Uint8List?> _getVideoThumbnail(String videoUrl) async {
  //   if (_thumbnailCache.containsKey(videoUrl)) {
  //     return _thumbnailCache[videoUrl];
  //   }

  //   for (int attempt = 0; attempt < 3; attempt++) {
  //     try {
  //       final uint8list = await VideoThumbnail.thumbnailData(
  //         video: videoUrl,
  //         imageFormat: ImageFormat.JPEG,
  //         maxHeight: (MediaQuery.of(context).size.height * 0.2).toInt(),
  //         maxWidth: (MediaQuery.of(context).size.width * 0.3).toInt(),
  //         quality: 50,
  //       );

  //       if (uint8list != null) {
  //         _thumbnailCache[videoUrl] = uint8list;
  //         return uint8list;
  //       }
  //     } catch (e) {
  //       print("Error in _getVideoThumbnail (attempt ${attempt + 1}): $e");
  //     }
  //     await Future.delayed(Duration(seconds: 1)); // Wait before retrying
  //   }

  //   return null;
  // }

  @override
  void initState() {
    super.initState();
    // preloadThumbnails();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(widget.note.noteUrl);
    // Check if the file is already cached
    DefaultCacheManager().getFileFromCache(widget.note.noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });
    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    _audioPlayer.onPlayerComplete.listen((state) {
      setState(() {
        _isPlaying = false;
      });
    });
  }
  // @override
  // void didChangeDependencies() {
  //   getDuration();
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_cachedFilePath != null) {
        _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setPlaybackRate(1); // Set playback speed
        await _audioPlayer.play(UrlSource(_cachedFilePath!));

        // updatePlayedComment();
      } else {
        // Cache the file if not already cached
        _audioPlayer.setReleaseMode(ReleaseMode.stop);
        DefaultCacheManager()
            .downloadFile(widget.note.noteUrl)
            .then((fileInfo) {
          if (fileInfo.file.existsSync()) {
            _cachedFilePath = fileInfo.file.path;
            _audioPlayer.setPlaybackRate(1); // Set playback speed
            _audioPlayer.play(
              UrlSource(_cachedFilePath!),
            );
          }
        });
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  getDuration() async {
    duration = (await _audioPlayer.getDuration())!;
    position = (await _audioPlayer.getCurrentPosition())!;
    setState(() {});
  }

  getPosition() async {
    setState(() {});
  }

  String getReverseDuration(Duration position, Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds - position.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getInitialDurationnText(Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // log
    var size = MediaQuery.of(context).size;
    log('mobile wid ${size.width}');
    double padding = 0;
    if (widget.isSecondPost && size.width >= 412) {
      padding = 40;
    } else {
      padding = 0;
    }
    // getDuration();

    return SizedBox(
      height: size.height * 0.2,
      width: widget.isFirstPost ? size.width * 0.665 : size.width * 0.335,
      child: ClipRRect(
        child: Stack(
          children: [
            SizedBox(
              height: size.height * 0.2,
              width:
                  widget.isFirstPost ? size.width * 0.665 : size.width * 0.335,
              child: widget.note.backgroundImage.isNotEmpty
                  ? widget.note.backgroundType.contains('video')
                      ? CachedNetworkImage(
                          imageUrl: widget.note.videoThumbnail,
                          fit: BoxFit.cover,
                        )
                      // ThumbnailVideoPlayer(
                      //     videoUrl: widget.note.backgroundImage,
                      //     height: size.height * 0.2,
                      //     width: widget.isFirstPost
                      //         ? size.width * 0.665
                      //         : size.width * 0.335)
                      // CustomVideoThumbnail(
                      //     videoUrl: widget.note.backgroundImage,
                      //     height: size.height * 0.2,
                      //     width:
                      // widget.isFirstPost
                      //         ? size.width * 0.665
                      //         : size.width * 0.335,
                      //   )
                      : CachedNetworkImage(
                          imageUrl: widget.note.backgroundImage,
                          fit: BoxFit.cover,
                        )
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.note.userUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserModel user =
                              UserModel.fromMap(snapshot.data!.data()!);
                          return CachedNetworkImage(
                            imageUrl: user.photoUrl,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Image.network(
                            widget.note.photoUrl,
                            fit: BoxFit.cover,
                          );
                        }
                      }),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                height: size.height * 0.2,
                width:
                    widget.isFirstPost ? size.width * 0.67 : size.width * 0.34,
                color: Colors.white.withOpacity(0.1), // Transparent color
              ),
            ),
            // Container(
            //   height: size.height * 0.2,
            //   width: widget.isFirstPost ? size.width * 0.67 : size.width * 0.34,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       // stops: [0.75, 0.25],
            //       colors: [
            //         const Color(0xff3d3d3d).withOpacity(0.5),
            //         whiteColor
            //       ],
            //     ),
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 20, // Same height as the pin icon
                      alignment: Alignment.center,
                      child: widget.isPinned && !widget.isFirstPost
                          ? null
                          : Text(
                              widget.note.title.toUpperCase(),
                              style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 10,
                                  color: whiteColor,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                    if (widget.isPinned && !widget.isFirstPost)
                      Positioned(
                        left: size.width * 0.153,
                        top: 10,
                        child: Icon(
                          Icons.push_pin,
                          color: whiteColor,
                          size: 11,
                        ),
                      ),
                  ],
                ),
                // if (widget.isPinned && !widget.isFirstPost)
                //   Icon(
                //     Icons.push_pin,
                //     color: whiteColor,
                //     size: 11,
                //   )
                // else
                //   Text(
                //     widget.note.title.toUpperCase(),
                //     style: TextStyle(
                //         fontFamily: fontFamily,
                //         fontSize: 10,
                //         color: whiteColor,
                //         fontWeight: FontWeight.w700),
                //   ),
                if (widget.isFirstPost)
                  CustomProgressPlayer(
                      lockPosts: widget.lockPosts,
                      postId: widget.note.noteId,
                      backgroundColor: Colors.transparent,
                      stopMainPlayer: () {},
                      mainWidth: size.width >= 412
                          ? MediaQuery.of(context).size.width * 0.45
                          : MediaQuery.of(context).size.width * 0.55,
                      mainHeight: 82,
                      height: 50,
                      isProfilePlayer: true,
                      width: widget.lockPosts.contains(0) ? 67 : 70,
                      isMainPlayer: true,
                      title: widget.note.title,
                      waveColor: primaryColor,
                      noteUrl: widget.note.noteUrl)
                else
                  Align(
                    alignment: Alignment.center,
                    child: CircularPercentIndicator(
                      radius: 35.0,
                      lineWidth: 8.0,
                      percent: position.inSeconds / duration.inSeconds,
                      center: widget.lockPosts.contains(widget.index)
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubscribeScreen(),
                                    ));
                              },
                              child: Container(
                                  // height: 10,
                                  // width: 10,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: SvgPicture.asset(
                                    'assets/icons/Lock.svg',
                                    color: primaryColor,
                                  )),
                            )
                          : InkWell(
                              splashColor: Colors.transparent,
                              onTap: playPause,
                              child: Container(
                                // height: 10,
                                // width: 10,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor:
                          _isPlaying ? const Color(0xFFB8C7CB) : primaryColor,
                      progressColor: primaryColor,
                      animation: _isPlaying,
                      animationDuration: duration.inSeconds,
                    ),
                  ),

                // CircularPercentIndicator(
                //   radius: 44,
                //   // 44.0,
                //   lineWidth: 5.0,
                //   percent: position.inSeconds / duration.inSeconds,
                //   center: Container(
                //     width: 40,
                //     height: 40,
                //     decoration: BoxDecoration(
                //       color: whiteColor,
                //       borderRadius: BorderRadius.circular(140),
                //     ),
                //     child:
                // widget.lockPosts.contains(widget.index)
                //         ? InkWell(
                //             onTap: () {
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) => SubscribeScreen(),
                //                   ));
                //             },
                //             child: Container(
                //                 // height: 10,
                //                 // width: 10,
                //                 padding: const EdgeInsets.all(8),
                //                 decoration: BoxDecoration(
                //                     color: primaryColor,
                //                     borderRadius: BorderRadius.circular(20)),
                //                 child:
                //                     SvgPicture.asset('assets/icons/Lock.svg')),
                //           )
                //         : InkWell(
                //             splashColor: Colors.transparent,
                //             onTap: playPause,
                //             child: Container(
                //               // height: 10,
                //               // width: 10,
                //               padding: const EdgeInsets.all(8),
                //               decoration: BoxDecoration(
                //                   color: primaryColor,
                //                   borderRadius: BorderRadius.circular(20)),
                //               child: Icon(
                //                 _isPlaying ? Icons.pause : Icons.play_arrow,
                //                 color: whiteColor,
                //                 size: 20,
                //               ),
                //             ),
                //           ),
                //   ),
                //   circularStrokeCap: CircularStrokeCap.round,
                //   backgroundColor: _isPlaying ? whiteColor : primaryColor,
                //   progressColor: primaryColor,
                //   animation: _isPlaying,
                //   animationDuration: duration.inSeconds,
                // ),

                if (widget.index != 0)
                  position.inSeconds == 0
                      ? Text(
                          getInitialDurationnText(duration),
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: whiteColor),
                        )
                      : Text(
                          getReverseDuration(position, duration),
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: whiteColor),
                        )
                else
                  Text(
                    '',
                    style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: whiteColor),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
