// import 'dart:developer';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:waveform_extractor/waveform_extractor.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatPlayer extends StatefulWidget {
  ChatPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      this.backgroundColor = Colors.white,
      required this.playPause,
      this.isShare = false,
      this.isOtherMsg = false,
      required this.changeIndex,
      required this.currentIndex,
      required this.messageId,
      required this.player,
      required this.position,
      required this.isPlaying,
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
  AudioPlayer player;
  final Duration position;
  final int changeIndex;
  final int currentIndex;
  final bool isPlaying;
  final VoidCallback playPause;
  final String messageId;

  @override
  State<ChatPlayer> createState() => _ChatPlayerState();
}

class _ChatPlayerState extends State<ChatPlayer> {
  late AudioPlayer player;
  late ScrollController _scrollController;
  String? _cachedFilePath;
  final waveformExtractor = WaveformExtractor();
  List<double> waveForm = [];
  // final _player = AudioPlayer();
  // final audoPlayer = audo.AudioPlayer();
  // bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  // late audo.AudioPlayer player;

  // Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    player = AudioPlayer();
    // player = audo.AudioPlayer();
    extractWavedata();
    // _init();
    player.setReleaseMode(ReleaseMode.stop);
    player.setSourceUrl(widget.noteUrl).then((value) {
      // widget.player.getDuration().then(
      //       (value) => setState(() {
      //         duration = value!;
      //         // playPause();
      //       }),
      //     );
    });
    player.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
  }

  // Future<void> extractWavedata() async {
  //   final result =
  //       await waveformExtractor.extractWaveform(widget.noteUrl, useCache: true);
  //   List<int> waveForms = result.waveformData;
  //   setState(() {
  //     waveForm = waveForms.map((int e) => e < 1 ? 6.0 : e.toDouble()).toList();
  //   });
  // }
  Future<void> extractWavedata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cacheKey = widget.messageId;

    List<String>? cachedData = prefs.getStringList(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      waveForm = cachedData.map((e) => double.tryParse(e) ?? 6.0).toList();
      setState(() {
        waveForm = waveForm.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
      });
    } else {
      final result = await waveformExtractor.extractWaveform(
        widget.noteUrl,
        useCache: true,
        cacheKey: cacheKey,
      );
      List<int> waveForms = result.waveformData;

      setState(() {
        waveForm = waveForms.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
      });

      await prefs.setStringList(
          cacheKey, waveForms.map((e) => e.toString()).toList());
    }
  }

  void scrollToPosition(Duration position) {
    final progressPercent = position.inMilliseconds / duration.inMilliseconds;
    final targetScrollOffset =
        progressPercent * waveForm.length * widget.width - widget.width / 2;
    _scrollController.animateTo(
      targetScrollOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // widget.player.dispose();
    // duration = Duration.zero;
    // widget.position = Duration.zero;

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
                widget.playPause();
              },
              icon:
                  widget.isPlaying && widget.currentIndex == widget.changeIndex
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
                          widget.position.inSeconds / duration.inSeconds)!
                      : primaryColor;
                  return SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: GestureDetector(
                        onHorizontalDragStart: (details) {
                          final position = details.localPosition.dx /
                              widget.width *
                              duration.inMilliseconds;
                          final seekPosition =
                              Duration(milliseconds: position.toInt());
                          widget.player.seek(seekPosition);
                        },
                        onHorizontalDragEnd: (details) {
                          final position = details.localPosition.dx /
                              widget.width *
                              duration.inMilliseconds;
                          final seekPosition =
                              Duration(milliseconds: position.toInt());
                          widget.player.seek(seekPosition);
                        },
                        onTapUp: (details) {
                          final position = details.localPosition.dx /
                              widget.width *
                              duration.inMilliseconds;
                          final seekPosition =
                              Duration(milliseconds: position.toInt());
                          widget.player.seek(seekPosition);
                          scrollToPosition(seekPosition);
                        },
                        child: CustomPaint(
                          size: Size(widget.width, widget.height),
                          painter: RectangleActiveWaveformPainter(
                            onSeek: (p0) {
                              widget.player.seek(p0);
                            },
                            activeColor:
                                widget.changeIndex == widget.currentIndex &&
                                        widget.isPlaying
                                    ? widget.waveColor == null
                                        ? color
                                        : widget.waveColor!
                                    : widget.waveColor == null
                                        ? primaryColor.withOpacity(0.5)
                                        : widget.waveColor!.withOpacity(0.5),
                            inactiveColor: widget.waveColor == null
                                ? primaryColor.withOpacity(0.5)
                                : widget.waveColor!.withOpacity(0.5),
                            scrollController: _scrollController,
                            duration: duration,
                            position: widget.position,
                            style: PaintingStyle.fill,
                            activeSamples: waveForm,
                            borderColor: primaryColor.withOpacity(0.5),
                            sampleWidth: 2.5,
                            borderWidth: BorderSide.strokeAlignCenter,
                            color: widget.waveColor == null
                                ? primaryColor.withOpacity(0.5)
                                : widget.waveColor!.withOpacity(0.5),
                            isCentered: true,
                            isRoundedRectangle: true,
                            waveformAlignment: WaveformAlignment.center,
                          ),
                        ),
                      ),
                    ),
                  );
                  // return WaveformProgressbar(
                  //   color:
                  // widget.waveColor == null
                  //       ? primaryColor.withOpacity(0.5)
                  //       : widget.waveColor!.withOpacity(0.5),
                  //   progressColor:
                  //       widget.waveColor == null ? color : widget.waveColor!,
                  //   progress: position.inSeconds /
                  //       duration
                  //           .inSeconds, // Stop progressing when audio is loaded
                  //   onTap: (progress) {
                  //     Duration seekPosition = Duration(
                  //         seconds: (progress * duration.inSeconds).round());
                  //     _player.seek(seekPosition);
                  //   },
                  // );
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.position.inSeconds == 0
                    ? Text(
                        getInitialDurationnText(duration),
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: widget.waveColor ?? primaryColor,
                        ),
                      )
                    : Text(
                        widget.changeIndex == widget.currentIndex &&
                                widget.isPlaying
                            ? getReverseDuration(widget.position, duration)
                            : getInitialDurationnText(duration),
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
                      if (widget.isPlaying) {
                        widget.player.setPlaybackRate(_playbackSpeed);
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
