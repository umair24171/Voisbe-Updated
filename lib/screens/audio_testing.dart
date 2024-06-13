import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

///This will paint the waveform
///
///Addtional Information to play around
///
///this gives location of first wave from right to left when scrolling
///
///-totalBackDistance.dx + dragOffset.dx + (spacing * i)
///
///this gives location of first wave from left to right when scrolling
///
///-totalBackDistance.dx + dragOffset.dx
class RecorderWavePainter extends CustomPainter {
  final List<double> waveData;
  final Color waveColor;
  final bool showMiddleLine;
  final double spacing;
  final double initialPosition;
  final bool showTop;
  final bool showBottom;
  final double bottomPadding;
  final StrokeCap waveCap;
  final Color middleLineColor;
  final double middleLineThickness;
  final Offset totalBackDistance;
  final Offset dragOffset;
  final double waveThickness;
  final VoidCallback pushBack;
  final bool callPushback;
  final bool extendWaveform;
  final bool showDurationLabel;
  final bool showHourInDuration;
  final double updateFrequecy;
  final Paint _wavePaint;
  final Paint _linePaint;
  final Paint _durationLinePaint;
  final TextStyle durationStyle;
  final Color durationLinesColor;
  final double durationTextPadding;
  final double durationLinesHeight;
  final double labelSpacing;
  final Shader? gradient;
  final bool shouldClearLabels;
  final VoidCallback revertClearLabelCall;
  final Function(int) setCurrentPositionDuration;
  final bool shouldCalculateScrolledPosition;
  final double scaleFactor;
  final Duration currentlyRecordedDuration;

  RecorderWavePainter({
    required this.waveData,
    required this.waveColor,
    required this.showMiddleLine,
    required this.spacing,
    required this.initialPosition,
    required this.showTop,
    required this.showBottom,
    required this.bottomPadding,
    required this.waveCap,
    required this.middleLineColor,
    required this.middleLineThickness,
    required this.totalBackDistance,
    required this.dragOffset,
    required this.waveThickness,
    required this.pushBack,
    required this.callPushback,
    required this.extendWaveform,
    required this.updateFrequecy,
    required this.showHourInDuration,
    required this.showDurationLabel,
    required this.durationStyle,
    required this.durationLinesColor,
    required this.durationTextPadding,
    required this.durationLinesHeight,
    required this.labelSpacing,
    required this.gradient,
    required this.shouldClearLabels,
    required this.revertClearLabelCall,
    required this.setCurrentPositionDuration,
    required this.shouldCalculateScrolledPosition,
    required this.scaleFactor,
    required this.currentlyRecordedDuration,
  })  : _wavePaint = Paint()
          ..color = waveColor
          ..strokeWidth = waveThickness
          ..strokeCap = waveCap,
        _linePaint = Paint()
          ..color = middleLineColor
          ..strokeWidth = middleLineThickness,
        _durationLinePaint = Paint()
          ..strokeWidth = 3
          ..color = durationLinesColor;
  var _labelPadding = 0.0;

  final List<Label> _labels = [];
  static const int durationBuffer = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (shouldClearLabels) {
      _labels.clear();
      pushBack();
      revertClearLabelCall();
    }
    for (var i = 0; i < waveData.length; i++) {
      ///wave gradient
      if (gradient != null) _waveGradient();

      if (((spacing * i) + dragOffset.dx + spacing >
              size.width / (extendWaveform ? 1 : 2) + totalBackDistance.dx) &&
          callPushback) {
        pushBack();
      }

      ///draws waves
      _drawWave(canvas, size, i);

      ///duration labels
      if (showDurationLabel) {
        _addLabel(canvas, i, size);
        _drawTextInRange(canvas, i, size);
      }
    }

    ///middle line
    if (showMiddleLine) _drawMiddleLine(canvas, size);

    ///calculates scrolled position with respect to duration
    if (shouldCalculateScrolledPosition) _setScrolledDuration(size);
  }

  @override
  bool shouldRepaint(RecorderWavePainter oldDelegate) => true;

  void _drawTextInRange(Canvas canvas, int i, Size size) {
    if (_labels.isNotEmpty && i < _labels.length) {
      final label = _labels[i];
      final content = label.content;
      final offset = label.offset;
      final halfWidth = size.width * 0.5;
      final textSpan = TextSpan(
        text: content,
        style: durationStyle,
      );

      // Text painting is performance intensive process so we will only render
      // labels whose position is greater then -halfWidth and triple of
      // halfWidth because it will be in visible viewport and it has extra
      // buffer so that bigger labels can be visible when they are extremely at
      // right or left.
      if (offset.dx > -halfWidth && offset.dx < halfWidth * 3) {
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(minWidth: 0, maxWidth: halfWidth * 2);
        textPainter.paint(canvas, offset);
      }
    }
  }

  void _addLabel(Canvas canvas, int i, Size size) {
    final labelDuration = Duration(seconds: i);
    final durationLineDx = _labelPadding + dragOffset.dx - totalBackDistance.dx;
    final height = size.height;
    final currentDuration =
        Duration(seconds: currentlyRecordedDuration.inSeconds + durationBuffer);
    if (labelDuration < currentDuration) {
      canvas.drawLine(
        Offset(durationLineDx, height),
        Offset(durationLineDx, height + durationLinesHeight),
        _durationLinePaint,
      );
      _labels.add(
        Label(
          content: showHourInDuration
              ? labelDuration.toHHMMSS()
              : labelDuration.inSeconds.toMMSS(),
          offset: Offset(
            durationLineDx - durationTextPadding,
            height + labelSpacing,
          ),
        ),
      );
    }
    _labelPadding += spacing * updateFrequecy;
  }

  void _drawMiddleLine(Canvas canvas, Size size) {
    final halfWidth = size.width * 0.5;
    canvas.drawLine(
      Offset(halfWidth, 0),
      Offset(halfWidth, size.height),
      _linePaint,
    );
  }

  void _drawWave(Canvas canvas, Size size, int i) {
    final halfWidth = size.width * 0.5;
    final height = size.height;
    final dx =
        -totalBackDistance.dx + dragOffset.dx + (spacing * i) - initialPosition;
    final scaledWaveHeight = waveData[i] * scaleFactor;
    final upperDy = height - (showTop ? scaledWaveHeight : 0) - bottomPadding;
    final lowerDy =
        height + (showBottom ? scaledWaveHeight : 0) - bottomPadding;

    // To remove unnecessary rendering, we will only draw waves whose position
    // is less then double of half width which is max width and half width from
    // 0 is negative direction have some buffer on left side.
    if (dx > -halfWidth && dx < halfWidth * 2) {
      canvas.drawLine(Offset(dx, upperDy), Offset(dx, lowerDy), _wavePaint);
    }
  }

  void _waveGradient() {
    _wavePaint.shader = gradient;
  }

  void _setScrolledDuration(Size size) {
    setCurrentPositionDuration(
        (((-totalBackDistance.dx + dragOffset.dx - (size.width / 2)) /
                    (spacing * updateFrequecy)) *
                1000)
            .abs()
            .toInt());
  }
}


///Duration labels for AudioWaveform widget.
class Label {
  /// Fixed label content for a single instance.
  final String content;

  /// An offset for labels which get new position everytime waveforms are
  /// scrolled.
  Offset offset;

  Label({
    required this.content,
    required this.offset,
  });
}

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

// class WaveformPainter extends CustomPainter {
//   final List<double> waveform;
//   final double waveHeight;
//   final Color waveColor;

//   WaveformPainter({
//     required this.waveform,
//     this.waveHeight = 100.0,
//     this.waveColor = Colors.blue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = waveColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     final path = Path();
//     final widthPerSample = size.width / waveform.length;

//     for (int i = 0; i < waveform.length; i++) {
//       final x = i * widthPerSample;
//       final y = size.height / 2 - (waveform[i] * waveHeight);
//       if (i == 0) {
//         path.moveTo(x, y);
//       } else {
//         path.lineTo(x, y);
//       }
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class WaveformWidget extends StatelessWidget {
//   final List<double> waveform;

//   WaveformWidget({required this.waveform});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       size: Size(double.infinity, 200), // You can set the height you want
//       painter: WaveformPainter(waveform: waveform),
//     );
//   }
// }


// class AudioTesting extends StatefulWidget {
//   const AudioTesting({super.key, required this.path});

//   final String path;

//   @override
//   State<AudioTesting> createState() => _AudioTestingState();
// }

// class _AudioTestingState extends State<AudioTesting> {
//   PlayerController controller = PlayerController();
//   List<double> waveformData = [];

//   @override
//   void initState() {
//     super.initState();
//     preparePlayer();
//     controller.onCompletion.listen((_) {
//       controller.seekTo(0);
//     });
//   }

//   preparePlayer() async {
//     await controller.preparePlayer(
//       path: widget.path,
//       shouldExtractWaveform: true,
//       noOfSamples: 100,
//       volume: 1.0,
//     );
//     waveformData = await controller.extractWaveformData(
//       path: 'path',
//       noOfSamples: 100,
//     );
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         IconButton(
//             onPressed: () {
//               if (controller.playerState.isPlaying) {
//                 controller.stopPlayer();
//               } else {
//                 controller.startPlayer(finishMode: FinishMode.stop);
//               }
//             },
//             icon: Icon(Icons.play_circle)),
//         AudioFileWaveforms(
//           size: Size(MediaQuery.of(context).size.width, 100.0),
//           playerController: controller,
//           enableSeekGesture: true,
//           waveformType: WaveformType.long,
//           waveformData: waveformData,
//           playerWaveStyle: const PlayerWaveStyle(
//             fixedWaveColor: Colors.white54,
//             liveWaveColor: Colors.blueAccent,
//             spacing: 6,
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'dart:io';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:just_waveform/just_waveform.dart';
// import 'package:dio/dio.dart';

// class AudioTesting extends StatefulWidget {
//   const AudioTesting({Key? key}) : super(key: key);

//   @override
//   State<AudioTesting> createState() => _AudioTestingState();
// }

// class _AudioTestingState extends State<AudioTesting> {
//   final progressStream = BehaviorSubject<WaveformProgress>();

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     final audioFile =
//         File(p.join((await getTemporaryDirectory()).path, 'waveform.mp3'));
//     final dio = Dio();
//     final response = await dio.get(
//         'https://firebasestorage.googleapis.com/v0/b/voisbe.appspot.com/o/voices%2Fd18e8809-8ae9-429a-a72c-601a775c97e5?alt=media&token=b3afd27c-2f2f-4f5d-8dbc-3e746b7c72bf',
//         options: Options(responseType: ResponseType.bytes));

//     await audioFile
//         .writeAsBytes(Uint8List.fromList(response.data as List<int>));
//     final waveFile =
//         File(p.join((await getTemporaryDirectory()).path, 'waveform.wave'));
//     JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile)
//         .listen(progressStream.add, onError: progressStream.addError);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             height: 150.0,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: const BorderRadius.all(Radius.circular(20.0)),
//             ),
//             padding: const EdgeInsets.all(16.0),
//             width: double.maxFinite,
//             child: StreamBuilder<WaveformProgress>(
//               stream: progressStream,
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       'Error: ${snapshot.error}',
//                       style: Theme.of(context).textTheme.titleLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }
//                 final progress = snapshot.data?.progress ?? 0.0;
//                 final waveform = snapshot.data?.waveform;
//                 if (waveform == null) {
//                   return Center(
//                     child: Text(
//                       '${(100 * progress).toInt()}%',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                   );
//                 }
//                 return AudioWaveformWidget(
//                   waveform: waveform,
//                   start: Duration.zero,
//                   duration: waveform.duration,
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AudioWaveformWidget extends StatefulWidget {
//   final Color waveColor;
//   final double scale;
//   final double strokeWidth;
//   final double pixelsPerStep;
//   final Waveform waveform;
//   final Duration start;
//   final Duration duration;

//   const AudioWaveformWidget({
//     Key? key,
//     required this.waveform,
//     required this.start,
//     required this.duration,
//     this.waveColor = Colors.blue,
//     this.scale = 1.0,
//     this.strokeWidth = 5.0,
//     this.pixelsPerStep = 8.0,
//   }) : super(key: key);

//   @override
//   _AudioWaveformState createState() => _AudioWaveformState();
// }

// class _AudioWaveformState extends State<AudioWaveformWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return ClipRect(
//       child: CustomPaint(
//         painter: AudioWaveformPainter(
//           waveColor: widget.waveColor,
//           waveform: widget.waveform,
//           start: widget.start,
//           duration: widget.duration,
//           scale: widget.scale,
//           strokeWidth: widget.strokeWidth,
//           pixelsPerStep: widget.pixelsPerStep,
//         ),
//       ),
//     );
//   }
// }

// class AudioWaveformPainter extends CustomPainter {
//   final double scale;
//   final double strokeWidth;
//   final double pixelsPerStep;
//   final Paint wavePaint;
//   final Waveform waveform;
//   final Duration start;
//   final Duration duration;

//   AudioWaveformPainter({
//     required this.waveform,
//     required this.start,
//     required this.duration,
//     Color waveColor = Colors.blue,
//     this.scale = 1.0,
//     this.strokeWidth = 3.0,
//     this.pixelsPerStep = 5.0,
//   }) : wavePaint = Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = strokeWidth
//           ..strokeCap = StrokeCap.round
//           ..color = waveColor;

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (duration == Duration.zero) return;

//     double width = size.width;
//     double height = size.height;

//     final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
//     final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
//     final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
//     final sampleOffset = waveform.positionToPixel(start);
//     final sampleStart = -sampleOffset % waveformPixelsPerStep;
//     for (var i = sampleStart.toDouble();
//         i <= waveformPixelsPerWindow + 1.0;
//         i += waveformPixelsPerStep) {
//       final sampleIdx = (sampleOffset + i).toInt();
//       final x = i / waveformPixelsPerDevicePixel;
//       final minY = normalise(waveform.getPixelMin(sampleIdx), height);
//       final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
//       canvas.drawLine(
//         Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
//         Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
//         wavePaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
//     return false;
//   }

//   double normalise(int s, double height) {
//     if (waveform.flags == 0) {
//       final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
//       return height - 1 - y * height / 65536;
//     } else {
//       final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
//       return height - 1 - y * height / 256;
//     }
//   }
// }
