import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class SingleBookMarkItem extends StatefulWidget {
  const SingleBookMarkItem({super.key, required this.note});
  final NoteModel note;

  @override
  State<SingleBookMarkItem> createState() => _SingleBookMarkItemState();
}

class _SingleBookMarkItemState extends State<SingleBookMarkItem> {
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
    _audioPlayer.setSourceUrl(widget.note.noteUrl);
    _playerState = _audioPlayer.state;

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
            .downloadFile(widget.note.noteUrl)
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
  AudioPlayer _audio = AudioPlayer();
  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: 121,
      width: 121,
      child: Stack(
        children: [
          SizedBox(
            height: 121,
            width: 121,
            child: GestureDetector(
              onLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoteDetailsScreen(
                        audioPlayer: _audio,
                        changeIndex: 0,
                        currentIndex: 0,
                        duration: Duration.zero,
                        isPlaying: true,
                        pageController: controller,
                        playPause: () {
                          // playPause(userPosts[index].noteUrl, index);
                        },
                        position: Duration.zero,
                        stopMainPlayer: () {},
                        size: MediaQuery.of(context).size,
                        note: widget.note),
                  ),
                );
              },
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => OtherUserProfile(
                //         userId: widget.note.userUid,
                //       ),
                //     ));
              },
              child: Image.network(
                widget.note.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(),
          Align(
            alignment: Alignment.center,
            child: CircularPercentIndicator(
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
                    color: Color(widget.note.topicColor.value),
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
                  : Color(widget.note.topicColor.value),
              progressColor: Color(widget.note.topicColor.value),
              animation: _isPlaying,
              animationDuration: duration.inSeconds,
            ),
          )
        ],
      ),
    );
  }
}
