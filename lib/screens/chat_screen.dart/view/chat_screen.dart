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
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

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
  bool _isPlaying = false;
  int _currentIndex = -1;
  late AudioPlayer _audioPlayer;
  Duration position = Duration.zero;

  // late final audi.RecorderController recorderController;

  //   creating the empty list to get all the messages

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

  List<ChatModel>? messagesSnapshots;
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

    //  initialing the player to play one message at a time

    _audioPlayer = AudioPlayer();

    //  getting all the messages function

    getStreamMessages();
  }

  //   getting all the messages through function

  getStreamMessages() async {
    //  prefs to delete the chat  for the current user

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;

    //  getting time based messages

    allMessages = FirebaseFirestore.instance
        .collection('chats')
        .doc(getConversationId())
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      //  converting messages to chat model

      List<ChatModel> chats =
          snapshot.docs.map((e) => ChatModel.fromMap(e.data())).toList();

      // filtering the chats if the specific messsage is deleted

      List<ChatModel> filteredChats = chats.where((chat) {
        return !chat.deletedChat.contains(currentUser!.uid);
      }).toList();

      //  creating the emtpy list to remove the chat

      List<ChatModel> itemsToRemove = [];

      //  checking the key to exist and then removing the message

      List<String>? commentIDs = preferences.getStringList(currentUser!.uid);
      if (commentIDs != null) {
        for (var item in filteredChats) {
          for (var id in commentIDs) {
            if (item.chatId.contains(id)) {
              itemsToRemove.add(item);
              break; // Break inner loop if match is found
            }
          }
        }
      }

      //  then from the filtered list remove the deleted message

      // Remove the collected items from the list
      filteredChats.removeWhere((item) => itemsToRemove.contains(item));
      setState(() {
        //  updating the messages to the global list
        // messagesSnapshots = chats;
        messagesSnapshots = filteredChats;
      });
    });
  }

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

  //  playing the audio chat one at a time

  void _playAudio(
    String url,
    int index,
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
      setState(() {
        _isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  audi.PlayerController controller = audi.PlayerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _stopAndDisposeAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }

  bool _isBlurred = true;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    //  getting the current user

    var userProvider = Provider.of<UserProvider>(context, listen: false).user;

    //  getting the data based on the logic and coming from the different screens

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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didpop,result) async {
        // Stop and dispose of audio before navigating
        await _stopAndDisposeAudio();
      },
      child: Scaffold(
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
            children: [
              //  getting the chat user  image and name real time

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(recID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel recImage =
                          UserModel.fromMap(snapshot.data!.data()!);
                      return CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          recImage.photoUrl,
                        ),
                      );
                    } else {
                      return const Text('');
                    }
                  }),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  getting the chat username  real time and checking the verified user

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
                                    : const Text('')
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                ],
              )
            ],
          ),
        ),

        //  refresh indicator to get the latest messages

        body: RefreshIndicator(
          backgroundColor: whiteColor,
          color: primaryColor,
          onRefresh: () async {
            return getStreamMessages();
          },
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                //  background of the screen would be chat user image getting real time through stream builder

                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(recID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        UserModel recImage =
                            UserModel.fromMap(snapshot.data!.data()!);
                        return Container(
                          height: size.height,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(recImage.photoUrl))),
                        );
                      } else {
                        return const Text('');
                      }
                    }),

                //  above that there is a blur filter
                // if (_isBlurred)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.white.withOpacity(0.1), // Transparent color
                      ),
                    ),
                  ),
                SizedBox(
                  height: size.height,
                  child: Column(
                    children: [
                      Expanded(
                          child: messagesSnapshots != null

                              //  building the messages through list

                              ? ListView.builder(
                                  reverse: true,
                                  itemCount: messagesSnapshots!.length,
                                  itemBuilder: (context, index) {
                                    // converting the messages into the list of chat model

                                    ChatModel chat = messagesSnapshots![index];

                                    //   checking the message send by me or not
                                    bool isMe = chat.senderId ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                        ? true
                                        : false;

                                    //  converting into the time format

                                    String formattedDateTime =
                                        DateFormat('yyyy-MM-dd hh:mm a')
                                            .format(chat.time);

                                    //  getting the unique key for each chat

                                    final key = ValueKey<String>(
                                        'comment_${chat.chatId}');
                                    return KeyedSubtree(
                                      key: key,
                                      child: Column(
                                        children: [
                                          // time of the sent message

                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Text(
                                              formattedDateTime,
                                              style:
                                                  TextStyle(color: whiteColor),
                                            ),
                                          ),

                                          //  building the custom message and passing the required data

                                          CustomMessageNote(
                                            getStreamChats: getStreamMessages,
                                            changeIndex: _currentIndex,
                                            currentIndex: index,
                                            isPlaying: _isPlaying,
                                            playPause: () {
                                              _playAudio(chat.message, index);
                                            },
                                            player: _audioPlayer,
                                            position: position,
                                            isShare: chat.isShare,
                                            isMe: isMe,
                                            chatModel: chat,
                                            conversationId: getConversationId(),
                                          ),
                                        ],
                                      ),
                                    );
                                  })

                              //  while the messages are loading show this bar

                              : SpinKitThreeBounce(
                                  color: primaryColor,
                                  size: 15,
                                )),
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

                            //  show recording or if  need to start recording

                            Consumer<NoteProvider>(builder: (context, note, _) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    if (note.voiceNote == null)

                                      //  showing the current user image

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
                                                //  showing the recorded voice chat

                                                VoiceMessageView(
                                                    size: 25,
                                                    innerPadding: 0,
                                                    controller: VoiceController(
                                                        audioSrc: note
                                                            .voiceNote!.path,
                                                        maxDuration:
                                                            const Duration(
                                                                seconds: 500),
                                                        isFile: true,
                                                        onComplete: () {},
                                                        onPause: () {},
                                                        onPlaying: () {})),
                                                const SizedBox(
                                                  width: 3,
                                                ),

                                                //  while sending the voice show loader

                                                note.isLoading
                                                    ? SizedBox(
                                                        height: 15,
                                                        width: 15,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: blackColor,
                                                        ),
                                                      )
                                                    : GestureDetector(
                                                        onTap: note.isLoading
                                                            ? null
                                                            : () async {
                                                                note.setIsLoading(
                                                                    true);
                                                                String chatId =
                                                                    const Uuid()
                                                                        .v4();

                                                                //  uploading the chat note

                                                                String message =
                                                                    await AddNoteController().uploadFile(
                                                                        'chats',
                                                                        note.voiceNote!,
                                                                        context);

                                                                List<double>
                                                                    waveformData =
                                                                    await controller
                                                                        .extractWaveformData(
                                                                  path: note
                                                                      .voiceNote!
                                                                      .path,
                                                                  noOfSamples:
                                                                      200,
                                                                );

                                                                //  creating the chat model

                                                                ChatModel chat = ChatModel(
                                                                    waveforms:
                                                                        waveformData,
                                                                    deletedChat: [],
                                                                    name: userProvider!
                                                                        .name,
                                                                    message:
                                                                        message,
                                                                    senderId:
                                                                        userProvider
                                                                            .uid,
                                                                    chatId:
                                                                        chatId,
                                                                    postOwner:
                                                                        '',
                                                                    time: DateTime
                                                                        .now(),
                                                                    isShare:
                                                                        false,
                                                                    receiverId:
                                                                        recID,
                                                                    messageRead:
                                                                        '',
                                                                    avatarUrl:
                                                                        userProvider
                                                                            .photoUrl);

                                                                //  creating the sub model of the chat

                                                                RecentChatModel recentChatModel = RecentChatModel(
                                                                    waveforms:
                                                                        waveformData,
                                                                    deletedChat: [],
                                                                    chatId:
                                                                        chatId,
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
                                                                    seen:
                                                                        false);

                                                                // sending the message to the database

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
                                                                        waveformData,
                                                                        context)
                                                                    .then(
                                                                        (value) async {
                                                                  //   notifying the user after sending

                                                                  NotificationMethods.sendPushNotification(
                                                                      recID,
                                                                      recToken,
                                                                      '${userProvider.username} sent a voice note',
                                                                      userProvider
                                                                          .name,
                                                                      'chat',
                                                                      '',
                                                                      context);
                                                                  note.setIsLoading(
                                                                      false);

                                                                  //  removing the recorded note after  sending

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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                        note.record(context);
                                                      }
                                                    },
                                                    child: Icon(
                                                      note.isRecording
                                                          ? Icons.stop
                                                          : Icons
                                                              .mic_none_rounded,
                                                      color: blackColor,
                                                      size: 30,
                                                    ),
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 45),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      19)),
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              19)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            19),
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
