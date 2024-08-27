import 'dart:developer';

// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

//  provider to manage the player globally
//  initilizing the player and then disposing it when we need

class PlayerProvider with ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize the video player with a given URL
  Future<void> initialize(String videoUrl) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = VideoPlayerController.network(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    await _controller!.initialize();
    _controller!.play();
    _controller!.setVolume(0.0);
    _controller!.setLooping(true);

    _isInitialized = true;
    notifyListeners();
  }

  // Dispose the video player
  Future<void> disposeVideoPlayer() async {
    await _controller?.dispose();
    _isInitialized = false;
    notifyListeners();
  }

  VideoPlayerController? get videoPlayerController => _controller;

  // Get the video player controller
  // late CachedVideoPlayerPlusController videoPlayerController;
  // late Future<void> initializeVideoPlayerFuture;

  // void initializeController(String videoUrl) async {
  //   videoPlayerController =
  //       CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoUrl),
  //           videoPlayerOptions: VideoPlayerOptions(
  //             mixWithOthers: true,
  //           ));
  //   initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
  //     videoPlayerController.play();
  //     videoPlayerController.setVolume(0.0);
  //     videoPlayerController.setLooping(true);
  //     notifyListeners();
  //   }).catchError((error) {
  //     print("Video player initialization error: $error");
  //   });

  //   videoPlayerController.addListener(() {
  //     if (videoPlayerController.value.hasError) {
  //       print(
  //           "Video player error: ${videoPlayerController.value.errorDescription}");
  //     }
  //   });
  // }

  // initPlayer(String videoUrl) {
  //   videoPlayerPlusController =
  //       CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoUrl));

  //   initializeVideoPlayerFuture =
  //       videoPlayerPlusController.initialize().then((_) {
  //     videoPlayerPlusController.play();
  //     videoPlayerPlusController.setVolume(0.0);

  //     videoPlayerPlusController.seekTo(Duration.zero);
  //     videoPlayerPlusController.setLooping(true);
  //     notifyListeners();
  //     // setState(() {});
  //   }).onError(
  //     (error, stackTrace) {
  //       log('Error is ${error.toString()}');
  //     },
  //   );
  //   notifyListeners();
  // }

  // disposePlayer() {
  //   videoPlayerController.dispose();
  //   notifyListeners();
  // }
}
