import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
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

class UiHideScreen extends StatefulWidget {
  const UiHideScreen({super.key, required this.feedModel});
  final NoteModel feedModel;

  @override
  State<UiHideScreen> createState() => _UiHideScreenState();
}

class _UiHideScreenState extends State<UiHideScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isPlaying = false;
  AudioPlayer player = AudioPlayer();
  Duration position = Duration.zero;
  int _currentIndex = 0;
  late final audo.RecorderController recorderController;

  Duration duration = Duration.zero;
  bool _isScrolling = false;
  String? path;
  late Directory directory;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
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

  void playPause(String url, int index) async {
    // Check if the file is already cached
    final cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);

    if (fileInfo == null) {
      // File is not cached, download and cache it
      try {
        fileInfo = await cacheManager.downloadFile(url, key: url);
      } catch (e) {
        print('Error downloading file: $e');
        return;
      }
    }

    // Use the cached file for playback
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
      await _audioPlayer
          .play( 
            Platform.isAndroid ? UrlSource(fileInfo.file.path) :
        UrlSource(url),
      )
          .then((value) async {
        setState(() {
          _currentIndex = index;
          _isPlaying = true;
        });
        duration = (await _audioPlayer.getDuration())!;
        setState(() {});
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
        _currentIndex = -1;
        position = Duration.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.feedModel.userUid)
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(user.photoUrl),
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
                      // Image.network(
                      //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                      //   height: 20,
                      //   width: 20,
                      // ),
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
      backgroundColor: widget.feedModel.backgroundImage.isNotEmpty
          ? Colors.transparent
          : null,
      body: Consumer<FilterProvider>(builder: (context, filterPro, _) {
        return Container(
          height: MediaQuery.of(context).size.height,
          // color: Colors.transparent,
          child: Stack(
            children: [
              if (widget.feedModel.backgroundImage.isEmpty)
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
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: widget.feedModel.backgroundType.contains('photo')
                    ? Image.network(
                        widget.feedModel.backgroundImage,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        repeat: ImageRepeat.noRepeat,
                      )
                    : SearchPlayer(
                        videoUrl: widget.feedModel.backgroundImage,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(''),
                  // Padding(
                  //   padding:
                  //       EdgeInsets.only(top: size.height * 0.16, right: 40),
                  //   child: Align(
                  //     alignment: Alignment.topRight,
                  //     child:
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Consumer<DisplayNotesProvider>(
                        //     builder: (context, displayPro, _) {
                        //   return MainPlayer(
                        //       // playCounts: playCounts,
                        //       listenedWaves:
                        //           widget.feedModel.mostListenedWaves,
                        //       postId: widget.feedModel.noteId,
                        //       duration: displayPro.duration,
                        //       playPause: () {
                        //         displayPro.playPause(
                        //             widget.feedModel.noteUrl,
                        //             widget.feedModelentIndex);
                        //       },
                        //       audioPlayer: displayPro.audioPlayer,
                        //       changeIndex: widget.feedModelgeIndex,
                        //       position: displayPro.position,
                        //       isPlaying: displayPro.isPlaying,
                        //       pageController: widget.feedModelController,
                        //       currentIndex: widget.feedModelentIndex,
                        //       // postIndex: widget.postIndex ?? 0,
                        //       isMainPlayer: true,
                        //       noteUrl: widget.feedModel.noteUrl,
                        //       height: 40,
                        //       width: size.width * 0.3,
                        //       mainWidth: size.width * 0.65,
                        //       mainHeight: size.height * 0.12);
                        // }),
                        CustomProgressPlayer(
                            postId: widget.feedModel.noteId,
                            lockPosts: [],
                            stopMainPlayer: () {},
                            currentIndex: _currentIndex,
                            isFeedDetail: true,
                            // postIndex: widget.postIndex ?? 0,
                            backgroundColor: whiteColor,
                            isMainPlayer: true,
                            noteUrl: widget.feedModel.noteUrl,
                            height: 40,
                            width: size.width * 0.3,
                            mainWidth: size.width * 0.65,
                            mainHeight: size.height * 0.12),
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
                                    noteProvider.stop( );
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
                                      postId: filterPro.detailsNote!.noteId,
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
                                            filterPro.detailsNote!.noteId,
                                            commentId,
                                            commentModel,
                                            context)
                                        .then((value) async {
                                      String notificationId = const Uuid().v4();
                                      noteProvider.removeVoiceNote();
                                      noteProvider.setIsSending(false);
                                      Provider.of<NoteProvider>(context,
                                              listen: false)
                                          .setIsLoading(false);
                                      DocumentSnapshot<Map<String, dynamic>>
                                          userModel = await FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(filterPro
                                                  .detailsNote!.userUid)
                                              .get();

                                      UserModel toNotiUser =
                                          UserModel.fromMap(userModel.data()!);

                                      if (toNotiUser.isReply &&
                                          userProvider.uid !=
                                              filterPro.detailsNote!.userUid) {
                                        NotificationMethods
                                            .sendPushNotification(
                                                filterPro.detailsNote!.userUid,
                                                filterPro
                                                    .detailsNote!.userToken,
                                                'replied',
                                                userProvider.username,
                                                'notification',
                                                '');

                                        CommentNotoficationModel noti =
                                            CommentNotoficationModel(
                                                time: DateTime.now(),
                                                postBackground: widget
                                                    .feedModel.backgroundImage,
                                                postThumbnail: widget
                                                    .feedModel.videoThumbnail,
                                                postType: widget
                                                    .feedModel.backgroundType,
                                                noteUrl: filterPro
                                                    .detailsNote!.noteUrl,
                                                isRead: '',
                                                notificationId: notificationId,
                                                notification: comment,
                                                currentUserId: userProvider.uid,
                                                notificationType: 'comment',
                                                toId: filterPro
                                                    .detailsNote!.userUid);
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
                                    await recorderController.record(path: path);
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
    );
  }
}
