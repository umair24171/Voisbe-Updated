import 'dart:io';
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

class NewDesignUserPost extends StatefulWidget {
  const NewDesignUserPost({
    super.key,
    required this.noteModel,
  });
  final NoteModel noteModel;

  @override
  State<NewDesignUserPost> createState() => _NewDesignUserPostState();
}

class _NewDesignUserPostState extends State<NewDesignUserPost> {
  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // Default playback speed
  PlayerState? _playerState;

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

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
            Platform.isAndroid ?  UrlSource(_cachedFilePath!) : UrlSource(widget.noteModel.noteUrl),
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
              child: widget.noteModel.backgroundImage.isNotEmpty
                  ? widget.noteModel.backgroundType.contains('video')
                      ? SearchPlayer(
                          videoUrl: widget.noteModel.backgroundImage,
                          height: size.height * 0.2,
                          width: size.width * 0.5,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.noteModel.backgroundImage,
                          fit: BoxFit.cover,
                        )
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.noteModel.userUid)
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
                            widget.noteModel.photoUrl,
                            fit: BoxFit.cover,
                          );
                        }
                      }),
            ),
          ),
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
                      return Text('');
                    }
                  }),
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
                        child: Text(
                          widget.noteModel.topic,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: a,
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 11,
                              color: whiteColor),
                        )),
                  ),
                  Positioned(
                      left: size.width * 0.29,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          Provider.of<BottomProvider>(context, listen: false)
                              .setCurrentIndex(1);
                          // Provider.of<BottomProvider>(context, listen: false)
                          //     .pageController
                          //     .jumpTo(1);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        note: widget.noteModel,
                                        // screenChange: 1,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                              color: whiteColor.withOpacity(1),
                              borderRadius: BorderRadius.circular(18)),
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
}
