// // import 'dart:async';
// // import 'dart:developer';
// import 'dart:ui';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/navigation.dart';
// import 'package:social_notes/resources/white_overlay_popup.dart';
// // import 'package:social_notes/resources/show_snack.dart';
// import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
// import 'package:social_notes/screens/auth_screens/model/user_model.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/home_screen/controller/share_services.dart';
// import 'package:social_notes/screens/home_screen/model/book_mark_model.dart';
// import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
// import 'package:social_notes/screens/home_screen/model/feed_detail_model.dart';
// // import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
// // import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
// import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
// import 'package:social_notes/screens/home_screen/view/feed_detail_screen.dart';
// import 'package:social_notes/screens/home_screen/view/like_screen.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/circle_comments.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/comments_modal_sheet.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/main_player.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/report_modal_sheet.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/share_post_sheet.dart';
// import 'package:social_notes/screens/home_screen/view/widgets/show_tagged_users.dart';
// import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
// import 'package:social_notes/screens/user_profile/other_user_profile.dart';
// import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// // import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// import 'package:uuid/uuid.dart';
// // import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
// // import 'package:social_notes/screens/home_screen/view/widgets/voice_message.dart';
// // import 'package:voice_message_package/voice_message_package.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NoteDetailsScreen extends StatefulWidget {
//   const NoteDetailsScreen({
//     super.key,
//     // required this.size,
//     required this.note,
//     // required this.pageController,
//     required this.currentIndex,
//     // required this.duration,
//     // required this.isPlaying,
//     // required this.audioPlayer,
//     // required this.changeIndex,
//     // required this.position,
//     // required this.stopMainPlayer,
//     // required this.playPause,
//     // this.postIndex,
//   });

//   // final Size size;
//   final NoteModel note;
//   // final PageController pageController;
//   final int currentIndex;
//   // final int? postIndex;
//   // final bool isPlaying;
//   // final AudioPlayer audioPlayer;
//   // final Duration position;
//   // final int changeIndex;
//   // final VoidCallback playPause;
//   // final VoidCallback stopMainPlayer;
//   // final Duration duration;
//   @override
//   State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
// }

// class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
//   late AudioPlayer mainAudioPlayer;
//   late PageController pageController;
//   @override
//   void initState() {
//     // playPauseForIndexZero();
//     pageController = PageController();
//     mainAudioPlayer = AudioPlayer();
//     super.initState();
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     // var commentProvider =
//     //     Provider.of<DisplayNotesProvider>(context, listen: false).allComments;
//     var userProvider = Provider.of<UserProvider>(context, listen: false).user;
//     return Scaffold(
//       extendBody: true,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           InkWell(
//             onTap: () {
//               // int page = _pageController.page!.round();
//               // log('currentPage ${_pageController.page!.round()}');
//               Navigator.push(context, MaterialPageRoute(
//                 builder: (context) {
//                   FeedDetailModel feedDetailModel = FeedDetailModel(
//                       note: widget.note,
//                       duration: Duration(seconds: 0),
//                       position: Duration.zero,
//                       playPause: () {
//                         // displayPro.playPause(
//                         //    widget.note.noteUrl,
//                         //     0);
//                       },
//                       audioPlayer: mainAudioPlayer,
//                       changeIndex: 0,
//                       isPlaying: true,
//                       pageController: pageController,
//                       currentIndex: 0,
//                       isMainPlayer: true);

//                   return FeedDetailScreen(
//                     feedModel: feedDetailModel,
//                   );
//                 },
//               ));
//             },
//             child: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14)
//                       .copyWith(left: 2),
//                   child: SvgPicture.asset(
//                     'assets/icons/mobile.svg',
//                     height: 28,
//                     width: 28,
//                     // color: _page == 3 ? primaryColor : null,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned(
//                   left: 11,
//                   top: 9.5,
//                   child: SvgPicture.asset(
//                     'assets/icons/minus.svg',
//                     height: 10,
//                     width: 10,
//                     // color: _page == 3 ? primaryColor : null,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         child: Stack(
//           children: [
//             widget.note.backgroundImage.isNotEmpty
//                 ? Stack(
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height,
//                         child: widget.note.backgroundType.contains('video')
//                             ? CustomVideoPlayer(
//                                 videoUrl: widget.note.backgroundImage,
//                                 height: MediaQuery.of(context).size.height,
//                                 width: MediaQuery.of(context).size.width)
//                             : CachedNetworkImage(
//                                 imageUrl: widget.note.backgroundImage,
//                                 fit: BoxFit.cover,
//                               ),
//                       ),
//                       BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                         child: Container(
//                           color: Colors.white
//                               .withOpacity(0.1), // Transparent color
//                         ),
//                       ),
//                       Container(
//                         height: size.height,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             // stops: [],
//                             colors: [
//                               Colors.transparent,
//                               const Color(0xff3d3d3d).withOpacity(0.5),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Container(
//                     height: MediaQuery.of(context).size.height,
//                     decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             stops: [
//                           0.25,
//                           0.75,
//                         ],
//                             colors: [
//                           Color(0xffee856d),
//                           Color(0xffed6a5a)
//                         ])),
//                   ),
//             Column(
//               // crossAxisAlignment: CrossAxisAlignment.center,

//               children: [
//                 const SizedBox(
//                   height: 50,
//                 ),
//                 StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(widget.note.userUid)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         UserModel bubbleUser =
//                             UserModel.fromMap(snapshot.data!.data()!);
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 15)
//                               .copyWith(top: 30),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: SizedBox(
//                               // alignment: Alignment.center,

//                               width: bubbleUser.name.length <= 5
//                                   ? size.width * 0.73
//                                   : bubbleUser.name.length <= 7
//                                       ? size.width * 0.77
//                                       : size.width * 0.81,
//                               child: Stack(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 4, horizontal: 8),
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         if (widget.note.userUid !=
//                                             FirebaseAuth
//                                                 .instance.currentUser!.uid) {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) {
//                                               return OtherUserProfile(
//                                                 userId: widget.note.userUid,
//                                               );
//                                             }),
//                                           );
//                                         }
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                             color: whiteColor,
//                                             borderRadius:
//                                                 BorderRadius.circular(22)),
//                                         padding: const EdgeInsets.all(8),
//                                         child: Row(
//                                           children: [
//                                             CircleAvatar(
//                                               radius: 15,
//                                               backgroundImage: NetworkImage(
//                                                   bubbleUser.photoUrl),
//                                             ),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             Text(
//                                               bubbleUser.name.length > 9
//                                                   ? '${bubbleUser.name.substring(0, 9)}...'
//                                                   : bubbleUser.name,
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                   fontFamily: fontFamily,
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                             bubbleUser.isVerified
//                                                 ? Image.network(
//                                                     'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
//                                                     height: 20,
//                                                     width: 20,
//                                                   )
//                                                 : const Text('')
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                       left: bubbleUser.name.length <= 5
//                                           ? size.width * 0.30
//                                           : bubbleUser.name.length <= 7
//                                               ? size.width * 0.34
//                                               : size.width * 0.38,
//                                       top: 4,
//                                       child: Container(
//                                         width: size.width * 0.42,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 0, vertical: 15),
//                                         decoration: BoxDecoration(
//                                             color: Color(
//                                                 widget.note.topicColor.value),
//                                             borderRadius:
//                                                 BorderRadius.circular(24)),
//                                         child: Text(
//                                           widget.note.topic,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               overflow: TextOverflow.ellipsis,
//                                               fontWeight: FontWeight.w600,
//                                               fontFamily: fontFamily,
//                                               color: whiteColor),
//                                         ),
//                                       ))
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         return const Text('');
//                       }
//                     }),

//                 const Expanded(child: SizedBox()),
//                 Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: CustomProgressPlayer(
//                         lockPosts: [],
//                         postId: widget.note.noteId,
//                         stopMainPlayer: () {},
//                         noteUrl: widget.note.noteUrl,
//                         isMainPlayer: true,
//                         height: 40,
//                         width: 170,
//                         mainWidth: 300,
//                         mainHeight: 85)
//                     // MainPlayer(
//                     //     duration: widget.duration,
//                     //     playPause: widget.playPause,
//                     //     audioPlayer: widget.audioPlayer,
//                     //     changeIndex: widget.changeIndex,
//                     //     position: widget.position,
//                     //     isPlaying: true,
//                     //     pageController: widget.pageController,
//                     //     currentIndex: widget.currentIndex,
//                     //     // postIndex: widget.postIndex ?? 0,
//                     //     isMainPlayer: true,
//                     //     noteUrl: widget.note.noteUrl,
//                     //     height: 40,
//                     //     width: 170,
//                     //     mainWidth: 300,
//                     //     mainHeight: 85),
//                     ),
//                 Align(
//                   alignment: Alignment.center,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.note.title.isNotEmpty
//                             ? ' ${widget.note.title.toUpperCase()} - '
//                             : '',
//                         style: TextStyle(
//                             fontFamily: fontFamily,
//                             color: whiteColor,
//                             fontSize: 11),
//                       ),
//                       Text(
//                         timeago.format(widget.note.publishedDate).toUpperCase(),
//                         style: TextStyle(
//                             color: whiteColor,
//                             fontFamily: fontFamily,
//                             fontSize: 11),
//                       ),
//                       // Text(
//                       //   ' |  ',
//                       //   style: TextStyle(color: whiteColor, fontSize: 11),
//                       // ),
//                       // Icon(
//                       //   Icons.play_arrow,
//                       //   size: 10,
//                       //   color: whiteColor,

//                       // ),
//                       // Text(
//                       //   ' ${note.title}',
//                       //   style: TextStyle(
//                       //       fontFamily: fontFamily, color: whiteColor, fontSize: 11),
//                       // )
//                     ],
//                   ),
//                 ),
//                 const Expanded(child: SizedBox()),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5)
//                       .copyWith(top: 6, bottom: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: GestureDetector(
//                             onTap: () {
//                               String notiId = const Uuid().v4();

//                               CommentNotoficationModel
//                                   commentNotoficationModel =
//                                   CommentNotoficationModel(
//                                       postBackground:
//                                           widget.note.backgroundImage,
//                                       postThumbnail: widget.note.videoThumbnail,
//                                       postType: widget.note.backgroundType,
//                                       noteUrl: widget.note.noteUrl,
//                                       notificationId: notiId,
//                                       notification: 'liked your post',
//                                       currentUserId: userProvider!.uid,
//                                       notificationType: 'like',
//                                       isRead: '',
//                                       toId: widget.note.userUid);
//                               Provider.of<DisplayNotesProvider>(context,
//                                       listen: false)
//                                   .likePost(
//                                       widget.note.likes,
//                                       widget.note.noteId,
//                                       commentNotoficationModel,
//                                       widget.note.userToken,
//                                       userProvider.name,
//                                       widget.note.userUid,
//                                       userProvider.uid);
//                               //     .then((value) {
//                               //   Provider.of<DisplayNotesProvider>(context,
//                               //           listen: false)
//                               //       .addLikeInProvider(widget.note.noteId);
//                               // });
//                             },
//                             child: StreamBuilder(
//                                 stream: FirebaseFirestore.instance
//                                     .collection('notes')
//                                     .doc(widget.note.noteId)
//                                     .snapshots(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     if (snapshot.data!
//                                         .data()!['likes']
//                                         .contains(FirebaseAuth
//                                             .instance.currentUser!.uid)) {
//                                       return SvgPicture.asset(
//                                         'assets/icons/Like Active.svg',
//                                         height: 28,
//                                         width: 35,
//                                         // fit: BoxFit.cover,
//                                       );
//                                     } else {
//                                       return SvgPicture.asset(
//                                         'assets/icons/Like inactive.svg',
//                                         height: 28,
//                                         width: 35,
//                                         // fit: BoxFit.cover,
//                                       );
//                                     }
//                                   } else {
//                                     return const Text('');
//                                   }
//                                 })),
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: GestureDetector(
//                           onTap: () async {
//                             await showModalBottomSheet(
//                                 context: context,
//                                 builder: (context) {
//                                   return SharePostSheet(
//                                     note: widget.note,
//                                   );
//                                 });
//                           },
//                           child: Image.asset(
//                             'assets/images/send_message.png',
//                             height: 25,
//                             width: 25,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: InkWell(
//                             onTap: () {
//                               String bookMarkId = const Uuid().v4();
//                               BookmarkModel bookmarkModel = BookmarkModel(
//                                   bookmarkId: bookMarkId,
//                                   postId: widget.note.noteId,
//                                   userId:
//                                       FirebaseAuth.instance.currentUser!.uid);
//                               Provider.of<DisplayNotesProvider>(context,
//                                       listen: false)
//                                   .addPostToSaved(bookmarkModel, context);
//                             },
//                             child: StreamBuilder(
//                               stream: FirebaseFirestore.instance
//                                   .collection('bookmarks')
//                                   .where('userId',
//                                       isEqualTo: FirebaseAuth
//                                           .instance.currentUser!.uid)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   var bookmarks = snapshot.data!.docs;
//                                   var found = false;
//                                   for (var doc in bookmarks) {
//                                     BookmarkModel bookmark =
//                                         BookmarkModel.fromMap(doc.data());
//                                     if (bookmark.postId == widget.note.noteId) {
//                                       found = true;
//                                       break;
//                                     }
//                                   }
//                                   if (found) {
//                                     return SvgPicture.asset(
//                                       'assets/icons/Bookmark active.svg',
//                                       height: 32,
//                                       width: 35,
//                                     );
//                                   } else {
//                                     return SvgPicture.asset(
//                                       'assets/icons/Bookmark inactive.svg',
//                                       height: 32,
//                                       width: 35,
//                                     );
//                                   }
//                                 } else {
//                                   return const Text('');
//                                 }
//                               },
//                             )),
//                       ),
//                       // IconButton(
//                       //     onPressed: () {},
//                       //     icon: Icon(
//                       //       Icons.image_outlined,
//                       //       color: whiteColor,
//                       //       size: 30,
//                       //     )),
//                       if (widget.note.tagPeople.isNotEmpty)
//                         InkWell(
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                     backgroundColor: whiteColor,
//                                     elevation: 0,
//                                     content: ShowTaggedUsers(
//                                         noteModel: widget.note));
//                               },
//                             );
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Image.asset(
//                               'assets/images/tags.png',
//                               height: 30,
//                               width: 25,
//                             ),
//                           ),
//                         ),
//                       IconButton(
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                   actionsPadding: const EdgeInsets.all(0),
//                                   contentPadding: const EdgeInsets.all(4),
//                                   backgroundColor: whiteColor,
//                                   elevation: 0,
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     // crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       // Align(
//                                       //   alignment: Alignment.centerRight,
//                                       //   child: IconButton(
//                                       //       onPressed: () {
//                                       //         navPop(context);
//                                       //       },
//                                       //       icon: Icon(
//                                       //         Icons.close,
//                                       //         color: blackColor,
//                                       //         size: 30,
//                                       //       )),
//                                       // ),
//                                       if (widget.note.tagPeople
//                                           .contains(userProvider!.uid))
//                                         InkWell(
//                                           onTap: () async {
//                                             navPop(context);
//                                             Provider.of<DisplayNotesProvider>(
//                                                     context,
//                                                     listen: false)
//                                                 .updateTag(
//                                                     widget.note.noteId,
//                                                     userProvider.uid,
//                                                     widget.currentIndex);
//                                             await FirebaseFirestore.instance
//                                                 .collection('notes')
//                                                 .doc(widget.note.noteId)
//                                                 .update({
//                                               'tagPeople':
//                                                   FieldValue.arrayRemove(
//                                                       [userProvider.uid])
//                                             });
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 8,
//                                                 left: 10,
//                                                 right: 10,
//                                                 top: 10),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Remove me from post',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontFamily: khulaRegular,
//                                                       fontSize: 18,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 const Icon(Icons
//                                                     .arrow_forward_ios_outlined)
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       if (widget.note.tagPeople
//                                           .contains(userProvider.uid))
//                                         Container(
//                                           width:
//                                               MediaQuery.of(context).size.width,
//                                           height: 1,
//                                           color: const Color(0xffEAEAEA),
//                                         ),
//                                       if (widget.note.userUid !=
//                                           userProvider.uid)
//                                         InkWell(
//                                           onTap: () {
//                                             showModalBottomSheet(
//                                                 showDragHandle: true,
//                                                 isScrollControlled: true,
//                                                 useSafeArea: true,
//                                                 constraints: BoxConstraints(
//                                                     minHeight:
//                                                         size.height * 0.95,
//                                                     maxHeight:
//                                                         size.height * 0.95),
//                                                 backgroundColor: whiteColor,
//                                                 elevation: 0,
//                                                 context: context,
//                                                 builder: (context) =>
//                                                     ReportModalSheet(
//                                                       note: widget.note,
//                                                     ));
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 8,
//                                                 left: 10,
//                                                 right: 10,
//                                                 top: 10),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Report Post',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontFamily: khulaRegular,
//                                                       fontSize: 18,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 const Icon(Icons
//                                                     .arrow_forward_ios_outlined)
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       if (widget.note.userUid !=
//                                           userProvider.uid)
//                                         Container(
//                                           width:
//                                               MediaQuery.of(context).size.width,
//                                           height: 1,
//                                           color: const Color(0xffEAEAEA),
//                                         ),
//                                       // Divider(
//                                       //   endIndent: 0,
//                                       //   indent: 0,
//                                       //   height: 1,
//                                       //   color: Colors.black.withOpacity(0.1),
//                                       // ),
//                                       if (widget.note.userUid ==
//                                           userProvider.uid)
//                                         InkWell(
//                                           onTap: () async {
//                                             Provider.of<DisplayNotesProvider>(
//                                                     context,
//                                                     listen: false)
//                                                 .removeNote(widget.note);
//                                             Provider.of<UserProfileProvider>(
//                                                     context,
//                                                     listen: false)
//                                                 .deletePost(widget.note.noteId);
//                                             navPop(context);
//                                             showWhiteOverlayPopup(
//                                                 context, Icons.check_box, null,
//                                                 title: 'Successful',
//                                                 message: 'Post was deleted!',
//                                                 isUsernameRes: false);
//                                             // ScaffoldMessenger.of(context)
//                                             //     .showSnackBar(SnackBar(
//                                             //         backgroundColor: Colors.white,
//                                             //         content: Text(
//                                             //           'Post was deleted!',
//                                             //           style: TextStyle(
//                                             //               fontFamily: khulaRegular,
//                                             //               color: blackColor),
//                                             //         )));

//                                             // navPop(context);
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 8,
//                                                 left: 10,
//                                                 right: 10,
//                                                 top: 10),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Delete post',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontFamily: khulaRegular,
//                                                       fontSize: 18,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                                 const Icon(Icons
//                                                     .arrow_forward_ios_outlined)
//                                               ],
//                                             ),
//                                           ),
//                                         ),

//                                       if (widget.note.userUid ==
//                                           userProvider.uid)
//                                         Divider(
//                                           endIndent: 0,
//                                           indent: 0,
//                                           height: 1,
//                                           color: Colors.black.withOpacity(0.1),
//                                         ),
//                                       InkWell(
//                                         onTap: () async {
//                                           await DeepLinkPostService()
//                                               .createReferLink(widget.note)
//                                               .then((value) async {
//                                             await Clipboard.setData(
//                                                     ClipboardData(text: value))
//                                                 .then((value) {
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(SnackBar(
//                                                       backgroundColor:
//                                                           Colors.white,
//                                                       content: Text(
//                                                         'Link was copied to clipboard!',
//                                                         style: TextStyle(
//                                                             fontFamily:
//                                                                 khulaRegular,
//                                                             color: blackColor),
//                                                       )));

//                                               navPop(context);
//                                             });
//                                           });
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 8,
//                                               left: 10,
//                                               right: 10,
//                                               top: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 'Copy link to post',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     fontFamily: khulaRegular,
//                                                     fontSize: 18,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               const Icon(Icons
//                                                   .arrow_forward_ios_outlined)
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Divider(
//                                         endIndent: 0,
//                                         indent: 0,
//                                         height: 1,
//                                         color: Colors.black.withOpacity(0.1),
//                                       ),
//                                       // InkWell(
//                                       //   onTap: () async {
//                                       //     // await DeepLinkPostService()
//                                       //     //     .createReferLink(widget.note)
//                                       //     //     .then((value) {
//                                       //     //   Share.share(value);
//                                       //     //   navPop(context);
//                                       //     // });
//                                       //   },
//                                       //   child: Padding(
//                                       //     padding: const EdgeInsets.only(
//                                       //         bottom: 8,
//                                       //         left: 10,
//                                       //         right: 10,
//                                       //         top: 10),
//                                       //     child: Row(
//                                       //       mainAxisAlignment:
//                                       //           MainAxisAlignment.spaceBetween,
//                                       //       children: [
//                                       //         Text(
//                                       //           'Share to instagram ',
//                                       //           textAlign: TextAlign.center,
//                                       //           style: TextStyle(
//                                       //               fontFamily: khulaRegular,
//                                       //               fontSize: 18,
//                                       //               fontWeight: FontWeight.w600),
//                                       //         ),
//                                       //         const Icon(
//                                       //             Icons.arrow_forward_ios_outlined)
//                                       //       ],
//                                       //     ),
//                                       //   ),
//                                       // ),

//                                       // Divider(
//                                       //   endIndent: 0,
//                                       //   indent: 0,
//                                       //   height: 1,
//                                       //   color: Colors.black.withOpacity(0.1),
//                                       // ),
//                                       InkWell(
//                                         onTap: () async {
//                                           await DeepLinkPostService()
//                                               .createReferLink(widget.note)
//                                               .then((value) {
//                                             Share.share(value);
//                                             navPop(context);
//                                           });
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 8,
//                                               left: 10,
//                                               right: 10,
//                                               top: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 'Share to... ',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     fontFamily: khulaRegular,
//                                                     fontSize: 18,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               const Icon(Icons
//                                                   .arrow_forward_ios_outlined)
//                                             ],
//                                           ),
//                                         ),
//                                       ),

//                                       // Divider(
//                                       //   endIndent: 10,
//                                       //   indent: 10,
//                                       //   height: 1,
//                                       //   color: Colors.black.withOpacity(0.1),
//                                       // ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                           icon: Icon(
//                             Icons.more_horiz,
//                             color: whiteColor,
//                           ))
//                     ],
//                   ),
//                 ),

//                 const Expanded(child: SizedBox()),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20)
//                       .copyWith(top: 10, bottom: 15),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('notes')
//                               .doc(widget.note.noteId)
//                               .snapshots(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               NoteModel likes =
//                                   NoteModel.fromMap(snapshot.data!.data()!);
//                               return InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => LikeScreen(
//                                             likes: widget.note.likes),
//                                       ));
//                                 },
//                                 child: Text(
//                                   likes.likes.isNotEmpty
//                                       ? '${likes.likes.length} likes'
//                                       : 'No likes',
//                                   style: TextStyle(
//                                       fontFamily: fontFamily,
//                                       color: whiteColor,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               );
//                             } else {
//                               return const Text('');
//                             }
//                           }),
//                       GestureDetector(
//                         onTap: () async {
//                           await showModalBottomSheet(
//                               useSafeArea: true,
//                               enableDrag: true,
//                               isScrollControlled: true,
//                               constraints: BoxConstraints(
//                                   // maxWidth: MediaQuery.of(context).size.width * 0.8,
//                                   // minWidth: MediaQuery.of(context).size.width * 0.8,
//                                   minHeight:
//                                       MediaQuery.of(context).size.height * 0.7,
//                                   maxHeight:
//                                       MediaQuery.of(context).size.height * 0.7),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20)),
//                               context: context,
//                               builder: (context) => CommentModalSheet(
//                                     postId: widget.note.noteId,
//                                     userId: widget.note.userUid,
//                                     noteData: widget.note,
//                                   ));
//                         },
//                         child: StreamBuilder(
//                             stream: FirebaseFirestore.instance
//                                 .collection('notes')
//                                 .doc(widget.note.noteId)
//                                 .collection('comments')
//                                 .snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData) {
//                                 return Text(
//                                   snapshot.data!.docs.isNotEmpty
//                                       ? 'View all ${snapshot.data!.docs.length} replies'
//                                       : 'No replies',
//                                   style: TextStyle(
//                                       fontFamily: fontFamily,
//                                       color: whiteColor,
//                                       fontWeight: FontWeight.w600),
//                                 );
//                               } else {
//                                 return const Text('');
//                               }
//                             }),
//                       )
//                     ],
//                   ),
//                 ),

//                 CircleComments(
//                   stopMainPlayer: () {},
//                   mainAudioPlayer: mainAudioPlayer,

//                   noteModel: widget.note,

//                   // commentsLength: snapshot.data!.docs.length,
//                 ),

//                 const SizedBox(
//                   height: 10,
//                 ),

//                 // Row(
//                 //   children: [
//                 //     Container(decoration: Boxde,)
//                 //   ],
//                 // )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
