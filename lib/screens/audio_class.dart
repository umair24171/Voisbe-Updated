// import 'dart:async';
// import 'dart:math';
// import 'dart:core';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';

// import 'package:mic_stream/mic_stream.dart';

// enum Command {
//   start,
//   stop,
//   change,
// }

// int screenWidth = 0;

// class MicStreamExampleApp extends StatefulWidget {
//   @override
//   _MicStreamExampleAppState createState() => _MicStreamExampleAppState();
// }

// class _MicStreamExampleAppState extends State<MicStreamExampleApp>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   Stream<Uint8List>? stream;
//   late StreamSubscription listener;

//   List<double>? waveSamples;
//   List<double>? intensitySamples;
//   int sampleIndex = 0;
//   double localMax = 0;
//   double localMin = 0;

//   // Refreshes the Widget for every possible tick to force a rebuild of the sound wave
//   late AnimationController controller;

//   Color _iconColor = Colors.white;
//   bool isRecording = false;
//   bool memRecordingState = false;
//   late bool isActive;
//   DateTime? startTime;

//   int page = 0;
//   List state = ["SoundWavePage", "IntensityWavePage", "InformationPage"];

//   @override
//   void initState() {
//     print("Init application");
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setState(() {
//       initPlatformState();
//     });
//   }

//   void _controlPage(int index) => setState(() => page = index);

//   // Responsible for switching between recording / idle state
//   void _controlMicStream({Command command = Command.change}) async {
//     switch (command) {
//       case Command.change:
//         _changeListening();
//         break;
//       case Command.start:
//         _startListening();
//         break;
//       case Command.stop:
//         _stopListening();
//         break;
//     }
//   }

//   Future<bool> _changeListening() async =>
//       !isRecording ? await _startListening() : _stopListening();

//   late int bytesPerSample;
//   late int samplesPerSecond;

//   Future<bool> _startListening() async {
//     if (isRecording) return false;
//     // Default option. Set to false to disable request permission dialogue
//     MicStream.shouldRequestPermission(true);

//     stream = MicStream.microphone(
//         audioSource: AudioSource.DEFAULT,
//         sampleRate: 48000,
//         channelConfig: ChannelConfig.CHANNEL_IN_MONO,
//         audioFormat: AudioFormat.ENCODING_PCM_16BIT);
//     listener =
//         stream!.transform(MicStream.toSampleStream).listen(_processSamples);
//     listener.onError(print);
//     print(
//         "Start listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}, bufferSize: ${await MicStream.bufferSize}");

//     localMax = 0;
//     localMin = 0;

//     bytesPerSample = await MicStream.bitDepth ~/ 8;
//     samplesPerSecond = await MicStream.sampleRate;
//     setState(() {
//       isRecording = true;
//       startTime = DateTime.now();
//     });
//     return true;
//   }

//   void _processSamples(_sample) async {
//     if (screenWidth == 0) return;

//     double sample = 0;
//     if ("${_sample.runtimeType}" == "(int, int)" ||
//         "${_sample.runtimeType}" == "(double, double)") {
//       sample = 0.9 * (_sample.$1 + _sample.$2);
//     } else {
//       sample = _sample.toDouble();
//     }
//     waveSamples ??= List.filled(screenWidth, 0);

//     final overridden = waveSamples![sampleIndex];
//     waveSamples![sampleIndex] = sample;
//     sampleIndex = (sampleIndex + 1) % screenWidth;

//     if (overridden == localMax) {
//       localMax = 0;
//       for (final val in waveSamples!) {
//         localMax = max(localMax, val);
//       }
//     } else if (overridden == localMin) {
//       localMin = 0;
//       for (final val in waveSamples!) {
//         localMin = min(localMin, val);
//       }
//     } else {
//       if (sample > 0)
//         localMax = max(localMax, sample);
//       else
//         localMin = min(localMin, sample);
//     }

//     _calculateIntensitySamples();
//   }

//   void _calculateIntensitySamples() {}

//   bool _stopListening() {
//     if (!isRecording) return false;
//     print("Stop listening to the microphone");
//     listener.cancel();

//     setState(() {
//       isRecording = false;
//       waveSamples = List.filled(screenWidth, 0);
//       intensitySamples = List.filled(screenWidth, 0);
//       startTime = null;
//     });
//     return true;
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     if (!mounted) return;
//     isActive = true;

//     Statistics(false);

//     controller =
//         AnimationController(duration: const Duration(seconds: 1), vsync: this)
//           ..addListener(() {
//             if (isRecording) setState(() {});
//           })
//           ..addStatusListener((status) {
//             if (status == AnimationStatus.completed)
//               controller.reverse();
//             else if (status == AnimationStatus.dismissed) controller.forward();
//           })
//           ..forward();
//   }

//   Color _getBgColor() => (isRecording) ? Colors.red : Colors.cyan;
//   Icon _getIcon() =>
//       (isRecording) ? const Icon(Icons.stop) : const Icon(Icons.keyboard_voice);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark(),
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Plugin: mic_stream :: Debug'),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: _controlMicStream,
//             child: _getIcon(),
//             foregroundColor: _iconColor,
//             backgroundColor: _getBgColor(),
//             tooltip: (isRecording) ? "Stop recording" : "Start recording",
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: [
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.broken_image),
//                 label: "Sound Wave",
//               ),
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.broken_image),
//                 label: "Intensity Wave",
//               ),
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.view_list),
//                 label: "Statistics",
//               )
//             ],
//             backgroundColor: Colors.black26,
//             elevation: 20,
//             currentIndex: page,
//             onTap: _controlPage,
//           ),
//           body: (page == 0 || page == 1)
//               ? CustomPaint(
//                   painter: page == 0
//                       ? WavePainter(
//                           samples: waveSamples,
//                           color: _getBgColor(),
//                           index: sampleIndex,
//                           localMax: localMax,
//                           localMin: localMin,
//                           context: context,
//                         )
//                       : IntensityPainter(
//                           samples: intensitySamples,
//                           color: _getBgColor(),
//                           index: sampleIndex,
//                           localMax: localMax,
//                           localMin: localMin,
//                           context: context,
//                         ))
//               : Statistics(
//                   isRecording,
//                   startTime: startTime,
//                 )),
//     );
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       isActive = true;
//       print("Resume app");

//       _controlMicStream(
//           command: memRecordingState ? Command.start : Command.stop);
//     } else if (isActive) {
//       memRecordingState = isRecording;
//       _controlMicStream(command: Command.stop);

//       print("Pause app");
//       isActive = false;
//     }
//   }

//   @override
//   void dispose() {
//     listener.cancel();
//     controller.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }

// class WavePainter extends CustomPainter {
//   int? index;
//   double? localMax;
//   double? localMin;
//   List<double>? samples;
//   late List<Offset> points;
//   Color? color;
//   BuildContext? context;
//   Size? size;

//   WavePainter(
//       {this.samples,
//       this.color,
//       this.context,
//       this.index,
//       this.localMax,
//       this.localMin});

//   @override
//   void paint(Canvas canvas, Size? size) {
//     this.size = context!.size;
//     size = this.size;
//     if (size == null) return;
//     screenWidth = size.width.toInt();

//     Paint paint = new Paint()
//       ..color = color!
//       ..strokeWidth = 3.0
//       ..style = PaintingStyle.stroke;

//     samples ??= List.filled(screenWidth, 0);
//     index ??= 0;
//     points = toPoints(samples!, index!);

//     Path path = new Path();
//     path.addPolygon(points, false);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldPainting) => true;

//   // Maps a list of ints and their indices to a list of points on a cartesian grid
//   List<Offset> toPoints(List<double> samples, int index) {
//     List<Offset> points = [];
//     double totalMax = max(-1 * localMin!, localMax!);
//     double maxHeight = 0.2 * size!.height;
//     for (int i = 0; i < screenWidth; i++) {
//       double height = maxHeight +
//           ((totalMax == 0 || index == 0)
//               ? 0
//               : (samples[(i + index) % index] / totalMax * maxHeight));
//       var point = Offset(i.toDouble(), height);
//       points.add(point);
//     }
//     return points;
//   }
// }

// class IntensityPainter extends CustomPainter {
//   int? index;
//   double? localMax;
//   double? localMin;
//   List<double>? samples;
//   late List<Offset> points;
//   Color? color;
//   BuildContext? context;
//   Size? size;

//   IntensityPainter(
//       {this.samples,
//       this.color,
//       this.context,
//       this.index,
//       this.localMax,
//       this.localMin});

//   @override
//   void paint(Canvas canvas, Size? size) {}

//   @override
//   bool shouldRepaint(CustomPainter oldPainting) => true;

//   // Maps a list of ints and their indices to a list of points on a cartesian grid
//   List<Offset> toPoints(List<int>? samples) {
//     return points;
//   }

//   double project(double val, double max, double height) {
//     if (max == 0) {
//       return 0.5 * height;
//     }
//     var rv = val / max * 0.5 * height;
//     return rv;
//   }
// }

// class Statistics extends StatelessWidget {
//   final bool isRecording;
//   final DateTime? startTime;

//   final String url = "https://github.com/anarchuser/mic_stream";

//   Statistics(this.isRecording, {this.startTime});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(children: <Widget>[
//       const ListTile(
//           leading: Icon(Icons.title),
//           title: Text("Microphone Streaming Example App")),
//       ListTile(
//         leading: const Icon(Icons.keyboard_voice),
//         title: Text((isRecording ? "Recording" : "Not recording")),
//       ),
//       ListTile(
//           leading: const Icon(Icons.access_time),
//           title: Text((isRecording
//               ? DateTime.now().difference(startTime!).toString()
//               : "Not recording"))),
//     ]);
//   }
// }

// Iterable<T> eachWithIndex<E, T>(
//     Iterable<T> items, E Function(int index, T item) f) {
//   var index = 0;

//   for (final item in items) {
//     f(index, item);
//     index = index + 1;
//   }

//   return items;
// }

// // import 'package:flutter/material.dart';
// // import 'dart:async';

// // import 'package:waveform_extractor/model/waveform.dart';
// // import 'package:waveform_extractor/model/waveform_progress.dart';
// // import 'package:waveform_extractor/waveform_extractor.dart';

// // class AudioClass extends StatefulWidget {
// //   const AudioClass({super.key});

// //   @override
// //   State<AudioClass> createState() => _AudioClassState();
// // }

// // class _AudioClassState extends State<AudioClass> {
// //   Waveform? _currentWaveform;
// //   final List<double> _downscaledWaveformList = [];
// //   int _downscaledTargetSize = 100;

// //   Duration? _currentExtractionTime;
// //   Duration? _currentDownloadTime;
// //   int _currentIndex = 0;
// //   double _barWidth = 2;
// //   final horizontalPadding = 24.0;
// //   final _waveformExtractor = WaveformExtractor();
// //   final links = [
// //     "https://actions.google.com/sounds/v1/alarms/assorted_computer_sounds.ogg",
// //     "https://actions.google.com/sounds/v1/alarms/dosimeter_alarm.ogg",
// //     "https://actions.google.com/sounds/v1/alarms/phone_alerts_and_rings.ogg",
// //     "https://actions.google.com/sounds/v1/ambiences/ambient_hum_air_conditioner.ogg",
// //     "https://actions.google.com/sounds/v1/alarms/mechanical_clock_ring.ogg",
// //     "https://actions.google.com/sounds/v1/alarms/dinner_bell_triangle.ogg",
// //     "https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg",
// //     "https://actions.google.com/sounds/v1/ambiences/coffee_shop.ogg",
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     generateWaveform((sources) => sources[_currentIndex]);
// //   }

// //   void _resetValues() {
// //     _downscaledWaveformList
// //       ..clear()
// //       ..addAll(List<double>.filled(_downscaledTargetSize, 0.1));
// //     _currentWaveform = null;
// //     _currentExtractionTime = null;
// //     _currentDownloadTime = null;
// //   }

// //   Future<void> generateWaveform(
// //       String Function(List<String> sources) source) async {
// //     _resetValues();
// //     setState(() {});
// //     final downloadStart = DateTime.now();
// //     DateTime? downloadEnd;
// //     final time = await executeWithTimeDifference(() async {
// //       _currentWaveform = await _waveformExtractor.extractWaveform(
// //         source(links),
// //         onProgress: (progress) {
// //           if (progress.operation != ProgressOperation.downloading) {
// //             downloadEnd = DateTime.now();
// //           }
// //         },
// //       );
// //     });
// //     _currentDownloadTime = downloadEnd?.difference(downloadStart);
// //     _currentExtractionTime = time - (_currentDownloadTime ?? Duration.zero);
// //     updateDownscaledList(_currentWaveform?.waveformData, _downscaledTargetSize);
// //     setState(() {});
// //   }

// //   void updateDownscaledList(List<int>? list, int targetSize) {
// //     final downscaled = list?.reduceListSize(targetSize: targetSize);
// //     _downscaledWaveformList
// //       ..clear()
// //       ..addAll(downscaled ?? []);
// //     _barWidth = (MediaQuery.of(context).size.width - horizontalPadding) /
// //         (downscaled?.length ?? 1) *
// //         0.45;
// //   }

// //   Future<Duration> executeWithTimeDifference<T>(
// //       FutureOr<T> Function() fn) async {
// //     final start = DateTime.now();
// //     await fn();
// //     final end = DateTime.now();
// //     return end.difference(start);
// //   }

// //   Widget getText(String title, dynamic subtitle) {
// //     return RichText(
// //       text: TextSpan(
// //         text: "$title: ",
// //         style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
// //         children: [
// //           TextSpan(
// //             text: subtitle.toString(),
// //             style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     _waveformExtractor.clearAllWaveformCache();
// //     return MaterialApp(
// //       theme: ThemeData.dark(useMaterial3: true),
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('WaveformExtractor Example App'),
// //         ),
// //         body: Padding(
// //           padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
// //           child: ListView(
// //             children: [
// //               const SizedBox(height: 24.0),
// //               SizedBox(
// //                 height: MediaQuery.of(context).size.width,
// //                 child: PageView.builder(
// //                   itemCount: links.length,
// //                   onPageChanged: (value) async {
// //                     _currentIndex = value;
// //                     await generateWaveform((sources) => sources[value]);
// //                   },
// //                   itemBuilder: (context, index) {
// //                     return Container(
// //                       decoration: BoxDecoration(
// //                           color: const Color.fromARGB(255, 40, 40, 40),
// //                           borderRadius: BorderRadius.circular(24.0)),
// //                       width: MediaQuery.of(context).size.width,
// //                       child: index == _currentIndex
// //                           ? Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                               mainAxisSize: MainAxisSize.max,
// //                               children: [
// //                                 ..._downscaledWaveformList
// //                                     .map((e) => AnimatedContainer(
// //                                           duration:
// //                                               const Duration(milliseconds: 300),
// //                                           decoration: BoxDecoration(
// //                                               color: Colors.brown,
// //                                               borderRadius:
// //                                                   BorderRadius.circular(6.0)),
// //                                           height: (e * 12).clamp(
// //                                               1.0,
// //                                               MediaQuery.of(context)
// //                                                   .size
// //                                                   .width),
// //                                           width: _barWidth,
// //                                         )),
// //                               ],
// //                             )
// //                           : const SizedBox(),
// //                     );
// //                   },
// //                 ),
// //               ),
// //               const SizedBox(height: 12.0),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: links
// //                     .asMap()
// //                     .entries
// //                     .map(
// //                       (e) => Padding(
// //                         padding: const EdgeInsets.all(4.0),
// //                         child: CircleAvatar(
// //                           radius: 6.0,
// //                           backgroundColor:
// //                               _currentIndex == e.key ? null : Colors.grey,
// //                         ),
// //                       ),
// //                     )
// //                     .toList(),
// //               ),
// //               const SizedBox(height: 24.0),
// //               Slider.adaptive(
// //                 min: 40,
// //                 max: 400,
// //                 divisions: 400 - 40,
// //                 label: _downscaledTargetSize.toString(),
// //                 value: _downscaledTargetSize.toDouble(),
// //                 onChanged: (valueDouble) {
// //                   final value = valueDouble.toInt();
// //                   _downscaledTargetSize = value;
// //                   updateDownscaledList(
// //                       _currentWaveform?.waveformData ?? [], value);
// //                   setState(
// //                     () {},
// //                   );
// //                 },
// //               ),
// //               getText("Source", _currentWaveform?.source),
// //               const SizedBox(height: 6.0),
// //               getText("Duration", _currentWaveform?.duration),
// //               const SizedBox(height: 6.0),
// //               getText(
// //                   "Waveform count", _currentWaveform?.waveformData.length ?? 0),
// //               const SizedBox(height: 6.0),
// //               getText("Download Time", _currentDownloadTime),
// //               const SizedBox(height: 6.0),
// //               getText("Extraction Time", _currentExtractionTime),
// //               const SizedBox(height: 6.0),
// //               getText(
// //                   "Total Time",
// //                   (_currentDownloadTime ?? Duration.zero) +
// //                       (_currentExtractionTime ?? Duration.zero)),
// //               const SizedBox(height: 12.0),
// //               ElevatedButton.icon(
// //                 onPressed: () async =>
// //                     await generateWaveform((sources) => sources[_currentIndex]),
// //                 icon: const Icon(Icons.refresh_outlined),
// //                 label: const Text('Re Extract'),
// //               ),
// //               const SizedBox(height: 12.0),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // extension ListSize<N extends num> on List<N> {
// //   List<double> reduceListSize({
// //     required int targetSize,
// //   }) {
// //     if (length > targetSize) {
// //       final finalList = <double>[];
// //       final chunk = length / targetSize;
// //       final iterationsCount = targetSize;
// //       for (int i = 0; i < iterationsCount; i++) {
// //         final part = skip((chunk * i).floor()).take(chunk.floor());
// //         final sum = part.fold<double>(
// //             0, (previousValue, element) => previousValue + element);
// //         final peak = sum / part.length;
// //         finalList.add(peak);
// //       }
// //       return finalList;
// //     } else {
// //       return map((e) => e.toDouble()).toList();
// //     }
// //   }
// // }
