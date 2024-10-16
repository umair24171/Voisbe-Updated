import 'dart:io';

// import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/controller/audio_handler.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/model/feed_detail_model.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/search_screen/view/widgets/search_player.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
import 'package:uuid/uuid.dart';

import 'package:audio_waveforms/audio_waveforms.dart' as audo;

class FeedDetailScreen extends StatefulWidget {
  const FeedDetailScreen({super.key, required this.feedModel});
  final FeedDetailModel feedModel;

  // getting data from the constructor

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  // AudioPlayer _audioPlayer = AudioPlayer();
  // PageController _pageController = PageController();
  // int currentIndex = 0;
  // bool _isPlaying = false;
  // AudioPlayer player = AudioPlayer();
  // Duration position = Duration.zero;
  // int _currentIndex = 0;
  late final audo.RecorderController recorderController;

  // Duration duration = Duration.zero;
  // bool _isScrolling = false;
  String? path;
  late Directory directory;

  @override
  void initState() {
    // initializing the audio player

    // _audioPlayer = AudioPlayer();

    //  initializing controllers for the real time wave generation
    _initialiseController();
    super.initState();
  }

  void _initialiseController() {
    recorderController = audo.RecorderController()
      ..androidEncoder = audo.AndroidEncoder.aac
      ..androidOutputFormat = audo.AndroidOutputFormat.mpeg4
      ..iosEncoder = audo.IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }
  // sandbox password x&Q>D9M_"c;H`@bC

  @override
  Widget build(BuildContext context) {
    // getting the current user
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var provider = Provider.of<NoteProvider>(context);
    var size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        provider.cancelReply();
        provider.setIsSending(false);
        provider.setRecording(false);
        provider.stop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          //getting the name of the user realtime

          title: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.feedModel.note.userUid)
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
                          ));
                    },

                    // getting user pic

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          user.name,
                          style: TextStyle(
                              fontFamily: fontFamily,
                              color: whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),

                        // checking user verified or not

                        if (user.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: SvgPicture.asset(
                              verifiedPath,
                              fit: BoxFit.cover,
                              // color: Colors.blue,
                              height: 13,
                              width: 13,
                            ),
                          )
                      ],
                    ),
                  );
                } else {
                  return const Text('');
                }
              }),

          automaticallyImplyLeading: false,
          // shadowColor: Colors.transparent,
          toolbarOpacity: 0,
          // foregroundColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            // show UI icon and logic

            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                  onTap: () {
                    navPop(context);
                  },
                  child: Stack(children: [
                    SvgPicture.asset(
                      'assets/icons/mobile (1).svg',
                      height: 30,
                      width: 35,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: SvgPicture.asset(
                        'assets/icons/Add_round.svg',
                        height: 10,
                        width: 10,
                        // color: _page == 3 ? primaryColor : null,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ])),
            ),
          ],
        ),
        backgroundColor: widget.feedModel.note.backgroundImage.isNotEmpty
            ? Colors.transparent
            : null,
        body: Consumer<FilterProvider>(builder: (context, filterPro, _) {
          return Container(
            height: MediaQuery.of(context).size.height,
            // color: Colors.transparent,
            child: Stack(
              children: [
                if (widget.feedModel.note.backgroundImage.isEmpty)

                  // static background if no image or video found

                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [
                          0.25,
                          0.75,
                        ],
                            colors: [
                          Color(0xffee856d),
                          Color(0xffed6a5a)
                        ])),
                  ),

                // background if it contains video or photo

                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: widget.feedModel.note.backgroundType.contains('photo')
                      ? CachedNetworkImage(
                          imageUrl: widget.feedModel.note.backgroundImage,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          repeat: ImageRepeat.noRepeat,
                        )
                      : SearchPlayer(
                          videoUrl: widget.feedModel.note.backgroundImage,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(''),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // showing the player to play the post voice

                          Consumer<DisplayNotesProvider>(
                              builder: (context, displayPro, _) {
                            return MainPlayer(
                                // audioHandler: AudioPlayerHandler(),
                                waveforms:
                                    widget.feedModel.note.waveforms ?? [],
                                lockPosts: [],
                                title: '',
                                // playCounts: playCounts,
                                listenedWaves:
                                    widget.feedModel.note.mostListenedWaves,
                                postId: widget.feedModel.note.noteId,
                                duration: displayPro.duration,
                                playPause: widget.feedModel.playPause,
                                audioPlayer: displayPro.audioPlayer,
                                changeIndex: displayPro.changeIndex,
                                position: displayPro.position,
                                isPlaying: displayPro.isPlaying,
                                pageController: widget.feedModel.pageController,
                                currentIndex: displayPro.changeIndex,
                                // postIndex: widget.postIndex ?? 0,
                                isMainPlayer: true,
                                noteUrl: widget.feedModel.note.noteUrl,
                                height: 40,
                                width: size.width * 0.3,
                                mainWidth: size.width * 0.65,
                                mainHeight: size.height * 0.12);
                          }),

                          // sending reply widget and logics like main feed

                          Consumer<NoteProvider>(
                            builder: (context, noteProvider, child) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 15),
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
                                    // widget.stopMainPlayer();

                                    Provider.of<DisplayNotesProvider>(context,
                                            listen: false)
                                        .pausePlayer();
                                    Provider.of<DisplayNotesProvider>(context,
                                            listen: false)
                                        .setChangeIndex(-1);
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
                                        postId: widget.feedModel.note.noteId,
                                        likes: [],
                                        playedComment: 0,
                                        userImage: userProvider.photoUrl,
                                      );
                                      var commentProvider =
                                          Provider.of<DisplayNotesProvider>(
                                              context,
                                              listen: false);

                                      commentProvider
                                          .addComment(
                                              widget.feedModel.note.noteId,
                                              commentId,
                                              commentModel,
                                              context)
                                          .then((value) async {
                                        String notificationId =
                                            const Uuid().v4();
                                        noteProvider.removeVoiceNote();
                                        noteProvider.setIsSending(false);
                                        Provider.of<NoteProvider>(context,
                                                listen: false)
                                            .setIsLoading(false);
                                        DocumentSnapshot<Map<String, dynamic>>
                                            userModel = await FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(widget
                                                    .feedModel.note.userUid)
                                                .get();

                                        UserModel toNotiUser =
                                            UserModel.fromMap(
                                                userModel.data()!);

                                        if (toNotiUser.isReply &&
                                            userProvider.uid !=
                                                widget.feedModel.note.userUid) {
                                          NotificationMethods
                                              .sendPushNotification(
                                                  widget.feedModel.note.userUid,
                                                  widget
                                                      .feedModel.note.userToken,
                                                  'replied',
                                                  userProvider.name,
                                                  'notification',
                                                  '',
                                                  context);

                                          CommentNotoficationModel noti =
                                              CommentNotoficationModel(
                                                  time: DateTime.now(),
                                                  postBackground:
                                                      widget.feedModel.note
                                                          .backgroundImage,
                                                  postThumbnail: widget
                                                      .feedModel
                                                      .note
                                                      .videoThumbnail,
                                                  postType: widget.feedModel
                                                      .note.backgroundType,
                                                  noteUrl: widget
                                                      .feedModel.note.noteUrl,
                                                  isRead: '',
                                                  notificationId:
                                                      notificationId,
                                                  notification: comment,
                                                  currentUserId:
                                                      userProvider.uid,
                                                  notificationType: 'comment',
                                                  toId: widget
                                                      .feedModel.note.userUid);
                                          Provider.of<NotificationProvider>(
                                                  context,
                                                  listen: false)
                                              .addCommentNotification(noti);
                                        }
                                      });
                                    } else {
                                      directory =
                                          await getApplicationDocumentsDirectory();
                                      path = "${directory.path}/test_audio.aac";
                                      await recorderController.record(
                                          path: path);
                                      // update state here to, for eample, change the button's state
                                      noteProvider.record(context);
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
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: noteProvider.isLoading
                                            ? SizedBox(
                                                height: 35,
                                                width: 35,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: primaryColor,
                                                ),
                                              )
                                            : noteProvider.isCancellingReply
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                                              waveCap: StrokeCap
                                                                  .butt,
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
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
