// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:cached_video_player_plus/cached_video_player_plus.dart';

// class SearchPlayerProvider with ChangeNotifier {
//   CachedVideoPlayerPlusController? _controller;
//   String? _currentUrl;
//   Future<void>? _initializeVideoPlayerFuture;

//   CachedVideoPlayerPlusController? get controller => _controller;
//   Future<void>? get initializeVideoPlayerFuture => _initializeVideoPlayerFuture;

//   Future<void> initialize(String url) async {
//     if (_controller == null || _currentUrl != url) {
//       _controller?.dispose();
//       _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(url),
//           videoPlayerOptions: VideoPlayerOptions(
//             mixWithOthers: true,
//           ));
//       _currentUrl = url;
//       _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
//         _controller!.play();
//         _controller!.setVolume(0.0);
//         _controller!.setLooping(true);
//         notifyListeners();
//       }).catchError((error) {
//         log("Video player initialization error: $error");
//       });

//       _controller!.addListener(() {
//         if (_controller!.value.hasError) {
//           log("Video player error: ${_controller!.value.errorDescription}");
//         }
//         notifyListeners();
//       });
//     }
//   }

//   void disposeController() {
//     _controller?.dispose();
//     _controller = null;
//     _currentUrl = null;
//     notifyListeners();
//   }
// }
