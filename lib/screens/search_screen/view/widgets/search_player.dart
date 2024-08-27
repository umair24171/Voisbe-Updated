import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SearchPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;
  final VideoPlayerController? controller;

  // getting data from the constructor

  const SearchPlayer({
    Key? key,
    required this.videoUrl,
    required this.height,
    required this.width,
    this.controller,
  }) : super(key: key);

  @override
  State<SearchPlayer> createState() => _SearchPlayerState();
}

class _SearchPlayerState extends State<SearchPlayer> {
  VideoPlayerController? _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = widget.controller;
    _initializeVideoPlayerFuture = _initializePlayer();
  }

  // initializing the controller

  Future<void> _initializePlayer() async {
    if (_videoPlayerController == null) {
      // getting cached file

      final File videoFile = await _getCachedVideoFile(widget.videoUrl);

      if (await videoFile.exists()) {
        _videoPlayerController = VideoPlayerController.file(videoFile,
            videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true, allowBackgroundPlayback: false));

        // getting the original file if the cached is null
      } else {
        await _downloadAndCacheVideo(widget.videoUrl, videoFile);
        _videoPlayerController = VideoPlayerController.file(videoFile,
            videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true, allowBackgroundPlayback: false));
      }

      await _videoPlayerController!.initialize();
      _videoPlayerController!.play();
      _videoPlayerController!.setVolume(0.0);
      _videoPlayerController!.setLooping(true);

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.hasError) {
          log("Video player error: ${_videoPlayerController!.value.errorDescription}");
        }
      });
    }
  }

  // function to get the cached if the video is already played

  Future<File> _getCachedVideoFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = _generateFilename(url);
    return File('${directory.path}/$filename');
  }

  String _generateFilename(String url) {
    final hash = md5.convert(utf8.encode(url)).toString();
    return '$hash.mp4';
  }

  Future<void> _downloadAndCacheVideo(String url, File file) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download video: ${response.statusCode}');
    }
  }

// disposing it when no longer needed

  @override
  void dispose() {
    if (widget.controller == null) {
      _videoPlayerController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  how the video will look like

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized) {
            return ClipRect(
              child: Container(
                width: widget.width,
                height: widget.height,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoPlayerController!.value.size.width,
                    height: _videoPlayerController!.value.size.height,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text(""));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text(""));
        } else {
          return const Center(child: Text(""));
        }
      },
    );
  }
}
