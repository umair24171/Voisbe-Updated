// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

// import 'package:another_xlider/another_xlider.dart';
// import 'package:another_xlider/models/handler.dart';
// import 'package:another_xlider/models/handler_animation.dart';
// import 'package:another_xlider/models/tooltip/tooltip.dart';
// import 'package:another_xlider/models/tooltip/tooltip_box.dart';
// import 'package:another_xlider/models/trackbar.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
// import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter/media_information.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:ffmpeg_kit_flutter/statistics.dart';
// import 'package:ffmpeg_kit_flutter/stream_information.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:saver_gallery/saver_gallery.dart';
// import 'package:uuid/uuid.dart';
// import 'package:video_player/video_player.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class Editor extends StatefulWidget {
//   const Editor({super.key});

//   @override
//   State<Editor> createState() => _EditorState();
// }

// class _EditorState extends State<Editor> {
//   late final MediaInformation mediaInformation;

//   final EditedInfo editedInfo = EditedInfo();

//   late VideoPlayerController _controller;

//   bool isInitialized = false;
//   Future<bool> initialize() async {
//     if (!isInitialized) {
//       isInitialized = true;
//       await FFprobeKit.getMediaInformation(editedInfo.filepath)
//           .then((session) async {
//         mediaInformation = session.getMediaInformation()!;
//       });
//       editedInfo.frameRate = getFramerate();
//       editedInfo.totalLength = editedInfo.end = Duration(
//           microseconds:
//               (double.parse(mediaInformation.getDuration()!) * 1000000)
//                   .floor());
//       _controller = VideoPlayerController.file(File(editedInfo.filepath));
//       await _controller.initialize();
//       WakelockPlus.enable();
//     }
//     return isInitialized;
//   }

//   @override
//   void dispose() async {
//     super.dispose();
//     _controller.dispose();
//     WakelockPlus.disable();
//     FilePicker.platform.clearTemporaryFiles();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args =
//         ModalRoute.of(context)!.settings.arguments as Map<String, String>;
//     editedInfo.filepath = args.values.first;
//     editedInfo.fileName = args.values.elementAt(1);
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (FullScreenView.isFullScreen) {
//           FullScreenView.hideFullScreen();
//         } else {
//           Navigator.pop(context);
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(args.values.elementAt(1)),
//           actions: [
//             RawMaterialButton(
//               onPressed: () => saveFile(context),
//               constraints: const BoxConstraints(minHeight: 36.0),
//               child: const Text(
//                 "SAVE",
//               ),
//             ),
//             IconButton(
//               onPressed: () => showInfo(args.values.first, context),
//               icon: const Icon(
//                 Icons.info_outlined,
//               ),
//             ),
//           ],
//         ),
//         resizeToAvoidBottomInset: false,
//         body: FutureBuilder(
//             future: initialize(),
//             builder: (context, AsyncSnapshot<bool> snapshot) {
//               if (snapshot.hasData) {
//                 return DefaultTabController(
//                   length: 2,
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: TabBarView(
//                           physics: const NeverScrollableScrollPhysics(),
//                           children: [
//                             TrimTab(
//                               editedInfo: editedInfo,
//                               controller: _controller,
//                             ),
//                             CropTab(
//                               editedInfo: editedInfo,
//                               controller: _controller,
//                             ),
//                             // EnhanceTab(
//                             //   editedInfo: editedInfo,
//                             //   controller: _controller,
//                             // ),
//                             // TextTab(
//                             //   editedInfo: editedInfo,
//                             //   controller: _controller,
//                             // )
//                           ],
//                         ),
//                       ),
//                       Theme(
//                         data: ThemeData().copyWith(
//                           splashColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                         ),
//                         child: TabBar(
//                           indicator: BoxDecoration(
//                             color: Theme.of(context).canvasColor,
//                             borderRadius: BorderRadius.circular(100),
//                           ),
//                           indicatorPadding: const EdgeInsets.all(5),
//                           tabs: const [
//                             Tab(
//                               icon: Icon(Icons.cut),
//                             ),
//                             Tab(
//                               icon: Icon(Icons.crop_rotate),
//                             ),
//                             // Tab(
//                             //   icon: Icon(Icons.auto_awesome),
//                             // ),
//                             // Tab(
//                             //   icon: Icon(Icons.text_fields),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               } else {
//                 return const Loading();
//               }
//             }),
//       ),
//     );
//   }

//   Future<void> showInfo(String path, BuildContext context) async {
//     List<String> vidInfo = [];

//     vidInfo.add("Media Information");

//     vidInfo.add("Path: ${mediaInformation.getFilename()}");
//     vidInfo.add("Format: ${mediaInformation.getFormat()}");
//     vidInfo.add("Duration: ${mediaInformation.getDuration()}");
//     vidInfo.add("Start time: ${mediaInformation.getStartTime()}");
//     vidInfo.add("Bitrate: ${mediaInformation.getBitrate()}");
//     Map<dynamic, dynamic> tags = mediaInformation.getTags()!;
//     tags.forEach((key, value) {
//       vidInfo.add("Tag: $key:$value\n");
//     });

//     List<StreamInformation>? streams = mediaInformation.getStreams();

//     if (streams.isNotEmpty) {
//       for (var stream in streams) {
//         vidInfo.add("Stream id: ${stream.getAllProperties()!['index']}");
//         vidInfo.add("Stream type: ${stream.getAllProperties()!['codec_type']}");
//         vidInfo
//             .add("Stream codec: ${stream.getAllProperties()!['codec_name']}");
//         vidInfo.add(
//             "Stream full codec: ${stream.getAllProperties()!['codec_long_name']}");
//         vidInfo.add("Stream format: ${stream.getAllProperties()!['pix_fmt']}");
//         vidInfo.add("Stream width: ${stream.getAllProperties()!['width']}");
//         vidInfo.add("Stream height: ${stream.getAllProperties()!['height']}");
//         vidInfo
//             .add("Stream bitrate: ${stream.getAllProperties()!['bit_rate']}");
//         vidInfo.add(
//             "Stream sample rate: ${stream.getAllProperties()!['sample_rate']}");
//         vidInfo.add(
//             "Stream sample format: ${stream.getAllProperties()!['sample_fmt']}");
//         vidInfo.add(
//             "Stream channel layout: ${stream.getAllProperties()!['channel_layout']}");
//         vidInfo.add(
//             "Stream sar: ${stream.getAllProperties()!['sample_aspect_ratio']}");
//         vidInfo.add(
//             "Stream dar: ${stream.getAllProperties()!['display_aspect_ratio']}");
//         vidInfo.add(
//             "Stream average frame rate: ${stream.getAllProperties()!['avg_frame_rate']}");
//         vidInfo.add(
//             "Stream real frame rate: ${stream.getAllProperties()!['r_frame_rate']}");
//         vidInfo.add(
//             "Stream time base: ${stream.getAllProperties()!['time_base']}");
//         vidInfo.add(
//             "Stream codec time base: ${stream.getAllProperties()!['codec_time_base']}");

//         Map<dynamic, dynamic> tags = stream.getAllProperties()!['tags'];
//         tags.forEach((key, value) {
//           vidInfo.add("Stream tag: $key:$value\n");
//         });
//       }
//     }

//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true, // user must tap button!
//       builder: (BuildContext context) {
//         return BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//           child: AlertDialog(
//             title: const Text('Video Information'),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: vidInfo.map((e) => Text(e)).toList(),
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Close'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   double getFramerate() {
//     List<String> a = (mediaInformation
//             .getStreams()
//             .firstWhere((element) =>
//                 element.getAllProperties()!['codec_type'] == 'video')
//             .getAllProperties()!['avg_frame_rate'])
//         .toString()
//         .split('/');
//     return double.parse(a.first) / double.parse(a.last);
//   }

//   void saveFile(BuildContext context) {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return SavePopup(
//           editedInfo: editedInfo,
//         );
//       },
//     );
//   }
// }

// class TrimTab extends StatefulWidget {
//   final EditedInfo editedInfo;
//   final VideoPlayerController controller;
//   const TrimTab(
//       {super.key, required this.editedInfo, required this.controller});

//   @override
//   State<TrimTab> createState() => _TrimTabState();
// }

// class _TrimTabState extends State<TrimTab>
//     with AutomaticKeepAliveClientMixin<TrimTab> {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Column(
//       children: [
//         Expanded(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               child: GestureDetector(
//                 onDoubleTap: () =>
//                     FullScreenView.showFullScreen(context, widget.controller),
//                 onTap: () => setState(() {
//                   widget.controller.value.isPlaying
//                       ? widget.controller.pause()
//                       : widget.controller.play();
//                 }),
//                 child: (widget.controller.value.isInitialized)
//                     ? AspectRatio(
//                         aspectRatio: widget.controller.value.aspectRatio,
//                         child: VideoPlayer(widget.controller),
//                       )
//                     : const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: double.infinity,
//           height: 220,
//           child: Column(
//             children: [
//               VideoPlayerControlls(
//                 controller: widget.controller,
//                 framerate: widget.editedInfo.frameRate,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               TrimWidget(
//                 controller: widget.controller,
//                 editedInfo: widget.editedInfo,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class VideoPlayerControlls extends StatefulWidget {
//   final VideoPlayerController controller;
//   final double framerate;
//   const VideoPlayerControlls(
//       {super.key, required this.controller, required this.framerate});

//   @override
//   State<VideoPlayerControlls> createState() => _VideoPlayerControllsState();
// }

// class _VideoPlayerControllsState extends State<VideoPlayerControlls> {
//   bool _ismuted = false;
//   @override
//   void initState() {
//     super.initState();
//     _ismuted = widget.controller.value.volume == 0;
//   }

//   void setPosition(bool next) {
//     setState(() {
//       if (next) {
//         widget.controller.seekTo(widget.controller.value.position +
//             Duration(milliseconds: 1000 ~/ widget.framerate));
//       } else {
//         widget.controller.seekTo(widget.controller.value.position -
//             Duration(milliseconds: 1000 ~/ widget.framerate));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: VideoSeek(controller: widget.controller),
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _ismuted
//                       ? widget.controller.setVolume(1)
//                       : widget.controller.setVolume(0);
//                 });
//                 _ismuted = !_ismuted;
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//               ),
//               child: Icon(
//                 _ismuted ? Icons.volume_mute : Icons.volume_up,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 widget.controller.pause();
//                 setPosition(false);
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//               ),
//               child: const Icon(Icons.navigate_before),
//             ),
//             ElevatedButton(
//               onPressed: () => setState(() {
//                 widget.controller.value.isPlaying
//                     ? widget.controller.pause()
//                     : widget.controller.play();
//               }),
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 fixedSize: const Size.fromRadius(25),
//                 padding: const EdgeInsets.all(0),
//               ),
//               child: Icon(
//                 widget.controller.value.isPlaying
//                     ? Icons.pause
//                     : Icons.play_arrow,
//                 size: 30,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 widget.controller.pause();
//                 setPosition(true);
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//               ),
//               child: const Icon(Icons.navigate_next),
//             ),
//             ElevatedButton(
//               onPressed: () =>
//                   FullScreenView.showFullScreen(context, widget.controller),
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//               ),
//               child: const Icon(Icons.fullscreen_rounded),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class VideoSeek extends StatefulWidget {
//   const VideoSeek({super.key, required this.controller});
//   final VideoPlayerController controller;

//   @override
//   State<VideoSeek> createState() => _VideoSeekState();
// }

// class _VideoSeekState extends State<VideoSeek> {
//   double position = 0;
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(() {
//       setState(() {
//         position = widget.controller.value.position.inMilliseconds.toDouble();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               Utils.formatTime(position, true),
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.tertiary,
//                 fontSize: 12,
//               ),
//             ),
//             Text(
//               Utils.formatTime(
//                 widget.controller.value.duration.inMilliseconds,
//                 true,
//               ),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).colorScheme.tertiary,
//               ),
//             ),
//           ],
//         ),
//         FlutterSlider(
//           values: [position],
//           min: 0,
//           max: widget.controller.value.duration.inMilliseconds.toDouble(),
//           handlerHeight: 15,
//           tooltip: FlutterSliderTooltip(
//             boxStyle: FlutterSliderTooltipBox(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: Theme.of(context).colorScheme.tertiaryContainer,
//               ),
//             ),
//             format: (String s) {
//               double t = double.tryParse(s) ?? 0;
//               return Utils.formatTime(t, true);
//             },
//             textStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
//           ),
//           trackBar: FlutterSliderTrackBar(
//               inactiveTrackBar: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surfaceVariant,
//               ),
//               activeTrackBar: const BoxDecoration(
//                   gradient:
//                       LinearGradient(colors: [Colors.blue, Colors.purple]))),
//           handler: FlutterSliderHandler(child: const SizedBox()),
//           onDragging: (handlerIndex, lowerValue, upperValue) {
//             setState(() {
//               position = lowerValue;
//               setPosition();
//             });
//           },
//         ),
//       ],
//     );
//   }

//   void setPosition() {
//     widget.controller.seekTo(Duration(milliseconds: position.toInt()));
//   }
// }

// class Utils {
//   static String formatTime(num millisec, bool splitSecs) {
//     String s = "";
//     if (millisec ~/ 3600000 > 0) {
//       s += "${millisec ~/ 3600000}:";
//     }
//     s +=
//         "${((millisec % 3600000) ~/ 60000).toString().padLeft(2, '0')}:${((millisec % 60000) ~/ 1000).toString().padLeft(2, '0')}";
//     if (splitSecs) {
//       s += ".${((millisec % 1000) ~/ 10).toString().padLeft(2, '0')}";
//     }

//     return s;
//   }
// }

// class FullScreenView extends StatefulWidget {
//   final VideoPlayerController controller;
//   const FullScreenView({super.key, required this.controller});

//   static late OverlayEntry _overlayEntry;
//   static bool isFullScreen = false;
//   static void hideFullScreen() {
//     _overlayEntry.remove();
//     isFullScreen = false;
//   }

//   static void showFullScreen(
//       BuildContext context, VideoPlayerController controller) {
//     OverlayState? overlayState = Overlay.of(context);
//     _overlayEntry = OverlayEntry(
//         builder: (context) => FullScreenView(controller: controller),
//         opaque: true,
//         maintainState: true);
//     overlayState.insert(_overlayEntry);
//     isFullScreen = true;
//   }

//   @override
//   State<FullScreenView> createState() => _FullScreenViewState();
// }

// class _FullScreenViewState extends State<FullScreenView> {
//   @override
//   void initState() {
//     super.initState();
//     if (widget.controller.value.aspectRatio > 1) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeRight,
//         DeviceOrientation.landscapeLeft,
//       ]);
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     total = widget.controller.value.duration;
//   }

//   double netOffset = 0;
//   bool showPosition = false;
//   Duration current = Duration.zero;
//   late Duration total;
//   @override
//   Widget build(BuildContext context) {
//     return (widget.controller.value.isInitialized == false)
//         ? Container(
//             width: 0,
//           )
//         : GestureDetector(
//             onTap: () => setState(() {
//               widget.controller.value.isPlaying
//                   ? widget.controller.pause()
//                   : widget.controller.play();
//             }),
//             onDoubleTap: () => FullScreenView.hideFullScreen(),
//             onHorizontalDragStart: (details) {
//               getPosition();
//               setState(() {
//                 netOffset = 0;
//                 showPosition = true;
//               });
//             },
//             onHorizontalDragUpdate: (details) {
//               setState(() {
//                 netOffset += details.delta.dx / 10;
//               });
//             },
//             onHorizontalDragEnd: (details) {
//               changePosition();
//               setState(() {
//                 showPosition = false;
//               });
//             },
//             onVerticalDragDown: (details) {},
//             child: Center(
//               child: Stack(
//                 children: [
//                   Center(
//                     child: AspectRatio(
//                       aspectRatio: widget.controller.value.aspectRatio,
//                       child: VideoPlayer(widget.controller),
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       showPosition ? positionDragText() : "",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                           fontSize: 20,
//                           color: Colors.white,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black87,
//                               blurRadius: 10,
//                             )
//                           ],
//                           fontStyle: FontStyle.normal,
//                           decoration: TextDecoration.none),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );
//   }

//   void getPosition() {
//     current = widget.controller.value.position;
//   }

//   String positionDragText() {
//     String s = '';
//     if (netOffset >= 0) {
//       s = "+${netOffset.toStringAsFixed(2)}s\n";
//     } else {
//       s = '${netOffset.toStringAsFixed(2)}s\n';
//     }
//     int c = current.inMilliseconds + (netOffset * 1000).toInt();
//     int t = total.inMilliseconds;
//     if (c > t) {
//       c = t;
//     }
//     if (c < 0) {
//       c = 0;
//     }
//     s += Utils.formatTime(c, true);
//     s += ' / ';
//     s += Utils.formatTime(t, true);
//     return s;
//   }

//   void changePosition() {
//     Duration position =
//         current + Duration(milliseconds: (netOffset * 1000).toInt());
//     if (position < Duration.zero) {
//       widget.controller.seekTo(Duration.zero);
//     } else if (position > widget.controller.value.duration) {
//       widget.controller.seekTo(widget.controller.value.duration);
//     } else {
//       widget.controller.seekTo(position);
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//   }
// }

// class TrimWidget extends StatefulWidget {
//   final VideoPlayerController controller;
//   final EditedInfo editedInfo;
//   const TrimWidget(
//       {super.key, required this.controller, required this.editedInfo});

//   @override
//   State<TrimWidget> createState() => _TrimWidgetState();
// }

// class _TrimWidgetState extends State<TrimWidget> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       double h = 60;
//       double w = constraints.maxWidth - constraints.maxWidth % h;
//       return Column(
//         children: [
//           Stack(
//             alignment: AlignmentDirectional.center,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                 child: Center(
//                   child: Container(
//                     height: h,
//                     width: w,
//                     color: Colors.grey[900],
//                     child: Thumbnails(
//                       w: w,
//                       h: h,
//                       editedInfo: widget.editedInfo,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: h + 5,
//                 width: w + 20,
//                 child: TrimBox(
//                   h: h,
//                   w: w,
//                   editedInfo: widget.editedInfo,
//                 ),
//               ),
//             ],
//           ),
//           TrimText(
//             editedInfo: widget.editedInfo,
//             controller: widget.controller,
//           )
//         ],
//       );
//     });
//   }
// }

// class TrimText extends StatefulWidget {
//   const TrimText(
//       {super.key, required this.editedInfo, required this.controller});
//   final EditedInfo editedInfo;
//   final VideoPlayerController controller;

//   @override
//   State<TrimText> createState() => _TrimTextState();
// }

// class _TrimTextState extends State<TrimText> {
//   @override
//   void initState() {
//     super.initState();
//     widget.editedInfo.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 30,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             child: Text(
//                 Utils.formatTime(widget.editedInfo.start.inMilliseconds, true)),
//             onPressed: () {
//               if (widget.controller.value.position <
//                   (widget.editedInfo.end - const Duration(milliseconds: 500))) {
//                 widget.editedInfo.start = widget.controller.value.position;
//                 widget.editedInfo.notify();
//               }
//             },
//           ),
//           TextButton(
//             child: Text(
//                 Utils.formatTime(widget.editedInfo.end.inMilliseconds, true)),
//             onPressed: () {
//               if (widget.controller.value.position >
//                   (widget.editedInfo.start +
//                       const Duration(milliseconds: 500))) {
//                 widget.editedInfo.end = widget.controller.value.position;
//                 widget.editedInfo.notify();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TrimBox extends StatefulWidget {
//   final double h;
//   final double w;
//   final EditedInfo editedInfo;
//   const TrimBox(
//       {super.key, required this.h, required this.w, required this.editedInfo});

//   @override
//   State<TrimBox> createState() => _TrimBoxState();
// }

// class _TrimBoxState extends State<TrimBox> {
//   @override
//   void initState() {
//     super.initState();
//     widget.editedInfo.addListener(() {
//       setState(() {
//         start = widget.editedInfo.start.inMilliseconds.toDouble();
//         end = widget.editedInfo.end.inMilliseconds.toDouble();
//       });
//     });
//   }

//   double start = 0;
//   late double end = widget.editedInfo.totalLength.inMilliseconds.toDouble();
//   @override
//   Widget build(BuildContext context) {
//     return FlutterSlider(
//       values: [start, end],
//       rangeSlider: true,
//       max: widget.editedInfo.totalLength.inMilliseconds.toDouble(),
//       min: 0,
//       handlerWidth: 20,
//       handlerHeight: widget.h + 5,
//       handler: FlutterSliderHandler(
//         child: Image.asset(
//           'assets/boxleft.png',
//         ),
//         decoration: const BoxDecoration(),
//       ),
//       rightHandler: FlutterSliderHandler(
//         child: Image.asset(
//           'assets/boxright.png',
//         ),
//         decoration: const BoxDecoration(),
//       ),
//       handlerAnimation: const FlutterSliderHandlerAnimation(
//         duration: Duration(milliseconds: 500),
//         scale: 1.1,
//       ),
//       selectByTap: false,
//       minimumDistance: 500,
//       trackBar: FlutterSliderTrackBar(
//         activeTrackBarHeight: widget.h + 5,
//         activeTrackBar: const BoxDecoration(
//             color: Colors.transparent,
//             image: DecorationImage(
//               image: AssetImage('assets/boxmid.png'),
//               fit: BoxFit.fill,
//             )),
//         inactiveTrackBar: const BoxDecoration(
//           color: Colors.transparent,
//         ),
//       ),
//       tooltip: FlutterSliderTooltip(
//         boxStyle: FlutterSliderTooltipBox(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Theme.of(context).colorScheme.secondaryContainer,
//           ),
//         ),
//         textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
//         format: (String s) {
//           double t = double.tryParse(s) ?? 0;
//           return Utils.formatTime(t, true);
//         },
//       ),
//       onDragging: (handlerIndex, lowerValue, upperValue) {
//         setState(() {
//           start = lowerValue;
//           end = upperValue;
//         });
//       },
//       onDragCompleted: (a, b, c) => trimRange(),
//     );
//   }

//   void trimRange() {
//     widget.editedInfo.start = Duration(milliseconds: start.round());
//     widget.editedInfo.end = Duration(milliseconds: end.round());
//     widget.editedInfo.notify();
//     debugPrint(
//         "Start: ${widget.editedInfo.start}  end: ${widget.editedInfo.end}");
//   }
// }

// class Thumbnails extends StatefulWidget {
//   const Thumbnails(
//       {super.key, required this.h, required this.w, required this.editedInfo});
//   final double w, h;
//   final EditedInfo editedInfo;
//   @override
//   State<Thumbnails> createState() => _ThumbnailsState();
// }

// class _ThumbnailsState extends State<Thumbnails> {
//   List<File> list = [];

//   @override
//   void initState() {
//     super.initState();
//     thumbnailBuilder(widget.w, widget.h);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: list.map((f) {
//         return f.existsSync()
//             ? Image.file(
//                 f,
//                 width: widget.h,
//                 height: widget.h,
//                 fit: BoxFit.cover,
//               )
//             : Loading(w: widget.h);
//       }).toList(),
//     );
//   }

//   void thumbnailBuilder(double w, double h) async {
//     debugPrint(w.toString() + widget.editedInfo.toString());
//     Directory temp = await getTemporaryDirectory();
//     if (Directory("${temp.path}/thumbs").existsSync()) {
//       Directory("${temp.path}/thumbs").deleteSync(recursive: true);
//     }
//     Directory("${temp.path}/thumbs").createSync();
//     int n = w ~/ h;
//     for (var i = 0; i < n; i++) {
//       String outpath = "${temp.path}/thumbs/$i.png";
//       list.add(File(outpath));
//       debugPrint(outpath);
//       List<String> arguments = [
//         "-y",
//         "-ss",
//         (widget.editedInfo.totalLength ~/ n * i).toString(),
//         "-i",
//         widget.editedInfo.filepath,
//         "-vf",
//         "scale=320:-1",
//         "-frames:v",
//         "1",
//         outpath
//       ];
//       await FFmpegKit.executeWithArguments(arguments);
//       if (mounted) {
//         setState(() {});
//       } else {
//         break;
//       }
//     }
//   }
// }

// class Loading extends StatelessWidget {
//   final double? w;
//   const Loading({super.key, this.w});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: w,
//         color: const Color(0x00000050),
//         child: const Center(child: CircularProgressIndicator()));
//   }
// }

// class EditedInfo with ChangeNotifier {
//   double frameRate = 0;
//   Duration totalLength = Duration.zero;
//   String filepath = '';
//   String fileName = '';
//   Duration start = Duration.zero;
//   Duration end = Duration.zero;
//   double cropTop = 0;
//   double cropLeft = 0;
//   double cropRight = 1;
//   double cropBottom = 1;
//   int turns = 0;
//   bool flipX = false;
//   bool flipY = false;

//   EditedInfo();
//   @override
//   String toString() {
//     return "framerate: $frameRate, totalLength: $totalLength, filepath: $filepath, start: $start, end: $end";
//   }

//   void notify() {
//     notifyListeners();
//   }
// }

// class SavePopup extends StatefulWidget {
//   const SavePopup({super.key, required this.editedInfo});
//   final EditedInfo editedInfo;

//   @override
//   State<SavePopup> createState() => _SavePopupState();
// }

// class _SavePopupState extends State<SavePopup> {
//   late String fileName;
//   List<String> extensions = ['.mp4', '.webm', '.mov', '.avi'];
//   late String extension;
//   List<String> videocodecs = ['h264', 'hevc', 'vp8', 'vp9', 'av1'];
//   late String videocodec;
//   List<String> audiocodecs = ['aac', 'mp3', 'opus', 'vorbis'];
//   late String audiocodec;

//   @override
//   void initState() {
//     super.initState();
//     fileName = widget.editedInfo.fileName.split('.').first;
//     extension = extensions[0];
//     videocodec = videocodecs[0];
//     audiocodec = audiocodecs[0];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BackdropFilter(
//       filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//       child: AlertDialog(
//         title: const Center(child: Text("Save File")),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('SAVE'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               onsave();
//             },
//           ),
//           TextButton(
//             child: const Text('CANCEL'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Name: "),
//             TextFormField(
//               initialValue: fileName,
//               onChanged: (value) => fileName = value,
//             ),
//             Row(
//               children: [
//                 const Text("File extension: "),
//                 DropdownButton(
//                   value: extension,
//                   items: extensions.map((String item) {
//                     return DropdownMenuItem(
//                       value: item,
//                       child: Text(item),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       extension = newValue!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text("Video codec: "),
//                 DropdownButton(
//                   value: videocodec,
//                   items: videocodecs.map((String item) {
//                     return DropdownMenuItem(
//                       value: item,
//                       child: Text(item),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       videocodec = newValue!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text("Audio codec: "),
//                 DropdownButton(
//                   value: audiocodec,
//                   items: audiocodecs.map((String item) {
//                     return DropdownMenuItem(
//                       value: item,
//                       child: Text(item),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       audiocodec = newValue!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void onsave() {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return SavingPopup(
//           editedInfo: widget.editedInfo,
//           audiocodec: audiocodec,
//           extension: extension,
//           fileName: fileName,
//           videocodec: videocodec,
//         );
//       },
//     );
//   }
// }

// class SavingPopup extends StatefulWidget {
//   const SavingPopup(
//       {super.key,
//       required this.editedInfo,
//       required this.fileName,
//       required this.extension,
//       required this.videocodec,
//       required this.audiocodec});
//   final EditedInfo editedInfo;
//   final String fileName;
//   final String extension;
//   final String videocodec;
//   final String audiocodec;
//   @override
//   State<SavingPopup> createState() => _SavingPopupState();
// }

// class _SavingPopupState extends State<SavingPopup> {
//   late Duration total = widget.editedInfo.end - widget.editedInfo.start;
//   Duration done = Duration.zero;
//   bool _isdone = false;
//   String doneStr = "";
//   String? tempfile;
//   @override
//   void initState() {
//     super.initState();
//     savefile(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double donePercent = (done.inMilliseconds) / total.inMilliseconds;
//     return BackdropFilter(
//       filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//       child: AlertDialog(
//         title: Center(
//             child: _isdone
//                 ? Text(
//                     doneStr,
//                   )
//                 : const Text(
//                     "Saving",
//                   )),
//         content: _isdone
//             ? null
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   LinearProgressIndicator(
//                     value: donePercent,
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     "${Utils.formatTime(done.inMilliseconds, false)}/${Utils.formatTime(total.inMilliseconds, false)}",
//                   )
//                 ],
//               ),
//         actions: <Widget>[
//           TextButton(
//             child: _isdone ? const Text("Close") : const Text('Cancel'),
//             onPressed: () {
//               cancel();
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   String? getVideoFilters() {
//     List<String> filters = [];
//     if (widget.editedInfo.cropLeft != 0 ||
//         widget.editedInfo.cropTop != 0 ||
//         widget.editedInfo.cropBottom != 1 ||
//         widget.editedInfo.cropRight != 1) {
//       filters.add(
//           'crop=${(widget.editedInfo.cropRight - widget.editedInfo.cropLeft)}*in_w:${(widget.editedInfo.cropBottom - widget.editedInfo.cropTop)}*in_h:${widget.editedInfo.cropLeft}*in_w:${widget.editedInfo.cropTop}*in_h');
//     }
//     if (widget.editedInfo.turns != 0) {
//       if (widget.editedInfo.turns == 1) {
//         filters.add("transpose=clock");
//       } else if (widget.editedInfo.turns == 2) {
//         filters.add("transpose=2,transpose=2");
//       } else if (widget.editedInfo.turns == 3) {
//         filters.add("transpose=cclock");
//       }
//     }
//     if (widget.editedInfo.flipX) {
//       filters.add("hflip");
//     }
//     if (widget.editedInfo.flipY) {
//       filters.add("vflip");
//     }
//     if (filters.isEmpty) {
//       return null;
//     }
//     return filters.join(",");
//   }

//   int? sessionId;
//   void savefile(BuildContext context) async {
//     try {
//       Directory? tmp = await getExternalStorageDirectory();
//       String temp = tmp!.path;
//       tempfile = '$temp/${widget.fileName}${widget.extension}';
//       debugPrint(tempfile);
//       List<String> commands = [
//         "-hwaccel",
//         "mediacodec",
//         "-y",
//         // "-c:v",
//         // "h264_mediacodec",
//         "-i",
//         (widget.editedInfo.filepath),
//         "-ss",
//         "${widget.editedInfo.start}",
//         "-to",
//         "${widget.editedInfo.end}",
//         "-map_metadata",
//         "0",
//         "-c:v",
//         widget.videocodec,
//         '-vf',
//         getVideoFilters() ?? "null",
//         "-c:a",
//         widget.audiocodec,
//         tempfile!
//       ];
//       debugPrint("Commands: $commands");
//       FFmpegKit.executeWithArgumentsAsync(
//           commands, completed, null, updateStatics);
//     } on PlatformException {
//       debugPrint("canceled");
//       if (context.mounted) {
//         Navigator.of(context).pop();
//       }
//     }
//   }

//   void updateStatics(Statistics s) {
//     if (mounted) {
//       setState(() {
//         done = Duration(milliseconds: s.getTime().round());
//       });
//     }
//     debugPrint(
//         "Time: ${s.getTime()}, Bitrate: ${s.getBitrate()}, Quality: ${s.getVideoQuality()}, Speed: ${s.getSpeed()}");
//   }

//   void completed(FFmpegSession session) async {
//     _isdone = true;
//     ReturnCode? returnCode = await session.getReturnCode();
//     debugPrint('FFmpeg process return code: ${returnCode?.getValue()}');

//     if (ReturnCode.isSuccess(returnCode)) {
//       setState(() {
//         SaverGallery.saveFile(
//           file: tempfile!,
//           androidRelativePath: "Video Editor",
//           androidExistNotSave: true,
//           name: '${Uuid().v4()}.mp4'
//         );
//         doneStr = "Completed!";
//       });
//     } else {
//       final output = await session.getOutput();
//       final failStackTrace = await session.getFailStackTrace();
//       debugPrint('FFmpeg process failed output: $output');
//       debugPrint('FFmpeg process failed stack trace: $failStackTrace');
//       if (mounted) {
//         setState(() {
//           doneStr = "Error";
//         });
//       }
//     }
//     debugPrint(doneStr);
//   }

//   void cancel() {
//     FFmpegKit.cancel();
//   }
// }

// class CropTab extends StatefulWidget {
//   final EditedInfo editedInfo;
//   final VideoPlayerController controller;

//   const CropTab(
//       {super.key, required this.editedInfo, required this.controller});

//   @override
//   State<CropTab> createState() => _CropTabState();
// }

// class _CropTabState extends State<CropTab>
//     with AutomaticKeepAliveClientMixin<CropTab> {
//   @override
//   bool get wantKeepAlive => true;
//   CropController cropController = CropController();

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Column(
//       children: [
//         Expanded(
//           child: Center(
//             child: SizedBox(
//               height: MediaQuery.of(context).size.width,
//               width: MediaQuery.of(context).size.width,
//               child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: CropPlayer(
//                     controller: widget.controller,
//                     cropController: cropController,
//                     editedInfo: widget.editedInfo,
//                   )),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: double.infinity,
//           height: 220,
//           child: Column(
//             children: [
//               VideoPlayerControlls(
//                 controller: widget.controller,
//                 framerate: widget.editedInfo.frameRate,
//               ),
//               CropOptions(
//                 cropController: cropController,
//                 editedInfo: widget.editedInfo,
//                 aspectRatio: widget.controller.value.aspectRatio,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class CropPlayer extends StatefulWidget {
//   const CropPlayer(
//       {super.key,
//       required this.controller,
//       required this.cropController,
//       required this.editedInfo});

//   final VideoPlayerController controller;
//   final EditedInfo editedInfo;
//   final CropController cropController;

//   @override
//   State<CropPlayer> createState() => _CropPlayerState();
// }

// class _CropPlayerState extends State<CropPlayer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController animController;

//   @override
//   void initState() {
//     super.initState();

//     animController = AnimationController(
//       duration: const Duration(milliseconds: 250),
//       vsync: this,
//     );
//     rotation = Tween<double>(begin: 0, end: 0).animate(animController);
//     flipX = Tween<double>(begin: 0, end: 0).animate(animController);
//     flipY = Tween<double>(begin: 0, end: 0).animate(animController);

//     widget.cropController.addListener(() {
//       setRotate(rotation.value, pi / 2 * widget.cropController.turns);
//       setFlipX(flipX.value, widget.cropController.flipX ? pi : 0);
//       setFlipY(flipY.value, widget.cropController.flipY ? pi : 0);
//       animController.forward(from: 0);
//     });
//   }

//   late Animation<double> rotation;
//   late Animation<double> flipX;
//   late Animation<double> flipY;
//   void setRotate(double before, double after) {
//     if (before == pi / 2 * 3 && after == 0) {
//       rotation =
//           Tween<double>(begin: -pi / 2, end: after).animate(animController);
//     } else if (before == 0 && after == pi / 2 * 3) {
//       rotation =
//           Tween<double>(begin: pi / 2 * 4, end: after).animate(animController);
//     } else {
//       rotation =
//           Tween<double>(begin: before, end: after).animate(animController);
//     }
//   }

//   void setFlipX(double before, double after) {
//     flipX = Tween<double>(begin: before, end: after).animate(animController);
//   }

//   void setFlipY(double before, double after) {
//     flipY = Tween<double>(begin: before, end: after).animate(animController);
//   }

//   double scale = 1;
//   Offset position = Offset.zero;
//   void onScale(ScaleUpdateDetails details) {
//     setState(() {
//       if (details.scale < 2 && details.scale > 0.8) {
//         scale = details.scale;
//       }
//       position += details.focalPointDelta;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animController,
//       builder: (context, child) {
//         return Transform(
//             transform: Matrix4.rotationX(flipY.value)
//               ..rotateY(flipX.value)
//               ..rotateZ(rotation.value)
//               ..scale(scale)
//               ..setTranslationRaw(position.dx, position.dy, 0),
//             alignment: Alignment.center,
//             child: child);
//       },
//       child: (widget.controller.value.isInitialized)
//           ? Stack(
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: AspectRatio(
//                       aspectRatio: widget.controller.value.aspectRatio,
//                       child: VideoPlayer(widget.controller),
//                     ),
//                   ),
//                 ),
//                 LayoutBuilder(builder: (context, constraints) {
//                   return CropBox(
//                     height: constraints.maxHeight,
//                     width: constraints.maxWidth,
//                     padding: 10,
//                     aspectRatio: widget.controller.value.aspectRatio,
//                     cropController: widget.cropController,
//                     editedInfo: widget.editedInfo,
//                   );
//                 }),
//                 GestureDetector(
//                   onScaleStart: onScaleStart,
//                   onScaleUpdate: onScaleUpdate,
//                   onScaleEnd: onScaleEnd,
//                 ),
//               ],
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }

//   bool isPan = false;
//   bool isScale = false;

//   void onScaleStart(ScaleStartDetails details) {
//     if (details.pointerCount == 1) {
//       isPan = true;
//       isScale = false;
//       widget.cropController.onResizeStart(details.localFocalPoint);
//     }

//     if (details.pointerCount == 2) {
//       isScale = true;
//       isPan = false;
//     }
//     // debugPrint('$isPan $isScale ${details.pointerCount}');
//   }

//   void onScaleEnd(ScaleEndDetails details) {
//     if (isPan) {
//       widget.cropController.onResizeEnd();
//     }
//     isScale = false;
//     isPan = false;
//   }

//   void onScaleUpdate(ScaleUpdateDetails details) {
//     if (isPan) {
//       widget.cropController
//           .onResizeUpdate(details.localFocalPoint, details.focalPointDelta);
//     } else if (isScale) {
//       // onScale(details);
//     }
//   }
// }

// class CropOptions extends StatefulWidget {
//   const CropOptions(
//       {super.key,
//       required this.cropController,
//       required this.editedInfo,
//       required this.aspectRatio});
//   final CropController cropController;
//   final EditedInfo editedInfo;
//   final double aspectRatio;
//   @override
//   State<CropOptions> createState() => _CropOptionsState();
// }

// class _CropOptionsState extends State<CropOptions> {
//   Map<String, double?> ratios = {
//     'Free': null,
//     '1:1': 1,
//     '9:16': 9 / 16,
//     '16:9': 16 / 9
//   };
//   late String ratio = ratios.keys.first;
//   late bool isLandscape;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.aspectRatio > 1) {
//       isLandscape = true;
//       ratios["Original"] = widget.aspectRatio;
//     } else {
//       isLandscape = false;
//       ratios["Original"] = 1 / widget.aspectRatio;
//     }
//   }

//   ButtonStyle buttonStyle(bool selected) {
//     return ElevatedButton.styleFrom(
//       backgroundColor:
//           selected ? Theme.of(context).colorScheme.secondaryContainer : null,
//       foregroundColor: Theme.of(context).colorScheme.secondary,
//       shape: const CircleBorder(),
//       fixedSize: const Size.square(35),
//       minimumSize: Size.zero,
//       padding: EdgeInsets.zero,
//       elevation: 0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 15),
//       child: Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   widget.cropController.turns = widget.cropController.turns - 1;
//                 });
//                 widget.editedInfo.turns = widget.cropController.turns;
//               },
//               style: buttonStyle(widget.cropController.turns == 3 ||
//                   widget.cropController.turns == 2),
//               child: const Icon(
//                 Icons.rotate_left,
//                 size: 28,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   widget.cropController.turns = widget.cropController.turns + 1;
//                 });
//                 widget.editedInfo.turns = widget.cropController.turns;
//               },
//               style: buttonStyle(widget.cropController.turns == 1 ||
//                   widget.cropController.turns == 2),
//               child: const Icon(
//                 Icons.rotate_right,
//                 size: 28,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   widget.cropController.flipHorizontal();
//                 });
//                 widget.editedInfo.flipX = widget.cropController.flipX;
//               },
//               style: buttonStyle(widget.cropController.flipX),
//               child: const Icon(Icons.flip),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   widget.cropController.flipVertical();
//                 });
//                 widget.editedInfo.flipY = widget.cropController.flipY;
//               },
//               style: buttonStyle(widget.cropController.flipY),
//               child: const RotatedBox(
//                 quarterTurns: 1,
//                 child: Icon(
//                   Icons.flip,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.background,
//                 borderRadius: BorderRadius.circular(17),
//               ),
//               clipBehavior: Clip.antiAlias,
//               height: 35,
//               padding: const EdgeInsets.symmetric(horizontal: 5),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                     width: 60,
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton(
//                         value: ratio,
//                         items: ratios.keys.map((String item) {
//                           return DropdownMenuItem(
//                             alignment: AlignmentDirectional.center,
//                             value: item,
//                             child: Text(
//                               item,
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.secondary,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             ratio = newValue!;
//                           });
//                           if (isLandscape) {
//                             widget.cropController.ratio = ratios[ratio];
//                           } else {
//                             if (ratios[ratio] != null) {
//                               widget.cropController.ratio =
//                                   1 / (ratios[ratio] ?? 1);
//                             } else {
//                               widget.cropController.ratio = null;
//                             }
//                           }
//                         },
//                         alignment: AlignmentDirectional.center,
//                         iconSize: 0,
//                         borderRadius: BorderRadius.circular(10),
//                         style: const TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold),
//                         itemHeight: 48,
//                         isExpanded: true,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 35,
//                     child: RawMaterialButton(
//                       onPressed: () {
//                         setState(() {
//                           isLandscape = !isLandscape;
//                           if (isLandscape) {
//                             widget.cropController.ratio = ratios[ratio];
//                           } else {
//                             if (ratios[ratio] != null) {
//                               widget.cropController.ratio =
//                                   1 / (ratios[ratio] ?? 1);
//                             } else {
//                               widget.cropController.ratio = null;
//                             }
//                           }
//                         });
//                       },
//                       child: Icon(
//                         isLandscape ^
//                                 (widget.cropController.turns == 1 ||
//                                     widget.cropController.turns == 3)
//                             ? Icons.crop_landscape
//                             : Icons.crop_portrait,
//                         size: 24,
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CropController with ChangeNotifier {
//   int _turns = 0;
//   bool flipX = false;
//   bool flipY = false;
//   double? _ratio;
//   // Not yet implemented
//   double _rotation = 0;

//   late final void Function(Offset details) onResizeStart;
//   late final void Function(Offset details, Offset delta) onResizeUpdate;
//   late final void Function() onResizeEnd;
//   late final void Function(double? ratio) onRatioChange;

//   set ratio(double? r) {
//     _ratio = r;
//     onRatioChange(_ratio);
//   }

//   double? get ratio {
//     return _ratio;
//   }

//   set turns(int t) {
//     _turns = t % 4;
//     notifyListeners();
//   }

//   int get turns {
//     return _turns;
//   }

//   set rotation(double r) {
//     _rotation = r % 360;
//     notifyListeners();
//   }

//   double get rotation {
//     return _rotation;
//   }

//   void flipHorizontal() {
//     flipX = !flipX;
//     notifyListeners();
//   }

//   void flipVertical() {
//     flipY = !flipY;
//     notifyListeners();
//   }
// }

// class CropBox extends StatefulWidget {
//   const CropBox(
//       {super.key,
//       required this.height,
//       required this.width,
//       required this.padding,
//       required this.cropController,
//       required this.aspectRatio,
//       required this.editedInfo});
//   final double height;
//   final double width;
//   final double padding;
//   final double aspectRatio;
//   final CropController cropController;
//   final EditedInfo editedInfo;

//   @override
//   State<CropBox> createState() => _CropBoxState();
// }

// class _CropBoxState extends State<CropBox> with SingleTickerProviderStateMixin {
//   late double top;
//   late double left;
//   late double right;
//   late double bottom;
//   late final double minTop;
//   late final double minLeft;
//   late final double maxRight;
//   late final double maxBottom;
//   late final double videoHeight;
//   late final double videoWidth;

//   final double minDistance = 20;

//   Widget corner = const Icon(
//     Icons.circle,
//     color: Colors.white,
//   );

//   @override
//   void initState() {
//     super.initState();

//     widget.cropController.onResizeStart = onStart;
//     widget.cropController.onResizeUpdate = onUpdate;
//     widget.cropController.onResizeEnd = onEnd;
//     widget.cropController.onRatioChange = setRatio;

//     if (widget.aspectRatio > 1) {
//       videoWidth = widget.width - 2 * widget.padding;
//       videoHeight = (videoWidth) / widget.aspectRatio;
//       minTop = (widget.height - videoHeight) / 2;
//       minLeft = widget.padding;
//       maxRight = widget.width - widget.padding;
//       maxBottom = minTop + videoHeight;
//     } else {
//       videoHeight = widget.height - 2 * widget.padding;
//       videoWidth = (videoHeight) * widget.aspectRatio;
//       minTop = widget.padding;
//       minLeft = (widget.width - videoWidth) / 2;
//       maxRight = minLeft + videoWidth;
//       maxBottom = widget.height - widget.padding;
//     }

//     top = minTop;
//     left = minLeft;
//     right = maxRight;
//     bottom = maxBottom;

//     animController = AnimationController(
//       duration: const Duration(milliseconds: 250),
//       vsync: this,
//     )..addListener(() {
//         setState(() {
//           top = animTop.value;
//           bottom = animBottom.value;
//           left = animLeft.value;
//           right = animRight.value;
//         });
//       });
//   }

//   late final AnimationController animController;
//   late Animation<double> animTop;
//   late Animation<double> animBottom;
//   late Animation<double> animLeft;
//   late Animation<double> animRight;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(width: top, color: Colors.black38),
//               left: BorderSide(width: left, color: Colors.black38),
//               right: BorderSide(
//                   width: widget.width - right, color: Colors.black38),
//               bottom: BorderSide(
//                   width: widget.height - bottom, color: Colors.black38),
//             ),
//             color: Colors.transparent,
//           ),
//         ),
//         Positioned(
//           top: top,
//           left: left,
//           width: right - left,
//           height: bottom - top,
//           child: Container(
//             decoration: BoxDecoration(
//                 border: Border.all(
//               color: Colors.white,
//               width: 2,
//             )),
//           ),
//         ),
//         Positioned(
//           top: top - 10,
//           left: left - 10,
//           child: corner,
//         ),
//         Positioned(
//           top: top - 10,
//           left: right - 13,
//           child: corner,
//         ),
//         Positioned(
//           top: bottom - 13,
//           left: left - 10,
//           child: corner,
//         ),
//         Positioned(
//           top: bottom - 13,
//           left: right - 13,
//           child: corner,
//         ),
//       ],
//     );
//   }

//   void setRatio(double? ratio) {
//     if (ratio == null) {
//     } else {
//       double centerH = (left + right) / 2;
//       double centerV = (top + bottom) / 2;
//       double widthIn = right - left;
//       double heightIn = bottom - top;

//       double widthOut = (widthIn + (heightIn * ratio)) / 2;
//       double heightOut = (heightIn + (widthIn / ratio)) / 2;

//       if (widthOut > (maxRight - minLeft)) {
//         widthOut = maxRight - minLeft;
//         heightOut = widthOut / ratio;
//       }
//       if (heightOut > (maxBottom - minTop)) {
//         heightOut = maxBottom - minTop;
//         widthOut = heightOut * ratio;
//       }

//       double topf = centerV - heightOut / 2;
//       double bottomf = centerV + heightOut / 2;
//       double leftf = centerH - widthOut / 2;
//       double rightf = centerH + widthOut / 2;

//       if (topf < minTop) {
//         bottomf += minTop - topf;
//         topf = minTop;
//       } else if (bottomf > maxBottom) {
//         topf -= bottomf - maxBottom;
//         bottomf = maxBottom;
//       }
//       if (leftf < minLeft) {
//         rightf += minLeft - leftf;
//         leftf = minLeft;
//       } else if (rightf > maxRight) {
//         leftf -= rightf - maxRight;
//         rightf = maxRight;
//       }

//       animTop = Tween(begin: top, end: topf).animate(animController);
//       animLeft = Tween(begin: left, end: leftf).animate(animController);
//       animBottom = Tween(begin: bottom, end: bottomf).animate(animController);
//       animRight = Tween(begin: right, end: rightf).animate(animController);
//       animController.forward(from: 0);
//     }
//   }

//   int select = 0;
//   void onStart(Offset details) {
//     bool isTop =
//         (details.dy < top + minDistance) && (details.dy > top - minDistance);
//     bool isBottom = (details.dy < bottom + minDistance) &&
//         (details.dy > bottom - minDistance);
//     bool isLeft =
//         (details.dx < left + minDistance) && (details.dx > left - minDistance);
//     bool isRight = (details.dx < right + minDistance) &&
//         (details.dx > right - minDistance);

//     // debugPrint("l:$isLeft r:$isRight t:$isTop b:$isBottom");
//     if (isTop && isLeft) {
//       // top left
//       select = 1;
//     } else if (isBottom && isLeft) {
//       // botton left
//       select = 2;
//     } else if (isTop && isRight) {
//       // top right
//       select = 3;
//     } else if (isBottom && isRight) {
//       // botton right
//       select = 4;
//     } else if (isLeft) {
//       //left only
//       if ((details.dy < bottom) && (details.dy > top)) {
//         select = 5;
//       }
//     } else if (isRight) {
//       // right only
//       if ((details.dy < bottom) && (details.dy > top)) {
//         select = 6;
//       }
//     } else if (isTop) {
//       // top only
//       if ((details.dx < right) && (details.dx > left)) {
//         select = 7;
//       }
//     } else if (isBottom) {
//       // bottom only
//       if ((details.dx < right) && (details.dx > left)) {
//         select = 8;
//       }
//     }
//   }

//   double minHeight = 50;
//   double minWidth = 50;

//   void onUpdate(Offset details, Offset delta) {
//     void setTop(double y) {
//       if ((bottom - y) < minHeight) {
//         top = bottom - minHeight;
//       } else {
//         if (y >= minTop) {
//           top = y;
//         } else {
//           top = minTop;
//         }
//       }
//     }

//     void setLeft(double x) {
//       if ((right - x) < minWidth) {
//         left = right - minWidth;
//       } else {
//         if (x >= minLeft) {
//           left = x;
//         } else {
//           left = minLeft;
//         }
//       }
//     }

//     void setBottom(double y) {
//       if ((y - top) < minHeight) {
//         bottom = top + minHeight;
//       } else {
//         if (y <= maxBottom) {
//           bottom = y;
//         } else {
//           bottom = maxBottom;
//         }
//       }
//     }

//     void setRight(double x) {
//       if ((x - left) < minWidth) {
//         right = left + minWidth;
//       } else {
//         if (x <= maxRight) {
//           right = x;
//         } else {
//           right = maxRight;
//         }
//       }
//     }

//     void move(Offset offset) {
//       double topN = top + offset.dy;
//       double leftN = left + offset.dx;
//       double rightN = right + offset.dx;
//       double bottomN = bottom + offset.dy;
//       if (topN < minTop) {
//         top = minTop;
//         bottom += top - topN + offset.dy;
//       } else if (bottomN > maxBottom) {
//         bottom = maxBottom;
//         top += bottom - bottomN + offset.dy;
//       } else {
//         top = topN;
//         bottom = bottomN;
//       }
//       if (leftN < minLeft) {
//         left = minLeft;
//         right += left - leftN + offset.dx;
//       } else if (rightN > maxRight) {
//         right = maxRight;
//         left += right - rightN + offset.dx;
//       } else {
//         left = leftN;
//         right = rightN;
//       }
//     }

//     double? ratoi = widget.cropController.ratio;
//     switch (select) {
//       case 1:
//         if (ratoi == null) {
//           setState(() {
//             setTop(details.dy);
//             setLeft(details.dx);
//           });
//         } else {
//           double distance = delta.distance * cos(atan(ratoi) - delta.direction);
//           double t = distance * cos(atan(ratoi)) + top;
//           double l = distance * sin(atan(ratoi)) + left;
//           if (((t) >= minTop) &&
//               ((bottom - t) > minHeight) &&
//               ((right - l) > minWidth) &&
//               (l >= minLeft)) {
//             setState(() {
//               top = t;
//               left = l;
//             });
//           }
//         }
//         break;
//       case 2:
//         if (ratoi == null) {
//           setState(() {
//             setBottom(details.dy);
//             setLeft(details.dx);
//           });
//         } else {
//           double distance =
//               delta.distance * cos(atan(-1 / ratoi) - delta.direction);
//           double b = bottom - distance * cos(atan(ratoi));
//           double l = distance * sin(atan(ratoi)) + left;
//           if ((b <= maxBottom) &&
//               ((b - top) > minHeight) &&
//               ((right - l) > minWidth) &&
//               (l >= minLeft)) {
//             setState(() {
//               bottom = b;
//               left = l;
//             });
//           }
//         }
//         break;
//       case 3:
//         if (ratoi == null) {
//           setState(() {
//             setTop(details.dy);
//             setRight(details.dx);
//           });
//         } else {
//           double distance =
//               delta.distance * cos(atan(-1 / ratoi) - delta.direction);
//           double t = top - distance * cos(atan(ratoi));
//           double r = distance * sin(atan(ratoi)) + right;
//           if (((t) >= minTop) &&
//               ((bottom - t) > minHeight) &&
//               ((r - left) > minWidth) &&
//               (r <= maxRight)) {
//             setState(() {
//               top = t;
//               right = r;
//             });
//           }
//         }
//         break;
//       case 4:
//         if (ratoi == null) {
//           setState(() {
//             setBottom(details.dy);
//             setRight(details.dx);
//           });
//         } else {
//           double distance = delta.distance * cos(atan(ratoi) - delta.direction);
//           double b = distance * cos(atan(ratoi)) + bottom;
//           double r = distance * sin(atan(ratoi)) + right;
//           if ((b <= maxBottom) &&
//               ((b - top) > minHeight) &&
//               ((r - left) > minWidth) &&
//               (r <= maxRight)) {
//             setState(() {
//               bottom = b;
//               right = r;
//             });
//           }
//         }
//         break;
//       case 5:
//         if (ratoi == null) {
//           setState(() {
//             setLeft(details.dx);
//           });
//         } else {
//           double l = left + delta.dx;
//           double t = top + (delta.dx / ratoi) / 2;
//           double b = bottom - (delta.dx / ratoi) / 2;
//           if (((right - l) > minWidth) &&
//               (l >= minLeft) &&
//               ((b - t) >= minHeight)) {
//             setState(() {
//               if ((t >= minTop) && (b <= maxBottom)) {
//                 top = t;
//                 bottom = b;
//                 left = l;
//               } else if (t < minTop && (b <= maxBottom)) {
//                 bottom -= delta.dx / ratoi;
//                 left = l;
//               } else if (b > maxBottom && (t >= minTop)) {
//                 top += delta.dx / ratoi;
//                 left = l;
//               }
//             });
//           }
//         }
//         break;
//       case 6:
//         if (ratoi == null) {
//           setState(() {
//             setRight(details.dx);
//           });
//         } else {
//           double r = right + delta.dx;
//           double t = top - (delta.dx / ratoi) / 2;
//           double b = bottom + (delta.dx / ratoi) / 2;
//           if (((r - left) > minWidth) &&
//               (r <= maxRight) &&
//               ((b - t) >= minHeight)) {
//             setState(() {
//               if ((t >= minTop) && (b <= maxBottom)) {
//                 top = t;
//                 bottom = b;
//                 right = r;
//               } else if (t < minTop && (b <= maxBottom)) {
//                 bottom += delta.dx / ratoi;
//                 right = r;
//               } else if (b > maxBottom && (t >= minTop)) {
//                 top -= delta.dx / ratoi;
//                 right = r;
//               }
//             });
//           }
//         }
//         break;
//       case 7:
//         if (ratoi == null) {
//           setState(() {
//             setTop(details.dy);
//           });
//         } else {
//           double t = top + delta.dy;
//           double l = left + (delta.dy * ratoi) / 2;
//           double r = right - (delta.dy * ratoi) / 2;
//           if (((bottom - t) > minWidth) &&
//               (t >= minTop) &&
//               ((r - l) >= minHeight)) {
//             setState(() {
//               if ((l >= minLeft) && (r <= maxRight)) {
//                 left = l;
//                 right = r;
//                 top = t;
//               } else if (l < minLeft && (r <= maxRight)) {
//                 right -= delta.dy * ratoi;
//                 top = t;
//               } else if (r > maxRight && (l >= minLeft)) {
//                 left += delta.dy * ratoi;
//                 top = t;
//               }
//             });
//           }
//         }
//         break;
//       case 8:
//         if (ratoi == null) {
//           setState(() {
//             setBottom(details.dy);
//           });
//         } else {
//           double b = bottom + delta.dy;
//           double l = left - (delta.dy * ratoi) / 2;
//           double r = right + (delta.dy * ratoi) / 2;
//           if (((b - top) > minHeight) &&
//               (b <= maxBottom) &&
//               ((r - l) >= minHeight)) {
//             setState(() {
//               if ((l >= minLeft) && (r <= maxRight)) {
//                 left = l;
//                 right = r;
//                 bottom = b;
//               } else if (l < minLeft && (r <= maxRight)) {
//                 right += delta.dy * ratoi;
//                 bottom = b;
//               } else if (r > maxRight && (l >= minLeft)) {
//                 left -= delta.dy * ratoi;
//                 bottom = b;
//               }
//             });
//           }
//         }
//         break;
//       default:
//         setState(() {
//           move(delta);
//         });
//         break;
//     }
//   }

//   void onEnd() {
//     select = 0;
//     widget.editedInfo.cropTop = (top - minTop) / videoHeight;
//     widget.editedInfo.cropLeft = (left - minLeft) / videoWidth;
//     widget.editedInfo.cropRight = (right - minLeft) / videoWidth;
//     widget.editedInfo.cropBottom = (bottom - minTop) / videoHeight;
//     debugPrint(
//         't: ${widget.editedInfo.cropTop}, b: ${widget.editedInfo.cropBottom}, l: ${widget.editedInfo.cropLeft}, r: ${widget.editedInfo.cropRight}');
//   }
// }

// class Home extends StatelessWidget {
//   const Home({super.key});

//   void selectFile(BuildContext context) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.video,
//       );
//       if (result != null) {
//         if (result.files.single.path != null) {
//           String path = result.files.single.path.toString();
//           debugPrint(path);
//           if (context.mounted) {
//             Navigator.pushNamed(context, '/editor',
//                 arguments: {'path': path, 'name': result.files.single.name});
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Video Editor"),
//       ),
//       body: InkWell(
//         child: SizedBox.expand(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/video.png',
//                 width: 200,
//                 color: Theme.of(context).primaryColorLight,
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Text(
//                 "Tap to select video",
//                 style: TextStyle(
//                   color: Theme.of(context).primaryColorLight,
//                   fontSize: 25,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         onTap: () => selectFile(context),
//       ),
//     );
//   }
// }
