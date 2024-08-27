import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;

  final bool isDraftPlayer;

  const CustomVideoPlayer(
      {Key? key,
      required this.videoUrl,
      required this.height,
      required this.width,
      this.isDraftPlayer = false})
      : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  //  creating the instance of  the controller video player
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    //  initilzing the player
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
            ));
    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      setState(() {
        videoPlayerController.play();
        videoPlayerController.setVolume(0.0);
        videoPlayerController.setLooping(widget.isDraftPlayer ? false : true);
      });
    }).catchError((error) {
      log("Video player initialization error: $error");
    });

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.hasError) {
        log("Video player error: ${videoPlayerController.value.errorDescription}");
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
    //  how the video will look

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (videoPlayerController.value.isInitialized) {
            return ClipRect(
              child: Container(
                width: widget.width,
                height: widget.height,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoPlayerController.value.size.width,
                    height: videoPlayerController.value.size.height,
                    child: VideoPlayer(videoPlayerController),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text(""));
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(""));
        } else {
          return Center(child: SizedBox());
        }
      },
    );
  }
}
