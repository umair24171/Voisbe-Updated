import 'dart:async';
import 'dart:developer';
import 'dart:io';
// import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:uuid/uuid.dart';

class CircleComments extends StatefulWidget {
  const CircleComments(
      {super.key,
      required this.postId,
      required this.userId,
      required this.mainAudioPlayer,
      required this.stopMainPlayer,
      required this.userToken,
      required this.userName});
  final String postId;
  final String userId;
  final String userToken;
  final String userName;

  final AudioPlayer mainAudioPlayer;
  final VoidCallback stopMainPlayer;
  @override
  State<CircleComments> createState() => _CircleCommentsState();
}

class _CircleCommentsState extends State<CircleComments> {
  List<CommentModel> firstListViewComments = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration position = Duration.zero;
  int? indexNewComment;
  late StreamSubscription<QuerySnapshot> _subscription;
  late StreamSubscription<DocumentSnapshot> _userSubscription;
  List<int> subscriberCommentsIndexes = [];

  List<int> closeFriendIndexes = [];
  List<int> remainingCommentsIndex = [];
  List<CommentModel> commentsList = [];
  int engageCommentIndex = 0;
  // int indexOfNewComent = -1;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    getStreamComments();
  }

  getStreamComments() async {
    UserModel? currentNoteUser;
    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(widget.userId)
    //     .get()
    //     .then((value) {
    //   currentNoteUser = UserModel.fromMap(value.data() ?? {});
    // });
    _userSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .snapshots()
        .listen((snapshot) {
      currentNoteUser = UserModel.fromMap(snapshot.data() ?? {});
    });

    _subscription = FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<CommentModel> list =
            snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();
        // list.sort((a, b) => b.playedComment.compareTo(a.playedComment));

        List<int> subcomments = [];
        List<int> closeComm = [];
        List<int> remainCom = [];
        closeFriendIndexes.clear();
        subscriberCommentsIndexes.clear();
        remainingCommentsIndex.clear();

        for (var index = 0; index < list.length; index++) {
          var comment = list[index];
          if (currentNoteUser!.closeFriends.contains(comment.userId)) {
            closeFriendIndexes.add(index);
            log('Close Friends Comments: $closeFriendIndexes');
          } else if (currentNoteUser!.subscribedUsers
              .contains(comment.userId)) {
            subscriberCommentsIndexes.add(index);
            log('Subscriber Comments: $subscriberCommentsIndexes');
          } else {
            remainingCommentsIndex.add(index);
            log('Remaining Comments: $remainingCommentsIndex');
          }
        }
        List<CommentModel> engageComments = List.from(list);
        // engageComments.addAll(list);

        engageComments
            .sort((a, b) => b.playedComment.compareTo(a.playedComment));
        CommentModel mostEngageComment = engageComments[0];
        int indexOfEngageComment = list.indexWhere(
            (element) => element.commentid == mostEngageComment.commentid);
        // if (list.isNotEmpty) {
        //   setState(() {
        //     indexOfNewComent = list.indexWhere((element) =>
        //         element.commentid == widget.newlyComment!.commentid);
        //   });
        //   list.removeWhere(
        //       (element) => element.commentid == widget.newlyComment!.commentid);
        //   log('New Index Comment $indexOfNewComent');
        // }

        // log('index of subscriber comments: $subscriberCommentsIndexes');
        // // log('MostLikedComment: $mostEngagedComment');
        // // log('CommentContainsSubscriber: $commentContainsSubscriber');
        // log('RemainingComments: $remainCom');
        // // log('CloseFriendsComments: $closeFriendsComments');
        // log('CloseFriednIndexes: $closeFriendIndexes');
        setState(() {
          // Update the local list with the sorted list

          commentsList = list;
          subcomments = subscriberCommentsIndexes;
          closeComm = closeFriendIndexes;
          remainCom = remainingCommentsIndex;
          engageCommentIndex = indexOfEngageComment;
          // indexNewComment = indexOfNewComent;
        });
      }
    });
  }

  void _updatePlayedComment(String commentId, int playedComment) async {
    int updateCommentCounter = playedComment + 1;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .update({'playedComment': updateCommentCounter});
  }

  void _playAudio(
    String url,
    int index,
    String commentId,
    int playedComment,
  ) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();

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

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _audioPlayer.dispose();
    _subscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant CircleComments oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // Update commentsList when the widget is updated
  //   updateCommentsList();
  // }

  // void updateCommentsList() {
  //   // Reset commentsList
  //   commentsList = [];

  //   // Fetch comments from Firestore
  //   FirebaseFirestore.instance
  //       .collection('notes')
  //       .doc(widget.postId)
  //       .collection('comments')
  //       .snapshots()
  //       .listen((snapshot) {
  //     setState(() {
  //       commentsList = snapshot.docs
  //           .map((doc) => CommentModel.fromMap(doc.data()))
  //           .toList();

  //       // Remove newlyComment if it exists
  //       commentsList.removeWhere(
  //           (comment) => comment.commentid == widget.newlyComment?.commentid);
  //     });
  //   });
  // }

  // @override
  // void didUpdateWidget(covariant CircleComments oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // Update commentsList when the widget is updated
  //   updateCommentsList();
  // }

  // void updateCommentsList() {
  //   List<CommentModel> updatedList = List.from(commentsList);

  //   // Remove the newly added comment from the list
  //   updatedList.removeWhere(
  //     (element) => element.commentid == widget.newlyComment?.commentid,
  //   );

  //   // Limit the number of items to show to 3 after removing the new comment
  //   firstListViewComments = updatedList.length > 3
  //       ? updatedList.sublist(0, 3)
  //       : List.from(updatedList);

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    var commentProvider =
        Provider.of<DisplayNotesProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var size = MediaQuery.of(context).size;

    // log('new comment index: $indexOfNewComent ');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            children: [
              Expanded(
                // height: size.height * 0.15,
                child: Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 7,

                    // spacing: 4,

                    // spacing: 2,
                    // runSpacing: 12,

                    children: [
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
                                  noteProvider.stop();
                                } else if (noteProvider.isSending) {
                                  Provider.of<NoteProvider>(context,
                                          listen: false)
                                      .setIsLoading(true);
                                  String commentId = const Uuid().v4();
                                  String comment = await AddNoteController()
                                      .uploadFile('comments',
                                          noteProvider.voiceNote!, context);
                                  CommentModel commentModel = CommentModel(
                                    commentid: commentId,
                                    comment: comment,
                                    username: userProvider!.name,
                                    time: DateTime.now(),
                                    userId: userProvider.uid,
                                    postId: widget.postId,
                                    likes: [],
                                    playedComment: 0,
                                    userImage: userProvider.photoUrl,
                                  );

                                  commentProvider
                                      .addComment(widget.postId, commentId,
                                          commentModel, context)
                                      .then((value) {
                                    String notificationId = const Uuid().v4();
                                    NotificationMethods.sendPushNotification(
                                        widget.userToken,
                                        'replied',
                                        userProvider.username);
                                    CommentNotoficationModel noti =
                                        CommentNotoficationModel(
                                            isRead: '',
                                            notificationId: notificationId,
                                            notification: comment,
                                            currentUserId: userProvider.uid,
                                            notificationType: 'comment',
                                            toId: widget.userId);
                                    Provider.of<NotificationProvider>(context,
                                            listen: false)
                                        .addCommentNotification(noti);

                                    noteProvider.removeVoiceNote();
                                    noteProvider.setIsSending(false);
                                    Provider.of<NoteProvider>(context,
                                            listen: false)
                                        .setIsLoading(false);
                                  });
                                } else {
                                  noteProvider.record();
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: size.width > 400
                                        ? 98
                                        : size.height * 0.107,
                                    width: size.height * 0.106,
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
                                                      ),
                                                    ],
                                                  )
                                                : noteProvider.isRecording
                                                    ? Icon(
                                                        Icons.stop,
                                                        color: primaryColor,
                                                        size: 40,
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
                                                          ),
                                                        ],
                                                      ),
                                  ),
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

                      // if (widget.commentsLength >= 1)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 10, left: 0),
                      //     child: CircleVoiceNotes(
                      //       audioPlayer: _audioPlayer,
                      //       changeIndex: _currentIndex,
                      //       onPlayPause: () {
                      //         _playAudio(
                      //             widget.newlyComment!.comment,
                      //             indexOfNewComent,
                      //             widget.newlyComment!.commentid,
                      //             widget.newlyComment!.playedComment);
                      //       },
                      //       isPlaying: _isPlaying,
                      //       position: position,
                      //       index: indexOfNewComent,
                      //       commentModel: widget.newlyComment!,
                      //       subscriberCommentIndex: subscriberCommentsIndexes,
                      //       closeFriendIndexs: closeFriendIndexes,
                      //       onPlayStateChanged: (isPlaying) {},
                      //     ),
                      //   ),
                      ...commentsList.take(3).map((comment) {
                        final key =
                            ValueKey<String>('comment_${comment.commentid}');
                        return KeyedSubtree(
                          key: key,
                          child: CircleVoiceNotes(
                            audioPlayer: _audioPlayer,
                            engageCommentIndex: engageCommentIndex,
                            changeIndex: _currentIndex,
                            onPlayPause: () {
                              _playAudio(
                                  comment.comment,
                                  commentsList.indexOf(comment),
                                  comment.commentid,
                                  comment.playedComment);
                            },
                            isPlaying: _isPlaying,
                            position: position,
                            index: commentsList.indexOf(comment),
                            commentModel: comment,
                            subscriberCommentIndex: subscriberCommentsIndexes,
                            closeFriendIndexs: closeFriendIndexes,
                            onPlayStateChanged: (isPlaying) {},
                          ),
                        );
                      }),
                      const SizedBox(width: 10),
                      ...commentsList.skip(3).take(4).map((comment) {
                        final key =
                            ValueKey<String>('comment_${comment.commentid}');
                        return KeyedSubtree(
                          key: key,
                          child: CircleVoiceNotes(
                            engageCommentIndex: engageCommentIndex,
                            audioPlayer: _audioPlayer,
                            changeIndex: _currentIndex,
                            onPlayPause: () {
                              _playAudio(
                                  comment.comment,
                                  commentsList.indexOf(comment),
                                  comment.commentid,
                                  comment.playedComment);
                            },
                            isPlaying: _isPlaying,
                            position: position,
                            index: commentsList.indexOf(comment),
                            commentModel: comment,
                            subscriberCommentIndex: subscriberCommentsIndexes,
                            closeFriendIndexs: closeFriendIndexes,
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
