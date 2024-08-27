import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/view/select_topic_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:path/path.dart' as path;

class SingleDraft extends StatefulWidget {
  const SingleDraft(
      {super.key,
      required this.file,
      required this.userImage,
      required this.thumbnailPath,
      required this.isGalleryThumbnail,
      required this.backImage});
  final String userImage;
  final String file;
  final String backImage;
  final String thumbnailPath;
  final bool isGalleryThumbnail;

  // getting the required from the constructor

  @override
  State<SingleDraft> createState() => _SingleDraftState();
}

class _SingleDraftState extends State<SingleDraft> {
  //  checking the background is image or not
  bool isImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('image') ||
        lowerUrl.contains('jpg') ||
        lowerUrl.contains('jpeg') ||
        lowerUrl.contains('png') ||
        lowerUrl.contains('gif');
  }

  //  checking the background is video or not

  bool isVideo(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return false;

    final lastSegment = pathSegments.last;
    final extensionIndex = lastSegment.lastIndexOf('.');
    if (extensionIndex == -1) return false;

    final extension = lastSegment.substring(extensionIndex).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.wmv', '.flv'].contains(extension);
  }

  late AudioPlayer player;
  bool isPlaying = false;
  String? _cachedFilePath;
  // final waveformExtractor = WaveformExtractor();
  List<double> waveForm = [];
  // int? _currentIndex;
  // var _player = AudioPlayer();
  // bool isPlaying = false;
  bool isBuffering = false;
  // double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

// initialzing the player and getting the duration and position

  initPlayer() async {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    player.setSourceDeviceFile(widget.file).then((value) {});
    player.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    player.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    //  caching the voice

    DefaultCacheManager().getFileFromCache(widget.file).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });

    //   on completing changing the value of the  play pause

    player.onPlayerComplete.listen((state) {
      setState(() {
        isPlaying = false;
      });
    });

    //  updating the player state change

    player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
          // widget.isPlaying = widget.isPlaying;
        });
      } else {
        setState(() {
          isPlaying = false;
          // widget.isPlaying = widget.isPlaying;
        }); // Notify parent widget
      }
    });
  }

  @override
  void initState() {
    super.initState();

    //  initilzing the player to get the duration and position

    initPlayer();
  }

  //  play pause function to play the voice

  playAudio() async {
    try {
      if (isPlaying) {
        player.stop();
        setState(() {
          isPlaying = false;
        });
      } else {
        player.play(DeviceFileSource(widget.file));
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  //  disposing the player after no longer needed

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isImag = isImage(widget.backImage);
    bool isVide = isVideo(widget.backImage);

    log('isImage $isImag isVideo $isVide');

    return SizedBox(
      height: 121,
      width: 121,
      child: Stack(
        children: [
          //  getting the background of the draft post

          SizedBox(
            height: 121,
            width: 121,
            child: GestureDetector(
              onLongPress: () {},
              onTap: () {
                //  pushing to select topic screen for adding the post

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectTopicScreen(
                        type: isImage(widget.backImage) ? 'photo' : 'video',
                        backImage: widget.backImage,
                        title: '',
                        taggedPeople: [],
                        path: widget.file,
                      ),
                    ));
              },

              //  if the thumbnail is not empty show the thumbnail
              child: widget.thumbnailPath.isNotEmpty
                  ? Image.file(
                      File(widget.thumbnailPath),
                      fit: BoxFit.cover,
                    )

                  //  otherwise show photo or video as back

                  : widget.backImage.isNotEmpty
                      ? Container(
                          child: isImage(widget.backImage)
                              ? Image.network(
                                  widget.backImage,
                                  fit: BoxFit.cover,
                                )
                              : CustomVideoPlayer(
                                  isDraftPlayer: true,
                                  videoUrl: widget.backImage,
                                  height: 121,
                                  width: 121),
                        )

                      //  if none of the back exist then show the profile pic
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
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
                                widget.userImage,
                                fit: BoxFit.cover,
                              );
                            }
                          }),
            ),
          ),
          const SizedBox(),
          Align(
            alignment: Alignment.center,

            //  show the percent bar of the voice

            child: CircularPercentIndicator(
              radius: 35.0,
              lineWidth: 8.0,
              percent: position.inSeconds / duration.inSeconds,
              center: InkWell(
                splashColor: Colors.transparent,
                onTap: playAudio,
                child: Container(
                  // height: 10,
                  // width: 10,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,

              //  showing the percent colors

              backgroundColor:
                  isPlaying ? const Color(0xFFB8C7CB) : primaryColor,
              progressColor: primaryColor,
              animation: isPlaying,
              animationDuration: duration.inSeconds,
            ),
          )
        ],
      ),
    );
  }
}
