// import 'dart:developer';

import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';

class SinglePostNote extends StatefulWidget {
  const SinglePostNote(
      {super.key,
      required this.note,
      required this.isPinned,
      this.isThirdPost = false,
      this.isSecondPost = false,
      required this.isGridViewPost});
  final NoteModel note;
  final bool isPinned;
  final bool isGridViewPost;
  final bool isThirdPost;
  final bool isSecondPost;
  @override
  State<SinglePostNote> createState() => _SinglePostNoteState();
}

class _SinglePostNoteState extends State<SinglePostNote> {
  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(widget.note.noteUrl);
    // Check if the file is already cached
    DefaultCacheManager().getFileFromCache(widget.note.noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });
    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    _audioPlayer.onPlayerComplete.listen((state) {
      setState(() {
        _isPlaying = false;
      });
    });
  }
  // @override
  // void didChangeDependencies() {
  //   getDuration();
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_cachedFilePath != null) {
        _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setPlaybackRate(1); // Set playback speed
        await _audioPlayer.play(UrlSource(_cachedFilePath!));

        // updatePlayedComment();
      } else {
        // Cache the file if not already cached
        _audioPlayer.setReleaseMode(ReleaseMode.stop);
        DefaultCacheManager()
            .downloadFile(widget.note.noteUrl)
            .then((fileInfo) {
          if (fileInfo.file.existsSync()) {
            _cachedFilePath = fileInfo.file.path;
            _audioPlayer.setPlaybackRate(1); // Set playback speed
            _audioPlayer.play(
              UrlSource(_cachedFilePath!),
            );
          }
        });
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  getDuration() async {
    duration = (await _audioPlayer.getDuration())!;
    position = (await _audioPlayer.getCurrentPosition())!;
    setState(() {});
  }

  getPosition() async {
    setState(() {});
  }

  String getReverseDuration(Duration position, Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds - position.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getInitialDurationnText(Duration totalDuration) {
    int remainingSeconds = totalDuration.inSeconds;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // log
    var size = MediaQuery.of(context).size;
    log('mobile wid ${size.width}');
    double padding = 0;
    if (widget.isSecondPost && size.width >= 412) {
      padding = 40;
    } else {
      padding = 0;
    }
    // getDuration();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSecondPost && size.width >= 412 ? 10 : 0,
      ).copyWith(
        left: widget.isSecondPost && size.width >= 412
            ? 13
            : widget.isThirdPost && size.width >= 412
                ? 10
                : 2,
      ),
      child: CircularPercentIndicator(
        radius: 44,
        // 44.0,
        lineWidth: 5.0,
        percent: position.inSeconds / duration.inSeconds,
        center: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // if (!widget.isPinned && !widget.isGridViewPost)
              //   SizedBox(
              //     height: widget.isGridViewPost ? 0 : 10,
              //   ),
              // if (widget.isGridViewPost)
              //   SizedBox(
              //     height: 0,
              //   ),
              if (widget.isPinned)
                Icon(
                  Icons.push_pin,
                  color: primaryColor,
                  size: 11,
                ),
              if (!widget.isPinned)
                Text(
                  widget.note.title.toUpperCase(),
                  style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 8,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                splashColor: Colors.transparent,
                onTap: playPause,
                child: Container(
                  // height: 10,
                  // width: 10,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: whiteColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),

              // IconButton(
              //   onPressed: playPause,
              //   icon: Icon(
              //     _isPlaying
              //         ? Icons.pause_circle_filled
              //         : Icons.play_circle_fill,
              //     color: primaryColor,
              //     size: 35,
              //   ),
              // ),
              position.inSeconds == 0
                  ? Text(
                      getInitialDurationnText(duration),
                      style: TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          color: primaryColor),
                    )
                  : Text(
                      getReverseDuration(position, duration),
                      style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: primaryColor),
                    ),
            ],
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: _isPlaying ? whiteColor : primaryColor,
        progressColor: primaryColor,
        animation: _isPlaying,
        animationDuration: duration.inSeconds,
      ),
    );
  }
}
