import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/notifications_screen/widgets/single_comment_notification.dart';
import 'package:social_notes/screens/notifications_screen/widgets/single_like_noti.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late StreamSubscription notificationStream;

  //  creating the emtpy list to get the comment notifications

  List<CommentNotoficationModel> commentNotifications = [];

  //  creating the empty list for like notifications

  List<CommentNotoficationModel> likeNotifications = [];

  @override
  void initState() {
    getStreamNotifictions();
    super.initState();
  }

  //  getting all the notifications including like and comment

  getStreamNotifictions() async {
    notificationStream = await FirebaseFirestore.instance
        .collection('commentNotifications')
        .where('toId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      List<CommentNotoficationModel> notoficationModel = snapshot.docs
          .map((e) => CommentNotoficationModel.fromMap(e.data()))
          .toList();
      List<CommentNotoficationModel> commentNotifi = [];
      List<CommentNotoficationModel> likeNotific = [];
      commentNotifi.clear();
      likeNotific.clear();

      //  adding notifications to seperate list based on the type

      for (var noti in notoficationModel) {
        if (noti.notificationType.contains('comment')) {
          commentNotifi.add(noti);
        } else {
          likeNotific.add(noti);
        }
      }

      //  updating the the data to the list

      setState(() {
        commentNotifications = commentNotifi;
        likeNotifications = likeNotific;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //  getting current user

    var userProvider = Provider.of<UserProvider>(context, listen: false).user;

    //  getting the notification provider

    var notiProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              navPop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        title: Text(
          'Notifications',
          style: TextStyle(
              color: Colors.black,
              fontFamily: khulaRegular,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: whiteColor,
      ),
      body: RefreshIndicator(
        backgroundColor: whiteColor,
        color: primaryColor,
        onRefresh: () {
          //  on refresh getting all the notifications

          return getStreamNotifictions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            // const SizedBox(
            //   height: 50,
            // ),
            const Row(
              children: [
                // IconButton(
                //     onPressed: () {
                //       navPop(context);
                //     },
                //     icon: const Icon(
                //       Icons.arrow_back_ios,
                //       color: Colors.black,
                //     )),
                SizedBox(
                  width: 100,
                ),
                // Text(
                //   'Notifications',
                //   style: TextStyle(
                //       color: Colors.black,
                //       fontFamily: khulaRegular,
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold),
                // ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 0.5,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'New Followers',
                  style: TextStyle(
                      fontFamily: khulaRegular,
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),

            //  stream to get the followers and following req

            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('followTo', arrayContains: userProvider!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        //  building the requests

                        ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              UserModel user = UserModel.fromMap(
                                  snapshot.data!.docs[index].data());
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OtherUserProfile(
                                                      userId: user.uid),
                                            ));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    user.photoUrl),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              user.name,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: khulaRegular),
                                            ),
                                          ),
                                          if (user.isVerified) verifiedIcon()
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              fixedSize: const Size(90, 20),
                                              padding: const EdgeInsets.all(0),
                                              minimumSize: const Size(90, 35),
                                              elevation: 0,
                                              backgroundColor: blackColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1),
                                              ),
                                            ),
                                            onPressed: () async {
                                              //  accepting the request

                                              await notiProvider
                                                  .confirmFollowReq(
                                                      userProvider.uid,
                                                      user.uid);
                                            },
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  color: whiteColor,
                                                  fontSize: 14,
                                                  fontFamily: khulaRegular,
                                                  fontWeight: FontWeight.w700),
                                            )),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              fixedSize: const Size(90, 20),
                                              padding: const EdgeInsets.all(0),
                                              minimumSize: const Size(90, 35),
                                              elevation: 0,
                                              backgroundColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                      color: blackColor,
                                                      width: 1)),
                                            ),
                                            onPressed: () {
                                              //  canceling the request

                                              notiProvider.cancelFollowReq(
                                                  userProvider.uid, user.uid);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: khulaRegular,
                                                  fontWeight: FontWeight.w700),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        if (snapshot.data!.docs.length > 4)
                          GestureDetector(
                            onTap: () {
                              //  length greater than 4 than thow the expand

                              Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .setIsFollowExpand();
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Color.fromARGB(255, 46, 43, 43),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }),

            const Divider(
              thickness: 0.5,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'New Replies',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: khulaRegular),
                ),
              ],
            ),
            Consumer<NotificationProvider>(builder: (context, notifyPro, _) {
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: commentNotifications.length > 4 &&
                          !notifyPro.isExpandForComment
                      ? 4
                      : commentNotifications.length,
                  itemBuilder: (context, index) {
                    //  building all the comment notifications

                    CommentNotoficationModel commentNotificationModel =
                        commentNotifications[index];
                    return SingleCommentNotification(
                      commentNotificationModel: commentNotificationModel,
                    );
                  });
            }),
            commentNotifications.length > 4
                ? Consumer<NotificationProvider>(
                    builder: (context, notifyPro, _) {
                    return notiProvider.isExpandForComment
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: () {
                              notiProvider.setIsExpandForCOmment();
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Color.fromARGB(255, 46, 43, 43),
                            ),
                          );
                  })
                : const SizedBox(),
            // const Icon(
            //   Icons.add,
            //   size: 35,
            //   color: Color.fromARGB(255, 46, 43, 43),
            // ),
            const Divider(
              thickness: 0.5,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'New Likes',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: khulaRegular),
                ),
              ],
            ),

            //  like notifications

            Consumer<NotificationProvider>(builder: (context, notifyPro, _) {
              //  building like notifications

              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: likeNotifications.length > 4 && !notifyPro.isExpand
                      ? 4
                      : likeNotifications.length,
                  itemBuilder: (context, index) {
                    CommentNotoficationModel likeNotofication =
                        likeNotifications[index];
                    return SingleLikeNoti(likeNotofication: likeNotofication);
                  });
            }),
            likeNotifications.length > 4
                ? Consumer<NotificationProvider>(
                    builder: (context, notifyPro, _) {
                    return notiProvider.isExpand
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: () {
                              //  expand function

                              notiProvider.setIsExpand();
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Color.fromARGB(255, 46, 43, 43),
                            ),
                          );
                  })
                : const SizedBox(),
            const Divider(
              thickness: 0.5,
            ),
            const SizedBox(
              height: 10,
            ),
          ]),
        ),
      ),
    );
  }
}
