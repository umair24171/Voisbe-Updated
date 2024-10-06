// import 'dart:developer';
import 'dart:convert';
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
import 'package:uuid/uuid.dart';
import 'package:waveform_extractor/model/waveform_progress.dart';
import 'package:waveform_extractor/waveform_extractor.dart';
import 'package:http/http.dart' as http;

class CommentsPlayer extends StatefulWidget {
  CommentsPlayer(
      {Key? key,
      required this.noteUrl,
      required this.height,
      required this.width,
      required this.mainWidth,
      required this.mainHeight,
      this.backgroundColor = Colors.white,
      required this.changeIndex,
      required this.playPause,
      this.size = 35,
      this.isComment = false,
      this.isMainPlayer = false,
      this.commentId,
      this.postId,
      required this.player,
      required this.isPlaying,
      required this.position,
      // this.stopOtherPlayer,
      this.playedCounter,
      required this.currentIndex,
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
  // final Function(AudioPlayer)? stopOtherPlayer;
  int currentIndex;
  AudioPlayer player;
  final VoidCallback playPause;
  int changeIndex;
  bool isPlaying;
  Duration position;
  @override
  State<CommentsPlayer> createState() => _CommentsPlayerState();
}

class _CommentsPlayerState extends State<CommentsPlayer> {
  late ScrollController _scrollController;
  String? _cachedFilePath;
  final waveformExtractor = WaveformExtractor();
  List<double> waveForm = [];
  bool _mounted = true;

  // int? _currentIndex;
  // var _player = AudioPlayer();
  // bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Future<void> extractWavedata() async {
    if (!mounted) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = widget.commentId ?? '';

      if (cacheKey.isEmpty) {
        print('Error: commentId is null or empty');
        return;
      }

      List<String>? cachedData = prefs.getStringList(cacheKey);

      if (cachedData != null && cachedData.isNotEmpty) {
        List<double> extractedWaveForm = cachedData
            .map((e) => double.tryParse(e) ?? 6.0)
            .map((e) => e < 1 ? 6.0 : e)
            .toList();

        if (_mounted) {
          setState(() {
            waveForm = extractedWaveForm;
          });
        }
      } else {
        if (widget.noteUrl == null || widget.noteUrl!.isEmpty) {
          print('Error: noteUrl is null or empty');
          return;
        }

        final result = await waveformExtractor.extractWaveform(
          widget.noteUrl!,
          useCache: true,
          cacheKey: cacheKey,
        );
        List<int> waveForms = result.waveformData;

        List<double> extractedWaveForm =
            waveForms.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();

        if (_mounted) {
          setState(() {
            waveForm = extractedWaveForm;
          });
        }

        await prefs.setStringList(
            cacheKey, waveForms.map((e) => e.toString()).toList());
      }
    } catch (e) {
      print('Error in extractWavedata: $e');
      // Handle the error appropriately
    }
  }

  Future<void> loadAudioFromUrl(String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = widget.commentId ?? '';

      // Try to load cached data
      String? cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        // Use cached data
        final decodedData = json.decode(cachedData);
        // maxDuration = Duration(milliseconds: decodedData['maxDuration']);
        final samplesData = List<double>.from(decodedData['samples']);

        setState(() {
          waveForm = samplesData;
        });
      } else {
        // Fetch new data
        await widget.player.setSourceUrl(url);
        duration = await widget.player.getDuration() ??
            const Duration(milliseconds: 1000);

        // Fetch audio data for waveform
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final audioBytes = response.bodyBytes;
          final samplesData =
              await compute(generateWaveformSamples, audioBytes);

          // Scale the waveform data
          final scaledSamples = scaleWaveData(samplesData);

          setState(() {
            waveForm = scaledSamples;
          });

          // Cache the data
          final dataToCache = json.encode({
            'maxDuration': duration.inMilliseconds,
            'samples': scaledSamples,
          });
          await prefs.setString(cacheKey, dataToCache);
        } else {
          print('Failed to load audio data');
        }
      }

      widget.player.onPositionChanged.listen((position) {
        setState(() {
          position = position;
        });
      });
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

  initPlayer() async {
    widget.player = AudioPlayer();
    widget.player.setReleaseMode(ReleaseMode.stop);
    widget.player.setSourceUrl(widget.noteUrl).then((value) {
      // widget.player.getDuration().then(
      //       (value) => setState(() {
      //         duration = value!;
      //         // playPause();
      //       }),
      //     );
    });
    widget.player.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    // widget.player.setReleaseMode(ReleaseMode.stop);

    // Check if the file is already cached
    DefaultCacheManager().getFileFromCache(widget.noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });

    widget.player.onPlayerComplete.listen((state) {
      setState(() {
        widget.isPlaying = false;
        widget.changeIndex = -1;
      });
    });

    widget.player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          widget.isPlaying = true;
          // widget.isPlaying = widget.isPlaying;
        });
      } else {
        setState(() {
          widget.isPlaying = false;
          // widget.isPlaying = widget.isPlaying;
        }); // Notify parent widget
      }
    });
  }

  void scrollToPosition(Duration position) {
    // if (waveForm.isNotEmpty && _scrollController.hasClients) {
    //   final progressPercent = position.inMilliseconds / duration.inMilliseconds;
    //   final targetScrollOffset =
    //       progressPercent * waveForm.length * widget.width - widget.width / 2;
    //   _scrollController.animateTo(
    //     targetScrollOffset,
    //     duration: const Duration(milliseconds: 500),
    //     curve: Curves.easeInOut,
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // extractWavedata();
    if (Platform.isAndroid) {
      extractWavedata();
    } else {
      loadAudioFromUrl(widget.noteUrl);
    }
    initPlayer();
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
  void dispose() {
    _mounted = false;
    super.dispose();
  }

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
              if (widget.isMainPlayer)
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
                            color: filterPro.selectedFilter
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
                          child: widget.isPlaying
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
                    onTap: widget.playPause,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      // onPressed: playPause,
                      child: widget.changeIndex == widget.currentIndex &&
                              widget.isPlaying
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
                          // scrollToPosition(seekPosition);
                        },
                        child: CustomPaint(
                          size: Size(widget.width, widget.height),
                          painter: RectangleActiveWaveformPainter(
                            onSeek: (p0) {
                              widget.player.seek(p0);
                              // scrollToPosition(p0);
                            },
                            activeColor:
                                widget.currentIndex == widget.changeIndex &&
                                        widget.isPlaying
                                    ? filterPro.selectedFilter
                                            .contains('Close Friends')
                                        ? whiteColor
                                        : widget.isMainPlayer
                                            ? primaryColor
                                            : widget.waveColor!
                                    : whiteColor.withOpacity(0.5),
                            inactiveColor: filterPro.selectedFilter
                                    .contains('Close Friends')
                                ? whiteColor.withOpacity(0.5)
                                : widget.isMainPlayer
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
                            color: filterPro.selectedFilter
                                    .contains('Close Friends')
                                ? greenColor.withOpacity(0.5)
                                : primaryColor.withOpacity(0.5),
                            isCentered: true,
                            isRoundedRectangle: true,
                            waveformAlignment: WaveformAlignment.center,
                          ),
                        ),
                      )),
                );
              }),
              const SizedBox(
                width: 10,
              ),
              Consumer<FilterProvider>(builder: (context, filterPro, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.position.inSeconds == 0
                        ? Text(
                            getInitialDurationnText(duration),
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              color: filterPro.selectedFilter
                                      .contains('Close Friends')
                                  ? whiteColor
                                  : widget.waveColor ?? primaryColor,
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
                              color: filterPro.selectedFilter
                                      .contains('Close Friends')
                                  ? whiteColor
                                  : widget.waveColor ?? primaryColor,
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
                            if (widget.isPlaying) {
                              widget.player.setPlaybackRate(_playbackSpeed);
                            }
                          });
                        },
                        child: Consumer<FilterProvider>(
                            builder: (context, filterPro, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                                color: filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? greenColor
                                    : primaryColor,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${_playbackSpeed}X',
                              style: TextStyle(
                                color: whiteColor,
                                fontFamily: fontFamily,
                                fontSize: 12,
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
