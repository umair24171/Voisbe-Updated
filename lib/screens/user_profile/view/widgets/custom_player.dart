// import 'dart:developer';

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
import 'package:social_notes/resources/colors.dart';

import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';

class CustomProgressPlayer extends StatefulWidget {
  CustomProgressPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      this.backgroundColor = Colors.white,
      this.size = 35,
      this.isComment = false,
      this.isMainPlayer = false,
      this.title,
      this.commentId,
      this.postId,
      this.stopOtherPlayer,
      this.playedCounter,
      this.currentIndex,
      this.isProfilePlayer = false,
      this.isReceivingMsg = false,
      this.isListView = false,
      this.isChatUserPlayer = false,
      this.isSubCommentPlayer = false,
      this.waveColor})
      : super(key: key);

  final String noteUrl;
  final double height;
  final double width;
  final double mainWidth;
  final double mainHeight;
  final Color backgroundColor;
  double size;
  int? playedCounter;
  Color? waveColor;
  bool isComment;
  String? commentId;
  String? postId;
  bool isMainPlayer;
  final Function(AudioPlayer)? stopOtherPlayer;
  int? currentIndex;
  String? title;
  bool isProfilePlayer;
  bool isChatUserPlayer;
  bool isSubCommentPlayer;
  bool isReceivingMsg;
  bool isListView;
  // bool isMe
  @override
  State<CustomProgressPlayer> createState() => _CustomProgressPlayerState();
}

class _CustomProgressPlayerState extends State<CustomProgressPlayer> {
  var _player = AudioPlayer();
  bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    //  _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _init();
    _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    _player.playingStream.listen((event) {
      if (event == true) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });
    if (widget.isMainPlayer && widget.stopOtherPlayer != null) {
      widget.stopOtherPlayer!(_player);
    }
  }

  Future<void> _init() async {
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(widget.noteUrl)))
          .then((value) {
        setState(() {
          duration = value!;
        });
      }); // Load a remote audio file and play.
      _player.durationStream.listen((value) {
        setState(() {
          duration = value!;
        });
      });
      _player.positionStream.listen((event) {
        setState(() {
          position = event;
        });
      });
      _player.processingStateStream.listen((event) {
        if (event == ProcessingState.loading) {
          setState(() {
            isBuffering = true;
          });
        } else {
          setState(() {
            isBuffering = false;
          });
        }
      });
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
  }

  playAudio() async {
    try {
      setState(() {
        isPlaying = true;
      });
      log("playing");
      final audioSource = LockCachingAudioSource(Uri.parse(widget.noteUrl));
      var da = await _player.setAudioSource(audioSource);

      await _player.play();
      _updatePlayedComment();
    } catch (e) {
      log(e.toString());
    }
  }

  stopAudio() async {
    setState(() {
      isPlaying = false;
    });
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    duration = Duration.zero;
    position = Duration.zero;

    super.dispose();
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

  void _updatePlayedComment() {
    if (widget.isComment) {
      int updateCommentCounter = widget.playedCounter ?? 0;
      updateCommentCounter++;
      FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .update({'playedComment': updateCommentCounter});
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('Waveform: $doubleWaveformData');
    // checkAutoPlay();
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: Center(
        child: Container(
          height: widget.mainHeight,
          width: widget.mainWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(55),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.title != null)
                widget.title!.isNotEmpty
                    ? Text(
                        widget.title!.toUpperCase(),
                        style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: primaryColor),
                      )
                    : SizedBox(),
              Padding(
                padding: EdgeInsets.symmetric(
                        vertical:
                            widget.title != null && widget.title!.isNotEmpty
                                ? 4
                                : 0)
                    .copyWith(
                        bottom: widget.title != null && widget.title!.isNotEmpty
                            ? 8
                            : 0),
                child: Row(
                  children: [
                    if (widget.isMainPlayer)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: isPlaying ? stopAudio : playAudio,
                          child: Consumer<FilterProvider>(
                              builder: (context, filterPro, _) {
                            return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: widget.isProfilePlayer
                                      ? primaryColor
                                      : filterPro.selectedFilter
                                              .contains('Close Friends')
                                          ? greenColor
                                          : widget.waveColor ?? primaryColor,
                                  // border: Border.all(
                                  //   color: widget.waveColor ?? primaryColor,
                                  //   width: 2,
                                  // ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                // onPressed: playPause,
                                child: isPlaying
                                    ? Icon(
                                        Icons.pause_outlined,
                                        color: whiteColor,
                                        size: 20,
                                      )
                                    // : _playerState == PlayerState.paused
                                    //     ?
                                    //  Icon(
                                    //     Icons.pause_outlined,
                                    //     color: whiteColor,
                                    //     size: 20,
                                    //   )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_arrow,
                                            color: whiteColor,
                                            size: 20,
                                          ),
                                        ],
                                      ));
                          }),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: isPlaying ? stopAudio : playAudio,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            // onPressed: playPause,
                            child: isPlaying
                                ? Icon(
                                    Icons.pause,
                                    color: widget.backgroundColor,
                                    size: widget.size,
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: widget.backgroundColor,
                                        size: widget.size,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: Consumer<FilterProvider>(
                            builder: (context, filterPro, _) {
                          return WaveformProgressbar(
                            color: widget.isProfilePlayer
                                ? primaryColor.withOpacity(0.5)
                                : filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? whiteColor.withOpacity(0.5)
                                    : widget.isMainPlayer
                                        ? primaryColor.withOpacity(0.5)
                                        : widget.waveColor!.withOpacity(0.5),
                            // widget.waveColor == null
                            //     ? primaryColor
                            //     : widget.waveColor!,
                            progressColor: widget.isProfilePlayer
                                ? primaryColor
                                : filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? whiteColor
                                    : widget.isMainPlayer
                                        ? primaryColor
                                        : widget.waveColor ?? primaryColor,
                            // widget.waveColor == null
                            //     ? greenColor
                            //     : widget.waveColor!,
                            progress: position.inSeconds / duration.inSeconds,
                            onTap: (progress) {
                              Duration seekPosition = Duration(
                                  seconds:
                                      (progress * duration.inSeconds).round());
                              // Duration seekPosition =
                              //     Duration(seconds: progress.toInt());
                              _player.seek(seekPosition);
                            },
                          );
                        })),
                    const SizedBox(
                      width: 10,
                    ),
                    Consumer<FilterProvider>(builder: (context, filterPro, _) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          position.inSeconds == 0
                              ? Text(
                                  getInitialDurationnText(duration),
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: widget.isSubCommentPlayer
                                        ? null
                                        : FontWeight.w600,
                                    fontSize: widget.isSubCommentPlayer
                                        ? 12
                                        : widget.isProfilePlayer
                                            ? 8
                                            : 10,
                                    color: widget.isChatUserPlayer
                                        ? whiteColor
                                        : widget.isProfilePlayer
                                            ? primaryColor
                                            : filterPro.selectedFilter
                                                    .contains('Close Friends')
                                                ? greenColor
                                                : widget.waveColor ??
                                                    primaryColor,
                                  ),
                                )
                              : Text(
                                  getReverseDuration(position, duration),
                                  style: TextStyle(
                                    fontWeight: widget.isSubCommentPlayer
                                        ? null
                                        : FontWeight.w600,
                                    fontFamily: fontFamily,
                                    fontSize: widget.isSubCommentPlayer
                                        ? 12
                                        : widget.isProfilePlayer
                                            ? 8
                                            : 10,
                                    color: widget.isChatUserPlayer
                                        ? whiteColor
                                        : widget.isProfilePlayer
                                            ? primaryColor
                                            : filterPro.selectedFilter
                                                    .contains('Close Friends')
                                                ? greenColor
                                                : widget.waveColor ??
                                                    primaryColor,
                                  ),
                                ),
                          if (widget.waveColor == null)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (_playbackSpeed == 1.0) {
                                    _playbackSpeed = 1.5;
                                  } else if (_playbackSpeed == 1.5) {
                                    _playbackSpeed = 2.0;
                                  } else {
                                    _playbackSpeed = 1.0;
                                  }
                                  // Set playback speed if audio is already playing
                                  if (isPlaying) {
                                    _player.setSpeed(_playbackSpeed);
                                  }
                                });
                              },
                              child: Consumer<FilterProvider>(
                                  builder: (context, filterPro, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: filterPro.selectedFilter
                                              .contains('Close Friends')
                                          ? greenColor
                                          : primaryColor,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Text(
                                    '${_playbackSpeed}X',
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontFamily: fontFamily,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      );
                    })
                  ],
                ),
              ),
              // Text('')
            ],
          ),
        ),
      ),
    );
  }
}
