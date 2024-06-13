import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class SingleSearchItem extends StatefulWidget {
  const SingleSearchItem(
      {super.key,
      required this.noteModel,
      required this.index,
      required this.audioPlayer,
      required this.changeIndex,
      required this.duration,
      required this.playPause,
      required this.stopMainPlayer,
      required this.pageController,
      required this.isPlaying,
      required this.postion});
  final NoteModel noteModel;
  final int index;
  final AudioPlayer audioPlayer;
  final int changeIndex;
  final Duration postion;
  final Duration duration;
  final VoidCallback playPause;
  final VoidCallback stopMainPlayer;
  final bool isPlaying;
  final PageController pageController;

  @override
  State<SingleSearchItem> createState() => _SingleSearchItemState();
}

class _SingleSearchItemState extends State<SingleSearchItem> {
  late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0; // Default playback speed
  PlayerState? _playerState;

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  initPlayer() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(widget.noteModel.noteUrl);
    _playerState = _audioPlayer.state;

    // Check if the file is already cached
    DefaultCacheManager()
        .getFileFromCache(widget.noteModel.noteUrl)
        .then((file) {
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
        await _audioPlayer
            .setPlaybackRate(_playbackSpeed); // Set playback speed
        await _audioPlayer.play(UrlSource(_cachedFilePath!));
      } else {
        // Cache the file if not already cached
        DefaultCacheManager()
            .downloadFile(widget.noteModel.noteUrl)
            .then((fileInfo) {
          if (fileInfo.file.existsSync()) {
            _cachedFilePath = fileInfo.file.path;
            _audioPlayer.setPlaybackRate(_playbackSpeed); // Set playback speed
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.5,
      child: Stack(
        children: [
          SizedBox(
            height: size.height * 0.2,
            width: size.width * 0.5,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherUserProfile(
                        userId: widget.noteModel.userUid,
                      ),
                    ));
              },
              child: Image.network(
                widget.noteModel.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Positioned(
          //   top: 30,
          //   left: 54,
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: whiteColor,
          //       borderRadius: BorderRadius.circular(35),
          //     ),
          //     child: IconButton(
          //       onPressed: playPause,
          //       icon: Icon(
          //         _isPlaying ? Icons.pause_circle_filled : Icons.play_arrow,
          //         color: widget.index == 0
          //             ? Colors.red
          //             : widget.index == 1
          //                 ? greenColor
          //                 : color7,
          //       ),
          //     ),
          //   ),
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 8.0,
                percent: position.inSeconds / duration.inSeconds,

                center: InkWell(
                  splashColor: Colors.transparent,
                  onTap: playPause,
                  child: Container(
                    // height: 10,
                    // width: 10,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(30)),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Color(widget.noteModel.topicColor.value),
                      size: 20,
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                // backgroundColor: widget.index == 0
                //     ? const Color(0xff50a87e)
                //     : widget.index == 1
                //         ? const Color(0xff6cbfd9)
                //         : Colors.white,
                backgroundColor: _isPlaying
                    ? const Color(0xFFB8C7CB)
                    : Color(widget.noteModel.topicColor.value),
                progressColor: Color(widget.noteModel.topicColor.value),
                animation: _isPlaying,
                animationDuration: duration.inSeconds,
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: size.width * 0.45,
                        decoration: BoxDecoration(
                            color: Color(widget.noteModel.topicColor.value),
                            borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: Text(
                          widget.noteModel.topic,
                          overflow: TextOverflow.ellipsis,
                          // textAlign: a,
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 11,
                              color: whiteColor),
                        )),
                  ),
                  Positioned(
                      left: size.width * 0.29,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteDetailsScreen(
                                    audioPlayer: widget.audioPlayer,
                                    changeIndex: widget.changeIndex,
                                    currentIndex: widget.changeIndex,
                                    duration: widget.duration,
                                    isPlaying: widget.isPlaying,
                                    pageController: widget.pageController,
                                    playPause: widget.playPause,
                                    position: widget.postion,
                                    stopMainPlayer: widget.stopMainPlayer,
                                    size: size,
                                    note: widget.noteModel),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                              // boxShadow: const [
                              //   BoxShadow(
                              //       color: Color(0xffcf4836),
                              //       blurRadius: 4,
                              //       spreadRadius: 1)
                              // ],
                              color: whiteColor.withOpacity(1),
                              borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            'View Post',
                            style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 11,
                                color:
                                    Color(widget.noteModel.topicColor.value)),
                          ),
                        ),
                      ))
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
