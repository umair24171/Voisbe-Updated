import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/bottom_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/search_screen/view/widgets/search_player.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:video_player/video_player.dart';

class SingleSearchItem extends StatefulWidget {
  const SingleSearchItem({
    super.key,
    required this.noteModel,
    // this.controller,
    required this.index,
  });
  final NoteModel noteModel;
  // final VideoPlayerController? controller;
  final int index;

  @override
  State<SingleSearchItem> createState() => _SingleSearchItemState();
}

class _SingleSearchItemState extends State<SingleSearchItem> {
  //  instance of the audio player

  late AudioPlayer _audioPlayer;

  //  cached file path of the audio player

  String? _cachedFilePath;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // Default playback speed
  PlayerState? _playerState;

  @override
  void initState() {
    // initializing  the audio player

    initPlayer();
    super.initState();
  }

  // initilizing the audio player  and getting the duration

  initPlayer() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(widget.noteModel.noteUrl);
    _playerState = _audioPlayer.state;

    // Check if the file is already cached
    DefaultCacheManager()
        .getFileFromCache(widget.noteModel.noteUrl)
        .then((file) {
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

  // disposing the audio player when no longer neeeded

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // play and pause the player

  void playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_cachedFilePath != null) {
        await _audioPlayer
            .setPlaybackRate(_playbackSpeed); // Set playback speed
        await _audioPlayer.play(UrlSource(_cachedFilePath!));
      } else {
        // Cache the file if not already cached
        DefaultCacheManager()
            .downloadFile(widget.noteModel.noteUrl)
            .then((fileInfo) {
          if (fileInfo.file.existsSync()) {
            _cachedFilePath = fileInfo.file.path;
            _audioPlayer.setPlaybackRate(_playbackSpeed); // Set playback speed
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.5,
      child: Stack(
        children: [
          //  background of the post

          SizedBox(
            height: size.height * 0.2,
            width: size.width * 0.5,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserProfile(
                          userId: widget.noteModel.userUid,
                        ),
                      ));
                },

                //  building the background

                child: _buildBackgroundContent(size)),
          ),

          //  gradient of the backgound

          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    stops: [
                      0.25,
                      0.75,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black26, Colors.transparent])),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //  showing username of the post owner realtime

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.noteModel.userUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel noteUser =
                          UserModel.fromMap(snapshot.data!.data()!);
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherUserProfile(userId: noteUser.uid),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Text(
                                    noteUser.name,
                                    style: TextStyle(
                                        color: whiteColor,
                                        fontFamily: fontFamily),
                                  ),
                                  if (noteUser.isVerified) verifiedIcon()
                                ],
                              )),
                        ),
                      );
                    } else {
                      return const Text('');
                    }
                  }),

              // showing the percent bar of the audio duration

              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 8.0,
                percent: position.inSeconds / duration.inSeconds,
                center: InkWell(
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
                      color: Color(widget.noteModel.topicColor.value),
                      size: 20,
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: _isPlaying
                    ? const Color(0xFFB8C7CB)
                    : Color(widget.noteModel.topicColor.value),
                progressColor: Color(widget.noteModel.topicColor.value),
                animation: _isPlaying,
                animationDuration: duration.inSeconds,
              ),

              //   getting the topic of the post

              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: size.width * 0.45,
                      decoration: BoxDecoration(
                          color: Color(widget.noteModel.topicColor.value),
                          borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: GradientText(
                        widget.noteModel.topic,
                        style: const TextStyle(fontSize: 11),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withAlpha(0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      // Text(
                      //   widget.noteModel.topic,
                      //   overflow: TextOverflow.ellipsis,
                      //   // textAlign: a,
                      //   style: TextStyle(
                      //       fontFamily: fontFamily,
                      //       fontSize: 11,
                      //       color: whiteColor),
                      // )
                    ),
                  ),
                  Positioned(
                      left: size.width * 0.29,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          Provider.of<BottomProvider>(context, listen: false)
                              .setCurrentIndex(1);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        note: widget.noteModel,
                                        // currentIndex: widget.index,
                                        // screenChange: 1,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                              color: whiteColor.withOpacity(1),
                              borderRadius: BorderRadius.circular(18)),

                          //  view post details screen

                          child: Text(
                            'View Post',
                            style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 11,
                                color:
                                    Color(widget.noteModel.topicColor.value)),
                          ),
                        ),
                      ))
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBackgroundContent(Size size) {
    //  if the background is photo or video show this

    if (widget.noteModel.backgroundImage.isNotEmpty) {
      if (widget.noteModel.backgroundType.contains('video')) {
        return CachedNetworkImage(
          imageUrl: widget.noteModel.videoThumbnail,
          fit: BoxFit.cover,
        );
      } else {
        return CachedNetworkImage(
          imageUrl: widget.noteModel.backgroundImage,
          fit: BoxFit.cover,
        );
      }
    } else {
      //  show the users profile pic if the background is empty

      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.noteModel.userUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel user = UserModel.fromMap(snapshot.data!.data()!);
            return CachedNetworkImage(
              imageUrl: user.photoUrl,
              fit: BoxFit.cover,
            );
          } else {
            return Image.network(
              widget.noteModel.photoUrl,
              fit: BoxFit.cover,
            );
          }
        },
      );
    }
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
