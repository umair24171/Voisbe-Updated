// import 'dart:async';
// // import 'dart:developer' as lo;
// import 'dart:math';
// // import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

// // import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
// import 'package:flutter_svg/svg.dart';
// // import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// // import 'package:social_notes/screens/home_screen/controller/play_count_service.dart';
// import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/most_listened_waves.dart';
// import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
// // import 'package:uuid/uuid.dart';
// // import 'package:wave/config.dart';
// // import 'package:wave/wave.dart';
// import 'package:waveform_extractor/waveform_extractor.dart';

// class MainPlayer extends StatefulWidget {
//   MainPlayer({
//     Key? key,
//     required this.noteUrl,
//     required this.height,
//     required this.width,
//     required this.mainWidth,
//     required this.mainHeight,
//     required this.playPause,
//     this.backgroundColor = Colors.white,
//     this.size = 35,
//     this.isComment = false,
//     this.isMainPlayer = false,
//     this.commentId,
//     this.postId,
//     this.playedCounter,
//     this.pageController,
//     required this.isPlaying,
//     required this.duration,
//     required this.currentIndex,
//     // required this.playCounts,
//     required this.audioPlayer,
//     required this.listenedWaves,
//     required this.changeIndex,
//     required this.position,
//     required this.lockPosts,
//     required this.title,
//     this.isProfilePlayer = false,
//     // required this.waveformData,
//     this.waveColor,
//   }) : super(key: key);

//   final String noteUrl;
//   final double height;
//   final double width;
//   final double mainWidth;
//   final double mainHeight;
//   final Color backgroundColor;
//   double size;
//   int? playedCounter;
//   Color? waveColor;
//   bool isComment;
//   String? commentId;
//   String? postId;
//   bool isMainPlayer;
//   PageController? pageController;
//   // List<int> playCounts;
//   // final List<double> waveformData;

//   bool isPlaying;
//   final AudioPlayer audioPlayer;
//   final Duration position;
//   int changeIndex;
//   VoidCallback playPause;
//   Duration duration;

//   int currentIndex;
//   List<double> listenedWaves;
//   List<int> lockPosts;
//   bool isProfilePlayer;
//   final String title;

//   @override
//   State<MainPlayer> createState() => _MainPlayerState();
// }

// class _MainPlayerState extends State<MainPlayer> {
//   Duration elapsedDuration = Duration.zero;
//   final waveformExtractor = WaveformExtractor();
//   List<double> waveForm = [];
//   double _playbackSpeed = 1.0;
//   late ScrollController _scrollController;
//   List<double> waveCounts = [];
//   List<double> waveHeights = [];
//   // waveHeights = ;
//   // 180 is the length of your example list

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();

//     extractWavedata();
//     // _onAudioPositionChanged(widget.position);
//     // loadWaveHeights();
//   }

//   // void updateFirestore(List listenedWaves) async {
//   //   try {
//   //     await FirebaseFirestore.instance
//   //         .collection('notes')
//   //         .doc(widget.postId) // Assuming you have a noteId
//   //         .update({
//   //       'mostListenedWaves': waveHeights,
//   //     });
//   //     print('listenedWaves are $listenedWaves');
//   //   } catch (e) {
//   //     print('Error updating Firestore: $e');
//   //   }
//   // }
//   bool _mounted = true;

//   Future<void> extractWavedata() async {
//     if (!_mounted) return;

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String cacheKey = widget.postId!;

//     List<String>? cachedData = prefs.getStringList(cacheKey);

//     if (!_mounted) return;

//     if (cachedData != null && cachedData.isNotEmpty) {
//       waveForm = cachedData.map((e) => double.tryParse(e) ?? 6.0).toList();
//       _safeSetState(() {
//         waveForm = waveForm.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
//       });
//     } else {
//       final result = await waveformExtractor.extractWaveform(
//         widget.noteUrl,
//         useCache: true,
//         cacheKey: cacheKey,
//       );

//       if (!_mounted) return;

//       List<int> waveForms = result.waveformData;

//       _safeSetState(() {
//         waveForm = waveForms.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
//       });

//       await prefs.setStringList(
//           cacheKey, waveForms.map((e) => e.toString()).toList());
//     }

//     if (!_mounted) return;

//     waveHeights = List.filled(waveForm.length, 1.0);
//     _safeSetState(() {});

//     print('waves are $waveForm');
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (_mounted) {
//       setState(fn);
//     }
//   }
//   // Future<void> extractWavedata() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String cacheKey = widget.postId!;

//   //   List<String>? cachedData = prefs.getStringList(cacheKey);

//   //   if (cachedData != null && cachedData.isNotEmpty) {
//   //     waveForm = cachedData.map((e) => double.tryParse(e) ?? 6.0).toList();
//   //     setState(() {
//   //       waveForm = waveForm.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
//   //     });
//   //   } else {
//   //     final result = await waveformExtractor.extractWaveform(
//   //       widget.noteUrl,
//   //       useCache: true,
//   //       cacheKey: cacheKey,
//   //     );
//   //     List<int> waveForms = result.waveformData;

//   //     setState(() {
//   //       waveForm = waveForms.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
//   //     });

//   //     await prefs.setStringList(
//   //         cacheKey, waveForms.map((e) => e.toString()).toList());
//   //   }
//   //   // lo.log('waveLengths are ${waveForm.length}');
//   //   waveHeights = List.filled(waveForm.length, 1.0);
//   //   setState(() {});
//   // }

//   @override
//   void dispose() {
//     widget.duration = Duration.zero;
//     _scrollController.dispose();
//     _mounted = false;
//     super.dispose();
//   }

//   String getReverseDuration(Duration position, Duration totalDuration) {
//     int remainingSeconds = totalDuration.inSeconds - position.inSeconds;
//     int minutes = remainingSeconds ~/ 60;
//     int seconds = remainingSeconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }

//   String getInitialDurationnText(Duration totalDuration) {
//     int remainingSeconds = totalDuration.inSeconds;
//     int minutes = remainingSeconds ~/ 60;
//     int seconds = remainingSeconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }

//   void scrollToPosition(Duration position) {
//     if (waveForm.isNotEmpty && _scrollController.hasClients) {
//       final progressPercent =
//           position.inMilliseconds / widget.duration.inMilliseconds;
//       final targetScrollOffset =
//           progressPercent * waveForm.length * widget.width - widget.width / 2;
//       _scrollController.animateTo(
//         targetScrollOffset,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // lo.log('WaveHeights: ${waveHeights}');
//     // lo.log('Waveform plugin: ${waveForm}');

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 5),
//       child: Center(
//         child: Container(
//           height: widget.mainHeight,
//           width: widget.mainWidth,
//           decoration: BoxDecoration(
//             color: widget.backgroundColor,
//             borderRadius: BorderRadius.circular(55),
//           ),
//           child: Stack(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   if (widget.isProfilePlayer)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: widget.lockPosts.contains(0)
//                           ? GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => SubscribeScreen(),
//                                     ));
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: whiteColor,
//                                   borderRadius: BorderRadius.circular(50),
//                                 ),
//                                 // onPressed: playPause,
//                                 child:
//                                     SvgPicture.asset('assets/icons/Lock.svg'),
//                               ),
//                             )
//                           : InkWell(
//                               splashColor: Colors.transparent,
//                               onTap: widget.playPause,
//                               child: Container(
//                                   padding: const EdgeInsets.all(20),
//                                   decoration: BoxDecoration(
//                                     color: whiteColor,
//                                     border: widget.isProfilePlayer
//                                         ? Border.all(
//                                             color: whiteColor, width: 5)
//                                         : null,
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   // onPressed: playPause,
//                                   child: Icon(
//                                     widget.isPlaying &&
//                                             widget.changeIndex ==
//                                                 widget.currentIndex
//                                         ? Icons.pause
//                                         : Icons.play_arrow,
//                                     color: primaryColor,
//                                     size: 20,
//                                   )),
//                             ),
//                     )
//                   else
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: InkWell(
//                         splashColor: Colors.transparent,
//                         onTap: () {
//                           widget.playPause();
//                           scrollToPosition(widget.position);
//                         },
//                         child: Consumer<FilterProvider>(
//                             builder: (context, filterPro, _) {
//                           return Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: filterPro.selectedFilter
//                                       .contains('Close Friends')
//                                   ? greenColor
//                                   : widget.waveColor ?? primaryColor,
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: widget.isPlaying &&
//                                     widget.currentIndex == widget.changeIndex
//                                 ? Icon(
//                                     Icons.pause_outlined,
//                                     color: whiteColor,
//                                     size: 20,
//                                   )
//                                 : Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.play_arrow,
//                                         color: whiteColor,
//                                         size: 20,
//                                       ),
//                                     ],
//                                   ),
//                           );
//                         }),
//                       ),
//                     ),
//                   if (widget.isProfilePlayer)
//                     Consumer<FilterProvider>(builder: (context, filterPro, _) {
//                       return SizedBox(
//                         height: widget.height,
//                         width: widget.width,
//                         child: SingleChildScrollView(
//                           controller: _scrollController,
//                           scrollDirection: Axis.horizontal,
//                           child: GestureDetector(
//                             onHorizontalDragStart: (details) async {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.5,
//                               //         9.0); // Increment by 0.5, max of 9.0
//                               //   });

//                               //   // Update Firestore
//                               //   updateFirestore(waveHeights);
//                               // }
//                             },
//                             onHorizontalDragEnd: (details) {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.1,
//                               //         9.0); // Smaller increment for continuous update
//                               //   });

//                               //   // Update Firestore less frequently to avoid too many writes
//                               //   if (index % 5 == 0) {
//                               //     updateFirestore(waveHeights);
//                               //   }
//                               // }
//                             },
//                             onTapUp: (details) {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               scrollToPosition(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.1,
//                               //         9.0); // Smaller increment for continuous update
//                               //   });

//                               //   // Update Firestore less frequently to avoid too many writes
//                               //   if (index % 5 == 0) {
//                               //     updateFirestore(waveHeights);
//                               //   }
//                               // }
//                             },
//                             child: CustomPaint(
//                               size: Size(widget.width, widget.height),
//                               painter: RectangleActiveWaveformPainter(
//                                 onSeek: (position) {
//                                   widget.audioPlayer.seek(position);
//                                   // scrollToPosition(position);
//                                 },
//                                 activeColor:
//                                     widget.changeIndex == widget.currentIndex &&
//                                             widget.isPlaying
//                                         ? whiteColor
//                                         : whiteColor.withOpacity(0.5),
//                                 inactiveColor: whiteColor.withOpacity(0.5),
//                                 scrollController: _scrollController,
//                                 duration: widget.duration,
//                                 position: widget.position,
//                                 style: PaintingStyle.fill,
//                                 activeSamples: waveForm,
//                                 borderColor: primaryColor.withOpacity(0.5),
//                                 sampleWidth: 2.5,
//                                 borderWidth: BorderSide.strokeAlignCenter,
//                                 color: filterPro.selectedFilter
//                                         .contains('Close Friends')
//                                     ? greenColor.withOpacity(0.5)
//                                     : primaryColor.withOpacity(0.5),
//                                 isCentered: true,
//                                 isRoundedRectangle: true,
//                                 waveformAlignment: WaveformAlignment.center,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     })
//                   else
//                     Consumer<FilterProvider>(builder: (context, filterPro, _) {
//                       return SizedBox(
//                         height: widget.height,
//                         width: widget.width,
//                         child: SingleChildScrollView(
//                           controller: _scrollController,
//                           scrollDirection: Axis.horizontal,
//                           child: GestureDetector(
//                             onHorizontalDragStart: (details) async {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.5,
//                               //         9.0); // Increment by 0.5, max of 9.0
//                               //   });

//                               //   // Update Firestore
//                               //   updateFirestore(waveHeights);
//                               // }
//                             },
//                             onHorizontalDragEnd: (details) {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.1,
//                               //         9.0); // Smaller increment for continuous update
//                               //   });

//                               //   // Update Firestore less frequently to avoid too many writes
//                               //   if (index % 5 == 0) {
//                               //     updateFirestore(waveHeights);
//                               //   }
//                               // }
//                             },
//                             onTapUp: (details) {
//                               final position = details.localPosition.dx /
//                                   widget.width *
//                                   widget.duration.inMilliseconds;
//                               final seekPosition =
//                                   Duration(milliseconds: position.toInt());
//                               widget.audioPlayer.seek(seekPosition);
//                               scrollToPosition(seekPosition);
//                               // int index = (position /
//                               //         widget.duration.inMilliseconds *
//                               //         waveHeights.length)
//                               //     .floor();
//                               // if (index >= 0 && index < waveHeights.length) {
//                               //   setState(() {
//                               //     waveHeights[index] = min(
//                               //         waveHeights[index] + 0.1,
//                               //         9.0); // Smaller increment for continuous update
//                               //   });

//                               //   // Update Firestore less frequently to avoid too many writes
//                               //   if (index % 5 == 0) {
//                               //     updateFirestore(waveHeights);
//                               //   }
//                               // }
//                             },
//                             child: CustomPaint(
//                               size: Size(widget.width, widget.height),
//                               painter: RectangleActiveWaveformPainter(
//                                 onSeek: (position) {
//                                   widget.audioPlayer.seek(position);
//                                   // scrollToPosition(position);
//                                 },
//                                 activeColor: filterPro.selectedFilter
//                                         .contains('Close Friends')
//                                     ? greenColor
//                                     : primaryColor,
//                                 inactiveColor: filterPro.selectedFilter
//                                         .contains('Close Friends')
//                                     ? greenColor.withOpacity(0.5)
//                                     : primaryColor.withOpacity(0.5),
//                                 scrollController: _scrollController,
//                                 duration: widget.duration,
//                                 position: widget.position,
//                                 style: PaintingStyle.fill,
//                                 activeSamples: waveForm,
//                                 borderColor: primaryColor.withOpacity(0.5),
//                                 sampleWidth: 2.5,
//                                 borderWidth: BorderSide.strokeAlignCenter,
//                                 color: filterPro.selectedFilter
//                                         .contains('Close Friends')
//                                     ? greenColor.withOpacity(0.5)
//                                     : primaryColor.withOpacity(0.5),
//                                 isCentered: true,
//                                 isRoundedRectangle: true,
//                                 waveformAlignment: WaveformAlignment.center,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Consumer<FilterProvider>(builder: (context, filterPro, _) {
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         widget.position.inSeconds == 0
//                             ? Text(
//                                 getInitialDurationnText(widget.duration),
//                                 style: TextStyle(
//                                   fontFamily: fontFamily,
//                                   fontSize: widget.isProfilePlayer ? 10 : 12,
//                                   color: widget.isProfilePlayer
//                                       ? whiteColor
//                                       : filterPro.selectedFilter
//                                               .contains('Close Friends')
//                                           ? greenColor
//                                           : widget.waveColor ?? primaryColor,
//                                 ),
//                               )
//                             : Text(
//                                 widget.changeIndex == widget.currentIndex &&
//                                         widget.isPlaying
//                                     ? getReverseDuration(
//                                         widget.position, widget.duration)
//                                     : getInitialDurationnText(widget.duration),
//                                 style: TextStyle(
//                                   fontFamily: fontFamily,
//                                   fontSize: widget.isProfilePlayer ? 10 : 12,
//                                   color: widget.isProfilePlayer
//                                       ? whiteColor
//                                       : filterPro.selectedFilter
//                                               .contains('Close Friends')
//                                           ? greenColor
//                                           : widget.waveColor ?? primaryColor,
//                                 ),
//                               ),
//                         const SizedBox(height: 5),
//                         if (widget.waveColor == null)
//                           InkWell(
//                             onTap: () {
//                               setState(() {
//                                 if (_playbackSpeed == 1.0) {
//                                   _playbackSpeed = 1.5;
//                                 } else if (_playbackSpeed == 1.5) {
//                                   _playbackSpeed = 2.0;
//                                 } else {
//                                   _playbackSpeed = 1.0;
//                                 }
//                                 // Set playback speed if audio is already playing
//                                 if (widget.isPlaying) {
//                                   widget.audioPlayer
//                                       .setPlaybackRate(_playbackSpeed);
//                                 }
//                               });
//                             },
//                             child: Consumer<FilterProvider>(
//                                 builder: (context, filterPro, _) {
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 5, vertical: 8),
//                                 decoration: BoxDecoration(
//                                     color: filterPro.selectedFilter
//                                             .contains('Close Friends')
//                                         ? greenColor
//                                         : primaryColor,
//                                     borderRadius: BorderRadius.circular(25)),
//                                 child: Text(
//                                   '${_playbackSpeed.toDouble()}X',
//                                   style: TextStyle(
//                                     color: whiteColor,
//                                     fontFamily: fontFamily,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ),
//                       ],
//                     );
//                   })
//                 ],
//               ),
//               // Positioned(
//               //   top: 41,
//               //   left: 75,
//               //   child: StreamBuilder(
//               //       stream: FirebaseFirestore.instance
//               //           .collection('notes')
//               //           .doc(widget.postId)
//               //           .snapshots(),
//               //       builder: (context, snapshot) {
//               //         if (snapshot.hasData) {
//               //           NoteModel note =
//               //               NoteModel.fromMap(snapshot.data!.data()!);
//               //           return CustomPaint(
//               //             child: MostListenedWaves(
//               //               samples: note.mostListenedWaves,
//               //               height: widget.height - 7,
//               //               width: widget.width,
//               //               showActiveWaveform: true,
//               //               strokeWidth: 10,
//               //               activeColor: primaryColor.withOpacity(0.5),
//               //               inactiveColor: primaryColor.withOpacity(0.5),
//               //             ),
//               //           );
//               //         } else {
//               //           return const Text('');
//               //         }
//               //       }),
//               // )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class RectangleActiveWaveformPainter extends ActiveWaveformPainter {
//   RectangleActiveWaveformPainter({
//     required super.color,
//     required super.activeSamples,
//     required super.waveformAlignment,
//     required super.sampleWidth,
//     required super.borderColor,
//     required super.borderWidth,
//     required this.isRoundedRectangle,
//     required this.isCentered,
//     required this.duration,
//     required this.position,
//     required this.scrollController,
//     required this.activeColor,
//     required this.inactiveColor,
//     required this.onSeek,
//     super.gradient,
//     super.style = PaintingStyle.fill,
//   }) {
//     // Attach a listener to the ScrollController
//     scrollController.addListener(_onScroll);
//   }

//   final bool isRoundedRectangle;
//   final bool isCentered;
//   final Duration duration;
//   final Duration position;
//   final ScrollController scrollController;
//   final Color activeColor;
//   final Color inactiveColor;
//   final Function(Duration) onSeek; // Callback to perform seek

//   void _onScroll() {
//     final scrollOffset = scrollController.offset;
//     final totalSamples = activeSamples.length;
//     final scrollPositionInSamples = scrollOffset / sampleWidth;
//     final percentScrolled = scrollPositionInSamples / totalSamples;
//     final newPosition = Duration(
//         milliseconds: (percentScrolled * duration.inMilliseconds).toInt());

//     // Seek to the new position using the callback
//     onSeek(newPosition);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     final borderPaint = Paint()
//       ..style = PaintingStyle.fill
//       ..strokeWidth = borderWidth
//       ..color = borderColor;

//     final paint = Paint()
//       ..style = style
//       ..color = color;

//     if (gradient != null) {
//       paint.shader = gradient!.createShader(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//       );
//     }

//     final alignPosition = waveformAlignment.getAlignPosition(size.height);

//     canvas.save();
//     canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

//     if (duration.inMilliseconds == 0 || activeSamples.isEmpty) {
//       canvas.restore();
//       return;
//     }

//     final progressPercent = duration.inMilliseconds > 0
//         ? position.inMilliseconds / duration.inMilliseconds
//         : 0.0;
//     final currentSampleIndex = (progressPercent * activeSamples.length).floor();

//     final scrollOffset = scrollController.offset;

//     if (isRoundedRectangle) {
//       drawRoundedRectangles(
//         canvas,
//         alignPosition,
//         borderPaint,
//         waveformAlignment,
//         isCentered,
//         size,
//         currentSampleIndex,
//         progressPercent,
//         scrollOffset,
//       );
//     } else {
//       drawRegularRectangles(
//         canvas,
//         alignPosition,
//         borderPaint,
//         waveformAlignment,
//         isCentered,
//         size,
//         currentSampleIndex,
//         progressPercent,
//         scrollOffset,
//       );
//     }

//     canvas.restore();
//   }

//   void drawRegularRectangles(
//     Canvas canvas,
//     double alignPosition,
//     Paint borderPaint,
//     WaveformAlignment waveformAlignment,
//     bool isCentered,
//     Size size,
//     int currentSampleIndex,
//     double progressPercent,
//     double scrollOffset,
//   ) {
//     final visibleSampleCount = (size.width / sampleWidth).floor();
//     for (var i = 0; i < visibleSampleCount; i++) {
//       final x = sampleWidth * (i + scrollOffset / sampleWidth).floor();
//       if (x >= size.width + scrollOffset) break;

//       final sampleIndex = activeSamples.isNotEmpty
//           ? (i / visibleSampleCount * activeSamples.length).floor()
//           : 0;
//       final isAbsolute = waveformAlignment != WaveformAlignment.center;
//       final y = isCentered && !isAbsolute
//           ? activeSamples[sampleIndex] * 23
//           : activeSamples[sampleIndex];
//       final positionFromTop =
//           isCentered && !isAbsolute ? alignPosition - y / 2 : alignPosition;

//       final paint = Paint()
//         ..style = style
//         ..color =
//             sampleIndex <= currentSampleIndex ? activeColor : inactiveColor;

//       canvas.drawRect(
//         Rect.fromLTWH(x - scrollOffset, positionFromTop, sampleWidth, y),
//         paint,
//       );
//     }
//   }

//   void drawRoundedRectangles(
//     Canvas canvas,
//     double alignPosition,
//     Paint borderPaint,
//     WaveformAlignment waveformAlignment,
//     bool isCentered,
//     Size size,
//     int currentSampleIndex,
//     double progressPercent,
//     double scrollOffset,
//   ) {
//     final visibleSampleCount = (size.width / sampleWidth).floor();
//     for (var i = 0; i < visibleSampleCount; i++) {
//       if (i.isEven) {
//         final x = sampleWidth * (i + scrollOffset / sampleWidth).floor();
//         if (x >= size.width + scrollOffset)
//           break; // Ensure rounded rectangles stay within the width

//         final sampleIndex = activeSamples.isNotEmpty
//             ? (i / visibleSampleCount * activeSamples.length).floor()
//             : 0;
//         final isAbsolute = waveformAlignment != WaveformAlignment.center;
//         final y = isAbsolute
//             ? activeSamples[sampleIndex]
//             : !isCentered
//                 ? activeSamples[sampleIndex]
//                 : activeSamples[sampleIndex] * 2;
//         final positionFromTop = isAbsolute
//             ? alignPosition
//             : !isCentered
//                 ? alignPosition
//                 : alignPosition - y / 2;

//         final paint = Paint()
//           ..style = style
//           ..color =
//               sampleIndex <= currentSampleIndex ? activeColor : inactiveColor;

//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//             Rect.fromLTWH(x - scrollOffset, positionFromTop, sampleWidth, y),
//             Radius.circular(sampleWidth / 2),
//           ),
//           paint,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant RectangleActiveWaveformPainter oldDelegate) {
//     return getShouldRepaintValue(oldDelegate) ||
//         isRoundedRectangle != oldDelegate.isRoundedRectangle ||
//         isCentered != oldDelegate.isCentered ||
//         duration != oldDelegate.duration ||
//         position != oldDelegate.position ||
//         scrollController != oldDelegate.scrollController;
//   }
// }

import 'dart:async';
import 'dart:io';
// import 'dart:developer' as lo;

import 'dart:math';
import 'dart:developer' as dev;
import 'dart:typed_data';
// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

// import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart' as audo;
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// import 'package:social_notes/screens/home_screen/controller/play_count_service.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/most_listened_waves.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:wave/config.dart';
// import 'package:wave/wave.dart';
import 'package:waveform_extractor/waveform_extractor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as jus;
import 'package:audio_waveforms/audio_waveforms.dart' as wave;

class MainPlayer extends StatefulWidget {
  MainPlayer({
    Key? key,
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
    // required this.playCounts,
    required this.audioPlayer,
    required this.listenedWaves,
    required this.changeIndex,
    required this.position,
    // required this.price,
    required this.lockPosts,
    required this.title,
    this.isProfilePlayer = false,
    // required this.waveformData,
    this.waveColor,
  }) : super(key: key);

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
  // List<int> playCounts;
  // final List<double> waveformData;

  bool isPlaying;
  final AudioPlayer audioPlayer;
  final Duration position;
  int changeIndex;
  VoidCallback playPause;
  Duration duration;

  int currentIndex;
  List<double> listenedWaves;
  List<int> lockPosts;
  bool isProfilePlayer;
  final String title;
  // double price;

  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  // Duration elapsedDuration = Duration.zero;
  Duration maxDuration = const Duration(milliseconds: 1000);
  Duration elapsedDuration = const Duration();
  final waveformExtractor = WaveformExtractor();
  List<double> waveForm = [];
  double _playbackSpeed = 1.0;
  late ScrollController _scrollController;
  List<double> waveCounts = [];
  List<double> waveHeights = [];
  // waveHeights = ;
  // 180 is the length of your example list

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    if (Platform.isAndroid) {
      extractWavedata();
    } else {
      getWaves();
    }
    // _onAudioPositionChanged(widget.position);
    // loadWaveHeights();
  }

  getWaves() async {
    // totalSamples = 1000;
    // audioPlayer = AudioPlayer();
    // samples = [];

    loadAudioFromUrl(widget.noteUrl);
    // urlController.text = audioUrl;
  }

  // void updateFirestore(List listenedWaves) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('notes')
  //         .doc(widget.postId) // Assuming you have a noteId
  //         .update({
  //       'mostListenedWaves': waveHeights,
  //     });
  //     print('listenedWaves are $listenedWaves');
  //   } catch (e) {
  //     print('Error updating Firestore: $e');
  //   }
  // }
  bool _mounted = true;
  // final jus.AudioPlayer _audioPlayer = jus.AudioPlayer();
  String? _localFilePath;
  bool _isLoading = true;
  List<double> samples = [];
  int totalSamples = 1000;
  // late Duration maxDuration;
  // late Duration elapsedDuration;

  Future<void> loadAudioFromUrl(String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'audio_data_$url';

      // Try to load cached data
      String? cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        // Use cached data
        final decodedData = json.decode(cachedData);
        maxDuration = Duration(milliseconds: decodedData['maxDuration']);
        final samplesData = List<double>.from(decodedData['samples']);
        _safeSetState(() {
          samples = samplesData;
        });
      } else {
        // Fetch new data
        await widget.audioPlayer.setSourceUrl(url);
        maxDuration = await widget.audioPlayer.getDuration() ??
            const Duration(milliseconds: 1000);

        // Fetch audio data for waveform
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final audioBytes = response.bodyBytes;
          final samplesData =
              await compute(generateWaveformSamples, audioBytes);

          // Scale the waveform data
          final scaledSamples = scaleWaveData(samplesData);
          _safeSetState(() {
            samples = scaledSamples;
          });

          // Cache the data
          final dataToCache = json.encode({
            'maxDuration': maxDuration.inMilliseconds,
            'samples': scaledSamples,
          });
          await prefs.setString(cacheKey, dataToCache);
        } else {
          print('Failed to load audio data');
        }
      }

      widget.audioPlayer.onPositionChanged.listen((position) {
        _safeSetState(() {
          elapsedDuration = position;
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

  // Future<void> loadAudioFromUrl(String url) async {
  //   try {
  //     await widget.audioPlayer.setSourceUrl(url);
  //     maxDuration = await widget.audioPlayer.getDuration() ??
  //         const Duration(milliseconds: 1000);

  //     // Fetch audio data for waveform
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final audioBytes = response.bodyBytes;
  //       final samplesData = await compute(generateWaveformSamples, audioBytes);

  //       // Scale the waveform data
  //       final scaledSamples = scaleWaveData(samplesData);

  //       setState(() {
  //         samples = scaledSamples;
  //       });
  //     } else {
  //       print('Failed to load audio data');
  //     }

  //     widget.audioPlayer.onPositionChanged.listen((position) {
  //       setState(() {
  //         elapsedDuration = position;
  //       });
  //     });
  //   } catch (e) {
  //     print('Error loading audio: $e');
  //   }
  // }

  // static List<double> generateWaveformSamples(List<int> audioBytes) {
  //   // This is a simplified example. In a real-world scenario, you'd use
  //   // a proper audio processing library to generate accurate waveform data.
  //   List<double> samples = [];
  //   for (int i = 0; i < 1000; i++) {
  //     samples.add(audioBytes[i % audioBytes.length].toDouble() / 255);
  //   }
  //   return samples;
  // }

  // List<double> scaleWaveData(List<double> data,
  //     {double targetMax = 32, double targetMin = 1}) {
  //   if (data.isEmpty) return [];

  //   double currentMin = data.reduce(min);
  //   double currentMax = data.reduce(max);

  //   // Avoid division by zero
  //   if (currentMax == currentMin) {
  //     return List.filled(data.length, targetMin);
  //   }

  //   // Scale the values
  //   return data.map((x) {
  //     return ((x - currentMin) / (currentMax - currentMin)) *
  //             (targetMax - targetMin) +
  //         targetMin;
  //   }).toList();
  // }

  Future<void> extractWavedata() async {
    if (!_mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cacheKey = widget.postId!;

    List<String>? cachedData = prefs.getStringList(cacheKey);

    if (!_mounted) return;

    if (cachedData != null && cachedData.isNotEmpty) {
      waveForm = cachedData.map((e) => double.tryParse(e) ?? 6.0).toList();
      _safeSetState(() {
        waveForm = waveForm.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
      });
    } else {
      final result = await waveformExtractor.extractWaveform(
        widget.noteUrl,
        useCache: true,
        cacheKey: cacheKey,
      );

      if (!_mounted) return;

      List<int> waveForms = result.waveformData;

      _safeSetState(() {
        waveForm = waveForms.map((e) => e < 1 ? 6.0 : e.toDouble()).toList();
      });

      await prefs.setStringList(
          cacheKey, waveForms.map((e) => e.toString()).toList());
    }

    if (!_mounted) return;

    waveHeights = List.filled(waveForm.length, 1.0);
    _safeSetState(() {});
    dev.log('$waveForm');
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    widget.duration = Duration.zero;
    _scrollController.dispose();
    _mounted = false;
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

  void scrollToPosition(Duration position) {
    if (waveForm.isNotEmpty && _scrollController.hasClients) {
      final progressPercent =
          position.inMilliseconds / widget.duration.inMilliseconds;
      final targetScrollOffset =
          progressPercent * waveForm.length * widget.width - widget.width / 2;
      _scrollController.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    dev.log('before: ${samples}');
    // // samples = samples.map((e) => e < 0.4 ? 4.0 : e * 13).toList();
    // dev.log('after: ${samples}');
    // lo.log('Waveform plugin: ${waveForm}');

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
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (widget.isProfilePlayer)
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
                                  child:
                                      SvgPicture.asset('assets/icons/Lock.svg'),
                                ),
                              );
                            })
                          : InkWell(
                              splashColor: Colors.transparent,
                              onTap: widget.playPause,
                              child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    border: widget.isProfilePlayer
                                        ? Border.all(
                                            color: whiteColor, width: 5)
                                        : null,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  // onPressed: playPause,
                                  child: Icon(
                                    widget.isPlaying &&
                                            widget.changeIndex ==
                                                widget.currentIndex
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: primaryColor,
                                    size: 20,
                                  )),
                            ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          widget.playPause();
                          // scrollToPosition(widget.position);
                        },
                        child: Consumer<FilterProvider>(
                            builder: (context, filterPro, _) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: filterPro.selectedFilter
                                      .contains('Close Friends')
                                  ? greenColor
                                  : widget.waveColor ?? primaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: widget.isPlaying &&
                                    widget.currentIndex == widget.changeIndex
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
                  if (widget.isProfilePlayer)
                    Consumer<FilterProvider>(builder: (context, filterPro, _) {
                      return SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) async {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                            },
                            onHorizontalDragEnd: (details) {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                            },
                            onTapUp: (details) {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                              // scrollToPosition(seekPosition);
                            },
                            child: CustomPaint(
                              size: Size(widget.width, widget.height),
                              painter: RectangleActiveWaveformPainter(
                                onSeek: (position) {
                                  widget.audioPlayer.seek(position);
                                  // scrollToPosition(position);
                                },
                                activeColor:
                                    widget.changeIndex == widget.currentIndex &&
                                            widget.isPlaying
                                        ? whiteColor
                                        : whiteColor.withOpacity(0.5),
                                inactiveColor: whiteColor.withOpacity(0.5),
                                scrollController: _scrollController,
                                duration: widget.duration,
                                position: widget.position,
                                style: PaintingStyle.fill,
                                activeSamples:
                                    Platform.isIOS ? samples : waveForm,
                                borderColor: primaryColor.withOpacity(0.5),
                                sampleWidth: 2.5,
                                borderWidth: BorderSide.strokeAlignCenter,
                                color: filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? greenColor.withOpacity(0.5)
                                    : primaryColor.withOpacity(0.5),
                                isCentered: true,
                                isRoundedRectangle: true,
                                waveformAlignment:
                                    audo.WaveformAlignment.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  else
                    Consumer<FilterProvider>(builder: (context, filterPro, _) {
                      return SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: GestureDetector(
                            onHorizontalDragStart: (details) async {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                            },
                            onHorizontalDragEnd: (details) {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                            },
                            onTapUp: (details) {
                              final position = details.localPosition.dx /
                                  widget.width *
                                  widget.duration.inMilliseconds;
                              final seekPosition =
                                  Duration(milliseconds: position.toInt());
                              widget.audioPlayer.seek(seekPosition);
                              // scrollToPosition(seekPosition);
                            },
                            child: CustomPaint(
                              size: Size(widget.width, widget.height),
                              painter: RectangleActiveWaveformPainter(
                                onSeek: (position) {
                                  widget.audioPlayer.seek(position);
                                  // scrollToPosition(position);
                                },
                                activeColor: filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? greenColor
                                    : primaryColor,
                                inactiveColor: filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? greenColor.withOpacity(0.5)
                                    : primaryColor.withOpacity(0.5),
                                scrollController: _scrollController,
                                duration: widget.duration,
                                position: widget.position,
                                style: PaintingStyle.fill,
                                activeSamples:
                                    Platform.isIOS ? samples : waveForm,
                                borderColor: primaryColor.withOpacity(0.5),
                                sampleWidth: 2.5,
                                borderWidth: BorderSide.strokeAlignCenter,
                                color: filterPro.selectedFilter
                                        .contains('Close Friends')
                                    ? greenColor.withOpacity(0.5)
                                    : primaryColor.withOpacity(0.5),
                                isCentered: true,
                                isRoundedRectangle: true,
                                waveformAlignment:
                                    audo.WaveformAlignment.center,
                              ),
                            ),
                          ),
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
                        widget.position.inSeconds == 0
                            ? Text(
                                getInitialDurationnText(widget.duration),
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: widget.isProfilePlayer ? 10 : 12,
                                  color: widget.isProfilePlayer
                                      ? whiteColor
                                      : filterPro.selectedFilter
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
                                  fontSize: widget.isProfilePlayer ? 10 : 12,
                                  color: widget.isProfilePlayer
                                      ? whiteColor
                                      : filterPro.selectedFilter
                                              .contains('Close Friends')
                                          ? greenColor
                                          : widget.waveColor ?? primaryColor,
                                ),
                              ),
                        const SizedBox(height: 5),
                        if (widget.waveColor == null)
                          InkWell(
                            onTap: () {
                              _safeSetState(() {
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
            ],
          ),
        ),
      ),
    );
  }
}

class RectangleActiveWaveformPainter extends audo.ActiveWaveformPainter {
  RectangleActiveWaveformPainter({
    required super.color,
    required super.activeSamples,
    required super.waveformAlignment,
    required super.sampleWidth,
    required super.borderColor,
    required super.borderWidth,
    required this.isRoundedRectangle,
    required this.isCentered,
    required this.duration,
    required this.position,
    required this.scrollController,
    required this.activeColor,
    required this.inactiveColor,
    required this.onSeek,
    super.gradient,
    super.style = PaintingStyle.fill,
  }) {
    // Attach a listener to the ScrollController
    scrollController.addListener(_onScroll);
  }

  final bool isRoundedRectangle;
  final bool isCentered;
  final Duration duration;
  final Duration position;
  final ScrollController scrollController;
  final Color activeColor;
  final Color inactiveColor;
  final Function(Duration) onSeek; // Callback to perform seek

  void _onScroll() {
    final scrollOffset = scrollController.offset;
    final totalSamples = activeSamples.length;
    final scrollPositionInSamples = scrollOffset / sampleWidth;
    final percentScrolled = scrollPositionInSamples / totalSamples;
    final newPosition = Duration(
        milliseconds: (percentScrolled * duration.inMilliseconds).toInt());

    // Seek to the new position using the callback
    onSeek(newPosition);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = borderWidth
      ..color = borderColor;

    final paint = Paint()
      ..style = style
      ..color = color;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }

    final alignPosition = waveformAlignment.getAlignPosition(size.height);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (duration.inMilliseconds == 0 || activeSamples.isEmpty) {
      canvas.restore();
      return;
    }

    final progressPercent = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    final currentSampleIndex = (progressPercent * activeSamples.length).floor();

    final scrollOffset = scrollController.offset;

    if (isRoundedRectangle) {
      drawRoundedRectangles(
        canvas,
        alignPosition,
        borderPaint,
        waveformAlignment,
        isCentered,
        size,
        currentSampleIndex,
        progressPercent,
        scrollOffset,
      );
    } else {
      drawRegularRectangles(
        canvas,
        alignPosition,
        borderPaint,
        waveformAlignment,
        isCentered,
        size,
        currentSampleIndex,
        progressPercent,
        scrollOffset,
      );
    }

    canvas.restore();
  }

  void drawRegularRectangles(
    Canvas canvas,
    double alignPosition,
    Paint borderPaint,
    audo.WaveformAlignment waveformAlignment,
    bool isCentered,
    Size size,
    int currentSampleIndex,
    double progressPercent,
    double scrollOffset,
  ) {
    final visibleSampleCount = (size.width / sampleWidth).floor();
    for (var i = 0; i < visibleSampleCount; i++) {
      final x = sampleWidth * (i + scrollOffset / sampleWidth).floor();
      if (x >= size.width + scrollOffset) break;

      final sampleIndex = activeSamples.isNotEmpty
          ? (i / visibleSampleCount * activeSamples.length).floor()
          : 0;
      final isAbsolute = waveformAlignment != audo.WaveformAlignment.center;
      final y = isCentered && !isAbsolute
          ? activeSamples[sampleIndex] * 23
          : activeSamples[sampleIndex];
      final positionFromTop =
          isCentered && !isAbsolute ? alignPosition - y / 2 : alignPosition;

      final paint = Paint()
        ..style = style
        ..color =
            sampleIndex <= currentSampleIndex ? activeColor : inactiveColor;

      canvas.drawRect(
        Rect.fromLTWH(x - scrollOffset, positionFromTop, sampleWidth, y),
        paint,
      );
    }
  }

  void drawRoundedRectangles(
    Canvas canvas,
    double alignPosition,
    Paint borderPaint,
    audo.WaveformAlignment waveformAlignment,
    bool isCentered,
    Size size,
    int currentSampleIndex,
    double progressPercent,
    double scrollOffset,
  ) {
    final visibleSampleCount = (size.width / sampleWidth).floor();
    for (var i = 0; i < visibleSampleCount; i++) {
      if (i.isEven) {
        final x = sampleWidth * (i + scrollOffset / sampleWidth).floor();
        if (x >= size.width + scrollOffset)
          break; // Ensure rounded rectangles stay within the width

        final sampleIndex = activeSamples.isNotEmpty
            ? (i / visibleSampleCount * activeSamples.length).floor()
            : 0;
        final isAbsolute = waveformAlignment != audo.WaveformAlignment.center;
        final y = isAbsolute
            ? activeSamples[sampleIndex]
            : !isCentered
                ? activeSamples[sampleIndex]
                : activeSamples[sampleIndex] * 2;
        final positionFromTop = isAbsolute
            ? alignPosition
            : !isCentered
                ? alignPosition
                : alignPosition - y / 2;

        final paint = Paint()
          ..style = style
          ..color =
              sampleIndex <= currentSampleIndex ? activeColor : inactiveColor;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - scrollOffset, positionFromTop, sampleWidth, y),
            Radius.circular(sampleWidth / 2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RectangleActiveWaveformPainter oldDelegate) {
    return getShouldRepaintValue(oldDelegate) ||
        isRoundedRectangle != oldDelegate.isRoundedRectangle ||
        isCentered != oldDelegate.isCentered ||
        duration != oldDelegate.duration ||
        position != oldDelegate.position ||
        scrollController != oldDelegate.scrollController;
  }
}
