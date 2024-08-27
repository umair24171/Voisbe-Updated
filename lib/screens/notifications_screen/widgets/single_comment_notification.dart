import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';

class SingleCommentNotification extends StatefulWidget {
  const SingleCommentNotification(
      {super.key, required this.commentNotificationModel});
  final CommentNotoficationModel commentNotificationModel;

  @override
  State<SingleCommentNotification> createState() =>
      _SingleCommentNotificationState();
}

class _SingleCommentNotificationState extends State<SingleCommentNotification> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    SchedulerBinding.instance.scheduleFrameCallback((timer) {
      Provider.of<NotificationProvider>(context, listen: false)
          .readNotification(widget.commentNotificationModel.notificationId);
    });
    super.initState();
  }

  void _playAudio(
    String url,
  ) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();

    // if (_isPlaying) {
    //   await _audioPlayer.stop();
    // }

    if (_isPlaying) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
    } else {
      File cachedFile = await cacheManager.getSingleFile(url);
      if (cachedFile != null && await cachedFile.exists()) {
        await _audioPlayer.play(UrlSource(cachedFile.path));
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
      setState(() {
        _isPlaying = true;
      });
    }
    _audioPlayer.onPlayerComplete.listen((event) {
      // _updatePlayedComment(commentId, playedComment);
      setState(() {
        _isPlaying = false;
        // position = Duration.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.commentNotificationModel.currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserModel user = UserModel.fromMap(snapshot.data!.data()!);
                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OtherUserProfile(userId: user.uid),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                );
              } else {
                return const Text('');
              }
            }),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.commentNotificationModel.currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel user =
                                UserModel.fromMap(snapshot.data!.data()!);
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OtherUserProfile(userId: user.uid),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: khulaRegular),
                                  ),
                                  if (user.isVerified)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: verifiedIcon(),
                                    )
                                ],
                              ),
                            );
                          } else {
                            return const Text('');
                          }
                        }),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'replied',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomProgressPlayer(
                  lockPosts: [],
                  stopMainPlayer: () {},
                  isChatUserPlayer: true,
                  size: 10,
                  waveColor: whiteColor,
                  backgroundColor: primaryColor,
                  noteUrl: widget.commentNotificationModel.notification,
                  height: 25,
                  width: MediaQuery.of(context).size.width * 0.37,
                  mainWidth: MediaQuery.of(context).size.width * 0.65,
                  mainHeight: 42,
                ),
              ),
              // const Text(
              //   'i regullarly enjoyed to that.i would be great here about it',
              //   style: TextStyle(color: Colors.blueGrey),
              // )
            ],
          ),
        ),
        // const SizedBox(
        //   width: 20,
        // ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: widget.commentNotificationModel.postType
                        .contains('video') ||
                    widget.commentNotificationModel.postType.contains('photo')
                ? null
                : primaryColor,
            backgroundImage: widget.commentNotificationModel.postType
                        .contains('video') ||
                    widget.commentNotificationModel.postType.contains('photo')
                ? CachedNetworkImageProvider(
                    widget.commentNotificationModel.postType.contains('video')
                        ? widget.commentNotificationModel.postThumbnail
                        : widget.commentNotificationModel.postBackground)
                : null,
            child: IconButton(
                onPressed: () {
                  _playAudio(widget.commentNotificationModel.noteUrl);
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: whiteColor,
                  size: 25,
                )),
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(color: primaryColor),
        // ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
