import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart' as audi;

// import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
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
import 'package:social_notes/screens/home_screen/model/sub_comment_model.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/single_comment_note.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_message_package/voice_message_package.dart';

class CommentModalSheet extends StatefulWidget {
  // final List<String> comments;

  const CommentModalSheet(
      {super.key,
      required this.postId,
      required this.userId,
      required this.noteData});
  final String postId;
  final String userId;
  final NoteModel noteData;

  @override
  State<CommentModalSheet> createState() => _CommentModalSheetState();
}

class _CommentModalSheetState extends State<CommentModalSheet> {
  AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  late StreamSubscription<QuerySnapshot> _subscription;
  List<CommentModel> commentsList = [];
  // List<int> subscriberComments = [];
  // List<int> remainingComments = [];
  // List<int> closeCOmments = [];

  final _player = AudioPlayer();
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    // _initialiseControllers();
    commentManager = CommentManager(setState);
    _audioPlayer = AudioPlayer();
    _player.onPlayerComplete.listen((state) {
      setState(() {
        _isPlaying = false;
      });
    });
    _player.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
    getStreamComments();
  }

  late CommentManager commentManager;
  UserModel? currentNoteUser;

  getStreamComments() async {
    // Subscribe to the Firestore collection
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.noteData.userUid)
        .get()
        .then((value) {
      currentNoteUser = UserModel.fromMap(value.data() ?? {});
      setState(() {});
    });
    commentManager = CommentManager(setState);
    commentManager.initComments(
        widget.postId, currentUser!, currentNoteUser!.uid, true);

    // _subscription = FirebaseFirestore.instance
    //     .collection('notes')
    //     .doc(widget.postId)
    //     .collection('comments')
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (snapshot.docs.isNotEmpty) {
    //     List<CommentModel> list =
    //         snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();
    //     list.sort((a, b) => b.playedComment.compareTo(a.playedComment));

    //     List<int> subscriberCommentsIndexes = [];
    //     List<int> closeFriendIndexes = [];
    //     List<int> remainingCommentsIndex = [];

    //     // Collect the items to be removed in a separate list
    //     List<CommentModel> itemsToRemove = [];
    //     List<String>? commentIDs = preferences.getStringList(currentUser!.uid);
    //     if (commentIDs != null) {
    //       for (var item in list) {
    //         for (var id in commentIDs) {
    //           if (item.commentid.contains(id)) {
    //             itemsToRemove.add(item);
    //             break; // Break inner loop if match is found
    //           }
    //         }
    //       }
    //     }

    //     // Remove the collected items from the list
    //     list.removeWhere((item) => itemsToRemove.contains(item));

    //     for (var index = 0; index < list.length; index++) {
    //       var comment = list[index];
    //       if (currentNoteUser!.closeFriends.contains(comment.userId)) {
    //         closeFriendIndexes.add(index);
    //         log('Close Friends Comments: $closeFriendIndexes');
    //       } else if (currentNoteUser!.subscribedUsers
    //           .contains(comment.userId)) {
    //         subscriberCommentsIndexes.add(index);
    //         log('Subscriber Comments: $subscriberCommentsIndexes');
    //       } else {
    //         remainingCommentsIndex.add(index);
    //         log('Remaining Comments: $remainingCommentsIndex');
    //       }
    //     }

    //     log('index of subscriber comments: $subscriberCommentsIndexes');
    //     log('RemainingComments: $remainingComments');
    //     log('CloseFriednIndexes: $closeFriendIndexes');
    //     setState(() {
    //       // Update the local list with the sorted list
    //       commentsList = list;
    //       subscriberComments = subscriberCommentsIndexes;
    //       closeCOmments = closeFriendIndexes;
    //       remainingComments = remainingComments;
    //     });
    // }
    // });
  }

  // getStreamComments() async {
  //   // Subscribe to the Firestore collection
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   List<String>? commentIDs = preferences.getStringList('currentUser');
  //   UserModel? currentNoteUser;
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(widget.noteData.userUid)
  //       .get()
  //       .then((value) {
  //     currentNoteUser = UserModel.fromMap(value.data() ?? {});
  //   });

  //   _subscription = FirebaseFirestore.instance
  //       .collection('notes')
  //       .doc(widget.postId)
  //       .collection('comments')
  //       .snapshots()
  //       .listen((snapshot) {
  //     if (snapshot.docs.isNotEmpty) {
  //       List<CommentModel> list =
  //           snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();
  //       list.sort((a, b) => b.playedComment.compareTo(a.playedComment));

  //       List<int> subscriberCommentsIndexes = [];
  //       List<int> closeFriendIndexes = [];
  //       List<int> remainingCommentsIndex = [];
  //       if (commentIDs != null) {
  //         for (var item in list) {
  //           for (var id in commentIDs) {
  //             if (item.commentid.contains(id)) {
  //               list.remove(item);
  //             }
  //           }
  //         }
  //       }

  //       for (var index = 0; index < list.length; index++) {
  //         var comment = list[index];
  //         if (currentNoteUser!.closeFriends.contains(comment.userId)) {
  //           closeFriendIndexes.add(index);
  //           log('Close Friends Comments: $closeFriendIndexes');
  //         } else if (currentNoteUser!.subscribedUsers
  //             .contains(comment.userId)) {
  //           subscriberCommentsIndexes.add(index);
  //           log('Subscriber Comments: $subscriberCommentsIndexes');
  //         } else {
  //           remainingCommentsIndex.add(index);
  //           log('Remaining Comments: $remainingCommentsIndex');
  //         }
  //       }

  //       log('index of subscriber comments: $subscriberCommentsIndexes');
  //       // log('MostLikedComment: $mostEngagedComment');
  //       // log('CommentContainsSubscriber: $commentContainsSubscriber');
  //       log('RemainingComments: $remainingComments');
  //       // log('CloseFriendsComments: $closeFriendsComments');
  //       log('CloseFriednIndexes: $closeFriendIndexes');
  //       setState(() {
  //         // Update the local list with the sorted list
  //         commentsList = list;
  //         subscriberComments = subscriberCommentsIndexes;
  //         closeCOmments = closeFriendIndexes;
  //         remainingComments = remainingComments;
  //       });
  //     }
  //   });
  // }

  void _updatePlayedComment(String commentId, int playedComment) {
    int updateCommentCounter = playedComment + 1;
    FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .update({'playedComment': updateCommentCounter});
  }

  // playing the audio function

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

  void _playAudio(
    String url,
    int index,
    String commentId,
    int playedComment,
  ) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    stopMainPlayer();
    Provider.of<CircleCommentsProvider>(context, listen: false).pausePlayer();
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
      if (cachedFile != null &&
          await cachedFile.exists() &&
          Platform.isAndroid) {
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
      _updatePlayedComment(commentId, playedComment);
      setState(() {
        _isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  // stopping the audio

  stopAudio() {
    _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  audi.PlayerController controller = audi.PlayerController();

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _audioPlayer.dispose();
    commentManager.dispose();
    controller.dispose();
    // recorderController.dispose();
    super.dispose();
  }

  final Map<String, double> _cachedHeights = {};

  @override
  Widget build(BuildContext context) {
    // var noteProvider = Provider.of<NoteProvider>(context);
    commentsList = commentManager.commentsList;

    var commentProvider =
        Provider.of<DisplayNotesProvider>(context, listen: false);
    // commentProvider.displayAllComments(widget.postId);
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    // log('All Users: ${commentProvider.allUsers}');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 6,
            width: 55,
            decoration: BoxDecoration(
                color: const Color(0xffdcdcdc),
                borderRadius: BorderRadius.circular(30)),
          ),
          Container(
            margin:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Text(
              'Replies',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily),
            ),
          ),
          Divider(
            color: Colors.grey[300],
          ),
          Expanded(
              child: commentManager.commentsList.isNotEmpty
                  ? SingleChildScrollView(
                      //  building all the commentsList

                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentsList.length,
                        itemBuilder: (context, index) {
                          final key = ValueKey<String>(
                              'comment_${commentsList[index].commentid}');

                          //  building the design  through the template

                          return KeyedSubtree(
                            key: key,
                            child: SingleCommentNote(
                              mostEgageCOmmentIndex:
                                  commentManager.engageCommentIndex,
                              currentNoteUser: currentNoteUser!,
                              getStreamComments: getStreamComments,
                              postUserId: widget.userId,
                              commentManager: commentManager,
                              stopMainPlayer: stopAudio,
                              isPlaying: _isPlaying,
                              player: _audioPlayer,
                              position: position,
                              index: index,
                              commentModel: commentsList[index],
                              subscriberCommentIndex:
                                  commentManager.subscriberCommentsIndexes,
                              closeFriendIndexs:
                                  commentManager.closeFriendIndexes,
                              commentsList: commentsList,
                              playPause: () {
                                _playAudio(
                                    commentsList[index].comment,
                                    index,
                                    commentsList[index].commentid,
                                    commentsList[index].playedComment);
                              },
                              changeIndex: _currentIndex,

                              // comment: comment
                            ),
                          );
                        },
                      ),
                    )
                  : const Text('')

              // }),
              ),
          Consumer<NoteProvider>(builder: (context, noteProvider, child) {
            //

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  //  if the recorded voice note or comment note is null show the recorder icon

                  if (noteProvider.voiceNote == null &&
                      noteProvider.commentNoteFile == null &&
                      noteProvider.subCommentNoteFile == null)
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        userProvider!.photoUrl,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(
                          noteProvider.voiceNote == null ? 8.0 : 0),
                      child: noteProvider.voiceNote != null

                          //  if recording file is not null then show the  recorded voice

                          ? Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: VoiceMessageView(
                                    size: 40,
                                    circlesColor: primaryColor,
                                    cornerRadius: 50,
                                    innerPadding: 2,
                                    controller: VoiceController(
                                      audioSrc: noteProvider.commentNoteFile ==
                                              null
                                          ? noteProvider.voiceNote!.path
                                          : noteProvider.commentNoteFile!.path,
                                      maxDuration: const Duration(seconds: 500),
                                      isFile: true,
                                      onComplete: () {},
                                      onPause: () {},
                                      onPlaying: () {},
                                      onError: (err) {},
                                    ),
                                  ),
                                ),
                                noteProvider.isLoading
                                    ? SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                          color: blackColor,
                                        ),
                                      )
                                    : Expanded(
                                        child: InkWell(
                                            onTap: () async {
                                              // if (noteProvider.voiceNote != null) {
                                              noteProvider.setIsLoading(true);
                                              String commentId =
                                                  const Uuid().v4();
                                              List<double> waveformData =
                                                  await controller
                                                      .extractWaveformData(
                                                path:noteProvider.voiceNote!.path,
                                                noOfSamples: 200,
                                              );
                                              String comment =
                                                  await AddNoteController()
                                                      .uploadFile(
                                                          'comments',
                                                          noteProvider
                                                              .voiceNote!,
                                                          context);
                                              CommentModel commentModel =
                                                  CommentModel(
                                                    
                                                commentid: commentId,
                                                comment: comment,
                                                username: userProvider!.name,
                                                time: DateTime.now(),
                                                userId: userProvider.uid,
                                                playedComment: 0,
                                                postId: widget.postId,
                                                likes: [],
                                                userImage:
                                                    userProvider.photoUrl,
                                                    waveforms: waveformData
                                              );

                                              commentProvider
                                                  .addComment(
                                                      widget.postId,
                                                      commentId,
                                                      commentModel,
                                                      context)
                                                  .then((value) async {
                                                DocumentSnapshot<
                                                        Map<String, dynamic>>
                                                    userModel =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(widget.userId)
                                                        .get();

                                                UserModel toNotiUser =
                                                    UserModel.fromMap(
                                                        userModel.data()!);

                                                if (toNotiUser.isReply &&
                                                    userProvider.uid !=
                                                        widget.userId) {
                                                  NotificationMethods
                                                      .sendPushNotification(
                                                          widget
                                                              .noteData.userUid,
                                                          widget.noteData
                                                              .userToken,
                                                          'replied',
                                                          userProvider.username,
                                                          'notification',
                                                          '');
                                                  String notificationId =
                                                      const Uuid().v4();
                                                  CommentNotoficationModel noti =
                                                      CommentNotoficationModel(
                                                          time: DateTime.now(),
                                                          postBackground: widget
                                                              .noteData
                                                              .backgroundImage,
                                                          postThumbnail: widget
                                                              .noteData
                                                              .videoThumbnail,
                                                          postType: widget
                                                              .noteData
                                                              .backgroundType,
                                                          noteUrl: widget
                                                              .noteData.noteUrl,
                                                          isRead: '',
                                                          notificationId:
                                                              notificationId,
                                                          notification: comment,
                                                          notificationType:
                                                              'comment',
                                                          currentUserId:
                                                              userProvider.uid,
                                                          toId: widget.userId);
                                                  Provider.of<NotificationProvider>(
                                                          context,
                                                          listen: false)
                                                      .addCommentNotification(
                                                          noti);
                                                }

                                                // commentProvider
                                                //     .addOneComment(commentModel);
                                                noteProvider.removeVoiceNote();
                                                noteProvider
                                                    .setIsLoading(false);
                                              });
                                            },
                                            child: const Icon(Icons.send)),
                                      ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      noteProvider.removeVoiceNote();
                                      noteProvider.removeCommentNote();
                                      noteProvider.removeCommentModel();
                                      noteProvider.removeSubCommentNote();
                                      noteProvider.removeSubCommentModel();
                                      noteProvider.setIsReplying(false);
                                      noteProvider.setSubCOmmentReplying(false);
                                      noteProvider.setRecording(false);
                                      // noteProvider.setIsLoading(false);
                                    },
                                    child: const Icon(Icons.close),
                                  ),
                                )
                              ],
                            )
                          : noteProvider.commentNoteFile != null

                              // show the recorded comment voice note

                              ? Row(
                                  children: [
                                    VoiceMessageView(
                                      size: 40,
                                      circlesColor: primaryColor,
                                      cornerRadius: 50,
                                      innerPadding: 2,
                                      controller: VoiceController(
                                        audioSrc:
                                            noteProvider.commentNoteFile!.path,
                                        maxDuration:
                                            const Duration(seconds: 500),
                                        isFile: true,
                                        onComplete: () {},
                                        onPause: () {},
                                        onPlaying: () {},
                                        onError: (err) {},
                                      ),
                                    ),
                                    noteProvider.isLoading
                                        ? SizedBox(
                                            height: 15,
                                            width: 12,
                                            child: CircularProgressIndicator(
                                              color: blackColor,
                                            ),
                                          )
                                        : Expanded(
                                            child: InkWell(
                                                onTap: () async {
                                                  noteProvider
                                                      .setIsLoading(true);
                                                  String commentId =
                                                      const Uuid().v4();
                                                      List<double> waveformData =
                                                  await controller
                                                      .extractWaveformData(
                                                path:noteProvider.commentNoteFile!.path,
                                                noOfSamples: 200,
                                              );
                                                  String comment =
                                                      await AddNoteController()
                                                          .uploadFile(
                                                              'comments',
                                                              noteProvider
                                                                  .commentNoteFile!,
                                                              context);
                                                  SubCommentModel commentModel =
                                                      SubCommentModel(
                                                        waveforms: waveformData,
                                                    replyingTo: noteProvider
                                                        .commentModel!.userId,
                                                    subCommentId: commentId,
                                                    commentId: noteProvider
                                                        .commentModel!
                                                        .commentid,
                                                    comment: comment,
                                                    userName:
                                                        userProvider!.name,
                                                    createdAt: DateTime.now(),
                                                    userId: userProvider.uid,
                                                    // playedComment: 0,
                                                    postId: widget.postId,
                                                    // likes: [],
                                                    userImage:
                                                        userProvider.photoUrl,
                                                  );

                                                  commentProvider
                                                      .addSubComment(
                                                          commentModel, context)
                                                      .then((value) {
                                                    noteProvider
                                                        .setSubCOmmentReplying(
                                                            false);
                                                    noteProvider
                                                        .removeSubCommentModel();
                                                    noteProvider
                                                        .removeSubCommentNote();
                                                    noteProvider
                                                        .removeCommentModel();
                                                    noteProvider
                                                        .removeCommentNote();
                                                    noteProvider
                                                        .setIsReplying(false);
                                                    noteProvider
                                                        .setIsLoading(false);
                                                    noteProvider
                                                        .setIsLoading(false);
                                                    noteProvider
                                                        .setRecording(false);
                                                  });
                                                  // }
                                                },
                                                child: const Icon(Icons.send)),
                                          ),
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () {
                                          noteProvider.removeVoiceNote();
                                          noteProvider.removeCommentNote();
                                          noteProvider.removeCommentModel();
                                          noteProvider.removeSubCommentNote();
                                          noteProvider.removeSubCommentModel();
                                          noteProvider.setIsReplying(false);
                                          noteProvider.setRecording(false);

                                          noteProvider
                                              .setSubCOmmentReplying(false);
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    )
                                  ],
                                )

                              //   show the recorded sub comment

                              : noteProvider.subCommentNoteFile != null
                                  ? Row(
                                      children: [
                                        VoiceMessageView(
                                          size: 40,
                                          circlesColor: primaryColor,
                                          cornerRadius: 50,
                                          innerPadding: 2,
                                          controller: VoiceController(
                                            audioSrc: noteProvider
                                                .subCommentNoteFile!.path,
                                            maxDuration:
                                                const Duration(seconds: 500),
                                            isFile: true,
                                            onComplete: () {},
                                            onPause: () {},
                                            onPlaying: () {},
                                            onError: (err) {},
                                          ),
                                        ),
                                        noteProvider.isLoading
                                            ? SizedBox(
                                                height: 15,
                                                width: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: blackColor,
                                                ),
                                              )
                                            : Expanded(
                                                child: InkWell(
                                                    onTap: () async {
                                                      noteProvider
                                                          .setIsLoading(true);
                                                      String commentId =
                                                          const Uuid().v4();
                                                          List<double> waveformData =
                                                  await controller
                                                      .extractWaveformData(
                                                path:noteProvider.subCommentNoteFile!.path,
                                                noOfSamples: 200,
                                              );
                                                      String comment =
                                                          await AddNoteController()
                                                              .uploadFile(
                                                                  'comments',
                                                                  noteProvider
                                                                      .subCommentNoteFile!,
                                                                  context);
                                                      SubCommentModel
                                                          commentModel =
                                                          SubCommentModel(
                                                            waveforms: waveformData,
                                                        replyingTo: noteProvider
                                                            .subCommentModel!
                                                            .userId,
                                                        subCommentId: commentId,
                                                        commentId: noteProvider
                                                            .subCommentModel!
                                                            .commentId,
                                                        comment: comment,
                                                        userName:
                                                            userProvider!.name,
                                                        createdAt:
                                                            DateTime.now(),
                                                        userId:
                                                            userProvider.uid,
                                                        // playedComment: 0,
                                                        postId: widget.postId,
                                                        // likes: [],
                                                        userImage: userProvider
                                                            .photoUrl,
                                                      );

                                                      commentProvider
                                                          .addSubComment(
                                                              commentModel,
                                                              context)
                                                          .then((value) {
                                                        noteProvider
                                                            .setIsLoading(
                                                                false);
                                                        noteProvider
                                                            .removeVoiceNote();
                                                        noteProvider
                                                            .removeCommentNote();
                                                        noteProvider
                                                            .removeCommentModel();
                                                        noteProvider
                                                            .removeSubCommentNote();
                                                        noteProvider
                                                            .removeSubCommentModel();
                                                        noteProvider
                                                            .setIsReplying(
                                                                false);
                                                        noteProvider
                                                            .setSubCOmmentReplying(
                                                                false);
                                                        noteProvider
                                                            .setRecording(
                                                                false);
                                                      });
                                                      // }
                                                    },
                                                    child:
                                                        const Icon(Icons.send)),
                                              ),
                                        Expanded(
                                          child: IconButton(
                                            onPressed: () {
                                              noteProvider.setRecording(false);
                                              noteProvider.removeVoiceNote();
                                              noteProvider.removeCommentNote();
                                              noteProvider.removeCommentModel();
                                              noteProvider
                                                  .removeSubCommentNote();
                                              noteProvider
                                                  .removeSubCommentModel();

                                              noteProvider.setIsReplying(false);
                                              noteProvider
                                                  .setSubCOmmentReplying(false);
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                        )
                                      ],
                                    )

                                  //  all the recorded voices are empty then show the textform field

                                  : TextFormField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: 'Add a reply',
                                        hintStyle: TextStyle(
                                            fontFamily: fontFamily,
                                            color: Colors.grey,
                                            fontSize: 13),
                                        suffixIcon: noteProvider.isReplying
                                            ? GestureDetector(
                                                onTap: () async {
                                                  //  if the voice is not recording then start the recording

                                                  // otherwise stop the recording

                                                  try {
                                                    if (await noteProvider
                                                        .recorder
                                                        .isRecording()) {
                                                      noteProvider
                                                          .commentStop();
                                                    } else {
                                                      stopMainPlayer();
                                                      Provider.of<CircleCommentsProvider>(
                                                              context,
                                                              listen: false)
                                                          .pausePlayer();
                                                      noteProvider
                                                          .commentRecord(); // Path is optional
                                                    }
                                                  } catch (e) {
                                                    debugPrint(e.toString());
                                                  } finally {
                                                    noteProvider.setRecording(
                                                        !noteProvider
                                                            .isRecording);
                                                  }
                                                },

                                                // showing the icon based on the condition

                                                child: Icon(
                                                  noteProvider.isRecording
                                                      ? Icons.stop
                                                      : Icons.mic,
                                                  color: blackColor,
                                                  size: 30,
                                                ),
                                              )

                                            //  also for the subcomment

                                            : noteProvider.isSubCommentReplying
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      if (await noteProvider
                                                          .recorder
                                                          .isRecording()) {
                                                        noteProvider
                                                            .subCommentStop();
                                                      } else {
                                                        stopMainPlayer();
                                                        Provider.of<CircleCommentsProvider>(
                                                                context,
                                                                listen: false)
                                                            .pausePlayer();
                                                        noteProvider
                                                            .subCommentRecord();
                                                      }
                                                    },
                                                    child: Icon(
                                                      noteProvider.isRecording
                                                          ? Icons.stop
                                                          : Icons.mic,
                                                      color: blackColor,
                                                      size: 30,
                                                    ),
                                                  )

                                                //  same condition for this

                                                : GestureDetector(
                                                    onTap: () async {
                                                      if (await noteProvider
                                                          .recorder
                                                          .isRecording()) {
                                                        noteProvider.stop();
                                                      } else {
                                                        stopMainPlayer();
                                                        Provider.of<CircleCommentsProvider>(
                                                                context,
                                                                listen: false)
                                                            .pausePlayer();
                                                        noteProvider
                                                            .record(context);
                                                      }
                                                    },
                                                    child: Icon(
                                                      noteProvider.isRecording
                                                          ? Icons.stop
                                                          : Icons.mic,
                                                      color: blackColor,
                                                      size: 30,
                                                    ),
                                                  ),
                                        constraints:
                                            const BoxConstraints(maxHeight: 45),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(19)),
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(19)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(19),
                                        ),
                                      ),
                                    ),
                    ),
                  )
                ],
              ),
            );
          }),
          const SizedBox(
            height: 20,
          ),
          // Container(
          //   height: 6,
          //   width: 150,
          //   decoration: BoxDecoration(
          //       color: blackColor, borderRadius: BorderRadius.circular(50)),
          // ),
        ],
      ),
    );
  }
}
