// import 'dart:async';

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_waveforms/audio_waveforms.dart' as audi;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/controller/chat_controller.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/widgets/custom_message_note.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      this.receiverUser,
      this.receiverId,
      this.rectoken,
      this.receiverName,
      this.receiverPhotoUrl});

  final UserModel? receiverUser;
  final String? receiverId;
  final String? receiverName;
  final String? receiverPhotoUrl;
  final String? rectoken;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // late final audi.RecorderController recorderController;
  StreamSubscription? allMessages;
  String getConversationId() {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    String recID = widget.receiverUser == null
        ? widget.receiverId!
        : widget.receiverUser!.uid;
    return userProvider!.uid.hashCode <= recID.hashCode
        ? '${userProvider.uid}_${recID}'
        : '${recID}_${userProvider.uid}';
  }

  QuerySnapshot<Map<String, dynamic>>? messagesSnapshots;
  // void _initialiseControllers() {
  //   recorderController = audi.RecorderController()
  //     ..androidEncoder = audi.AndroidEncoder.aac
  //     ..androidOutputFormat = audi.AndroidOutputFormat.mpeg4
  //     ..iosEncoder = audi.IosEncoder.kAudioFormatMPEG4AAC
  //     ..sampleRate = 44100;
  // }

  @override
  void initState() {
    super.initState();
    // _initialiseControllers();
    allMessages = FirebaseFirestore.instance
        .collection('chats')
        .doc(getConversationId())
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messagesSnapshots = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    String recID = widget.receiverUser == null
        ? widget.receiverId!
        : widget.receiverUser!.uid;
    String recName = widget.receiverUser == null
        ? widget.receiverName!
        : widget.receiverUser!.name;
    String recPhoto = widget.receiverUser == null
        ? widget.receiverPhotoUrl!
        : widget.receiverUser!.photoUrl;
    String recToken = widget.receiverUser == null
        ? widget.rectoken!
        : widget.receiverUser!.token;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: whiteColor,
        titleSpacing: 0,
        backgroundColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              navPop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: blackColor,
            )),
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                recPhoto,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(recID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        UserModel blueTick =
                            UserModel.fromMap(snapshot.data!.data()!);
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OtherUserProfile(userId: blueTick.uid),
                                ));
                          },
                          child: Row(
                            children: [
                              Text(
                                blueTick.name,
                                style: TextStyle(
                                    fontFamily: fontFamily,
                                    color: blackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                              blueTick.isVerified
                                  ? verifiedIcon()
                                  // Image.network(
                                  //     'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                                  //     height: 20,
                                  //     width: 20,
                                  //   )
                                  : const Text('')
                            ],
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    }),
                // Text(
                //   'Business chat',
                //   style: TextStyle(
                //       fontFamily: fontFamily, color: Colors.grey, fontSize: 12),
                // )
              ],
            )
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.discount),
        //   )
        // ],
      ),
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            Container(
              height: size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover, image: NetworkImage(recPhoto))),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.1), // Transparent color
              ),
            ),
            SizedBox(
              height: size.height,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(getConversationId())
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (messagesSnapshots != null) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  // DateTime? previousDate;
                                  ChatModel chat = ChatModel.fromMap(
                                      snapshot.data!.docs[index].data());
                                  bool isMe = chat.senderId ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? true
                                      : false;
                                  // var format = DateFormat.yMd('ar');
                                  String formattedDateTime =
                                      DateFormat('yyyy-MM-dd hh:mm a')
                                          .format(chat.time);
                                  // bool showDate = previousDate == null ||
                                  //     previousDate
                                  //             .difference(chat.time)
                                  //             .inDays !=
                                  //         0;
                                  // previousDate = chat.time;

                                  // DateFormat('yyyy-MM-dd – kk:mm')
                                  //     .format(chat.time);
                                  final key = ValueKey<String>(
                                      'comment_${chat.chatId}');
                                  return KeyedSubtree(
                                    key: key,
                                    child: Column(
                                      children: [
                                        // if (showDate)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15),
                                          child: Text(
                                            formattedDateTime,
                                            style: TextStyle(color: whiteColor),
                                          ),
                                        ),
                                        CustomMessageNote(
                                          isShare: chat.isShare,
                                          isMe: isMe,
                                          chatModel: chat,
                                          conversationId: getConversationId(),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return SpinKitThreeBounce(
                              color: primaryColor,
                              size: 15,
                            );
                          }
                        }),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(color: whiteColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 12),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     children: [
                        //       Text(
                        //         '❤️',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '🙌',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '🔥',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '👏',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '😥',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '😍',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '😮',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //       Text(
                        //         '😂',
                        //         style: TextStyle(
                        //             fontSize: 22, fontFamily: fontFamily),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // CustomRecordChat()
                        Consumer<NoteProvider>(builder: (context, note, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                if (note.voiceNote == null)
                                  Consumer<UserProvider>(
                                      builder: (context, userPro, _) {
                                    return CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                        userPro.user!.photoUrl,
                                      ),
                                    );
                                  }),
                                Expanded(
                                  child: note.voiceNote != null
                                      ? Row(
                                          children: [
                                            VoiceMessageView(
                                                size: 25,
                                                innerPadding: 0,
                                                controller: VoiceController(
                                                    audioSrc:
                                                        note.voiceNote!.path,
                                                    maxDuration: const Duration(
                                                        seconds: 500),
                                                    isFile: true,
                                                    onComplete: () {},
                                                    onPause: () {},
                                                    onPlaying: () {})),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            note.isLoading
                                                ? SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: blackColor,
                                                    ))
                                                : GestureDetector(
                                                    onTap: note.isLoading
                                                        ? null
                                                        : () async {
                                                            note.setIsLoading(
                                                                true);
                                                            String chatId =
                                                                const Uuid()
                                                                    .v4();
                                                            String message =
                                                                await AddNoteController()
                                                                    .uploadFile(
                                                                        'chats',
                                                                        note.voiceNote!,
                                                                        context);
                                                            ChatModel chat = ChatModel(
                                                                name:
                                                                    userProvider!
                                                                        .name,
                                                                message:
                                                                    message,
                                                                senderId:
                                                                    userProvider
                                                                        .uid,
                                                                chatId: chatId,
                                                                postOwner: '',
                                                                time: DateTime
                                                                    .now(),
                                                                isShare: false,
                                                                receiverId:
                                                                    recID,
                                                                messageRead: '',
                                                                avatarUrl:
                                                                    userProvider
                                                                        .photoUrl);
                                                            RecentChatModel recentChatModel = RecentChatModel(
                                                                chatId: chatId,
                                                                senderId:
                                                                    userProvider
                                                                        .uid,
                                                                receiverId:
                                                                    recID,
                                                                message:
                                                                    message,
                                                                time: DateTime
                                                                    .now(),
                                                                senderImage:
                                                                    userProvider
                                                                        .photoUrl,
                                                                senderName:
                                                                    userProvider
                                                                        .name,
                                                                usersId:
                                                                    getConversationId(),
                                                                receiverName:
                                                                    recName,
                                                                receiverImage:
                                                                    recPhoto,
                                                                senderToken:
                                                                    userProvider
                                                                        .token,
                                                                receiverToken:
                                                                    recToken,
                                                                seen: false);
                                                            ChatController()
                                                                .sendMessage(
                                                                    chat,
                                                                    chatId,
                                                                    getConversationId(),
                                                                    recName,
                                                                    recPhoto,
                                                                    userProvider
                                                                        .token,
                                                                    recToken,
                                                                    context)
                                                                .then((value) {
                                                              // Provider.of<ChatProvider>(
                                                              //         context,
                                                              //         listen:
                                                              //             false)
                                                              //     .addOneRecentChat(
                                                              //         recentChatModel);
                                                              NotificationMethods
                                                                  .sendPushNotification(
                                                                      recToken,
                                                                      '${userProvider.username} sent a voice note',
                                                                      userProvider
                                                                          .name);
                                                              note.setIsLoading(
                                                                  false);
                                                              note.removeVoiceNote();
                                                            });
                                                          },
                                                    child: Icon(
                                                      Icons.send_rounded,
                                                      color: blackColor,
                                                      size: 30,
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    note.removeVoiceNote();
                                                  },
                                                  child: Icon(
                                                    Icons.close,
                                                    color: blackColor,
                                                    size: 30,
                                                  )),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            )
                                          ],
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              hintText: 'Add a reply',
                                              hintStyle: TextStyle(
                                                  fontFamily: fontFamily,
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                              // label: Text(
                                              //   'Add a reply',
                                              //   style: TextStyle(
                                              //       fontFamily: fontFamily,
                                              //       color: Colors.grey,
                                              //       fontSize: 13),
                                              // ),
                                              suffixIcon: GestureDetector(
                                                onTap: () async {
                                                  // try {
                                                  //   if (note.recorder.) {
                                                  //     recorderController
                                                  //         .reset();

                                                  //     String? path =
                                                  //         await recorderController
                                                  //             .stop(false);

                                                  //     if (path != null) {
                                                  //       note.setVoiceNote(
                                                  //           File(path));
                                                  //       debugPrint(path);
                                                  //       debugPrint(
                                                  //           "Recorded file size: ${File(path).lengthSync()}");
                                                  //     }
                                                  //   } else {
                                                  //     var id =
                                                  //         const Uuid().v4();
                                                  //     Directory appDocDir =
                                                  //         await getApplicationDocumentsDirectory();
                                                  //     String appDocPath =
                                                  //         appDocDir.path;
                                                  //     String? path =
                                                  //         '$appDocPath/$id.flac';
                                                  //     await recorderController
                                                  //         .record(
                                                  //             path:
                                                  //                 path); // Path is optional
                                                  //   }
                                                  // } catch (e) {
                                                  //   debugPrint(e.toString());
                                                  // } finally {
                                                  //   note.setRecording(
                                                  //       !note.isRecording);
                                                  //   // setState(() {
                                                  //   //   isRecording =
                                                  //   //       !isRecording;
                                                  //   // });
                                                  // }
                                                  if (await note.recorder
                                                      .isRecording()) {
                                                    note.stop();
                                                  } else {
                                                    note.record();
                                                  }
                                                },
                                                child: Icon(
                                                  note.isRecording
                                                      ? Icons.stop
                                                      : Icons.mic_none_rounded,
                                                  color: blackColor,
                                                  size: 30,
                                                ),
                                              ),
                                              constraints: const BoxConstraints(
                                                  maxHeight: 45),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          19)),
                                              border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          19)),
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
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class CustomRecordChat extends StatefulWidget {
//   const CustomRecordChat({super.key});

//   @override
//   State<CustomRecordChat> createState() => _CustomRecordChatState();
// }

// class _CustomRecordChatState extends State<CustomRecordChat> {
//   late final RecorderController recorderController;
//   late final AudioPlayer audioPlayer;

//   String? path;
//   String? musicFile;
//   bool isRecording = false;
//   bool isRecordingCompleted = false;
//   bool isLoading = true;
//   void _initialiseControllers() {
//     recorderController = RecorderController()
//       ..androidEncoder = AndroidEncoder.aac
//       ..androidOutputFormat = AndroidOutputFormat.mpeg4
//       ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
//       ..sampleRate = 44100;
//   }

//   @override
//   void initState() {
//     super.initState();

//     _initialiseControllers();
//     audioPlayer = AudioPlayer();
//     audioPlayer.onPlayerComplete.listen((event) {
//       setState(() {
//         isRecordingCompleted = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     recorderController.dispose();
//     audioPlayer.dispose();
//     super.dispose();
//   }

//   void _startOrStopRecording() async {
//     try {
//       if (isRecording) {
//         recorderController.reset();

//         path = await recorderController.stop(false);

//         if (path != null) {
//           isRecordingCompleted = true;
//           debugPrint(path);
//           Provider.of<NoteProvider>(context, listen: false)
//               .setVoiceNote(File(path!));
//           // await audioPlayer.setSourceDeviceFile(path!);
//           // await audioPlayer.play(
//           //   UrlSource(path!),
//           // );

//           debugPrint("Recorded file size: ${File(path!).lengthSync()}");
//         }
//       } else {
//         await recorderController.record(path: path); // Path is optional
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     } finally {
//       setState(() {
//         isRecording = !isRecording;
//       });
//     }
//   }

//   void _refreshWave() {
//     if (isRecording) recorderController.refresh();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var userProvider = Provider.of<UserProvider>(context, listen: false).user;
//     return Consumer<NoteProvider>(builder: (context, notePro, _) {
//       return Row(
//         children: [
//           const CircleAvatar(
//             radius: 18,
//             backgroundImage: NetworkImage(
//                 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D'),
//           ),
//           SizedBox(
//             width: 3,
//           ),
//           if (notePro.voiceNote != null)
//             VoiceMessageView(
//                 controller: VoiceController(
//               audioSrc: notePro.voiceNote!.path,
//               maxDuration: Duration(seconds: 500),
//               isFile: true,
//               onComplete: () {},
//               onPause: () {},
//               onPlaying: () {},
//             )),
//           if (notePro.voiceNote == null)
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 200),
//               child: isRecording
//                   ? AudioWaveforms(
//                       enableGesture: true,
//                       size: Size(MediaQuery.of(context).size.width / 2, 50),
//                       recorderController: recorderController,
//                       waveStyle: const WaveStyle(
//                         waveColor: Colors.black,
//                         extendWaveform: true,
//                         showMiddleLine: false,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.0),
//                         color: whiteColor,
//                         border: Border.all(width: 1, color: Colors.grey),
//                       ),
//                       padding: const EdgeInsets.only(left: 18),
//                       margin: const EdgeInsets.symmetric(horizontal: 15),
//                     )
//                   : Container(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: 50,
//                       child: TextFormField(
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           label: Text(
//                             'Add a reply',
//                             style: TextStyle(
//                                 fontFamily: fontFamily,
//                                 color: Colors.grey,
//                                 fontSize: 13),
//                           ),
//                           suffixIcon: GestureDetector(
//                             onTap: _startOrStopRecording,
//                             child: Icon(
//                               isRecording ? Icons.stop : Icons.mic_none_rounded,
//                               color: blackColor,
//                               size: 30,
//                             ),
//                           ),
//                           // constraints: const BoxConstraints(maxHeight: 45),
//                           border: OutlineInputBorder(
//                               borderSide: const BorderSide(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(19)),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(19),
//                           ),
//                         ),
//                       ),
//                     ),
//             ),
//           // IconButton(
//           //   onPressed: _refreshWave,
//           //   icon: Icon(
//           //     isRecording ? Icons.refresh : Icons.send,
//           //     color: Colors.black,
//           //   ),
//           // ),
//           // const SizedBox(width: 16),
//           // if (!isRecordingCompleted)
//           //   IconButton(
//           //     onPressed: _startOrStopRecording,
//           //     icon: Icon(isRecording ? Icons.stop : Icons.mic),
//           //     color: Colors.black,
//           //     iconSize: 28,
//           //   ),
//           // if (isRecordingCompleted)
//           //   IconButton(
//           //     onPressed: () async {
//           //       await audioPlayer.stop();
//           //       setState(() {
//           //         isRecordingCompleted = false;
//           //       });
//           //     },
//           //     icon: Icon(Icons.stop),
//           //     color: Colors.black,
//           //     iconSize: 28,
//           //   ),
//         ],
//       );
//     });
//   }
// }
