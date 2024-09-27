import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/controller/play_count_service.dart';
import 'package:social_notes/screens/home_screen/controller/share_services.dart';
import 'package:social_notes/screens/home_screen/controller/video_download_methods.dart';
import 'package:social_notes/screens/home_screen/model/book_mark_model.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
// import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
// import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/like_screen.dart';
import 'package:social_notes/screens/home_screen/view/widgets/circle_comments.dart';
import 'package:social_notes/screens/home_screen/view/widgets/comments_modal_sheet.dart';
import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
import 'package:social_notes/screens/home_screen/view/widgets/report_modal_sheet.dart';
import 'package:social_notes/screens/home_screen/view/widgets/share_post_sheet.dart';
import 'package:social_notes/screens/home_screen/view/widgets/show_tagged_users.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
import 'package:uuid/uuid.dart';
// import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
// import 'package:voice_message_package/voice_message_package.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleNotePost extends StatefulWidget {
  const SingleNotePost({
    super.key,
    required this.size,
    required this.note,
    required this.pageController,
    required this.currentIndex,
    required this.duration,
    required this.isPlaying,
    required this.audioPlayer,
    required this.changeIndex,
    required this.position,
    required this.stopMainPlayer,
    required this.isSecondHome,
    required this.playPause,
    this.postIndex,
  });

  //  getting the required data from the constructor

  final Size size;
  final NoteModel note;
  final PageController pageController;
  final int currentIndex;
  final int? postIndex;
  final bool isPlaying;
  final AudioPlayer audioPlayer;
  final Duration position;
  final int changeIndex;
  final VoidCallback playPause;
  final VoidCallback stopMainPlayer;
  final Duration duration;
  final bool isSecondHome;
  @override
  State<SingleNotePost> createState() => _SingleNotePostState();
}

class _SingleNotePostState extends State<SingleNotePost> {
  @override
  void initState() {
    //  automatically playing post for the zero index

    playPauseForIndexZero();

    super.initState();
  }

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

  playPauseForIndexZero() {
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      if (widget.pageController.page == 0) {
        widget.playPause();
      }
    });
  }

  bool isGoing = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    //  getting the current user data

    var userProvider = Provider.of<UserProvider>(context, listen: false).user;

    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          if (widget.isSecondHome)
            const SizedBox(
              height: 75,
            ),

          //  displaying the user name and profile image and verified icon realtime and selected topic of the post

          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.note.userUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel bubbleUser =
                      UserModel.fromMap(snapshot.data!.data()!);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15)
                        .copyWith(top: 30),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        // alignment: Alignment.center,
                        width: bubbleUser.name.length <= 5
                            ? widget.size.width * 0.73
                            : bubbleUser.name.length <= 7
                                ? widget.size.width * 0.77
                                : widget.size.width * 0.80,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.note.userUid !=
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    Provider.of<CircleCommentsProvider>(context,
                                            listen: false)
                                        .pausePlayer();
                                    stopMainPlayer();
                                    // audioPlayer.stop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return OtherUserProfile(
                                          userId: widget.note.userUid,
                                        );
                                      }),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(22)),
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                bubbleUser.photoUrl),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        bubbleUser.name.length > 9
                                            ? '${bubbleUser.name.substring(0, 9)}...'
                                            : bubbleUser.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      bubbleUser.isVerified
                                          ? verifiedIcon()

                                          // Image.network(
                                          //     'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                                          //     height: 20,
                                          //     width: 20,
                                          //   )
                                          : const Text('')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                left: bubbleUser.name.length <= 5
                                    ? widget.size.width * 0.30
                                    : bubbleUser.name.length <= 7
                                        ? widget.size.width * 0.34
                                        : widget.size.width * 0.38,
                                top: 4,
                                child: Container(
                                  width: widget.size.width * 0.42,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 14.5),
                                  decoration: BoxDecoration(
                                      color:
                                          Color(widget.note.topicColor.value),
                                      borderRadius: BorderRadius.circular(24)),
                                  child: Text(
                                    widget.note.topic,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: fontFamily,
                                        color: whiteColor),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Text('');
                }
              }),

          const Expanded(child: SizedBox()),

          //  showing the player  and passing the required data

          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: MainPlayer(
                lockPosts: [],
                title: '',

                // playCounts: playCounts,
                listenedWaves: widget.note.mostListenedWaves,
                postId: widget.note.noteId,
                duration: widget.duration,
                playPause: widget.playPause,
                audioPlayer: widget.audioPlayer,
                changeIndex: widget.changeIndex,
                position: widget.position,
                isPlaying: true,
                pageController: widget.pageController,
                currentIndex: widget.currentIndex,
                // postIndex: widget.postIndex ?? 0,
                isMainPlayer: true,
                noteUrl: widget.note.noteUrl,
                height: 40,
                width: 170,
                mainWidth: 300,
                mainHeight: 85),
          ),

          // showing the title of the post and date of the post

          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.note.title.isNotEmpty
                        ? ' ${widget.note.title.toUpperCase()} - '
                        : '',
                    // widget.note.title.toLowerCase(),
                    style: TextStyle(
                        fontFamily: fontFamily,
                        color: whiteColor,
                        fontSize: 11),
                  ),
                  Text(
                    timeago.format(widget.note.publishedDate).toUpperCase(),
                    style: TextStyle(
                        color: whiteColor,
                        fontFamily: fontFamily,
                        fontSize: 11),
                  ),
                  // Text(
                  //   ' |  ',
                  //   style: TextStyle(color: whiteColor, fontSize: 11),
                  // ),
                  // Icon(
                  //   Icons.play_arrow,
                  //   size: 10,
                  //   color: whiteColor,

                  // ),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),

          // showing post icons

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5)
                .copyWith(top: 6, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  like icon with the  logic of liking the post

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                      onTap: () {
                        String notiId = const Uuid().v4();

                        //  liking the post and sending notification to the post owner

                        CommentNotoficationModel commentNotoficationModel =
                            CommentNotoficationModel(
                                time: DateTime.now(),
                                postBackground: widget.note.backgroundImage,
                                postThumbnail: widget.note.videoThumbnail,
                                postType: widget.note.backgroundType,
                                noteUrl: widget.note.noteUrl,
                                notificationId: notiId,
                                notification: widget.note.noteUrl,
                                currentUserId: userProvider!.uid,
                                notificationType: 'like',
                                isRead: '',
                                toId: widget.note.userUid);
                        Provider.of<DisplayNotesProvider>(context,
                                listen: false)
                            .likePost(
                                widget.note.likes,
                                widget.note.noteId,
                                commentNotoficationModel,
                                widget.note.userToken,
                                userProvider.name,
                                widget.note.userUid,
                                userProvider.uid);
                      },

                      //  changing the value of the like realtime

                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('notes')
                              .doc(widget.note.noteId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              NoteModel likeNote =
                                  NoteModel.fromMap(snapshot.data!.data()!);
                              if (likeNote.likes.contains(
                                  FirebaseAuth.instance.currentUser!.uid)) {
                                return SvgPicture.asset(
                                  'assets/icons/Like Active.svg',
                                  height: 28,
                                  width: 35,
                                  // fit: BoxFit.cover,
                                );
                              } else {
                                return SvgPicture.asset(
                                  'assets/icons/Like inactive.svg',
                                  height: 28,
                                  width: 35,

                                  // fit: BoxFit.cover,
                                );
                              }
                            } else {
                              return const Text('');
                            }
                          })),
                ),

                //  sharing post icon

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () async {
                      //  share post to the chat

                      await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SharePostSheet(
                              note: widget.note,
                            );
                          });
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Subtract.svg',
                      height: 25,
                      color: whiteColor,
                      width: 25,
                      // color: _page == 3 ? primaryColor : null,
                      fit: BoxFit.cover,
                    ),
                    // Image.asset(
                    //   'assets/images/send_message.png',
                    //   height: 25,
                    //   width: 25,
                    // ),
                  ),
                ),

                //  saving post icon

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                      onTap: () {
                        // saving post with the shared prefs

                        String bookMarkId = const Uuid().v4();
                        BookmarkModel bookmarkModel = BookmarkModel(
                            bookmarkId: bookMarkId,
                            postId: widget.note.noteId,
                            userId: FirebaseAuth.instance.currentUser!.uid);
                        Provider.of<DisplayNotesProvider>(context,
                                listen: false)
                            .addPostToSaved(bookmarkModel, context);
                      },

                      //  changing the value of saved posts realtime

                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('bookmarks')
                            .where('userId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var bookmarks = snapshot.data!.docs;
                            var found = false;
                            for (var doc in bookmarks) {
                              BookmarkModel bookmark =
                                  BookmarkModel.fromMap(doc.data());
                              if (bookmark.postId == widget.note.noteId) {
                                found = true;
                                break;
                              }
                            }
                            if (found) {
                              return SvgPicture.asset(
                                'assets/icons/Bookmark active.svg',
                                height: 32,
                                width: 35,
                              );
                            } else {
                              return SvgPicture.asset(
                                'assets/icons/Bookmark inactive.svg',
                                height: 32,
                                width: 35,
                              );
                            }
                          } else {
                            return const Text('');
                          }
                        },
                      )),
                ),

                //  tag people icon only show when the certain conditions met

                if (widget.note.tagPeople.isNotEmpty)
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              backgroundColor: whiteColor,
                              elevation: 0,
                              content: ShowTaggedUsers(noteModel: widget.note));
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SvgPicture.asset(
                        'assets/icons/User_box.svg',
                        height: 30,
                        width: 25,
                      ),
                    ),
                  ),

                // showing different options  based on users needs

                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            actionsPadding: const EdgeInsets.all(0),
                            contentPadding: const EdgeInsets.all(4),
                            backgroundColor: whiteColor,
                            elevation: 0,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //  download post option

                                Consumer<DisplayNotesProvider>(
                                    builder: (context, displayPro, _) {
                                  return InkWell(
                                    onTap: displayPro.isLoading
                                        ? null
                                        : () async {
                                            var pro = Provider.of<
                                                    DisplayNotesProvider>(
                                                context,
                                                listen: false);
                                            pro.setIsloading(true);
                                            DocumentSnapshot<
                                                    Map<String, dynamic>>
                                                snapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.note.userUid)
                                                    .get();
                                            UserModel verifiedUSer =
                                                UserModel.fromMap(
                                                    snapshot.data()!);
                                            await VideoDownloadMethods()
                                                .downloadPostWithLogo(
                                                    hasBackgroundPhoto: widget
                                                            .note.backgroundType
                                                            .contains('photo')
                                                        ? true
                                                        : false,
                                                    hasBackgroundVideo: widget
                                                            .note.backgroundType
                                                            .contains('video')
                                                        ? true
                                                        : false,
                                                    backgroundPhotoUrl: widget.note.backgroundType.contains('photo') &&
                                                            widget
                                                                .note
                                                                .backgroundImage
                                                                .isNotEmpty
                                                        ? widget.note
                                                            .backgroundImage
                                                        : null,
                                                    backgroundVideoUrl: widget
                                                                .note
                                                                .backgroundType
                                                                .contains('video') &&
                                                            widget.note.backgroundImage.isNotEmpty
                                                        ? widget.note.backgroundImage
                                                        : null,
                                                    logo2AssetPath: 'assets/icons/logo 3.png',
                                                    username: widget.note.username,
                                                    videoUrl: widget.note.backgroundImage,
                                                    audioUrl: widget.note.noteUrl,
                                                    logoVideoPath:
                                                        // 'assets/icons/transparent-gif.mp4',
                                                        'assets/icons/gifvideo.mp4',
                                                    isVerified: verifiedUSer.isVerified,
                                                    outputFileName: 'voisbe/videos');
                                            // if (context.mounted)
                                            //   ScaffoldMessenger.of(context)
                                            //       .hideCurrentSnackBar();
                                            pro.setIsloading(false);
                                            // navPop(context);
                                          },
                                    child: displayPro.isLoading
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8,
                                                left: 10,
                                                right: 10,
                                                top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Post is downloading',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: khulaRegular,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SpinKitThreeBounce(
                                                  size: 13,
                                                  color: blackColor,
                                                ),
                                              ],
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8,
                                                left: 10,
                                                right: 10,
                                                top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Download post',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: khulaRegular,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const Icon(Icons
                                                    .arrow_forward_ios_outlined)
                                              ],
                                            ),
                                          ),
                                  );
                                }),

                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 1,
                                  color: const Color(0xffEAEAEA),
                                ),

                                //  option to remove itself from the tag

                                if (widget.note.tagPeople
                                    .contains(userProvider!.uid))
                                  InkWell(
                                    onTap: () async {
                                      navPop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          actionsPadding:
                                              const EdgeInsets.all(0),
                                          contentPadding:
                                              const EdgeInsets.all(4),
                                          backgroundColor: whiteColor,
                                          elevation: 0,
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                child: SvgPicture.asset(
                                                  'assets/icons/close_ring-1.svg',
                                                  height: 30,
                                                  width: 30,
                                                  color: blackColor,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: Text(
                                                  'Tag Removed',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: khulaBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: blackColor),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: Text(
                                                  'Your tag was removed from this post.',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: khulaRegular,
                                                      fontSize: 12,
                                                      color: Color(0xff6C6C6C)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                      Provider.of<DisplayNotesProvider>(context,
                                              listen: false)
                                          .updateTag(
                                              widget.note.noteId,
                                              userProvider!.uid,
                                              widget.currentIndex);
                                      await FirebaseFirestore.instance
                                          .collection('notes')
                                          .doc(widget.note.noteId)
                                          .update({
                                        'tagPeople': FieldValue.arrayRemove(
                                            [userProvider.uid])
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8,
                                          left: 10,
                                          right: 10,
                                          top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Remove me from post',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: khulaRegular,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(
                                              Icons.arrow_forward_ios_outlined)
                                        ],
                                      ),
                                    ),
                                  ),

                                if (widget.note.tagPeople
                                    .contains(userProvider!.uid))
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: const Color(0xffEAEAEA),
                                  ),

                                //  report the post option if the user is not the post owner

                                if (widget.note.userUid != userProvider!.uid)
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          showDragHandle: true,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          constraints: BoxConstraints(
                                              minHeight: size.height * 0.95,
                                              maxHeight: size.height * 0.95),
                                          backgroundColor: whiteColor,
                                          elevation: 0,
                                          context: context,
                                          builder: (context) =>
                                              ReportModalSheet(
                                                note: widget.note,
                                              ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8,
                                          left: 10,
                                          right: 10,
                                          top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Report Post',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: khulaRegular,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(
                                              Icons.arrow_forward_ios_outlined)
                                        ],
                                      ),
                                    ),
                                  ),
                                if (widget.note.userUid != userProvider.uid)
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: const Color(0xffEAEAEA),
                                  ),
                                // Divider(
                                //   endIndent: 0,
                                //   indent: 0,
                                //   height: 1,
                                //   color: Colors.black.withOpacity(0.1),
                                // ),

                                //  delete the post option for the post owner

                                if (widget.note.userUid == userProvider.uid)
                                  InkWell(
                                    onTap: () async {
                                      Provider.of<DisplayNotesProvider>(context,
                                              listen: false)
                                          .removeNote(widget.note);
                                      Provider.of<UserProfileProvider>(context,
                                              listen: false)
                                          .deletePost(widget.note.noteId);
                                      navPop(context);
                                      showWhiteOverlayPopup(
                                          context, Icons.check_box, null, null,
                                          title: 'Successful',
                                          message: 'Post was deleted!',
                                          isUsernameRes: false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8,
                                          left: 10,
                                          right: 10,
                                          top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Delete post',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: khulaRegular,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(
                                              Icons.arrow_forward_ios_outlined)
                                        ],
                                      ),
                                    ),
                                  ),

                                if (widget.note.userUid == userProvider.uid)
                                  Divider(
                                    endIndent: 0,
                                    indent: 0,
                                    height: 1,
                                    color: Colors.black.withOpacity(0.1),
                                  ),

                                //  copy the link of the post to share somewhere

                                InkWell(
                                  onTap: () async {
                                    await DeepLinkPostService()
                                        .createReferLink(widget.note)
                                        .then((value) async {
                                      await Clipboard.setData(
                                              ClipboardData(text: value))
                                          .then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                backgroundColor: Colors.white,
                                                content: Text(
                                                  'Link was copied to clipboard!',
                                                  style: TextStyle(
                                                      fontFamily: khulaRegular,
                                                      color: blackColor),
                                                )));

                                        navPop(context);
                                      });
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8,
                                        left: 10,
                                        right: 10,
                                        top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Copy link to post',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: khulaRegular,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios_outlined)
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  endIndent: 0,
                                  indent: 0,
                                  height: 1,
                                  color: Colors.black.withOpacity(0.1),
                                ),

                                //  share the post to different social media platforms

                                InkWell(
                                  onTap: () async {
                                    await DeepLinkPostService()
                                        .createReferLink(widget.note)
                                        .then((value) {
                                      Share.share(value);
                                      navPop(context);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8,
                                        left: 10,
                                        right: 10,
                                        top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Share to... ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: khulaRegular,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios_outlined)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: whiteColor,
                    ))
              ],
            ),
          ),

          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20)
                .copyWith(top: 10, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // showing the number of the likes realtime

                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('notes')
                        .doc(widget.note.noteId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        NoteModel likes =
                            NoteModel.fromMap(snapshot.data!.data()!);
                        return InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LikeScreen(
                                    likes: widget.note.likes,
                                    postOwner: widget.note.userUid,
                                  ),
                                ));
                          },
                          child: Text(
                            likes.likes.isNotEmpty
                                ? '${likes.likes.length} likes'
                                : 'No likes',
                            style: TextStyle(
                                fontFamily: fontFamily,
                                color: whiteColor,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      } else {
                        return const Text('');
                      }
                    }),

                //  displaying the modal sheet of all replies

                GestureDetector(
                  onTap: () async {
                    stopMainPlayer();
                    Provider.of<CircleCommentsProvider>(context, listen: false)
                        .pausePlayer();

                    await showModalBottomSheet(
                        useSafeArea: true,
                        enableDrag: true,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                            // maxWidth: MediaQuery.of(context).size.width * 0.8,
                            // minWidth: MediaQuery.of(context).size.width * 0.8,
                            minHeight: MediaQuery.of(context).size.height * 0.7,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        context: context,
                        builder: (context) => CommentModalSheet(
                              postId: widget.note.noteId,
                              userId: widget.note.userUid,
                              noteData: widget.note,
                            ));
                  },
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('notes')
                          .doc(widget.note.noteId)
                          .collection('comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!.docs.isNotEmpty
                                ? 'View all ${snapshot.data!.docs.length} replies'
                                : 'No replies',
                            style: TextStyle(
                                fontFamily: fontFamily,
                                color: whiteColor,
                                fontWeight: FontWeight.w600),
                          );
                        } else {
                          return const Text('');
                        }
                      }),
                )
              ],
            ),
          ),

          //  all the circle replies

          CircleComments(
            pagController: widget.pageController,
            changeIndex: widget.changeIndex,
            currentIndex: widget.currentIndex,
            stopMainPlayer: widget.stopMainPlayer,
            mainAudioPlayer: widget.audioPlayer,
            // isGoing: isGoing,

            noteModel: widget.note,

            // commentsLength: snapshot.data!.docs.length,
          ),

          const SizedBox(
            height: 10,
          ),

          // Row(
          //   children: [
          //     Container(decoration: Boxde,)
          //   ],
          // )
        ],
      ),
    );
  }
}
