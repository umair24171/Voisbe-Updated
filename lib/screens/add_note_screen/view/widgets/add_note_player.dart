import 'package:flutter/material.dart';
// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/player_provider.dart';
import 'package:video_player/video_player.dart';

class AddNotePlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;

  const AddNotePlayer({
    Key? key,
    required this.videoUrl,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  State<AddNotePlayer> createState() => _AddNotePlayerState();
}

class _AddNotePlayerState extends State<AddNotePlayer> {
  late PlayerProvider _videoPlayerProvider;

  @override
  void initState() {
    super.initState();
    _videoPlayerProvider = Provider.of<PlayerProvider>(context, listen: false);
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoPlayerProvider.disposeVideoPlayer();
    super.dispose();
  }

  void _initializeVideo() async {
    await _videoPlayerProvider.initialize(widget.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _videoPlayerProvider,
      child: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          if (provider.isInitialized) {
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: VideoPlayer(provider.videoPlayerController!),
                ),
              ),
            );
            // return AspectRatio(
            //   aspectRatio: 9 / 16,
            //   child: CachedVideoPlayerPlus(provider.videoPlayerController!),
            // );
          } else {
            return Center(child: Text(''));
          }
        },
      ),
    );
  }
}
