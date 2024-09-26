import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class SingleLikeNoti extends StatefulWidget {
  const SingleLikeNoti({
    super.key,
    required this.likeNotofication,
  });

  final CommentNotoficationModel likeNotofication;

  @override
  State<SingleLikeNoti> createState() => _SingleLikeNotiState();
}

class _SingleLikeNotiState extends State<SingleLikeNoti> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    SchedulerBinding.instance.scheduleFrameCallback((timer) {
      Provider.of<NotificationProvider>(context, listen: false)
          .readNotification(widget.likeNotofication.notificationId);
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
      if (cachedFile != null && await cachedFile.exists() && Platform.isAndroid) {
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
    // Provider.of<NotificationProvider>(context, listen: false)
    //     .readNotification(widget.likeNotofication.notificationId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(
          //   width: 15,
          // ),
          Row(
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.likeNotofication.currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel userModel =
                          UserModel.fromMap(snapshot.data!.data()!);
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtherUserProfile(userId: userModel.uid),
                              ));
                        },
                        child: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(userModel.photoUrl),
                        ),
                      );
                    } else {
                      return const Text('');
                    }
                  }),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.likeNotofication.currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel userModel =
                                UserModel.fromMap(snapshot.data!.data()!);
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtherUserProfile(
                                          userId: userModel.uid),
                                    ));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userModel.name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: khulaRegular),
                                  ),
                                  if (userModel.isVerified)
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
                  // const SizedBox(
                  //   width: 5,
                  // ),
                  Row(
                    children: [
                      const Text(
                        ' liked your ',
                        // overflow: t,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                      InkWell(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('notes')
                              .where('noteUrl',
                                  isEqualTo: widget.likeNotofication.noteUrl)
                              .get()
                              .then(
                            (value) {
                              NoteModel note =
                                  NoteModel.fromMap(value.docs.first.data());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      note: note,
                                    ),
                                  ));
                            },
                          );
                        },
                        child: const Text(
                          'post',
                          style: TextStyle(
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // const SizedBox(
          //   width: 65,
          // ),
          CircleAvatar(
            radius: 28,
            backgroundColor:
                widget.likeNotofication.postType.contains('video') ||
                        widget.likeNotofication.postType.contains('photo')
                    ? null
                    : primaryColor,
            backgroundImage:
                widget.likeNotofication.postType.contains('video') ||
                        widget.likeNotofication.postType.contains('photo')
                    ? CachedNetworkImageProvider(
                        widget.likeNotofication.postType.contains('video')
                            ? widget.likeNotofication.postThumbnail
                            : widget.likeNotofication.postBackground)
                    : null,
            child: IconButton(
                onPressed: () {
                  _playAudio(widget.likeNotofication.noteUrl);
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: whiteColor,
                  size: 25,
                )),
          ),
        ],
      ),
    );
  }
}
