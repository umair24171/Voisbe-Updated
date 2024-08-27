import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/home_screen/controller/share_services.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/settings_screen/view/settings_screen.dart';

// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';

// import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/subscribe_screen.dart/view/subscribe_screen.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/followers_screen.dart';
import 'package:social_notes/screens/user_profile/view/following_screen.dart';
import 'package:social_notes/screens/user_profile/view/widgets/contact_button.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_following_container.dart';
import 'package:social_notes/screens/user_profile/view/widgets/other_user_posts.dart';
import 'package:social_notes/screens/user_profile/view/widgets/report_user.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherUserProfile extends StatefulWidget {
  OtherUserProfile({super.key, required this.userId, this.previousId});
  final String userId;
  final String? previousId;

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  List<TextSpan> _buildTextSpans(BuildContext context, String bio) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'@(\w+)');
    int start = 0;

    for (final match in regExp.allMatches(bio)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: bio.substring(start, match.start),
          style: TextStyle(
              color: whiteColor, fontSize: 13, fontFamily: fontFamily),
        ));
      }
      final username = match.group(0);
      spans.add(
        TextSpan(
          text: username,
          style: TextStyle(
              color: whiteColor, fontSize: 13, fontFamily: fontFamily),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _navigateToUserProfile(context, username),
        ),
      );
      start = match.end;
    }
    if (start < bio.length) {
      spans.add(TextSpan(
        text: bio.substring(start),
        style:
            TextStyle(color: whiteColor, fontSize: 13, fontFamily: fontFamily),
      ));
    }

    return spans;
  }

  void _navigateToUserProfile(BuildContext context, String? username) async {
    if (username != null && username.startsWith('@')) {
      final cleanUsername = username.substring(1); // Remove the '@' symbol
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: cleanUsername)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userId =
            userDoc['uid']; // Assuming you store the user ID in the 'uid' field
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfile(
              userId: userId,
              previousId: widget.userId,
            ),
          ),
        );
      } else {
        // Handle user not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<UserProfileProvider>(context, listen: false)
        .otherUserProfile(widget.userId);
  }

  getData() async {}
  String formatCount(int count) {
    if (count >= 1000000) {
      double millions = count / 1000000;
      return '${millions.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // var userProvider =
    //     Provider.of<UserProfileProvider>(context, listen: false).otherUser;
    var currentUSer = Provider.of<UserProvider>(context, listen: false).user;

    // userProvider.otherUser;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: whiteColor,
        automaticallyImplyLeading: false,
        backgroundColor: whiteColor,
        title: Row(children: [
          Consumer<UserProfileProvider>(builder: (context, userProvider, _) {
            return Row(
              children: [
                Text(
                  userProvider.otherUser!.name,
                  style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.w600),
                ),
                if (userProvider.otherUser!.isVerified) verifiedIcon()
                // Image.network(
                //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                //   height: 20,
                //   width: 20,
                // ),
              ],
            );
          }),
          // Icon(
          //   Icons.keyboard_arrow_down_outlined,
          //   color: blackColor,
          // )
        ]),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(
          //       builder: (context) {
          //         return const NotificationScreen();
          //       },
          //     ));
          //   },
          //   icon: Icon(
          //     Icons.favorite_border_outlined,
          //     color: blackColor,
          //     size: 30,
          //   ),
          // ),
          IconButton(
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return SettingsScreen();
                },
              ));
            },
            icon: Icon(
              Icons.menu,
              color: blackColor,
              size: 30,
            ),
          )
        ],
      ),
      body: PopScope(
        onPopInvoked: (value) {
          if (widget.previousId != null) {
            Provider.of<UserProfileProvider>(context, listen: false)
                .otherUserProfile(widget.previousId!);
          }
        },
        child: Stack(
          children: [
            Consumer<UserProfileProvider>(builder: (context, userProvider, _) {
              return Container(
                height: size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                        userProvider.otherUser!.photoUrl),
                  ),
                ),
              );
            }),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.1), // Transparent color
              ),
            ),
            RefreshIndicator(
              backgroundColor: whiteColor,
              color: primaryColor,
              onRefresh: () {
                return getData();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    // Container(
                    //   height: MediaQuery.of(context).size.height,
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       begin: Alignment.topCenter,
                    //       end: Alignment.bottomCenter,
                    //       colors: [Colors.black.withOpacity(0.5), Colors.white],
                    //       stops: [0.5, 0.5],
                    //     ),
                    //   ),
                    // ),
                    Container(
                      child: Image.asset(
                        'assets/icons/profilepage_backgroundgradient 1.png',
                        fit: BoxFit.cover,
                        height: size.height,
                        width: size.width,
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(18)),
                                child: Consumer<UserProfileProvider>(
                                    builder: (context, userProvider, _) {
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                userProvider
                                                    .otherUser!.photoUrl),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        userProvider.otherUser!.name,
                                        style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      if (userProvider.otherUser!.isVerified)
                                        verifiedIcon()
                                      // Image.network(
                                      //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                                      //   height: 20,
                                      //   width: 20,
                                      // ),
                                    ],
                                  );
                                }),
                              ),

                              Consumer<UserProfileProvider>(
                                  builder: (context, userProvider, _) {
                                return userProvider.otherUser!.uid !=
                                        currentUSer!.uid
                                    ? const SizedBox(
                                        width: 5,
                                      )
                                    : const SizedBox();
                              }),

                              Consumer<UserProfileProvider>(
                                  builder: (context, userProvider, _) {
                                return userProvider.otherUser!.uid !=
                                        currentUSer!.uid
                                    ? InkWell(
                                        onTap: () async {
                                          if (userProvider
                                              .otherUser!.notificationsEnable
                                              .contains(currentUSer.uid)) {
                                            userProvider.removeNotification(
                                                currentUSer.uid);
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(
                                                    userProvider.otherUser!.uid)
                                                .update({
                                              'notificationsEnable':
                                                  FieldValue.arrayRemove(
                                                      [currentUSer.uid])
                                            });
                                            showWhiteOverlayPopup(context,
                                                Icons.check_box, null, null,
                                                title: 'Successful',
                                                isUsernameRes: false,
                                                message:
                                                    'You will not receive the notifications about the ${userProvider.otherUser!.username} posts.');
                                          } else {
                                            userProvider.addNotification(
                                                currentUSer.uid);
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(
                                                    userProvider.otherUser!.uid)
                                                .update({
                                              'notificationsEnable':
                                                  FieldValue.arrayUnion(
                                                      [currentUSer.uid])
                                            });
                                            showWhiteOverlayPopup(context,
                                                Icons.check_box, null, null,
                                                title: 'Successful',
                                                isUsernameRes: false,
                                                message:
                                                    'You will now receive the notifications about the ${userProvider.otherUser!.username} posts.');
                                          }
                                          // Provider.of<UserProvider>(context,
                                          //         listen: false)
                                          //     .setIsNotificationEnabled();
                                          // if (Provider.of<UserProvider>(context,
                                          //         listen: false)
                                          //     .isNotificationEnabled) {
                                          // showWhiteOverlayPopup(context,
                                          //     Icons.check_box_outlined, null,
                                          //     title: 'Successful',
                                          //     isUsernameRes: false,
                                          //     message:
                                          //         'You will now receive the notifications about the ${userProvider.otherUser!.username} posts');
                                          // } else {
                                          // showWhiteOverlayPopup(context,
                                          //     Icons.check_box_outlined, null,
                                          //     title: 'Successful',
                                          //     isUsernameRes: false,
                                          //     message:
                                          //         'You will not receive the notifications about the ${userProvider.otherUser!.username} posts');
                                          // }
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: !userProvider.otherUser!
                                                    .notificationsEnable
                                                    .contains(currentUSer.uid)
                                                ? SvgPicture.asset(
                                                    'assets/icons/Bell inactive.svg',
                                                    height: 30,
                                                    width: 30,
                                                  )
                                                : SvgPicture.asset(
                                                    'assets/icons/Bell active.svg',
                                                    height: 30,
                                                    width: 30,
                                                  )
                                            // Icon(
                                            //   Icons.notifications_none_outlined,
                                            //   color: primaryColor,
                                            //   size: 30,
                                            // ),
                                            ),
                                      )
                                    : const SizedBox();
                              }),
                              const SizedBox(
                                width: 5,
                              ),
                              // if (userProvider.isSubscriptionEnable)

                              Consumer<UserProfileProvider>(
                                  builder: (context, userProvider, _) {
                                return userProvider.otherUser!.uid !=
                                            currentUSer!.uid &&
                                        userProvider
                                            .otherUser!.isSubscriptionEnable &&
                                        userProvider.otherUser!.isVerified
                                    ? InkWell(
                                        onTap: () {
                                          navPush(SubscribeScreen.routeName,
                                              context);
                                        },
                                        child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.userId)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                UserModel subUser =
                                                    UserModel.fromMap(
                                                        snapshot.data!.data()!);
                                                return Container(
                                                    padding: EdgeInsets.all(
                                                        subUser.subscribedUsers
                                                                .contains(
                                                                    currentUSer
                                                                        .uid)
                                                            ? 9
                                                            : 6),
                                                    decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                    child: subUser
                                                            .subscribedUsers
                                                            .contains(
                                                                currentUSer.uid)
                                                        ? SvgPicture.asset(
                                                            'assets/icons/Sub active.svg',
                                                            height: 23,
                                                            width: 23,
                                                          )
                                                        : SvgPicture.asset(
                                                            'assets/icons/Sub inactive.svg',
                                                            height: 30,
                                                            width: 30,
                                                          ));
                                              } else {
                                                return Text("");
                                              }
                                            }),
                                      )
                                    : const SizedBox();
                              }),
                              const SizedBox(
                                width: 2,
                              ),

                              Consumer<UserProfileProvider>(
                                  builder: (context, userProvider, _) {
                                return userProvider.otherUser!.uid !=
                                        currentUSer!.uid
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: whiteColor,
                                                elevation: 0,
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        navPop(context);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                                elevation: 0,
                                                                backgroundColor:
                                                                    whiteColor,
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        'Block User',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                khulaRegular,
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'They won’t be able to find your profile or posts. VOISBE won’t let them know you blocked them.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            khulaRegular,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        ElevatedButton(
                                                                            style:
                                                                                ElevatedButton.styleFrom(elevation: 0, backgroundColor: blackColor),
                                                                            onPressed: () async {
                                                                              if (!currentUSer.blockedUsers.contains(userProvider.otherUser!.uid)) {
                                                                                await FirebaseFirestore.instance.collection('users').doc(currentUSer.uid).update({
                                                                                  'blockedUsers': FieldValue.arrayUnion([
                                                                                    userProvider.otherUser!.uid
                                                                                  ])
                                                                                });
                                                                                await FirebaseFirestore.instance.collection('users').doc(userProvider.otherUser!.uid).update({
                                                                                  'blockedByUsers': FieldValue.arrayUnion([
                                                                                    currentUSer.uid
                                                                                  ])
                                                                                });

                                                                                navPop(context);
                                                                                showWhiteOverlayPopup(context, Icons.check_box, null, null, title: 'Successful!', message: 'User blocked. ', isUsernameRes: false);

                                                                                // FirebaseFirestore.instance.collection('users').doc(userProvider.uid).update({'blockedUsers': }).then((value) => navPop(context));
                                                                              } else {
                                                                                showWhiteOverlayPopup(context, null, null, 'assets/icons/Info (1).svg', title: 'Oops!', message: 'User already blocked. ', isUsernameRes: false);
                                                                              }
                                                                            },
                                                                            child: Text(
                                                                              'Block User',
                                                                              style: TextStyle(color: whiteColor, fontFamily: khulaRegular),
                                                                            )),
                                                                        ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                                elevation: 0,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                                side: const BorderSide(color: Color(0xff868686), width: 1),
                                                                                backgroundColor: whiteColor),
                                                                            onPressed: () {
                                                                              navPop(context);
                                                                            },
                                                                            child: Text(
                                                                              'Cancel',
                                                                              style: TextStyle(color: blackColor, fontFamily: khulaRegular),
                                                                            ))
                                                                      ],
                                                                    )
                                                                  ],
                                                                ));
                                                          },
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        4)
                                                                .copyWith(
                                                                    bottom: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Block User',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      khulaRegular,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_outlined,
                                                              color: blackColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      endIndent: 0,
                                                      indent: 0,
                                                      height: 1,
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                    ),
                                                    if (userProvider
                                                        .otherUser!.followers
                                                        .contains(
                                                            currentUSer.uid))
                                                      InkWell(
                                                        onTap: () async {
                                                          if (!currentUSer
                                                              .closeFriends
                                                              .contains(
                                                                  userProvider
                                                                      .otherUser!
                                                                      .uid)) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(currentUSer
                                                                    .uid)
                                                                .update({
                                                              'closeFriends':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                userProvider
                                                                    .otherUser!
                                                                    .uid
                                                              ])
                                                            }).then((value) {
                                                              navPop(context);
                                                              showWhiteOverlayPopup(
                                                                  context,
                                                                  Icons
                                                                      .check_box,
                                                                  null,
                                                                  null,
                                                                  title:
                                                                      'Successful!',
                                                                  message:
                                                                      'User Added to Close Friends ',
                                                                  isUsernameRes:
                                                                      false);
                                                            });

                                                            // FirebaseFirestore.instance.collection('users').doc(userProvider.uid).update({'blockedUsers': }).then((value) => navPop(context));
                                                          } else {
                                                            showWhiteOverlayPopup(
                                                                context,
                                                                null,
                                                                'assets/icons/Info (1).svg',
                                                                null,
                                                                title: 'Oops!',
                                                                message:
                                                                    'User already added ',
                                                                isUsernameRes:
                                                                    false);
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          4)
                                                                  .copyWith(
                                                                      bottom:
                                                                          8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Add as close friend',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        khulaRegular,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_forward_ios_outlined,
                                                                color:
                                                                    blackColor,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    if (userProvider
                                                        .otherUser!.followers
                                                        .contains(
                                                            currentUSer.uid))
                                                      Divider(
                                                        endIndent: 0,
                                                        indent: 0,
                                                        height: 1,
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                      ),
                                                    if (userProvider
                                                        .otherUser!.followers
                                                        .contains(
                                                            currentUSer.uid))
                                                      Consumer<UserProvider>(
                                                          builder: (context,
                                                              userPro, _) {
                                                        return InkWell(
                                                          onTap: () async {
                                                            if (userPro.user!
                                                                .mutedAccouts
                                                                .contains(
                                                                    userProvider
                                                                        .otherUser!
                                                                        .uid)) {
                                                              Provider.of<UserProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .removeMuteAccount(
                                                                      userProvider
                                                                          .otherUser!
                                                                          .uid);
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      currentUSer
                                                                          .uid)
                                                                  .update({
                                                                'mutedAccouts':
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  userProvider
                                                                      .otherUser!
                                                                      .uid
                                                                ])
                                                              });
                                                              showWhiteOverlayPopup(
                                                                  context,
                                                                  null,
                                                                  'assets/icons/sound_max.svg',
                                                                  null,
                                                                  title:
                                                                      'Account unmuted',
                                                                  message:
                                                                      'This account has been unmuted and will appear in your feed again.',
                                                                  isUsernameRes:
                                                                      false);
                                                            } else {
                                                              Provider.of<UserProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .addMuteAccount(
                                                                      userProvider
                                                                          .otherUser!
                                                                          .uid);
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      currentUSer
                                                                          .uid)
                                                                  .update({
                                                                'mutedAccouts':
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  userProvider
                                                                      .otherUser!
                                                                      .uid
                                                                ])
                                                              });
                                                              showWhiteOverlayPopup(
                                                                  context,
                                                                  null,
                                                                  'assets/icons/sound_mute.svg',
                                                                  null,
                                                                  title:
                                                                      'Account muted',
                                                                  message:
                                                                      'This account has been muted and will not appear in your feed anymore until you unmute it again.',
                                                                  isUsernameRes:
                                                                      false);
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        4)
                                                                .copyWith(
                                                                    bottom: 8),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  userPro.user!
                                                                          .mutedAccouts
                                                                          .contains(userProvider
                                                                              .otherUser!
                                                                              .uid)
                                                                      ? 'Unmute Account'
                                                                      : 'Mute Account',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          khulaRegular,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_outlined,
                                                                  color:
                                                                      blackColor,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    if (userProvider
                                                        .otherUser!.followers
                                                        .contains(
                                                            currentUSer.uid))
                                                      Divider(
                                                        endIndent: 0,
                                                        indent: 0,
                                                        height: 1,
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                      ),
                                                    InkWell(
                                                      onTap: () async {
                                                        showModalBottomSheet(
                                                          // showDragHandle: true,
                                                          // isScrollControlled: true,
                                                          // useSafeArea: true,
                                                          context: context,
                                                          backgroundColor:
                                                              whiteColor,
                                                          elevation: 0,
                                                          builder: (context) {
                                                            return const ReportUser();
                                                          },
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        4)
                                                                .copyWith(
                                                                    bottom: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Report User',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      khulaRegular,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_outlined,
                                                              color: blackColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      endIndent: 0,
                                                      indent: 0,
                                                      height: 1,
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        DeepLinkPostService
                                                            deepLinkPostService =
                                                            DeepLinkPostService();
                                                        deepLinkPostService
                                                            .shareProfileLink(
                                                                widget.userId)
                                                            .then((value) {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: value));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      content:
                                                                          Text(
                                                                        'Link was copied to clipboard!',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                fontFamily,
                                                                            color:
                                                                                blackColor),
                                                                      )));
                                                          navPop(context);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        4)
                                                                .copyWith(
                                                                    bottom: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Copy profile URL ',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      khulaRegular,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_outlined,
                                                              color: blackColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Divider(
                                                    //   endIndent: 10,
                                                    //   indent: 10,
                                                    //   height: 1,
                                                    //   color: Colors.black
                                                    //       .withOpacity(0.1),
                                                    // ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.more_horiz,
                                          color: whiteColor,
                                        ),
                                      )
                                    : const SizedBox();
                              })
                            ],
                          ),
                        ),
                        SizedBox(
                          // height: 80,

                          child: Consumer<UserProfileProvider>(
                              builder: (context, userProvider, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  userProvider.otherUser!.username,
                                  style: TextStyle(
                                      color: whiteColor,
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.1,
                                          vertical: 0)
                                      .copyWith(bottom: 20, top: 5),
                                  // .copyWith(bottom: 7),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: _buildTextSpans(context,
                                            userProvider.otherUser!.bio),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Consumer<UserProfileProvider>(
                            builder: (context, userProvider, _) {
                          return userProvider.otherUser!.link.isEmpty
                              ? SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        var url =
                                            'https://${userProvider.otherUser!.link}';
                                        if (await launchUrl(Uri.parse(url))) {
                                        } else {
                                          throw Exception(
                                              'Could not launch $url');
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                            color: blackColor,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Text(
                                          userProvider.otherUser!.link,
                                          style: TextStyle(
                                              color: whiteColor,
                                              fontFamily: fontFamily,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Navigator.push(context,
                                    //         MaterialPageRoute(builder: (context) {
                                    //       return const SubscribeScreen();
                                    //     }));
                                    //   },
                                    //   child: Container(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 7, vertical: 5),
                                    //     decoration: BoxDecoration(
                                    //         color: primaryColor,
                                    //         borderRadius: BorderRadius.circular(15)),
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.spaceBetween,
                                    //       children: [
                                    //         Image.asset(
                                    //           'assets/images/sounds_button.png',
                                    //           height: 15,
                                    //           width: 15,
                                    //         ),
                                    //         Padding(
                                    //           padding: const EdgeInsets.symmetric(
                                    //               horizontal: 7),
                                    //           child: Text(
                                    //             'Audio',
                                    //             style: TextStyle(
                                    //                 color: whiteColor,
                                    //                 fontFamily: fontFamily,
                                    //                 fontWeight: FontWeight.w600),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                );
                        }),
                        Padding(
                          padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.06)
                              .copyWith(top: 15, bottom: 5),
                          child: Container(
                            // alignment: Alignment.center,
                            // height: 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 15),
                            decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(40)),
                            child: Consumer<UserProfileProvider>(
                                builder: (context, userProvider, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPostsLength(
                                    id: widget.userId,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          UserModel followUser =
                                              UserModel.fromMap(
                                                  snapshot.data!.data()!);
                                          return Row(
                                            children: [
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  if (followUser.isPrivate) {
                                                    if (followUser.followers
                                                        .contains(
                                                            currentUSer!.uid)) {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return FollowersScreen(
                                                            userId:
                                                                widget.userId);
                                                      }));
                                                    }
                                                  } else {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return FollowersScreen(
                                                          userId:
                                                              widget.userId);
                                                    }));
                                                  }
                                                },
                                                child: CustomFollowing(
                                                  number: formatCount(followUser
                                                      .followers.length),
                                                  text: 'Followers',
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  if (followUser.isPrivate) {
                                                    if (followUser.followers
                                                        .contains(
                                                            currentUSer!.uid)) {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return FollowingScreen(
                                                            userId:
                                                                widget.userId);
                                                      }));
                                                    }
                                                  } else {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return FollowingScreen(
                                                          userId:
                                                              widget.userId);
                                                    }));
                                                  }
                                                },
                                                child: CustomFollowing(
                                                  number: formatCount(followUser
                                                      .following.length),
                                                  text: 'Followings',
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Text(
                                            '0',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 25,
                                                fontFamily: fontFamilyMedium,
                                                fontWeight: FontWeight.w700),
                                          );
                                        }
                                      })
                                ],
                              );
                            }),
                          ),
                        ),
                        Consumer<UserProfileProvider>(
                            builder: (context, userProvider, _) {
                          return userProvider.otherUser!.uid != currentUSer!.uid
                              ? const OtherContactButtons()
                              : const SizedBox();
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<UserProfileProvider>(
                            builder: (context, userPro, _) {
                          return userPro.otherUser!.isPrivate &&
                                  !userPro.otherUser!.followers
                                      .contains(currentUSer!.uid)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/private lock.svg',
                                        height: 94,
                                        width: 94,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'This account is private.\n Follow to see their posts.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color(0xffED6A5A),
                                            fontSize: 14,
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                )
                              : OtherUserPosts(id: widget.userId);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPostsLength extends StatefulWidget {
  const CustomPostsLength({super.key, required this.id});
  final String id;
  @override
  State<CustomPostsLength> createState() => _CustomPostsLengthState();
}

class _CustomPostsLengthState extends State<CustomPostsLength> {
  int numberOfPosts = 0;

  @override
  void initState() {
    getUsersPosts();
    super.initState();
  }

  getUsersPosts() async {
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;

    // Fetch the user data for the post owner
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get();
    UserModel postOwner =
        UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

    bool isSubscribed = currentUser!.subscribedSoundPacks.contains(widget.id);
    bool hasSubscriptionTurnedOff = postOwner.isSubscriptionEnable;

    await FirebaseFirestore.instance
        .collection('notes')
        .where('userUid', isEqualTo: widget.id)
        .get()
        .then((value) {
      int visiblePosts = 0;
      if (postOwner.isSubscriptionEnable) {
        setState(() {
          numberOfPosts = value.docs.length;
        });
      } else {
        for (var doc in value.docs) {
          NoteModel post = NoteModel.fromMap(doc.data());
          if (!post.isPostForSubscribers ||
              (isSubscribed && hasSubscriptionTurnedOff)) {
            visiblePosts++;
          }
        }
        setState(() {
          numberOfPosts = visiblePosts;
        });
      }
    });
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      double millions = count / 1000000;
      return '${millions.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFollowing(
      number: formatCount(numberOfPosts),
      text: 'Posts',
    );
  }
}
