// import 'dart:developer';

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart' as audo;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/widgets.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';

import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:waveform_extractor/waveform_extractor.dart';
import 'package:http/http.dart' as http;

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
      this.isFeedDetail = false,
      this.isSubCommentPlayer = false,
      required this.stopMainPlayer,
      required this.lockPosts,
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
  final VoidCallback stopMainPlayer;
  final List<int> lockPosts;
  bool isFeedDetail;
  // final List<int> lockPosts;
  // bool isMe
  @override
  State<CustomProgressPlayer> createState() => _CustomProgressPlayerState();
}

class _CustomProgressPlayerState extends State<CustomProgressPlayer> {
  late ScrollController _scrollController;
  String? _cachedFilePath;
  final waveformExtractor = WaveformExtractor();
  List<double> waveForm = [];
  var _player = AudioPlayer();
  var audoPlayer = audo.AudioPlayer();

  bool isPlaying = false;
  bool isBuffering = false;
  double _playbackSpeed = 1.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> extractWavedata() async {
    if (widget.isChatUserPlayer) {
      String uniqueKEy = const Uuid().v4();

      final result = await waveformExtractor.extractWaveform(
        widget.noteUrl,
        // samplePerSecond: dynamicSamples,
        useCache: true,
        cacheKey: uniqueKEy,
      );
      List<int> waveForms = result.waveformData;

      if (mounted) {
        setState(() {
          waveForm =
              waveForms.map((int e) => e < 1 ? 6.0 : e.toDouble()).toList();
        });
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = widget.postId!;
      print('cacheKey is $cacheKey');

      List<String>? cachedData = prefs.getStringList(cacheKey);

      if (cachedData != null && cachedData.isNotEmpty) {
        waveForm = cachedData.map((e) => double.tryParse(e) ?? 6.0).toList();
        if (mounted) {
          setState(() {
            waveForm = waveForm.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
          });
        }
      } else {
        final result = await waveformExtractor.extractWaveform(
          widget.noteUrl,
          useCache: true,
          cacheKey: cacheKey,
        );
        List<int> waveForms = result.waveformData;

        if (mounted) {
          setState(() {
            waveForm =
                waveForms.map((int e) => e < 1 ? 6.0 : e.toDouble()).toList();
          });
        }

        await prefs.setStringList(
            cacheKey, waveForms.map((e) => e.toString()).toList());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (Platform.isAndroid) {
      extractWavedata();
    } else {
      loadAudioFromUrl(widget.noteUrl);
    }
    _player = AudioPlayer();
    //  _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _init();
    _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    });
    _player.playingStream.listen((event) {
      if (event == true) {
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
        }
      }
    });
    if (widget.isMainPlayer && widget.stopOtherPlayer != null) {
      widget.stopOtherPlayer!(_player);
    }
  }

  Future<void> loadAudioFromUrl(String url) async {
    try {
      audo.AudioPlayer player = audo.AudioPlayer();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = widget.postId ?? '';

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
        await player.setSourceUrl(url);
        duration =
            await player.getDuration() ?? const Duration(milliseconds: 1000);

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

      player.onPositionChanged.listen((position) {
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

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

  playAudio() async {
    try {
      stopMainPlayer();
      Provider.of<CircleCommentsProvider>(context, listen: false).pausePlayer();
      if (widget.isSubCommentPlayer) {
        widget.stopMainPlayer();
      }
      setState(() {
        isPlaying = true;
      });
      print("playing");
      final audioSource = LockCachingAudioSource(Uri.parse(widget.noteUrl));
      var da = await _player.setAudioSource(audioSource);

      await _player.play();
      _updatePlayedComment();
    } catch (e) {
      print(e.toString());
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
    _player.stop();
    _player.dispose();
    // Cancel all listeners
    _player.playerStateStream.drain();
    _player.playingStream.drain();
    _player.playbackEventStream.drain();
    _player.durationStream.drain();
    _player.positionStream.drain();
    _player.processingStateStream.drain();

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
    print('Waveform: $waveForm');
    // checkAutoPlay();
    return Padding(
      padding: const EdgeInsets.only(left: 2),
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
              // if (widget.title != null)
              //   widget.title!.isNotEmpty
              //       ? Text(
              //           widget.title!.toUpperCase(),
              //           style: TextStyle(
              //               fontFamily: fontFamily,
              //               fontSize: 8,
              //               fontWeight: FontWeight.w600,
              //               color: primaryColor),
              //         )
              //       : const SizedBox(),
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
                        child: widget.lockPosts.contains(0)
                            ? Consumer<UserProfileProvider>(
                                builder: (context, userPro, _) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubscribeScreen(
                                            price: userPro.otherUser!.price,
                                          ),
                                        ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: widget.isProfilePlayer
                                          ? Border.all(
                                              color: whiteColor, width: 5)
                                          : null,
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    // onPressed: playPause,
                                    child: SvgPicture.asset(
                                      'assets/icons/Lock.svg',
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              })
                            : InkWell(
                                splashColor: Colors.transparent,
                                onTap: isPlaying ? stopAudio : playAudio,
                                child: Consumer<FilterProvider>(
                                    builder: (context, filterPro, _) {
                                  return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: widget.isProfilePlayer
                                            ? Border.all(
                                                color: whiteColor, width: 5)
                                            : null,
                                        color: widget.isProfilePlayer
                                            ? whiteColor
                                            : filterPro.selectedFilter
                                                    .contains('Close Friends')
                                                ? greenColor
                                                : widget.waveColor ??
                                                    primaryColor,
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
                                              color: widget.isProfilePlayer
                                                  ? primaryColor
                                                  : whiteColor,
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
                                                  color: widget.isProfilePlayer
                                                      ? primaryColor
                                                      : whiteColor,
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
                        child: widget.lockPosts.contains(0)
                            ? Consumer<UserProfileProvider>(
                                builder: (context, userPro, _) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubscribeScreen(
                                            price: userPro.otherUser!.price,
                                          ),
                                        ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    // onPressed: playPause,
                                    child: SvgPicture.asset(
                                        'assets/icons/Lock.svg'),
                                  ),
                                );
                              })
                            : InkWell(
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
                          return SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: GestureDetector(
                                onHorizontalDragStart: (details) {
                                  if (!widget.lockPosts.contains(0)) {
                                    final position = details.localPosition.dx /
                                        widget.width *
                                        duration.inMilliseconds;
                                    final seekPosition = Duration(
                                        milliseconds: position.toInt());
                                    _player.seek(seekPosition);
                                  }
                                },
                                onHorizontalDragEnd: (details) {
                                  if (!widget.lockPosts.contains(0)) {
                                    final position = details.primaryVelocity! /
                                        widget.width *
                                        duration.inMilliseconds;
                                    final seekPosition = Duration(
                                        milliseconds: position.toInt());
                                    _player.seek(seekPosition);
                                  }
                                },
                                onTapUp: (details) {
                                  if (!widget.lockPosts.contains(0)) {
                                    final position = details.localPosition.dx /
                                        widget.width *
                                        duration.inMilliseconds;
                                    final seekPosition = Duration(
                                        milliseconds: position.toInt());
                                    _player.seek(seekPosition);
                                  }
                                  // scrollToPosition(seekPosition);
                                },
                                child: CustomPaint(
                                  size: Size(widget.width, widget.height),
                                  painter: RectangleActiveWaveformPainter(
                                    onSeek: (p0) {
                                      _player.seek(p0);
                                    },
                                    activeColor: widget.isProfilePlayer
                                        ? whiteColor
                                        : widget.isFeedDetail &&
                                                filterPro.selectedFilter
                                                    .contains('Close Friends')
                                            ? greenColor
                                            : widget.isProfilePlayer
                                                ? primaryColor
                                                : filterPro.selectedFilter
                                                        .contains(
                                                            'Close Friends')
                                                    ? whiteColor
                                                    : widget.isMainPlayer
                                                        ? primaryColor
                                                        : widget.waveColor ??
                                                            primaryColor,
                                    inactiveColor: widget.isProfilePlayer
                                        ? whiteColor.withOpacity(0.5)
                                        : widget.isFeedDetail &&
                                                filterPro.selectedFilter
                                                    .contains('Close Friends')
                                            ? greenColor.withOpacity(0.5)
                                            : widget.isProfilePlayer
                                                ? primaryColor.withOpacity(0.5)
                                                : filterPro.selectedFilter
                                                        .contains(
                                                            'Close Friends')
                                                    ? whiteColor
                                                        .withOpacity(0.5)
                                                    : widget.isMainPlayer
                                                        ? primaryColor
                                                            .withOpacity(0.5)
                                                        : widget.waveColor!
                                                            .withOpacity(0.5),
                                    scrollController: _scrollController,
                                    duration: duration,
                                    position: position,
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
                              ));
                          // return WaveformProgressbar(
                          //   color:
                          // widget.isProfilePlayer
                          //       ? primaryColor.withOpacity(0.5)
                          //       : filterPro.selectedFilter
                          //               .contains('Close Friends')
                          //           ? whiteColor.withOpacity(0.5)
                          //           : widget.isMainPlayer
                          //               ? primaryColor.withOpacity(0.5)
                          //               : widget.waveColor!.withOpacity(0.5),
                          //   // widget.waveColor == null
                          //   //     ? primaryColor
                          //   //     : widget.waveColor!,
                          //   progressColor:
                          // widget.isProfilePlayer
                          //       ? primaryColor
                          //       : filterPro.selectedFilter
                          //               .contains('Close Friends')
                          //           ? whiteColor
                          //           : widget.isMainPlayer
                          //               ? primaryColor
                          //               : widget.waveColor ?? primaryColor,
                          //   // widget.waveColor == null
                          //   //     ? greenColor
                          //   //     : widget.waveColor!,
                          //   progress: position.inSeconds / duration.inSeconds,
                          //   onTap: (progress) {
                          //     Duration seekPosition = Duration(
                          //         seconds:
                          //             (progress * duration.inSeconds).round());
                          //     // Duration seekPosition =
                          //     //     Duration(seconds: progress.toInt());
                          //     _player.seek(seekPosition);
                          //   },
                          // );
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
                                        : FontWeight.w700,
                                    fontSize: widget.isSubCommentPlayer
                                        ? 12
                                        : widget.isProfilePlayer
                                            ? 10
                                            : 10,
                                    color: widget.isProfilePlayer
                                        ? whiteColor
                                        : widget.isChatUserPlayer
                                            ? whiteColor
                                            : widget.isProfilePlayer
                                                ? primaryColor
                                                : filterPro.selectedFilter
                                                        .contains(
                                                            'Close Friends')
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
                                        : FontWeight.w700,
                                    fontFamily: fontFamily,
                                    fontSize: widget.isSubCommentPlayer
                                        ? 12
                                        : widget.isProfilePlayer
                                            ? 10
                                            : 10,
                                    color: widget.isProfilePlayer
                                        ? whiteColor
                                        : widget.isChatUserPlayer
                                            ? whiteColor
                                            : widget.isProfilePlayer
                                                ? primaryColor
                                                : filterPro.selectedFilter
                                                        .contains(
                                                            'Close Friends')
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
