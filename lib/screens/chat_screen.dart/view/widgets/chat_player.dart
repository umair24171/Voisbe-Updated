// import 'dart:developer';

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:flutter/widgets.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
import 'package:social_notes/resources/colors.dart';

class ChatPlayer extends StatefulWidget {
  ChatPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      this.backgroundColor = Colors.white,
      this.isShare = false,
      this.isOtherMsg = false,
      this.size = 35,
      this.waveColor})
      : super(key: key);

  final String noteUrl;
  final double height;
  final double width;
  final double mainWidth;
  final double mainHeight;
  final Color backgroundColor;
  double size;
  bool isOtherMsg;

  Color? waveColor;
  bool isShare;

  @override
  State<ChatPlayer> createState() => _ChatPlayerState();
}

class _ChatPlayerState extends State<ChatPlayer> {
  final _player = AudioPlayer();
  bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
    _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
          // duration = Duration.zero;
          // position = Duration.zero;
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

  @override
  Widget build(BuildContext context) {
    // _playerState = _audioPlayer.;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        alignment: Alignment.center,
        height: widget.mainHeight,
        width: widget.mainWidth,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(55),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (isPlaying) {
                  stopAudio();
                } else {
                  playAudio();
                }
              },
              icon: isPlaying
                  ? Icon(
                      Icons.pause_circle_filled,
                      color: widget.waveColor ?? Colors.red,
                      size: widget.size,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: widget.waveColor ?? Colors.red,
                          size: widget.size,
                        ),
                      ],
                    ),
            ),
            SizedBox(
              height: widget.height,
              width: widget.width,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: duration,
                builder: (context, progress, child) {
                  final color = duration.inSeconds > 0
                      ? Color.lerp(primaryColor, Colors.black,
                          position.inSeconds / duration.inSeconds)!
                      : primaryColor;
                  return WaveformProgressbar(
                    color: widget.waveColor == null
                        ? primaryColor.withOpacity(0.5)
                        : widget.waveColor!.withOpacity(0.5),
                    progressColor:
                        widget.waveColor == null ? color : widget.waveColor!,
                    progress: position.inSeconds /
                        duration
                            .inSeconds, // Stop progressing when audio is loaded
                    onTap: (progress) {
                      Duration seekPosition = Duration(
                          seconds: (progress * duration.inSeconds).round());
                      _player.seek(seekPosition);
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                position.inSeconds == 0
                    ? Text(
                        getInitialDurationnText(duration),
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: widget.waveColor ?? primaryColor,
                        ),
                      )
                    : Text(
                        getReverseDuration(position, duration),
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: widget.waveColor ?? primaryColor,
                        ),
                      ),
                // if (widget.waveColor == null)
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
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                        color: widget.isShare
                            ? whiteColor
                            : widget.isOtherMsg
                                ? whiteColor
                                : primaryColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${_playbackSpeed}X',
                      style: TextStyle(
                        color: widget.isShare
                            ? Colors.grey
                            : widget.isOtherMsg
                                ? primaryColor
                                : whiteColor,
                        fontFamily: fontFamily,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
