// // import 'dart:developer';

// // import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:audioplayers/audioplayers.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// // import 'package:flutter/widgets.dart';

// import 'package:social_notes/resources/colors.dart';

// import 'package:waveform_extractor/model/waveform.dart';
// import 'package:waveform_extractor/waveform_extractor.dart';

// class CustomProgressPlayer extends StatefulWidget {
//   CustomProgressPlayer(
//       {Key? key,
//       required this.noteUrl,
//       required this.height,
//       required this.width,
//       required this.mainWidth,
//       required this.mainHeight,
//       this.backgroundColor = Colors.white,
//       this.size = 35,
//       this.waveColor})
//       : super(key: key);

//   final String noteUrl;
//   final double height;
//   final double width;
//   final double mainWidth;
//   final double mainHeight;
//   final Color backgroundColor;
//   double size;

//   Color? waveColor;

//   @override
//   State<CustomProgressPlayer> createState() => _CustomProgressPlayerState();
// }

// class _CustomProgressPlayerState extends State<CustomProgressPlayer> {
//   late AudioPlayer _audioPlayer;
//   // audi.PlayerController _playerController = audi.PlayerController();
//   String? _cachedFilePath;
//   bool _isPlaying = false;
//   double _playbackSpeed = 1.0; // Default playback speed
//   // PlayerState? _playerState;
//   Waveform? _waveform;

//   @override
//   void initState() {
//     initPlayer();
//     _loadWaveform();
//     super.initState();
//   }

//   initPlayer() async {
//     _audioPlayer = AudioPlayer();
//     _audioPlayer.setReleaseMode(ReleaseMode.stop);
//     _audioPlayer.setSourceUrl(widget.noteUrl);
//     // _playerState = _audioPlayer.state;

//     // Check if the file is already cached
//     DefaultCacheManager().getFileFromCache(widget.noteUrl).then((file) {
//       if (file != null && file.file.existsSync()) {
//         _cachedFilePath = file.file.path;
//       }
//     });

//     _audioPlayer.onDurationChanged.listen((event) {
//       setState(() {
//         duration = event;
//       });
//     });
//     _audioPlayer.onPositionChanged.listen((event) {
//       setState(() {
//         position = event;
//       });
//     });

//     _audioPlayer.onPlayerComplete.listen((state) {
//       setState(() {
//         _isPlaying = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   void playPause() async {
//     if (_isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       if (_cachedFilePath != null) {
//         await _audioPlayer
//             .setPlaybackRate(_playbackSpeed); // Set playback speed
//         await _audioPlayer.play(UrlSource(_cachedFilePath!));
//       } else {
//         // Cache the file if not already cached
//         DefaultCacheManager().downloadFile(widget.noteUrl).then((fileInfo) {
//           if (fileInfo != null && fileInfo.file.existsSync()) {
//             _cachedFilePath = fileInfo.file.path;
//             _audioPlayer.setPlaybackRate(_playbackSpeed); // Set playback speed
//             _audioPlayer.play(
//               UrlSource(_cachedFilePath!),
//             );
//           }
//         });
//       }
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   List<double> doubleWaveformData = [];

//   Future<void> _loadWaveform() async {
//     final waveformExtractor = WaveformExtractor();
//     _waveform = await waveformExtractor.extractWaveform(widget.noteUrl);
//     final List<int> intWaveformData = _waveform!.waveformData;
//     doubleWaveformData =
//         intWaveformData.map((value) => value.toDouble()).toList();
//     // Waveform(
//     //   duration: _waveform!.duration,
//     //   waveformData:
//     //       _waveform!.waveformData.map((value) => value.toInt()).toList(),
//     //   amplitudesForFirstSecond: [],
//     //   source: '',
//     // );
//     // setState(() {});
//     setState(() {});
//   }

//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   // String _formatDuration(Duration duration) {
//   //   String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
//   //   String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
//   //   return '$minutes:$seconds';
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // log('waves data are $doubleWaveformData');
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             height: widget.mainHeight,
//             width: widget.mainWidth,
//             decoration: BoxDecoration(
//               color: widget.backgroundColor,
//               borderRadius: BorderRadius.circular(55),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   onPressed: playPause,
//                   icon: _isPlaying
//                       ? Icon(
//                           Icons.pause_circle_filled,
//                           color: widget.waveColor ?? Colors.red,
//                           size: widget.size,
//                         )
//                       : Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Icon(
//                               Icons.play_circle_fill,
//                               color: widget.waveColor ?? Colors.red,
//                               size: widget.size,
//                             ),
//                           ],
//                         ),
//                 ),
//                 Expanded(
//                   child: SizedBox(
//                     child: CustomPaint(
//                       painter: PlayerWavePainter(
//                         waveformData:
//                             doubleWaveformData.map((e) => e / 1).toList(),
//                         showTop: true,
//                         showBottom: true,
//                         animValue: 1,
//                         scaleFactor: 3,
//                         waveColor: widget.waveColor ?? primaryColor,
//                         waveCap: StrokeCap.round,
//                         waveThickness: 2,
//                         dragOffset: Offset.zero,
//                         totalBackDistance: Offset.zero,
//                         spacing: 4,
//                         audioProgress: position.inSeconds /
//                             duration.inSeconds /
//                             duration.inSeconds,
//                         liveWaveColor: greenColor,
//                         pushBack: () {},
//                         callPushback: false,
//                         scrollScale: 1,
//                         seekLineThickness: 2.0,
//                         seekLineColor: primaryColor,
//                         showSeekLine: false,
//                         waveformType: WaveformType.fitWidth,
//                         cachedAudioProgress:
//                             position.inSeconds / duration.inSeconds,
//                         liveWaveGradient: null,
//                         fixedWaveGradient: null,
//                       ),
//                     ),
//                     // AudioFileWaveforms(
//                     //   size: MediaQuery.of(context).size,
//                     //   playerController: _playerController,
//                     //   animationDuration: duration,
//                     //   waveformData: _waveform!.waveformData,
//                     // ),
//                     // TweenAnimationBuilder<double>(
//                     //   tween: Tween<double>(begin: 0.0, end: 1.0),
//                     //   duration: duration,
//                     //   builder: (context, tweenProgress, child) {
//                     //     double progress = position.inSeconds / duration.inSeconds;
//                     //     final color = duration.inSeconds > 0
//                     //         ? Color.lerp(primaryColor, Colors.black, progress)!
//                     //         : primaryColor;
//                     //     return WaveformProgressbar(
//                     //       color: primaryColor,
//                     //       //  widget.waveColor == null
//                     //       //     ? primaryColor
//                     //       //     : widget.waveColor!,
//                     //       progressColor: greenColor,
//                     //       // widget.waveColor == null ? color : widget.waveColor!,
//                     //       progress: progress,
//                     //       onTap: (progress) {
//                     //         if (_cachedFilePath != null) {
//                     //           Duration seekPosition = Duration(
//                     //               seconds: (progress * duration.inSeconds).round());
//                     //           _audioPlayer.seek(seekPosition);
//                     //         }
//                     //       },
//                     //     );
//                     //   },
//                     // ),
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       '${position.inSeconds}:${duration.inSeconds}',
//                       style: TextStyle(
//                         fontFamily: fontFamily,
//                         fontSize: 14,
//                         color: widget.waveColor ?? primaryColor,
//                       ),
//                     ),
//                     if (widget.waveColor == null)
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             if (_playbackSpeed == 1.0) {
//                               _playbackSpeed = 1.5;
//                             } else if (_playbackSpeed == 1.5) {
//                               _playbackSpeed = 2.0;
//                             } else {
//                               _playbackSpeed = 1.0;
//                             }
//                             // Set playback speed if audio is already playing
//                             if (_isPlaying) {
//                               _audioPlayer.setPlaybackRate(_playbackSpeed);
//                             }
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 4, vertical: 4),
//                           decoration: BoxDecoration(
//                               color: primaryColor,
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Text(
//                             '${_playbackSpeed}X',
//                             style: TextStyle(
//                               color: whiteColor,
//                               fontFamily: fontFamily,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlayerWavePainter extends CustomPainter {
//   final List<double> waveformData;
//   final bool showTop;
//   final bool showBottom;
//   final double animValue;
//   final double scaleFactor;
//   final Color waveColor;
//   final StrokeCap waveCap;
//   final double waveThickness;
//   final Shader? fixedWaveGradient;
//   final Shader? liveWaveGradient;
//   final double spacing;
//   final Offset totalBackDistance;
//   final Offset dragOffset;
//   final double audioProgress;
//   final Color liveWaveColor;
//   final VoidCallback pushBack;
//   final bool callPushback;
//   final double emptySpace;
//   final double scrollScale;
//   final bool showSeekLine;
//   final double seekLineThickness;
//   final Color seekLineColor;
//   final WaveformType waveformType;

//   PlayerWavePainter({
//     required this.waveformData,
//     required this.showTop,
//     required this.showBottom,
//     required this.animValue,
//     required this.scaleFactor,
//     required this.waveColor,
//     required this.waveCap,
//     required this.waveThickness,
//     required this.dragOffset,
//     required this.totalBackDistance,
//     required this.spacing,
//     required this.audioProgress,
//     required this.liveWaveColor,
//     required this.pushBack,
//     required this.callPushback,
//     required this.scrollScale,
//     required this.seekLineThickness,
//     required this.seekLineColor,
//     required this.showSeekLine,
//     required this.waveformType,
//     required this.cachedAudioProgress,
//     this.liveWaveGradient,
//     this.fixedWaveGradient,
//   })  : fixedWavePaint = Paint()
//           ..color = waveColor
//           ..strokeWidth = waveThickness
//           ..strokeCap = waveCap
//           ..shader = fixedWaveGradient,
//         liveWavePaint = Paint()
//           ..color = liveWaveColor
//           ..strokeWidth = waveThickness
//           ..strokeCap = waveCap
//           ..shader = liveWaveGradient,
//         emptySpace = spacing,
//         middleLinePaint = Paint()
//           ..color = seekLineColor
//           ..strokeWidth = seekLineThickness;

//   Paint fixedWavePaint;
//   Paint liveWavePaint;
//   Paint middleLinePaint;
//   double cachedAudioProgress;

//   @override
//   void paint(Canvas canvas, Size size) {
//     _drawWave(size, canvas);
//     if (showSeekLine && waveformType.isLong) _drawMiddleLine(size, canvas);
//   }

//   @override
//   bool shouldRepaint(PlayerWavePainter oldDelegate) => true;

//   void _drawMiddleLine(Size size, Canvas canvas) {
//     canvas.drawLine(
//       Offset(size.width / 2, 0),
//       Offset(size.width / 2, size.height),
//       fixedWavePaint
//         ..color = seekLineColor
//         ..strokeWidth = seekLineThickness,
//     );
//   }

//   void _drawWave(Size size, Canvas canvas) {
//     final length = waveformData.length;
//     final halfWidth = size.width * 0.5;
//     final halfHeight = size.height * 0.5;
//     if (cachedAudioProgress != audioProgress) {
//       pushBack();
//     }
//     for (int i = 0; i < length; i++) {
//       final currentDragPointer = dragOffset.dx - totalBackDistance.dx;
//       final waveWidth = i * spacing;
//       final dx = waveWidth +
//           currentDragPointer +
//           emptySpace +
//           (waveformType.isFitWidth ? 0 : halfWidth);
//       final waveHeight =
//           (waveformData[i] * animValue) * scaleFactor * scrollScale;
//       final bottomDy = halfHeight + (showBottom ? waveHeight : 0);
//       final topDy = halfHeight + (showTop ? -waveHeight : 0);

//       // Only draw waves which are in visible viewport.
//       if (dx > 0 && dx < halfWidth * 2) {
//         canvas.drawLine(
//           Offset(dx, bottomDy),
//           Offset(dx, topDy),
//           i < audioProgress * length ? liveWavePaint : fixedWavePaint,
//         );
//       }
//     }
//   }
// }
// // class WaveformPainter extends CustomPainter {
// //   final List<double> amplitudes;
// //   final Color color;
// //   final double strokeWidth;

// //   WaveformPainter({
// //     required this.amplitudes,
// //     required this.color,
// //     this.strokeWidth = 2.0,
// //   });

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final Paint paint = Paint()
// //       ..color = color
// //       ..strokeWidth = strokeWidth
// //       ..style = PaintingStyle.stroke;

// //     final double width = size.width;
// //     final double height = size.height;

// //     final Path path = Path();

// //     final double halfHeight = height / 2;
// //     final double amplitudeFactor = height / 2;

// //     final double midY = halfHeight;

// //     path.moveTo(0, midY);

// //     for (int i = 0; i < amplitudes.length; i++) {
// //       final double x = (i / amplitudes.length) * width;
// //       final double y = midY - (amplitudes[i] * amplitudeFactor);
// //       path.lineTo(x, y);
// //     }

// //     canvas.drawPath(path, paint);
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// //     return true;
// //   }
// // }

// class WavesCustom extends StatelessWidget {
//   final List<double> amplitudes;

//   const WavesCustom(this.amplitudes, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100.0,
//       child: CustomPaint(
//         painter: WaveformPainter(amplitudes),
//       ),
//     );
//   }
// }

// ///
// class WaveformPainter extends CustomPainter {
//   final List<double> amplitudes;

//   WaveformPainter(this.amplitudes);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.blue
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 4.0;

//     final Path path = Path();

//     for (int i = 0; i < amplitudes.length; i++) {
//       final double x = i * size.width / (amplitudes.length - 1);
//       final double y = (1 - amplitudes[i]) * size.height / 2;

//       if (i == 0) {
//         path.moveTo(x, y);
//       } else {
//         path.lineTo(x, y);
//       }
//     }

//     // Adding gradient
//     paint.shader = LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [
//         Colors.blue.withOpacity(0.5),
//         Colors.blue.withOpacity(0.0),
//       ],
//     ).createShader(Rect.fromPoints(Offset(0, 0), Offset(0, size.height)));

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
