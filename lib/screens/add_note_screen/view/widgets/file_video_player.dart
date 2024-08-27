import 'dart:io';

// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayer extends StatefulWidget {
  final File videoUrl;
  final double height;
  final double width;

  const FileVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  State<FileVideoPlayer> createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      setState(() {
        videoPlayerController.play();
        videoPlayerController.setVolume(0.0);
        videoPlayerController.setLooping(true);
      });
    }).catchError((error) {
      print("Video player initialization error: $error");
    });

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.hasError) {
        print(
            "Video player error: ${videoPlayerController.value.errorDescription}");
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (videoPlayerController.value.isInitialized) {
            return AspectRatio(
              aspectRatio: 9 / 16,
              child: VideoPlayer(videoPlayerController),
            );
            // return SizedBox.expand(
            //   child: FittedBox(
            //     fit: BoxFit.cover,
            //     child: SizedBox(
            //       width: widget.width,
            //       height: widget.height,
            //       child: VideoPlayer(videoPlayerController),
            //     ),
            //   ),
            // );
          } else {
            return Center(child: Text("Video not initialized"));
          }
        } else if (snapshot.hasError) {
          return Center(child: Text("Error initializing video"));
        } else {
          return Center(child: Text(''));
        }
      },
    );
  }
}
