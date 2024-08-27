import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

class MostListenedWaves extends AudioWaveform {
  MostListenedWaves({
    super.key,
    required super.samples,
    required super.height,
    required super.width,
    super.maxDuration,
    super.elapsedDuration,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.blue,
    this.strokeWidth = 1.0,
    this.style = PaintingStyle.stroke,
    super.showActiveWaveform = true,
    super.absolute = false,
    super.invert = false,
  }) : assert(strokeWidth >= 0, "strokeWidth can't be negative.");

  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  AudioWaveformState<MostListenedWaves> createState() =>
      _SquigglyWaveformState();
}

class _SquigglyWaveformState extends AudioWaveformState<MostListenedWaves> {
  @override
  Widget build(BuildContext context) {
    if (widget.samples.isEmpty) {
      return const SizedBox.shrink();
    }
    final processedSamples = this.processedSamples;
    final activeRatio = this.activeRatio;
    final waveformAlignment = this.waveformAlignment;

    return CustomPaint(
      size: Size(widget.width, widget.height),
      isComplex: true,
      painter: CurvedPolygonActiveInActiveWaveformPainter(
        samples: processedSamples,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
        activeRatio: activeRatio,
        waveformAlignment: waveformAlignment,
        strokeWidth: widget.strokeWidth,
        sampleWidth: sampleWidth,
        style: widget.style,
      ),
    );
  }
}

class CurvedPolygonActiveInActiveWaveformPainter
    extends ActiveInActiveWaveformPainter {
  CurvedPolygonActiveInActiveWaveformPainter({
    required super.samples,
    required super.waveformAlignment,
    required super.sampleWidth,
    required super.activeRatio,
    required super.inactiveColor,
    required super.activeColor,
    required super.strokeWidth,
    required super.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = style
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: const Alignment(-1.001, 0),
        end: const Alignment(1.001, 0),
        colors: [
          activeColor,
          inactiveColor,
        ],
        stops: [activeRatio, 0],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();

    final bezierSamplesList = <double>[];
    for (var i = 0; i < samples.length; i++) {
      final currentPoint = samples[i];
      final nextPoint = i + 1 > samples.length - 1 ? 0.0 : samples[i + 1];
      bezierSamplesList.add(currentPoint);
      final averagePoint = (nextPoint + currentPoint) / 2;
      bezierSamplesList.add(averagePoint);
      final averagePoint2 = (nextPoint + averagePoint) / 2;
      bezierSamplesList.add(averagePoint2);
    }

    bezierSamplesList.add(0);
    final updatedWidth = size.width / bezierSamplesList.length;

    path.moveTo(0, 0); // Start the path from the top of the container

    for (var i = 0; i < bezierSamplesList.length; i += 3) {
      final x = updatedWidth * i;
      final y = bezierSamplesList[i];
      final doNotDrawPath = i + 1 > bezierSamplesList.length - 1 ||
          i + 2 > bezierSamplesList.length - 1 ||
          i + 3 > bezierSamplesList.length - 1;

      if (!doNotDrawPath) {
        final x1 = updatedWidth * (i + 1);
        final y1 = bezierSamplesList[i + 1];
        final x2 = updatedWidth * (i + 2);
        final y2 = bezierSamplesList[i + 2];

        path.cubicTo(x, y, x1, y1, x2, y2);
      }
    }

    // Flipping the path vertically
    final matrix4 = Matrix4.identity()
      ..scale(1.0, -1.0, 1.0)
      ..translate(0.0, -size.height);
    final flippedPath = path.transform(matrix4.storage);

    final alignPosition = waveformAlignment.getAlignPosition(size.height);
    final shiftedPath = flippedPath.shift(Offset(0, alignPosition));

    canvas.drawPath(shiftedPath, paint);
  }
}
