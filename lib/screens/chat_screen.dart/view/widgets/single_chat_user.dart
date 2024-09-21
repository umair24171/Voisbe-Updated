import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
import 'package:intl/intl.dart';

class SingleChatUser extends StatefulWidget {
  const SingleChatUser(
      {super.key,
      required this.chatModel,
      required this.color,
      required this.index,
      // required this.allMessgaesIndex,
      // required this.messageReqIndex,
      required this.recId,
      required this.isSearching,
      required this.isSeen});
  final RecentChatModel chatModel;
  final Color color;
  final bool isSeen;
  final int index;
  // final List<int> allMessgaesIndex;
  // final List<int> messageReqIndex;
  final bool isSearching;
  final String recId;

  @override
  State<SingleChatUser> createState() => _SingleChatUserState();
}

class _SingleChatUserState extends State<SingleChatUser> {
  late StreamSubscription<QuerySnapshot> chatStream;
  ChatModel? chat;

  @override
  void initState() {
    super.initState();
    checkSeenStatus();
  }

  checkSeenStatus() async {
    chatStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatModel.usersId)
        .collection('messages')
        .where('messageRead', isEqualTo: '')
        .snapshots()
        .listen((value) {
      if (value.docs.isNotEmpty) {
        // Sort the documents in Dart code
        final sortedDocs = value.docs.toList()
          ..sort((a, b) => (b.data()['time'] as Timestamp)
              .compareTo(a.data()['time'] as Timestamp));

        setState(() {
          chat = ChatModel.fromMap(sortedDocs.first.data());
        });
      } else {
        setState(() {
          chat = null;
        });
      }
    });
  }

  // checkSeenStatus() async {
  //   chatStream = FirebaseFirestore.instance
  //       .collection('chats')
  //       .doc(widget.chatModel.usersId)
  //       .collection('messages')
  //       .where('messageRead', isEqualTo: '')
  //       .orderBy('time', descending: true)
  //       .limit(1)
  //       .snapshots()
  //       .listen((value) {
  //     if (value.docs.isNotEmpty) {
  //       setState(() {
  //         chat = ChatModel.fromMap(value.docs.first.data());
  //       });
  //     } else {
  //       setState(() {
  //         chat = null;
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    chatStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUSer = Provider.of<UserProvider>(context, listen: false).user;
    String formattedTime = DateFormat('hh:mm a').format(widget.chatModel.time!);
    bool isMe = widget.chatModel.senderId == currentUSer!.uid;
    // log('Chat id is ${widget.chatModel.message}');

    return Slidable(
      direction: Axis.horizontal,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
              padding: const EdgeInsets.all(0),
              onPressed: (context) async {
                final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                List delChat = widget.chatModel.deletedChat!;
                delChat.add(currentUSer.uid);
                await _firestore
                    .collection('chats')
                    .doc(widget.chatModel.usersId)
                    .update({'deletedChat': delChat});

                // Get all messages in the specified chat
                final QuerySnapshot messagesSnapshot = await _firestore
                    .collection('chats')
                    .doc(widget.chatModel.usersId)
                    .collection('messages')
                    .get();

                // Batch write to update all messages
                final WriteBatch batch = _firestore.batch();

                for (DocumentSnapshot message in messagesSnapshot.docs) {
                  // Get current deletedChat field value
                  List<String> deletedChat =
                      List<String>.from(message['deletedChat'] ?? []);

                  // Add current user's UID if not already present
                  if (!deletedChat.contains(currentUSer.uid)) {
                    deletedChat.add(currentUSer.uid);
                  }

                  // Update the deletedChat field
                  batch.update(message.reference, {'deletedChat': deletedChat});
                }

                // Commit the batch update
                await batch.commit();
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
      child: BuildSingleChatUser(
        widget: widget,
        currentUSer: currentUSer,
        formattedTime: formattedTime,
        chat: chat,
        isMe: isMe,
      ),
    );
  }
}

class BuildSingleChatUser extends StatelessWidget {
  const BuildSingleChatUser({
    super.key,
    required this.widget,
    required this.currentUSer,
    required this.formattedTime,
    required this.chat,
    required this.isMe,
  });

  final SingleChatUser widget;
  final UserModel? currentUSer;
  final String formattedTime;
  final ChatModel? chat;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(width: 3, color: widget.color)),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.recId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel recImage =
                          UserModel.fromMap(snapshot.data!.data()!);
                      return CircleAvatar(
                        backgroundImage: NetworkImage(recImage.photoUrl),
                        radius: 17,
                      );
                    } else {
                      return const Text('');
                    }
                  }),
            ),
          ),
          // const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUSer!.uid == widget.chatModel.senderId
                              ? widget.chatModel.receiverId!
                              : widget.chatModel.senderId!)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserModel chatUser =
                              UserModel.fromMap(snapshot.data!.data()!);
                          return Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                // const Spacer(),
                                Text(
                                  chatUser.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.w600),
                                ),
                                if (chatUser.isVerified) verifiedIcon()
                              ],
                            ),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        formattedTime,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                CustomProgressPlayer(
                  lockPosts: [],
                  stopMainPlayer: () {},
                  postId: widget.chatModel.chatId,
                  isChatUserPlayer: true,
                  size: 10,
                  waveColor: whiteColor,
                  backgroundColor:
                      currentUSer!.closeFriends.contains(widget.recId)
                          ? chat == null
                              ? greenColor.withOpacity(0.5)
                              : greenColor
                          : chat == null
                              ? const Color(0xffefa69d)
                              : primaryColor,
                  noteUrl: widget.chatModel.message!,
                  height: 25,
                  width: MediaQuery.of(context).size.width * 0.4850,
                  mainWidth: MediaQuery.of(context).size.width * 0.73,
                  mainHeight: 42,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatModel.usersId)
                      .collection('messages')
                      .where('messageRead', isEqualTo: '')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 23, right: 4),
                          child: isMe
                              ? Icon(
                                  chat == null ? Icons.done_all : Icons.done,
                                  color: widget.color,
                                  size: 20,
                                )
                              : const SizedBox(
                                  width: 20,
                                ),
                        );
                      } else {
                        return !isMe
                            ? Padding(
                                padding: const EdgeInsets.only(top: 22),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    snapshot.data!.docs.length.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: whiteColor),
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.only(top: 23, right: 4),
                                child: isMe
                                    ? Icon(
                                        chat == null
                                            ? Icons.done_all
                                            : Icons.done,
                                        color: widget.color,
                                        size: 20,
                                      )
                                    : const SizedBox(),
                              );
                      }
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
