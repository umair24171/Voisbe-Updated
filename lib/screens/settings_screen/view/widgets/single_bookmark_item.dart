import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class SingleBookMarkItem extends StatefulWidget {
  const SingleBookMarkItem({super.key, required this.note});
  final NoteModel note;

  //  getting the note model through constructor

  @override
  State<SingleBookMarkItem> createState() => _SingleBookMarkItemState();
}

class _SingleBookMarkItemState extends State<SingleBookMarkItem> {
  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // Default playback speed
  PlayerState? _playerState;

  @override
  void initState() {
    // initializing the audio player

    initPlayer();
    super.initState();
  }

  // initializing the audio player and getting and managing the duration and position of the audio player

  initPlayer() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(widget.note.noteUrl);
    _playerState = _audioPlayer.state;

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

  //  disposing when no longer needed

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  //  play pause the audio

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
            .downloadFile(widget.note.noteUrl)
            .then((fileInfo) {
          if (fileInfo.file.existsSync()) {
            _cachedFilePath = fileInfo.file.path;
            _audioPlayer.setPlaybackRate(_playbackSpeed); // Set playback speed
            _audioPlayer.play(
              Platform.isAndroid ? UrlSource(_cachedFilePath!) : UrlSource(widget.note.noteUrl),
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
  // AudioPlayer _audio = AudioPlayer();
  // PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: 121,
      width: 121,
      child: Stack(
        children: [
          SizedBox(
            height: 121,
            width: 121,
            child: GestureDetector(
              onLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(note: widget.note),
                  ),
                );
              },
              onTap: () {},

              //  getting the background of the post

              child: widget.note.backgroundImage.isNotEmpty
                  ? widget.note.backgroundType.contains('video')
                      ? CustomVideoPlayer(
                          videoUrl: widget.note.backgroundImage,
                          height: 121,
                          width: 121,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.note.backgroundImage,
                          fit: BoxFit.cover,
                        )

                  //  getting post owner pic if the background of the post is empty

                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.note.userUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserModel user =
                              UserModel.fromMap(snapshot.data!.data()!);
                          return Image.network(
                            user.photoUrl,
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
          ),
          const SizedBox(),

          //  calling play pause function

          Align(
            alignment: Alignment.center,
            child: CircularPercentIndicator(
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
                    color: Color(widget.note.topicColor.value),
                    size: 20,
                  ),
                ),
              ),

              //  managing the duration and progress of the  of book mark post

              circularStrokeCap: CircularStrokeCap.round,

              backgroundColor: _isPlaying
                  ? const Color(0xFFB8C7CB)
                  : Color(widget.note.topicColor.value),
              progressColor: Color(widget.note.topicColor.value),
              animation: _isPlaying,
              animationDuration: duration.inSeconds,
            ),
          )
        ],
      ),
    );
  }
}
