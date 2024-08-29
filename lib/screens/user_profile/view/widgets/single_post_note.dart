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

  //  getting all the data from the constructor

  @override
  State<SinglePostNote> createState() => _SinglePostNoteState();
}

class _SinglePostNoteState extends State<SinglePostNote> {
  //  creating the instance of the audio playeer

  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // preloadThumbnails();

    //  initializing the audio player

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    //  setting the url to play

    _audioPlayer.setSourceUrl(widget.note.noteUrl);
    // Check if the file is already cached

    //  saving in the cached

    DefaultCacheManager().getFileFromCache(widget.note.noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });

    //  setting the duration

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    //  setting the position

    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    //  changing the player on completion

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

// disposing it when no longer needs \

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  //  playing and pause the audio with the caching

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

  //  getting duruation of the  voice

  getDuration() async {
    duration = (await _audioPlayer.getDuration())!;
    position = (await _audioPlayer.getCurrentPosition())!;
    setState(() {});
  }

  getPosition() async {
    setState(() {});
  }

  //  setting format of duration to play

  String getReverseDuration(Duration position, Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds - position.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

//  initially duration of the audio

  String getInitialDurationnText(Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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

              //  background of the post

              child: widget.note.backgroundImage.isNotEmpty

                  //  if its video show the thumbnail
                  ? widget.note.backgroundType.contains('video')
                      ? CachedNetworkImage(
                          imageUrl: widget.note.videoThumbnail,
                          fit: BoxFit.cover,
                        )

                      //  other wise show the image

                      : CachedNetworkImage(
                          imageUrl: widget.note.backgroundImage,
                          fit: BoxFit.cover,
                        )

                  //  showing the profile pic of the user

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

            //  backdrop filter above the photo or video

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                height: size.height * 0.2,
                width:
                    widget.isFirstPost ? size.width * 0.67 : size.width * 0.34,
                color: Colors.white.withOpacity(0.1), // Transparent color
              ),
            ),

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

                      //  if posts are pinned show the pinne icon other wise show the title of the post

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

                //  if the post index is 0 show this player

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
                      width: widget.lockPosts.contains(0) ? 67 : 67,
                      isMainPlayer: true,
                      title: widget.note.title,
                      waveColor: primaryColor,
                      noteUrl: widget.note.noteUrl)
                else

                  //  otherwise show this percent bar player

                  Align(
                    alignment: Alignment.center,
                    child: CircularPercentIndicator(
                      radius: 35.0,
                      lineWidth: 8.0,
                      percent: position.inSeconds / duration.inSeconds,
                      center: widget.lockPosts.contains(widget.index)

                          //  if any of the post is lock post show icon lock and naviagte to subscribe screen

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

                          //  otherwise show the play pause button

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
                      backgroundColor: _isPlaying ? whiteColor : whiteColor,
                      progressColor: _isPlaying ? primaryColor : whiteColor,
                      animation: _isPlaying,

                      // fillColor: whiteColor,
                      animationDuration: duration.inSeconds,
                    ),
                  ),

                //  showing the duration and position when the post is playing

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
