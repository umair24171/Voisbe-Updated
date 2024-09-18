import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
// import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

// int? currentPlayingIndex;

class CircleVoiceNotes extends StatefulWidget {
  CircleVoiceNotes({
    Key? key,
    required this.commentModel,
    required this.index,
    required this.subscriberCommentIndex,
    required this.closeFriendIndexs,
    required this.onPlayStateChanged,
    required this.audioPlayer,
    required this.engageCommentIndex,
    // required this.backGround,
    required this.isPlaying,
    required this.position,
    required this.onPlayPause,
    required this.changeIndex,
  }) : super(key: key);

  //  getting the required data from the constructor

  final CommentModel commentModel;
  final int index;
  final List<int> subscriberCommentIndex;
  final List<int> closeFriendIndexs;
  final Function(bool) onPlayStateChanged;
  AudioPlayer audioPlayer;
  bool isPlaying;
  Duration position;
  VoidCallback onPlayPause;
  int changeIndex;
  int engageCommentIndex;

  @override
  State<CircleVoiceNotes> createState() => _CircleVoiceNotesState();
}

class _CircleVoiceNotesState extends State<CircleVoiceNotes> {
  // late AudioPlayer _audioPlayer;
  String? _cachedFilePath;
  // bool _isPlaying = false;
  double _playbackSpeed = 1.0; // Default playback speed
  PlayerState? _playerState;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    widget.audioPlayer = AudioPlayer();
    widget.audioPlayer.setReleaseMode(ReleaseMode.stop);
    await widget.audioPlayer.setSourceUrl(widget.commentModel.comment);
    _playerState = widget.audioPlayer.state;

    // Check if the file is already cached
    final fileInfo = await DefaultCacheManager()
        .getFileFromCache(widget.commentModel.comment);
    if (fileInfo != null && fileInfo.file.existsSync()) {
      _cachedFilePath = fileInfo.file.path;
    }

    widget.audioPlayer.onDurationChanged.listen((event) {
      if (mounted) {
        setState(() {
          duration = event;
        });
      }
    });
  }

//  disposing the player when no longer needs

  @override
  void dispose() {
    super.dispose();
    // widget.audioPlayer.dispose();
    // widget.audioPlayer.stop();
  }

// updating the value of played comment

  updatePlayedComment() async {
    int updateCommentCounter = widget.commentModel.playedComment;
    updateCommentCounter++;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.commentModel.postId)
        .collection('comments')
        .doc(widget.commentModel.commentid)
        .update({'playedComment': updateCommentCounter});
  }

  bool _isLiked = false;
  Duration duration = Duration.zero;
  // Duration position = Duration.zero;

  //  like function on the circle replies

  void _toggleLike() async {
    bool isAlreadyLiked = widget.commentModel.likes
        .contains(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _isLiked = !isAlreadyLiked;
    });

    if (_isLiked) {
      widget.commentModel.likes.add(FirebaseAuth.instance.currentUser!.uid);
    } else {
      widget.commentModel.likes.remove(FirebaseAuth.instance.currentUser!.uid);
    }

    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.commentModel.postId)
        .collection('comments')
        .doc(widget.commentModel.commentid)
        .update({
      'likes': widget.commentModel.likes,
    });

    // Wait for 2 seconds for the animation
    await Future.delayed(const Duration(seconds: 2));

    // Reset the like animation after 2 seconds
    setState(() {
      _isLiked = isAlreadyLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize =
        size.width * 0.23; // Adjust this value to change the overall size

    return GestureDetector(
      onTap: widget.onPlayPause,
      onDoubleTap: _toggleLike,
      child: Column(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress Indicator
                CircularPercentIndicator(
                  radius: circleSize / 2,
                  lineWidth: 6.0, // Reduced line width for better visibility
                  percent: duration.inSeconds > 0
                      ? (widget.position.inSeconds / duration.inSeconds)
                          .clamp(0.0, 1.0)
                      : 0.0,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: widget.isPlaying &&
                          widget.changeIndex == widget.index
                      ? const Color(0xFFB8C7CB)
                      : widget.index == widget.engageCommentIndex
                          ? const Color(0xff6cbfd9)
                          : widget.subscriberCommentIndex.contains(widget.index)
                              ? const Color(0xffa562cb)
                              : widget.closeFriendIndexs.contains(widget.index)
                                  ? const Color(0xff50a87e)
                                  : primaryColor,
                  progressColor: widget.index == widget.engageCommentIndex
                      ? const Color(0xff6cbfd9)
                      : widget.subscriberCommentIndex.contains(widget.index)
                          ? const Color(0xffa562cb)
                          : widget.closeFriendIndexs.contains(widget.index)
                              ? const Color(0xff50a87e)
                              : primaryColor,
                  center: _buildProfilePicture(circleSize),
                ),

                // Play/Pause or Like Icon
                _buildOverlayIcon(circleSize * 0.5),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OtherUserProfile(userId: widget.commentModel.userId),
                  ));
            },
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.commentModel.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data();
                    UserModel userModel = UserModel.fromMap(data!);
                    return userModel.name.isEmpty
                        ? Text('')
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userModel.isVerified
                                    ? (userModel.name.length > 7
                                        ? '${userModel.name.substring(0, 5)}...'
                                        : userModel.name)
                                    : (userModel.name.length > 7
                                        ? '${userModel.name.substring(0, 7)}...'
                                        : userModel.name),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              if (userModel.isVerified) verifiedIcon()
                            ],
                          );
                  } else {
                    return const Text('');
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(double size) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.commentModel.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data();
          if (userData != null) {
            final userModel = UserModel.fromMap(userData);
            return Container(
              width: size * 0.9, // Slightly smaller than the progress indicator
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(userModel.photoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        }
        return SizedBox(width: size * 0.9, height: size * 0.9);
      },
    );
  }

  Widget _buildOverlayIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _isLiked
            ? whiteColor
            : widget.index == widget.engageCommentIndex
                ? const Color.fromARGB(255, 111, 160, 175)
                : widget.subscriberCommentIndex.contains(widget.index)
                    ? const Color(0xffa562cb)
                    : widget.closeFriendIndexs.contains(widget.index)
                        ? const Color(0xff50a87e)
                        : primaryColor,
        shape: BoxShape.circle,
      ),
      child: Consumer<FilterProvider>(builder: (context, filterPro, _) {
        return Icon(
          _isLiked
              ? Icons.favorite
              : (widget.isPlaying && widget.changeIndex == widget.index
                  ? Icons.pause
                  : Icons.play_arrow),
          color: _isLiked
              ? filterPro.selectedFilter.contains('Close Friends')
                  ? greenColor
                  : primaryColor
              : whiteColor,
          size: size * 0.6,
        );
      }),
    );
  }

  Color _getProgressColor() {
    // Implement your logic for progress color here
    return Colors.blue; // Default color
  }
}
