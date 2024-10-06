// import 'dart:developer';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/widgets.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
import 'package:social_notes/resources/colors.dart';

import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:waveform_extractor/waveform_extractor.dart';
import 'package:http/http.dart' as http;

class RecordingPlayer extends StatefulWidget {
  RecordingPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      this.backgroundColor = Colors.white,
      // required this.changeIndex,
      // required this.playPause,
      this.size = 35,
      this.isMainPlayer = false,

      // required this.player,
      // required this.isPlaying,
      // required this.position,
      // this.stopOtherPlayer,

      this.waveColor})
      : super(key: key);

  final String noteUrl;
  final double height;
  final double width;
  final double mainWidth;
  final double mainHeight;
  final Color backgroundColor;
  double size;
  // int? playedCounter;
  Color? waveColor;
  // bool isComment;
  // String? commentId;
  // String? postId;
  bool isMainPlayer;
  // final Function(AudioPlayer)? stopOtherPlayer;
  // int currentIndex;
  // AudioPlayer player;
  // final VoidCallback playPause;
  // int changeIndex;
  // bool isPlaying;
  // Duration position;
  @override
  State<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends State<RecordingPlayer> {
  late ScrollController _scrollController;
  late AudioPlayer player;
  bool isPlaying = false;
  String? _cachedFilePath;
  final waveformExtractor = WaveformExtractor();
  List<double> samples = [];
  int totalSamples = 1000;
  List<double> waveForm = [];
  // int? _currentIndex;
  // var _player = AudioPlayer();
  // bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Duration postiion = Duration.zero;

  Future<void> extractWavedata() async {
    final result =
        await waveformExtractor.extractWaveform(widget.noteUrl, useCache: true);
    List<int> waveForms = result.waveformData;
    setState(() {
      waveForm = waveForms.map((int e) => e < 1 ? 3.0 : e.toDouble()).toList();
    });
  }

  // Duration position = Duration.zero;
  initPlayer() async {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    player.setSourceDeviceFile(widget.noteUrl).then((value) {});
    player.onDurationChanged.listen((event) {
      if (mounted) {
        setState(() {
          duration = event;
        });
      }
    });
    player.onPositionChanged.listen((event) {
      if (mounted) {
        setState(() {
          postiion = event;
        });
      }
    });

    // widget.player.setReleaseMode(ReleaseMode.stop);

    // Check if the file is already cached
    DefaultCacheManager().getFileFromCache(widget.noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });

    player.onPlayerComplete.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });

    player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        } // Notify parent widget
      }
    });
  }

  Future<void> loadAudioFromFile(String filePath) async {
    try {
      // Read the file
      File audioFile = File(filePath);
      if (await audioFile.exists()) {
        final audioBytes = await audioFile.readAsBytes();
        final samplesData = await compute(generateWaveformSamples, audioBytes);

        // Scale the waveform data
        final scaledSamples = scaleWaveData(samplesData);

        setState(() {
          samples = scaledSamples;
        });

        // If you need to get the duration, you might need to use a plugin like
        // just_audio or audioplayers to get this information
        // For example, with just_audio:
        // final player = AudioPlayer();
        // await player.setFilePath(filePath);
        // maxDuration = await player.duration ?? const Duration(milliseconds: 1000);
      } else {
        print('Audio file does not exist');
      }
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  static List<double> generateWaveformSamples(List<int> audioBytes) {
    // This is a simplified example. In a real-world scenario, you'd use
    // a proper audio processing library to generate accurate waveform data.
    List<double> samples = [];
    for (int i = 0; i < 1000; i++) {
      samples.add(audioBytes[i % audioBytes.length].toDouble() / 255);
    }
    return samples;
  }

  List<double> scaleWaveData(List<double> data,
      {double targetMax = 32, double targetMin = 1}) {
    if (data.isEmpty) return [];

    double currentMin = data.reduce(min);
    double currentMax = data.reduce(max);

    // Avoid division by zero
    if (currentMax == currentMin) {
      return List.filled(data.length, targetMin);
    }

    final random = Random();

    // Scale the values
    return data.map((x) {
      double scaledValue = ((x - currentMin) / (currentMax - currentMin)) *
              (targetMax - targetMin) +
          targetMin;

      // If the scaled value is very close to the minimum (1),
      // replace it with a random value between 3 and 6
      if (scaledValue < 1.1) {
        return 5 + random.nextDouble() * 3; // Random value between 3 and 6
      }

      return scaledValue;
    }).toList();
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
    player.seek(position);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    if (Platform.isAndroid) {
      extractWavedata();
    } else {
      loadAudioFromFile(widget.noteUrl);
    }
    initPlayer();
    // _player = AudioPlayer();
    //  widget.player.setReleaseMode(ReleaseMode.stop);

    // _init();
    // widget.player.onPlayerStateChanged.listen((event) {
    //   if (event.processingState == ProcessingState.completed) {
    //     setState(() {
    //       isPlaying = false;
    //     });
    //   }
    // });
    // widget.player.playingStream.listen((event) {
    //   if (event == true) {
    //     setState(() {
    //       isPlaying = true;
    //     });
    //   } else {
    //     setState(() {
    //       isPlaying = false;
    //     });
    //   }
    // });
  }

  // Future<void> _init() async {
  //   widget.player.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stackTrace) {
  //     print('A stream error occurred: $e');
  //   });
  //   // Try to load audio from a source and catch any errors.
  //   try {
  //     // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
  //     await widget.player
  //         .setAudioSource(AudioSource.uri(Uri.parse(widget.noteUrl)))
  //         .then((value) {
  //       setState(() {
  //         duration = value!;
  //       });
  //     }); // Load a remote audio file and play.
  //     widget.player.durationStream.listen((value) {
  //       setState(() {
  //         duration = value!;
  //       });
  //     });
  //     widget.player.positionStream.listen((event) {
  //       setState(() {
  //         position = event;
  //       });
  //     });
  //     widget.player.processingStateStream.listen((event) {
  //       if (event == ProcessingState.loading) {
  //         setState(() {
  //           isBuffering = true;
  //         });
  //       } else {
  //         setState(() {
  //           isBuffering = false;
  //         });
  //       }
  //     });
  //   } on PlayerException catch (e) {
  //     log("Error loading audio source: $e");
  //   }
  // }

  playAudio() async {
    try {
      if (isPlaying) {
        player.stop();
        setState(() {
          isPlaying = false;
        });
      } else {
        player.play(DeviceFileSource(widget.noteUrl));
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // void _playAudio() async {
  //   if (isPlaying && _currentIndex != widget.currentIndex) {
  //     await widget.player.stop();
  //   }

  //   if (_currentIndex == widget.currentIndex && isPlaying) {
  //     widget.player.pause();
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   } else {
  //     await widget.player.play();
  //     setState(() {
  //       _currentIndex = widget.currentIndex;
  //       isPlaying = true;
  //     });
  //   }
  // }

  // stopAudio() async {
  //   setState(() {
  //     isPlaying = false;
  //   });
  //   await widget.player.stop();
  // }

  @override
  void dispose() {
    player.dispose();

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

  @override
  Widget build(BuildContext context) {
    // log('Waveform: $doubleWaveformData');
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    playAudio();
                  },
                  child: Consumer<FilterProvider>(
                      builder: (context, filterPro, _) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            filterPro.selectedFilter.contains('Close Friends')
                                ? greenColor
                                : widget.waveColor ?? primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: isPlaying
                          ? Icon(
                              Icons.pause_outlined,
                              color: whiteColor,
                              size: 20,
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ],
                            ),
                    );
                  }),
                ),
              ),
              Consumer<FilterProvider>(builder: (context, filterPro, _) {
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
                        player.seek(seekPosition);
                      },
                      onHorizontalDragEnd: (details) {
                        final position = details.localPosition.dx /
                            widget.width *
                            duration.inMilliseconds;
                        final seekPosition =
                            Duration(milliseconds: position.toInt());
                        player.seek(seekPosition);
                      },
                      onTapUp: (details) {
                        final position = details.localPosition.dx /
                            widget.width *
                            duration.inMilliseconds;
                        final seekPosition =
                            Duration(milliseconds: position.toInt());
                        player.seek(seekPosition);
                        // scrollToPosition(seekPosition);
                      },
                      child: CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: RectangleActiveWaveformPainter(
                          onSeek: (p0) {
                            player.seek(p0);
                          },
                          activeColor:
                              filterPro.selectedFilter.contains('Close Friends')
                                  ? greenColor
                                  : primaryColor,
                          inactiveColor:
                              filterPro.selectedFilter.contains('Close Friends')
                                  ? greenColor.withOpacity(0.5)
                                  : primaryColor.withOpacity(0.5),
                          scrollController: _scrollController,
                          duration: duration,
                          position: postiion,
                          style: PaintingStyle.fill,
                          activeSamples: Platform.isIOS ? samples : waveForm,
                          borderColor: primaryColor.withOpacity(0.5),
                          sampleWidth: 2.5,
                          borderWidth: BorderSide.strokeAlignCenter,
                          color:
                              filterPro.selectedFilter.contains('Close Friends')
                                  ? greenColor.withOpacity(0.5)
                                  : primaryColor.withOpacity(0.5),
                          isCentered: true,
                          isRoundedRectangle: true,
                          waveformAlignment: WaveformAlignment.center,
                        ),
                      ),
                    ),
                    //  PlayerWavePainter(
                    //   animValue: widget.duration.inSeconds.toDouble(),
                    //   audioProgress: widget.position.inSeconds.toDouble(),
                    //   cachedAudioProgress:
                    //       widget.position.inSeconds.toDouble(),
                    //   scaleFactor: 1,
                    //   callPushback: false,
                    //   dragOffset: Offset(10, 0),
                    //   liveWaveColor: primaryColor.withOpacity(0.5),
                    //   pushBack: () {},
                    //   scrollScale: ScrollDragController
                    //       .momentumRetainVelocityThresholdFactor,
                    //   seekLineColor: primaryColor,
                    //   seekLineThickness: 2,
                    //   showBottom: true,
                    //   showSeekLine: true,
                    //   showTop: true,
                    //   spacing: 2,
                    //   totalBackDistance: Offset(0, 0),
                    //   waveCap: StrokeCap.round,
                    //   waveColor: primaryColor,
                    //   waveThickness: 3,
                    //   waveformData: waveForm,
                    //   waveformType: WaveformType.fitWidth,
                    // )
                  ),
                );
              }),
              const SizedBox(
                width: 10,
              ),
              Consumer<FilterProvider>(builder: (context, filterPro, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    postiion.inSeconds == 0
                        ? Text(
                            getInitialDurationnText(duration),
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
                            isPlaying
                                ? getReverseDuration(postiion, duration)
                                : getInitialDurationnText(duration),
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
                            if (isPlaying) {
                              player.setPlaybackRate(_playbackSpeed);
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
      ),
    );
  }
}
