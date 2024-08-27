import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ThumbnailVideoPlayer extends StatefulWidget {
  const ThumbnailVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.height,
    required this.width,
  });
  final String videoUrl;
  final double height;
  final double width;

  @override
  State<ThumbnailVideoPlayer> createState() => _ThumbnailVideoPlayerState();
}

class _ThumbnailVideoPlayerState extends State<ThumbnailVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    // Use flutter_cache_manager to cache the video
    final fileInfo =
        await DefaultCacheManager().getFileFromCache(widget.videoUrl);
    final file = fileInfo?.file ??
        await DefaultCacheManager().getSingleFile(widget.videoUrl);

    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false; // Update loading state
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: widget.width,
        height: widget.height,
        child: _isLoading
            ? Center(
                child: Text(''), // Show progress indicator while loading
              )
            : FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size?.width ?? widget.width,
                  height: _controller.value.size?.height ?? widget.height,
                  child: VideoPlayer(_controller),
                ),
              ),
      ),
    );
  }
}
