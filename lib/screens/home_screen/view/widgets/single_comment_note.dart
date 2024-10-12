import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/model/sub_comment_model.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/comments_player.dart';

import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';

class SingleCommentNote extends StatefulWidget {
  const SingleCommentNote(
      {super.key,
      required this.commentModel,
      required this.index,
      required this.closeFriendIndexs,
      required this.commentsList,
      required this.playPause,
      required this.player,
      required this.position,
      required this.isPlaying,
      required this.postUserId,
      required this.getStreamComments,
      required this.currentNoteUser,
      required this.stopMainPlayer,
      required this.commentManager,
      required this.mostEgageCOmmentIndex,
      required this.changeIndex,
      required this.subscriberCommentIndex});
  final CommentModel commentModel;
  final int index;
  final List<int> subscriberCommentIndex;
  final List<int> closeFriendIndexs;
  final List<CommentModel> commentsList;
  final AudioPlayer player;
  final VoidCallback playPause;
  final int changeIndex;
  final bool isPlaying;
  final Duration position;
  final VoidCallback stopMainPlayer;
  final String postUserId;
  final VoidCallback getStreamComments;
  final CommentManager commentManager;
  final UserModel currentNoteUser;
  final int mostEgageCOmmentIndex;

  @override
  State<SingleCommentNote> createState() => _SingleCommentNoteState();
}

class _SingleCommentNoteState extends State<SingleCommentNote> {
  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    bool canDismiss = widget.commentModel.userId == currentUser!.uid ||
        widget.postUserId == currentUser.uid;

    return canDismiss
        ? Slidable(
            direction: Axis.horizontal,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    padding: const EdgeInsets.all(0),
                    onPressed: (context) async {
                      final commentManager = widget.commentManager;
                      await commentManager.deleteComment(
                        widget.commentModel.commentid,
                      );
                    },
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    flex: 4,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      topLeft: Radius.circular(0),
                    ),
                    autoClose: true,
                    icon: Icons.delete,
                    label: "Delete"),
              ],
            ),
            child: BuildCommentContent(widget: widget),
          )
        : BuildCommentContent(widget: widget);
  }
}

class BuildCommentContent extends StatelessWidget {
  const BuildCommentContent({
    super.key,
    required this.widget,
  });

  final SingleCommentNote widget;

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OtherUserProfile(
                                userId: widget.commentModel.userId,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.commentModel.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!.data();
                          UserModel imageUser = UserModel.fromMap(data!);
                          return CircleAvatar(
                            backgroundImage: NetworkImage(
                              imageUser.photoUrl,
                            ),
                            radius: 17,
                          );
                        } else {
                          return const Text('');
                        }
                      }),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.commentModel.userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data!.data();
                                UserModel userModel = UserModel.fromMap(data!);
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OtherUserProfile(
                                                  userId: userModel.uid),
                                        ));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        userModel.name,
                                        style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      if (userModel.isVerified) verifiedIcon()
                                    ],
                                  ),
                                );
                              } else {
                                return const Text('');
                              }
                            }),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          timeago.format(widget.commentModel.time),
                          style: TextStyle(
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    CommentsPlayer(
                        waveforms: widget.commentModel.waveforms ?? [],
                        isPlaying: widget.isPlaying,
                        player: widget.player,
                        isComment: true,
                        commentId: widget.commentModel.commentid,
                        postId: widget.commentModel.postId,
                        changeIndex: widget.changeIndex,
                        currentIndex: widget.index,
                        playedCounter: widget.commentModel.playedComment,
                        playPause: widget.playPause,
                        position: widget.position,
                        size: 10,
                        waveColor: whiteColor,
                        backgroundColor: widget.index ==
                                widget.mostEgageCOmmentIndex
                            ? const Color(0xff6cbfd9)
                            : widget.closeFriendIndexs.contains(widget.index)
                                ? const Color(0xff50a87e)
                                : widget.subscriberCommentIndex
                                        .contains(widget.index)
                                    ? const Color(0xffa562cb)
                                    : primaryColor,
                        noteUrl: widget.commentModel.comment,
                        height: 20,
                        width: 150,
                        mainWidth: 250,
                        mainHeight: 42),
                    Consumer<NoteProvider>(builder: (context, noteProvider, _) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          Provider.of<NoteProvider>(context, listen: false)
                              .setIsReplying(true);
                          Provider.of<NoteProvider>(context, listen: false)
                              .setCommentModel(widget.commentModel);

                          if (await noteProvider.recorder.isRecording()) {
                            noteProvider.commentStop();
                          } else {
                            Provider.of<DisplayNotesProvider>(context,
                                    listen: false)
                                .pausePlayer();
                            Provider.of<DisplayNotesProvider>(context,
                                    listen: false)
                                .setIsPlaying(false);
                            Provider.of<DisplayNotesProvider>(context,
                                    listen: false)
                                .setChangeIndex(-1);
                            Provider.of<CircleCommentsProvider>(context,
                                    listen: false)
                                .pausePlayer();
                            noteProvider.commentRecord();
                          }
                          // Set cancel reply to false
                        },
                        child: Text(
                          'Reply',
                          style: TextStyle(
                              color: Colors.black38,
                              fontFamily: fontFamily,
                              fontSize: 14),
                        ),
                      );
                    })
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 34, right: 0),
                      child: GestureDetector(
                          onTap: () async {
                            List likes = widget.commentModel.likes;
                            if (likes.contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              likes.remove(
                                  FirebaseAuth.instance.currentUser!.uid);
                            } else {
                              likes.add(FirebaseAuth.instance.currentUser!.uid);
                            }
                            await FirebaseFirestore.instance
                                .collection('notes')
                                .doc(widget.commentModel.postId)
                                .collection('comments')
                                .doc(widget.commentModel.commentid)
                                .update({
                              'likes': likes,
                            });
                          },
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('notes')
                                  .doc(widget.commentModel.postId)
                                  .collection('comments')
                                  .doc(widget.commentModel.commentid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  CommentModel commentModel1 =
                                      CommentModel.fromMap(
                                          snapshot.data!.data()!);
                                  return Icon(
                                    commentModel1.likes.contains(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: commentModel1.likes.contains(
                                            FirebaseAuth
                                                .instance.currentUser!.uid)
                                        ? primaryColor
                                        : Colors.black,
                                  );
                                } else {
                                  return const Text('');
                                }
                              }))))
            ],
          ),
        ),

        //  reply comments

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .doc(widget.commentModel.postId)
              .collection('comments')
              .doc(widget.commentModel.commentid)
              .collection('subComments')
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  SubCommentModel subCommentModel = SubCommentModel.fromMap(
                      snapshot.data!.docs[index].data());
                  bool canDismiss =
                      subCommentModel.userId == currentUser!.uid ||
                          widget.postUserId == currentUser.uid;

                  return canDismiss
                      ? Slidable(
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: (context) async {
                                    await FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(widget.commentModel.postId)
                                        .collection('comments')
                                        .doc(widget.commentModel.commentid)
                                        .collection('subComments')
                                        .doc(subCommentModel.subCommentId)
                                        .delete();
                                    // final commentManager =
                                    //     widget.commentManager;
                                    // await commentManager.deleteComment(
                                    //   widget.commentModel.commentid,
                                    // );
                                  },
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  flex: 4,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    topLeft: Radius.circular(0),
                                  ),
                                  autoClose: true,
                                  icon: Icons.delete,
                                  label: "Delete"),
                            ],
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40, bottom: 10),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserProfile(
                                                  userId:
                                                      subCommentModel.userId,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(subCommentModel.userId)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            UserModel subCommentPic =
                                                UserModel.fromMap(
                                                    snapshot.data!.data()!);
                                            return CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                subCommentPic.photoUrl,
                                              ),
                                              radius: 17,
                                            );
                                          } else {
                                            return const Text('');
                                          }
                                        }),
                                  ),
                                ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(subCommentModel.userId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  UserModel verifiedUser =
                                                      UserModel.fromMap(snapshot
                                                          .data!
                                                          .data()!);
                                                  return InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                OtherUserProfile(
                                                                    userId:
                                                                        verifiedUser
                                                                            .uid),
                                                          ));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          verifiedUser.name,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  fontFamily,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        if (verifiedUser
                                                            .isVerified)
                                                          verifiedIcon()
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return const Text('');
                                                }
                                              }),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(subCommentModel
                                                      .replyingTo)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  UserModel replyingUser =
                                                      UserModel.fromMap(snapshot
                                                          .data!
                                                          .data()!);
                                                  return InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                OtherUserProfile(
                                                                    userId:
                                                                        replyingUser
                                                                            .uid),
                                                          ));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '@${replyingUser.name}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  fontFamily,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        if (replyingUser
                                                            .isVerified)
                                                          verifiedIcon(),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return const Text('');
                                                }
                                              }),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            timeago.format(
                                                subCommentModel.createdAt),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: fontFamily,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      CustomProgressPlayer(
                                          // waveforms:
                                          //     subCommentModel.waveforms ?? [],
                                          lockPosts: [],
                                          stopMainPlayer: widget.stopMainPlayer,
                                          isSubCommentPlayer: true,
                                          isComment: true,
                                          commentId:
                                              subCommentModel.subCommentId,
                                          postId: subCommentModel.postId,
                                          playedCounter:
                                              widget.commentModel.playedComment,
                                          size: 10,
                                          waveColor: whiteColor,
                                          backgroundColor: primaryColor,
                                          noteUrl: subCommentModel.comment,
                                          height: 20,
                                          width: 150,
                                          mainWidth: 250,
                                          mainHeight: 42),
                                      Consumer<NoteProvider>(
                                          builder: (context, noteProvider, _) {
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            Provider.of<NoteProvider>(context,
                                                    listen: false)
                                                .setSubCOmmentReplying(true);

                                            Provider.of<NoteProvider>(context,
                                                    listen: false)
                                                .setSubComment(subCommentModel);
                                            if (await noteProvider.recorder
                                                .isRecording()) {
                                              noteProvider.subCommentStop();
                                            } else {
                                              Provider.of<DisplayNotesProvider>(
                                                      context,
                                                      listen: false)
                                                  .pausePlayer();
                                              Provider.of<DisplayNotesProvider>(
                                                      context,
                                                      listen: false)
                                                  .setIsPlaying(false);
                                              Provider.of<DisplayNotesProvider>(
                                                      context,
                                                      listen: false)
                                                  .setChangeIndex(-1);
                                              Provider.of<CircleCommentsProvider>(
                                                      context,
                                                      listen: false)
                                                  .pausePlayer();
                                              noteProvider.subCommentRecord();
                                            }
                                            // try {
                                            //   if (noteProvider.isRecording) {
                                            //     recorderController.reset();

                                            //     String? path = await recorderController
                                            //         .stop(false);

                                            //     if (path != null) {
                                            //       noteProvider.setSubCommentNoteFile(
                                            //           File(path));
                                            //       debugPrint(path);
                                            //       debugPrint(
                                            //           "Recorded file size: ${File(path).lengthSync()}");
                                            //     }
                                            //   } else {
                                            //     var id = const Uuid().v4();
                                            //     Directory appDocDir =
                                            //         await getApplicationDocumentsDirectory();
                                            //     String appDocPath = appDocDir.path;
                                            //     String? path = '$appDocPath/$id.flac';
                                            //     await recorderController.record(
                                            //         path: path); // Path is optional
                                            //   }
                                            // } catch (e) {
                                            //   debugPrint(e.toString());
                                            // } finally {
                                            //   noteProvider.setRecording(
                                            //       !noteProvider.isRecording);
                                            //   // setState(() {
                                            //   //   isRecording =
                                            //   //       !isRecording;
                                            //   // });
                                            // }

                                            // Set cancel reply to false
                                          },
                                          child: Text(
                                            'Reply',
                                            style: TextStyle(
                                                color: Colors.black38,
                                                fontFamily: fontFamily,
                                                fontSize: 14),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                                // SizedBox(
                                //   width: 40,
                                // )
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 10),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OtherUserProfile(
                                                userId: subCommentModel.userId,
                                              )));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(subCommentModel.userId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          UserModel subCommentPic =
                                              UserModel.fromMap(
                                                  snapshot.data!.data()!);
                                          return CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              subCommentPic.photoUrl,
                                            ),
                                            radius: 17,
                                          );
                                        } else {
                                          return const Text('');
                                        }
                                      }),
                                ),
                              ),
                              // const SizedBox(
                              //   width: 5,
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(subCommentModel.userId)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                UserModel verifiedUser =
                                                    UserModel.fromMap(
                                                        snapshot.data!.data()!);
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OtherUserProfile(
                                                                  userId:
                                                                      verifiedUser
                                                                          .uid),
                                                        ));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        verifiedUser.name,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      if (verifiedUser
                                                          .isVerified)
                                                        verifiedIcon()
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            }),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(subCommentModel.replyingTo)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                UserModel replyingUser =
                                                    UserModel.fromMap(
                                                        snapshot.data!.data()!);
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OtherUserProfile(
                                                                  userId:
                                                                      replyingUser
                                                                          .uid),
                                                        ));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '@${replyingUser.name}',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontFamily:
                                                                fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      if (replyingUser
                                                          .isVerified)
                                                        verifiedIcon(),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            }),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          timeago.format(
                                              subCommentModel.createdAt),
                                          style: TextStyle(
                                              fontFamily: fontFamily,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    CustomProgressPlayer(
                                        // waveforms:
                                        //     subCommentModel.waveforms ?? [],
                                        lockPosts: [],
                                        stopMainPlayer: widget.stopMainPlayer,
                                        isSubCommentPlayer: true,
                                        isComment: true,
                                        commentId: subCommentModel.subCommentId,
                                        postId: subCommentModel.postId,
                                        playedCounter:
                                            widget.commentModel.playedComment,
                                        size: 10,
                                        waveColor: whiteColor,
                                        backgroundColor: primaryColor,
                                        noteUrl: subCommentModel.comment,
                                        height: 20,
                                        width: 150,
                                        mainWidth: 250,
                                        mainHeight: 42),
                                    Consumer<NoteProvider>(
                                        builder: (context, noteProvider, _) {
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () async {
                                          Provider.of<NoteProvider>(context,
                                                  listen: false)
                                              .setSubCOmmentReplying(true);

                                          Provider.of<NoteProvider>(context,
                                                  listen: false)
                                              .setSubComment(subCommentModel);
                                          if (await noteProvider.recorder
                                              .isRecording()) {
                                            noteProvider.subCommentStop();
                                          } else {
                                            Provider.of<DisplayNotesProvider>(
                                                    context,
                                                    listen: false)
                                                .pausePlayer();
                                            Provider.of<DisplayNotesProvider>(
                                                    context,
                                                    listen: false)
                                                .setIsPlaying(false);
                                            Provider.of<DisplayNotesProvider>(
                                                    context,
                                                    listen: false)
                                                .setChangeIndex(-1);
                                            Provider.of<CircleCommentsProvider>(
                                                    context,
                                                    listen: false)
                                                .pausePlayer();
                                            noteProvider.subCommentRecord();
                                          }
                                          // try {
                                          //   if (noteProvider.isRecording) {
                                          //     recorderController.reset();

                                          //     String? path = await recorderController
                                          //         .stop(false);

                                          //     if (path != null) {
                                          //       noteProvider.setSubCommentNoteFile(
                                          //           File(path));
                                          //       debugPrint(path);
                                          //       debugPrint(
                                          //           "Recorded file size: ${File(path).lengthSync()}");
                                          //     }
                                          //   } else {
                                          //     var id = const Uuid().v4();
                                          //     Directory appDocDir =
                                          //         await getApplicationDocumentsDirectory();
                                          //     String appDocPath = appDocDir.path;
                                          //     String? path = '$appDocPath/$id.flac';
                                          //     await recorderController.record(
                                          //         path: path); // Path is optional
                                          //   }
                                          // } catch (e) {
                                          //   debugPrint(e.toString());
                                          // } finally {
                                          //   noteProvider.setRecording(
                                          //       !noteProvider.isRecording);
                                          //   // setState(() {
                                          //   //   isRecording =
                                          //   //       !isRecording;
                                          //   // });
                                          // }

                                          // Set cancel reply to false
                                        },
                                        child: Text(
                                          'Reply',
                                          style: TextStyle(
                                              color: Colors.black38,
                                              fontFamily: fontFamily,
                                              fontSize: 14),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   width: 40,
                              // )
                            ],
                          ),
                        );
                },
              );
            } else {
              return const Text('');
            }
          },
        ),
      ],
    );
  }
}
