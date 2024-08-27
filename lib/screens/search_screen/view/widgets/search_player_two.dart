import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:social_notes/screens/home_screen/provider/video_player_manager.dart';
import 'package:video_player/video_player.dart';

class SearchPlayerTwo extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;

  const SearchPlayerTwo({
    Key? key,
    required this.videoUrl,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  State<SearchPlayerTwo> createState() => _SearchPlayerTwoState();
}

class _SearchPlayerTwoState extends State<SearchPlayerTwo> {
  VideoPlayerController? _controller;
  final VideoCacheManager _cacheManager = VideoCacheManager();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  // inititialing the controller

  Future<void> _initializeController() async {
    try {
      // getting file to play

      final videoFile = await _cacheManager.getCachedVideoFile(widget.videoUrl);
      _controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0.0);
      _controller!.play();

      if (mounted) setState(() {});
    } catch (e) {
      log("Error initializing video controller: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text(""));
    }

    // how the video looks

    return ClipRect(
      child: Container(
        width: widget.width,
        height: widget.height,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
