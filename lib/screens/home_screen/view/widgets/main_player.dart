// import 'dart:developer';

import 'dart:async';
import 'dart:developer';
// import 'dart:developer';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:general_audio_waveforms/general_audio_waveforms.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';

class MainPlayer extends StatefulWidget {
  MainPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      required this.playPause,
      this.backgroundColor = Colors.white,
      this.size = 35,
      this.isComment = false,
      this.isMainPlayer = false,
      this.commentId,
      this.postId,
      this.playedCounter,
      this.pageController,
      required this.isPlaying,
      required this.duration,
      required this.currentIndex,
      required this.audioPlayer,
      required this.changeIndex,
      required this.position,
      required this.waveformData,
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
  PageController? pageController;
  final List<double> waveformData;

  bool isPlaying;
  final AudioPlayer audioPlayer;
  final Duration position;
  int changeIndex;
  VoidCallback playPause;
  Duration duration;

  int currentIndex;
  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  Duration elapsedDuration = Duration.zero;
  // late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  // bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  // Duration duration = Duration.zero;
  // Duration position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  PlayerState? _playerState;

  @override
  void initState() {
    // widget.playPause();

    // _audioPlayer = AudioPlayer();
    // initPlayer();
    // SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {

    // });
    // _playerStateChangeSubscription =
    //     _audioPlayer.onPlayerStateChanged.listen((state) {
    //   setState(() {
    //     _playerState = state;
    //   });
    // });
    // _initStreams();

    super.initState();
  }

  @override
  void dispose() {
    widget.duration = Duration.zero;
    super.dispose();
  }

  // autoPlay() {
  //   if (widget.currentIndex == widget.pageController!.page!.round()) {
  //     if (_cachedFilePath != null) {
  //       _audioPlayer.setPlaybackRate(_playbackSpeed);
  //       _audioPlayer.play(UrlSource(_cachedFilePath!));
  //       // _updatePlayedComment();
  //     } else {
  //       DefaultCacheManager().downloadFile(widget.noteUrl).then((fileInfo) {
  //         if (fileInfo != null && fileInfo.file.existsSync()) {
  //           _cachedFilePath = fileInfo.file.path;
  //           _audioPlayer.setPlaybackRate(_playbackSpeed);
  //           _audioPlayer.play(
  //             UrlSource(_cachedFilePath!),
  //           );
  //         }
  //       });
  //     }
  //     widget.isPlaying = true;
  //     _isPlaying = true;
  //     // setState(() {
  //     //   _isPlaying = true;
  //     // });
  //   } else {
  //     _audioPlayer.pause();
  //     widget.isPlaying = false;
  //     _isPlaying = false;

  //     // setState(() {
  //     //   _isPlaying = false;
  //     // });
  //   }
  // }

  // initPlayer() async {
  //   // _audioPlayer = AudioPlayer();
  //   // _audioPlayer.setReleaseMode(ReleaseMode.stop);
  //   await widget.audioPlayer.setSourceUrl(widget.noteUrl).then((value) async {
  //     await widget.audioPlayer.getDuration().then(
  //           (value) => setState(() {
  //             duration = value!;
  // if (widget.currentIndex == widget.changeIndex) {
  //   widget.playPause();
  // }
  //           }),
  //         );
  //   });

  //   // _audioPlayer.setReleaseMode(ReleaseMode.stop);

  //   // Check if the file is already cached
  //   DefaultCacheManager().getFileFromCache(widget.noteUrl).then((file) {
  //     if (file != null && file.file.existsSync()) {
  //       _cachedFilePath = file.file.path;
  //     }
  //   });
  //   // _audioPlayer.getCurrentPosition().then(
  //   //       (value) => setState(() {
  //   //         position = value!;
  //   //       }),
  //   //     );
  //   widget.audioPlayer.onDurationChanged.listen((event) {
  //     setState(() {
  //       duration = event;
  //     });
  //   });
  //   // _audioPlayer.onPositionChanged.listen((event) {
  //   //   setState(() {
  //   //     position = event;
  //   //   });
  //   // });

  //   // _audioPlayer.onPlayerComplete.listen((state) {
  //   //   setState(() {
  //   //     _isPlaying = false;
  //   //     widget.isPlaying = _isPlaying;
  //   //   });
  //   // });

  //   // _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
  //   //   if (state == PlayerState.playing) {
  //   //     setState(() {
  //   //       _isPlaying = true;
  //   //       widget.isPlaying = _isPlaying;
  //   //     });
  //   //   } else {
  //   //     setState(() {
  //   //       _isPlaying = false;
  //   //       // widget.isPlaying = _isPlaying;
  //   //     }); // Notify parent widget
  //   //   }
  //   // });
  // }

  // void _initStreams() {
  //   _durationSubscription = widget.audioPlayer.onDurationChanged.listen((duration) {
  //     setState(() => duration = duration);
  //   });

  //   _positionSubscription = widget.audioPlayer.onPositionChanged.listen(
  //     (p) => setState(() => position = p),
  //   );

  //   _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
  //     setState(() {
  //       _playerState = PlayerState.stopped;
  //       position = Duration.zero;
  //       widget.isPlaying = false;
  //       _isPlaying = false;
  //     });
  //   });

  //   _playerStateChangeSubscription =
  //       _audioPlayer.onPlayerStateChanged.listen((state) {
  //     setState(() {
  //       _playerState = state;
  //     });
  //   });
  // }

  // void _updatePlayedComment() {
  //   if (widget.isComment) {
  //     int updateCommentCounter = widget.playedCounter ?? 0;
  //     updateCommentCounter++;
  //     FirebaseFirestore.instance
  //         .collection('notes')
  //         .doc(widget.postId)
  //         .collection('comments')
  //         .doc(widget.commentId)
  //         .update({'playedComment': updateCommentCounter});
  //   }
  // }

  // @override
  // void dispose() {
  //   _audioPlayer.dispose();
  //   _playerStateChangeSubscription?.cancel();
  //   _playerCompleteSubscription?.cancel();
  //   _positionSubscription?.cancel();
  //   _durationSubscription?.cancel();

  //   super.dispose();
  // }

  // void playPause() async {
  //   if (_audioPlayer.state == PlayerState.playing) {
  //     await _audioPlayer.pause();
  //   } else {
  //     if (_cachedFilePath != null) {
  //       await _audioPlayer.setPlaybackRate(_playbackSpeed);
  //       await _audioPlayer.play(UrlSource(_cachedFilePath!));
  //       // _updatePlayedComment();
  //     } else {
  //       DefaultCacheManager().downloadFile(widget.noteUrl).then((fileInfo) {
  //         if (fileInfo != null && fileInfo.file.existsSync()) {
  //           _cachedFilePath = fileInfo.file.path;
  //           _audioPlayer.setPlaybackRate(_playbackSpeed);
  //           _audioPlayer.play(
  //             UrlSource(_cachedFilePath!),
  //           );
  //         }
  //       });
  //     }
  //   }
  //   setState(() {
  //     _isPlaying = !_isPlaying;
  //     _playerState = _isPlaying ? PlayerState.playing : PlayerState.paused;
  //     widget.isPlaying = _isPlaying;
  //   });
  // }

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

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     // Release the player's resources when not in use. We use "stop" so that
  //     // if the app resumes later, it will still remember what position to
  //     // resume from.
  //     _player.stop();
  //   }
  // }

  // @override
  // void dispose() {
  //   _audioPlayer.dispose();
  //   super.dispose();
  // }

  // Stream<PositionData> get _positionDataStream =>
  //     Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
  //         _player.positionStream,
  //         _player.bufferedPositionStream,
  //         _player.durationStream,
  //         (position, bufferedPosition, duration) => PositionData(
  //             position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    log('Waveform: ${widget.duration.inSeconds}');
    // checkAutoPlay();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Center(
        child: Container(
          height: widget.mainHeight,
          width: widget.mainWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(55),
          ),
          child: Row(
            children: [
              // if (widget.isMainPlayer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: widget.playPause,
                  child: Consumer<FilterProvider>(
                      builder: (context, filterPro, _) {
                    return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              filterPro.selectedFilter.contains('Close Friends')
                                  ? greenColor
                                  : widget.waveColor ?? primaryColor,
                          // border: Border.all(
                          //   color: widget.waveColor ?? primaryColor,
                          //   width: 2,
                          // ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        // onPressed: playPause,
                        child: widget.isPlaying &&
                                widget.currentIndex == widget.changeIndex
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
              ),
              // else
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: InkWell(
              //       splashColor: Colors.transparent,
              //       onTap: widget.playPause,
              //       child: Container(
              //         padding: const EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //           color: whiteColor,
              //           borderRadius: BorderRadius.circular(50),
              //         ),
              //         // onPressed: playPause,
              //         child:
              //             // ? Icon(
              //             //     Icons.pause,
              //             //     color: widget.backgroundColor,
              //             //     size: widget.size,
              //             //   )
              //             // :
              //             Stack(
              //           alignment: Alignment.center,
              //           children: [
              //             Icon(
              //               Icons.play_arrow,
              //               color: widget.backgroundColor,
              //               size: widget.size,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child:
                      //  TweenAnimationBuilder<double>(
                      //   tween: Tween<double>(begin: 0.0, end: 1.0),
                      //   duration: duration,
                      //   builder: (context, tweenProgress, child) {
                      //     double progress = position.inSeconds / duration.inSeconds;
                      //     final color = duration.inSeconds > 0
                      //         ? Color.lerp(primaryColor, Colors.black, progress)!
                      //         : primaryColor;
                      //     return
                      Consumer<FilterProvider>(
                          builder: (context, filterPro, _) {
                    return WaveformWidget(waveform: widget.waveformData);
                    // Padding(

                    //   padding: const EdgeInsets.only(bottom: 90),
                    //   child: PolygonWaveform(
                    //     maxDuration: const Duration(seconds: 500),

                    //     elapsedDuration: elapsedDuration,
                    //     samples: widget.waveformData,
                    //     activeColor: primaryColor,
                    //     style: PaintingStyle.stroke,
                    //     // absolute: bool.fromEnvironment(''),

                    //     inactiveColor: primaryColor.withOpacity(0.5),
                    //     showActiveWaveform: true,
                    //     height: 140,
                    //     width: 140,
                    //   ),
                    // );
                    // WaveformProgressbar(
                    //   color: filterPro.selectedFilter.contains('Close Friends')
                    //       ? greenColor.withOpacity(0.5)
                    //       : widget.isMainPlayer
                    //           ? primaryColor.withOpacity(0.5)
                    //           : widget.waveColor!.withOpacity(0.5),
                    //   // widget.waveColor == null
                    //   //     ? primaryColor
                    //   //     : widget.waveColor!,
                    //   progressColor:
                    //       filterPro.selectedFilter.contains('Close Friends')
                    //           ? greenColor
                    //           : widget.isMainPlayer
                    //               ? primaryColor
                    //               : widget.waveColor ?? primaryColor,
                    //   // widget.waveColor == null
                    //   //     ? greenColor
                    //   //     : widget.waveColor!,
                    //   progress: widget.changeIndex == widget.currentIndex &&
                    //           widget.isPlaying
                    //       ? widget.position.inSeconds /
                    //           widget.duration.inSeconds
                    //       : 0.0,
                    //   onTap: (progress) {
                    //     // if (_cachedFilePath != null) {
                    //     Duration seekPosition = Duration(
                    //         seconds:
                    //             (progress * widget.duration.inSeconds).round());
                    //     // Duration seekPosition =
                    //     //     Duration(seconds: progress.toInt());
                    //     widget.audioPlayer.seek(seekPosition);
                    //     // }
                    //   },
                    // );
                  })
                  //     CustomPaint(
                  //   painter: PlayerWavePainter(
                  //     waveformData: doubleWaveformData.map((e) => e / 1).toList(),
                  //     showTop: true,
                  //     showBottom: true,
                  //     animValue: 1,
                  //     scaleFactor: 2,
                  //     waveColor: widget.waveColor ?? primaryColor,
                  //     waveCap: StrokeCap.round,
                  //     waveThickness: 2,
                  //     dragOffset: const Offset(-30, 6),
                  //     totalBackDistance: Offset.zero,
                  //     spacing: 4,
                  //     audioProgress: position.inSeconds /
                  //         duration.inSeconds /
                  //         duration.inSeconds,
                  //     liveWaveColor: greenColor,
                  //     pushBack: () {},
                  //     callPushback: false,
                  //     scrollScale: 1,
                  //     seekLineThickness: 2.0,
                  //     seekLineColor: primaryColor,
                  //     showSeekLine: false,
                  //     waveformType: audi.WaveformType.fitWidth,
                  //     cachedAudioProgress:
                  //         position.inSeconds / duration.inSeconds,
                  //     liveWaveGradient: null,
                  //     fixedWaveGradient: null,
                  //   ),
                  // ),

                  //   },
                  // ),
                  ),
              const SizedBox(
                width: 10,
              ),
              Consumer<FilterProvider>(builder: (context, filterPro, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.position.inSeconds == 0
                        ? Text(
                            // '${duration.inSeconds ~/ 60}:${duration.inSeconds % 60}',
                            getInitialDurationnText(widget.duration),
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              color: filterPro.selectedFilter
                                      .contains('Close Friends')
                                  ? greenColor
                                  : widget.waveColor ?? primaryColor,
                            ),
                          )
                        : Text(
                            widget.changeIndex == widget.currentIndex &&
                                    widget.isPlaying
                                ? getReverseDuration(
                                    widget.position, widget.duration)
                                : getInitialDurationnText(widget.duration),
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              color: filterPro.selectedFilter
                                      .contains('Close Friends')
                                  ? greenColor
                                  : widget.waveColor ?? primaryColor,
                            ),
                          ),
                    const SizedBox(height: 5),
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
                            if (widget.isPlaying) {
                              widget.audioPlayer
                                  .setPlaybackRate(_playbackSpeed);
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
                              '${_playbackSpeed.toDouble()}X',
                              // '',
                              style: TextStyle(
                                color: whiteColor,
                                fontFamily: fontFamily,
                                // fontWeight: FontWeight.w600,

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
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double waveHeight;
  final Shader? gradient;

  WaveformPainter({
    required this.waveform,
    this.waveHeight = 100.0,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final widthPerSample = size.width / waveform.length;

    for (int i = 0; i < waveform.length; i++) {
      final x = i * widthPerSample;
      final y = size.height / 2 - (waveform[i] * waveHeight);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class WaveformWidget extends StatelessWidget {
  final List<double> waveform;

  WaveformWidget({required this.waveform});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: WaveformPainter(
        waveform: waveform,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, double.infinity, 200)),
      ),
    );
  }
}
