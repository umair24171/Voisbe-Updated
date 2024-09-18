import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
// import 'dart:developer';

import 'package:audio_waveforms/audio_waveforms.dart' as audo;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/provider/comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:uuid/uuid.dart';

class CircleComments extends StatefulWidget {
  const CircleComments(
      {super.key,
      required this.mainAudioPlayer,
      required this.stopMainPlayer,
      required this.noteModel,
      required this.currentIndex,
      required this.pagController,
      required this.changeIndex});
  final NoteModel noteModel;

  final AudioPlayer mainAudioPlayer;
  final VoidCallback stopMainPlayer;
  final int currentIndex;
  final int changeIndex;
  final PageController pagController;

  //  getting the required data from the constructor

  @override
  State<CircleComments> createState() => _CircleCommentsState();
}

class _CircleCommentsState extends State<CircleComments> {
  //  controller for the wave generattion during recording

  late final audo.RecorderController recorderController;

  //  create the empty list of comments

  List<CommentModel> firstListViewComments = [];

//  instance of the audio player to play the reply

  AudioPlayer _audioPlayer = AudioPlayer();

  int _currentIndex = 0;
  late CommentManager commentManager;
  bool _isPlaying = false;
  Duration position = Duration.zero;
  int? indexNewComment;

  //  subsription to get the replies

  late StreamSubscription<QuerySnapshot> _subscription;

  // get the user data subscrition

  late StreamSubscription<DocumentSnapshot> _userSubscription;

  //  creating the empty lists to manage the colors based on the certain logics

  // List<int> subscriberCommentsIndexes = [];

  // List<int> closeFriendIndexes = [];
  // List<int> remainingCommentsIndex = [];
  // List<CommentModel> commentsList = [];
  // int engageCommentIndex = 0;
  String? path;
  late Directory directory;
  // int indexOfNewComent = -1;

  stopPlayingOnScrolling() {
    widget.pagController.addListener(_checkIndex);
  }

  _checkIndex() {
    if (widget.changeIndex != widget.currentIndex) {
      _audioPlayer.stop();
      setState(() {
        _currentIndex = -1;
        _isPlaying = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    commentManager = CommentManager(setState);
    //  initializing the player
    _audioPlayer = AudioPlayer();

    // getting 7 replies

    getStreamComments();

    //  initilizing wave generate controller

    _initialiseController();
    stopPlayingOnScrolling();
  }

  void _initialiseController() {
    recorderController = audo.RecorderController()
      ..androidEncoder = audo.AndroidEncoder.aac
      ..androidOutputFormat = audo.AndroidOutputFormat.mpeg4
      ..iosEncoder = audo.IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }

  bool isLoading = true;
  Future<void> getStreamComments() async {
    UserModel? currentNoteUser;
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;

    _userSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.noteModel.userUid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          currentNoteUser = UserModel.fromMap(snapshot.data() ?? {});
        });
      }
    });

    commentManager = CommentManager(setState);
    commentManager.initComments(
        widget.noteModel.noteId, currentUser!, widget.noteModel.userUid, false
        // currentNoteUser,
        );
    setState(() {
      isLoading = false;
    });

    // _subscription = FirebaseFirestore.instance
    //     .collection('notes')
    //     .doc(widget.noteModel.noteId)
    //     .collection('comments')
    //     .orderBy('time', descending: true)
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (mounted) {
    //     if (snapshot.docs.isNotEmpty) {
    //       // List<CommentModel> list =
    //       //     snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();

    //       // List<CommentModel> itemsToRemove = [];
    //       // List<String>? commentIDs =
    //       //     preferences.getStringList(currentUser!.uid);
    //       // if (commentIDs != null) {
    //       //   for (var item in list) {
    //       //     if (commentIDs.contains(item.commentid)) {
    //       //       itemsToRemove.add(item);
    //       //     }
    //       //   }
    //       // }

    //       // list.removeWhere((item) => itemsToRemove.contains(item));

    //       // List<int> newCloseFriendIndexes = [];
    //       // List<int> newSubscriberCommentsIndexes = [];
    //       // List<int> newRemainingCommentsIndex = [];

    //       // for (var index = 0; index < list.length; index++) {
    //       //   var comment = list[index];
    //       //   if (currentNoteUser?.closeFriends.contains(comment.userId) ??
    //       //       false) {
    //       //     newCloseFriendIndexes.add(index);
    //       //   } else if (currentNoteUser?.subscribedUsers
    //       //           .contains(comment.userId) ??
    //       //       false) {
    //       //     newSubscriberCommentsIndexes.add(index);
    //       //   } else {
    //       //     newRemainingCommentsIndex.add(index);
    //       //   }
    //       // }

    //       // List<CommentModel> engageComments = List.from(list);
    //       // engageComments
    //       //     .sort((a, b) => b.playedComment.compareTo(a.playedComment));
    //       // CommentModel mostEngageComment = engageComments[0];
    //       // int indexOfEngageComment = list.indexWhere(
    //       //     (element) => element.commentid == mostEngageComment.commentid);

    //       // setState(() {
    //       //   commentsList = list;
    //       //   closeFriendIndexes = newCloseFriendIndexes;
    //       //   subscriberCommentsIndexes = newSubscriberCommentsIndexes;
    //       //   remainingCommentsIndex = newRemainingCommentsIndex;
    //       //   engageCommentIndex = indexOfEngageComment;
    //       // });
    //     }
    //   }
    // });
  }

  // Future<void> getStreamComments() async {
  //   UserModel? currentNoteUser;
  //   var currentUser = Provider.of<UserProvider>(context, listen: false).user;

  //   _userSubscription = FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(widget.noteModel.userUid)
  //       .snapshots()
  //       .listen((snapshot) {
  //     if (mounted) {
  //       setState(() {
  //         currentNoteUser = UserModel.fromMap(snapshot.data() ?? {});
  //       });
  //     }
  //   });

  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .doc(widget.noteModel.noteId)
  //       .collection('comments')
  //       .orderBy('time', descending: true)
  //       .snapshots()
  //       .listen((snapshot) {
  //     if (mounted) {
  //       if (snapshot.docs.isNotEmpty) {
  //         List<CommentModel> list =
  //             snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();

  //         List<CommentModel> itemsToRemove = [];
  //         List<String>? commentIDs =
  //             preferences.getStringList(currentUser!.uid);
  //         if (commentIDs != null) {
  //           for (var item in list) {
  //             if (commentIDs.contains(item.commentid)) {
  //               itemsToRemove.add(item);
  //             }
  //           }
  //         }

  //         list.removeWhere((item) => itemsToRemove.contains(item));

  //         List<int> newCloseFriendIndexes = [];
  //         List<int> newSubscriberCommentsIndexes = [];
  //         List<int> newRemainingCommentsIndex = [];

  //         for (var index = 0; index < list.length; index++) {
  //           var comment = list[index];
  //           if (currentNoteUser?.closeFriends.contains(comment.userId) ??
  //               false) {
  //             newCloseFriendIndexes.add(index);
  //           } else if (currentNoteUser?.subscribedUsers
  //                   .contains(comment.userId) ??
  //               false) {
  //             newSubscriberCommentsIndexes.add(index);
  //           } else {
  //             newRemainingCommentsIndex.add(index);
  //           }
  //         }

  //         List<CommentModel> engageComments = List.from(list);
  // engageComments
  //     .sort((a, b) => b.playedComment.compareTo(a.playedComment));
  //         CommentModel mostEngageComment = engageComments[0];
  //         int indexOfEngageComment = list.indexWhere(
  //             (element) => element.commentid == mostEngageComment.commentid);

  //         setState(() {
  //           commentsList = list;
  //           closeFriendIndexes = newCloseFriendIndexes;
  //           subscriberCommentsIndexes = newSubscriberCommentsIndexes;
  //           remainingCommentsIndex = newRemainingCommentsIndex;
  //           engageCommentIndex = indexOfEngageComment;
  //         });
  //       }
  //     }
  //   });
  // }

  //  updating the value of the comment in the for most played

  void _updatePlayedComment(String commentId, int playedComment) async {
    int updateCommentCounter = playedComment + 1;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteModel.noteId)
        .collection('comments')
        .doc(commentId)
        .update({'playedComment': updateCommentCounter});
  }

  //  function to play one audio at a time

  void _playAudio(
    String url,
    int index,
    String commentId,
    int playedComment,
  ) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    var pro = Provider.of<DisplayNotesProvider>(context, listen: false);
    pro.pausePlayer();
    pro.setIsPlaying(false);
    pro.setChangeIndex(-1);

    if (_isPlaying && _currentIndex != index) {
      await _audioPlayer.stop();
    }

    if (_currentIndex == index && _isPlaying) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
        setState(() {
          _currentIndex = -1;
          _isPlaying = false;
        });
      } else {
        _audioPlayer.resume();
        setState(() {
          _currentIndex = index;
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
        _currentIndex = index;
        _isPlaying = true;
      });
    }

    _audioPlayer.onPositionChanged.listen((event) {
      if (_currentIndex == index) {
        setState(() {
          position = event;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      // _updatePlayedComment(commentId, playedComment);
      setState(() {
        _isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  //  disposing all the players when no longer needs

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _audioPlayer.dispose();
    // _subscription.cancel();
    commentManager.dispose();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  getting the provider

    var displayPro = Provider.of<DisplayNotesProvider>(context, listen: false);

    //  getting the current user data

    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var size = MediaQuery.of(context).size;

    // log('new comment index: $indexOfNewComent ');
    if (isLoading) {
      return Text("");
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            children: [
              Expanded(
                //   wrap to manage the 7 replies and recording widget

                child: Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 7,
                    children: [
                      //  recording widget
                      //  recording based on certain conditions
                      //  cancel reply
                      //  send reply
                      // show loading
                      //  show waves

                      Consumer<NoteProvider>(
                        builder: (context, noteProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: GestureDetector(
                              onLongPress: () {
                                // Timer(const Duration(seconds: 2), () {
                                // _audioPlayer.stop();
                                if (noteProvider.isCancellingReply) {
                                  noteProvider.setCancellingReply(false);
                                } else {
                                  noteProvider.setCancellingReply(true);
                                }
                                // });
                              },
                              onTap: () async {
                                widget.stopMainPlayer();
                                _audioPlayer.stop();
                                setState(() {
                                  _currentIndex = -1;
                                });
                                if (noteProvider.isCancellingReply) {
                                  noteProvider.cancelReply();
                                  noteProvider.setIsSending(false);

                                  noteProvider.setRecording(false);
                                } else if (await noteProvider.recorder
                                    .isRecording()) {
                                  noteProvider.setIsSending(true);
                                  noteProvider.stop(context);
                                  recorderController.stop();
                                } else if (noteProvider.isSending) {
                                  Provider.of<NoteProvider>(context,
                                          listen: false)
                                      .setIsLoading(true);
                                  String commentId = const Uuid().v4();

                                  //  uploading the recorded comment to storage

                                  String comment = await AddNoteController()
                                      .uploadFile('comments',
                                          noteProvider.voiceNote!, context);
                                  CommentModel commentModel = CommentModel(
                                    commentid: commentId,
                                    comment: comment,
                                    username: userProvider!.name,
                                    time: DateTime.now(),
                                    userId: userProvider.uid,
                                    postId: widget.noteModel.noteId,
                                    likes: [],
                                    playedComment: 0,
                                    userImage: userProvider.photoUrl,
                                  );

                                  //  adding comment to firestore

                                  displayPro
                                      .addComment(widget.noteModel.noteId,
                                          commentId, commentModel, context)
                                      .then((value) async {
                                    String notificationId = const Uuid().v4();

                                    //  removing everything setting false the values

                                    noteProvider.removeVoiceNote();
                                    noteProvider.setIsSending(false);
                                    Provider.of<NoteProvider>(context,
                                            listen: false)
                                        .setIsLoading(false);
                                    DocumentSnapshot<Map<String, dynamic>>
                                        userModel = await FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(widget.noteModel.userUid)
                                            .get();

                                    UserModel toNotiUser =
                                        UserModel.fromMap(userModel.data()!);

                                    //  sending notification to the post owner

                                    if (toNotiUser.isReply &&
                                        userProvider.uid !=
                                            widget.noteModel.userUid) {
                                      NotificationMethods.sendPushNotification(
                                          widget.noteModel.userUid,
                                          widget.noteModel.userToken,
                                          'replied',
                                          userProvider.name,
                                          'notification',
                                          '');

                                      CommentNotoficationModel noti =
                                          CommentNotoficationModel(
                                              time: DateTime.now(),
                                              postBackground: widget
                                                  .noteModel.backgroundImage,
                                              postThumbnail: widget
                                                  .noteModel.videoThumbnail,
                                              postType: widget
                                                  .noteModel.backgroundType,
                                              noteUrl: widget.noteModel.noteUrl,
                                              isRead: '',
                                              notificationId: notificationId,
                                              notification: comment,
                                              currentUserId: userProvider.uid,
                                              notificationType: 'comment',
                                              toId: widget.noteModel.userUid);
                                      Provider.of<NotificationProvider>(context,
                                              listen: false)
                                          .addCommentNotification(noti);
                                    }
                                  });
                                } else {
                                  directory =
                                      await getApplicationDocumentsDirectory();
                                  path = "${directory.path}/test_audio.aac";
                                  await recorderController.record(path: path);
                                  // update state here to, for eample, change the button's state

                                  noteProvider.record(context);
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //  showing icons based on the certain conditions

                                  Consumer<FilterProvider>(
                                      builder: (context, filterPro, _) {
                                    return Container(
                                      height: size.width * 0.23,
                                      width: size.width * 0.23,
                                      padding: EdgeInsets.all(
                                          noteProvider.isLoading ? 4 : 0),
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: noteProvider.isLoading
                                          ? SizedBox(
                                              height: 35,
                                              width: 35,
                                              child: CircularProgressIndicator(
                                                color: primaryColor,
                                              ),
                                            )
                                          : noteProvider.isCancellingReply
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/icons/Refresh.svg',
                                                      height: 40,
                                                      width: 40,
                                                      color: filterPro
                                                              .selectedFilter
                                                              .contains(
                                                                  'Close Friends')
                                                          ? greenColor
                                                          : null,
                                                    ),
                                                  ],
                                                )
                                              : noteProvider.isSending
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/icons/Send comment.svg',
                                                          height: 40,
                                                          width: 40,
                                                          color: filterPro
                                                                  .selectedFilter
                                                                  .contains(
                                                                      'Close Friends')
                                                              ? greenColor
                                                              : null,
                                                        ),
                                                      ],
                                                    )
                                                  : noteProvider.isRecording
                                                      ? audo.AudioWaveforms(
                                                          size: const Size(
                                                              85, 85),
                                                          recorderController:
                                                              recorderController,
                                                          // density: 1.5,
                                                          waveStyle:
                                                              audo.WaveStyle(
                                                            showMiddleLine:
                                                                false,
                                                            extendWaveform:
                                                                true,
                                                            waveColor:
                                                                primaryColor,
                                                            // scaleFactor: 0.8,
                                                            waveCap:
                                                                StrokeCap.butt,
                                                          ),
                                                        )
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/microphone_recordbutton.png',
                                                              height: 40,
                                                              width: 40,
                                                              color: filterPro
                                                                      .selectedFilter
                                                                      .contains(
                                                                          'Close Friends')
                                                                  ? greenColor
                                                                  : null,
                                                            ),
                                                          ],
                                                        ),
                                    );
                                  }),
                                  Text(
                                    noteProvider.isCancellingReply
                                        ? 'Cancel'
                                        : noteProvider.isRecording
                                            ? 'Stop'
                                            : noteProvider.isSending
                                                ? 'Send'
                                                : 'Reply',
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: 13,
                                      color: whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      //  filterd list to display 3 replies in first row

                      ...commentManager.commentsList.take(3).map((comment) {
                        final key =
                            ValueKey<String>('comment_${comment.commentid}');
                        return KeyedSubtree(
                          key: key,
                          child: CircleVoiceNotes(
                            // backGround: widget.,
                            audioPlayer: _audioPlayer,
                            engageCommentIndex:
                                commentManager.engageCommentIndex,
                            changeIndex: _currentIndex,
                            onPlayPause: () {
                              _playAudio(
                                  comment.comment,
                                  commentManager.commentsList.indexOf(comment),
                                  comment.commentid,
                                  comment.playedComment);
                            },
                            isPlaying: _isPlaying,
                            position: position,
                            index: commentManager.commentsList.indexOf(comment),
                            commentModel: comment,
                            subscriberCommentIndex:
                                commentManager.subscriberCommentsIndexes,
                            closeFriendIndexs:
                                commentManager.closeFriendIndexes,
                            onPlayStateChanged: (isPlaying) {},
                          ),
                        );
                      }),
                      const SizedBox(width: 0),

                      //  filterd list to display next 4 replies in second row with the colors

                      ...commentManager.commentsList
                          .skip(3)
                          .take(4)
                          .map((comment) {
                        final key =
                            ValueKey<String>('comment_${comment.commentid}');
                        return KeyedSubtree(
                          key: key,
                          child: CircleVoiceNotes(
                            engageCommentIndex:
                                commentManager.engageCommentIndex,
                            audioPlayer: _audioPlayer,
                            changeIndex: _currentIndex,
                            onPlayPause: () {
                              _playAudio(
                                  comment.comment,
                                  commentManager.commentsList.indexOf(comment),
                                  comment.commentid,
                                  comment.playedComment);
                            },
                            isPlaying: _isPlaying,
                            position: position,
                            index: commentManager.commentsList.indexOf(comment),
                            commentModel: comment,
                            subscriberCommentIndex:
                                commentManager.subscriberCommentsIndexes,
                            closeFriendIndexs:
                                commentManager.closeFriendIndexes,
                            onPlayStateChanged: (isPlaying) {},
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//  painter to show waves

class WavePainter extends CustomPainter {
  final List<double> amplitudes;
  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;

  WavePainter({
    required this.amplitudes,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = inactiveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double midY = size.height / 2;
    double maxAmp =
        size.height / 2; // Maximum amplitude to scale within the container

    for (int i = 0; i < amplitudes.length; i++) {
      var amp = amplitudes[i]; // Amplitude value for this wave
      double scaledAmp =
          (amp / 10) * maxAmp; // Scale it to the height of the container
      paint.color = i < amplitudes.length / 2
          ? activeColor
          : inactiveColor; // Change color if part of the wave is 'active'
      canvas.drawLine(
        Offset(i * strokeWidth * 2, midY - scaledAmp),
        Offset(i * strokeWidth * 2, midY + scaledAmp),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class WavePainter extends CustomPainter {
//   final double animationValue;

//   WavePainter(this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blueAccent
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     for (double i = 0; i <= size.width; i++) {
//       path.lineTo(
//         i,
//         sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 10 +
//             size.height / 2,
//       );
//     }
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
