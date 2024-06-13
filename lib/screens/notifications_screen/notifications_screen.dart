import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;

    var notiProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: whiteColor,
      // appBar: AppBar(
      //   backgroundColor: whiteColor,
      //   elevation: 0,
      //   surfaceTintColor: whiteColor,
      // ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    navPop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 100,
              ),
              Text(
                'Notifications',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: khulaRegular,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
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
          // const SizedBox(
          //   height: 10,
          // ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('followTo', arrayContains: userProvider!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        UserModel user = UserModel.fromMap(
                            snapshot.data!.docs[index].data());
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
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
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: khulaRegular),
                                    ),
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
                                                width: 1)),
                                      ),
                                      onPressed: () async {
                                        await notiProvider.confirmFollowReq(
                                            userProvider.uid, user.uid);
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
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: blackColor, width: 1)),
                                      ),
                                      onPressed: () {
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
                      });
                } else {
                  return const SizedBox();
                }
              }),
          const SizedBox(
            height: 10,
          ),
          // const Icon(
          //   Icons.add,
          //   size: 35,
          //   color: Color.fromARGB(255, 46, 43, 43),
          // ),
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
                'New Comments',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: khulaRegular),
              ),
            ],
          ),
          Consumer<NotificationProvider>(builder: (context, notiProvider, _) {
            log('All Notifications ${notiProvider.allNotifications}');
            List<CommentNotoficationModel> commentNotifications = [];
            commentNotifications.clear();
            for (var noti in notiProvider.allNotifications) {
              if (noti.notificationType.contains('comment')) {
                commentNotifications.add(noti);
              }
            }
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: commentNotifications.length,
                itemBuilder: (context, index) {
                  CommentNotoficationModel commentNotificationModel =
                      commentNotifications[index];
                  return SingleCommentNotification(
                    commentNotificationModel: commentNotificationModel,
                  );
                });
          }),
          Consumer<NotificationProvider>(builder: (context, notiPro, _) {
            log('All Notifications ${notiProvider.allNotifications}');
            List<CommentNotoficationModel> commentNotifications = [];
            commentNotifications.clear();
            for (var noti in notiProvider.allNotifications) {
              if (noti.notificationType.contains('comment')) {
                commentNotifications.add(noti);
              }
            }
            return commentNotifications.length > 4
                ? const Icon(
                    Icons.add,
                    size: 35,
                    color: Color.fromARGB(255, 46, 43, 43),
                  )
                : SizedBox();
          }),
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
          Consumer<NotificationProvider>(builder: (context, notiProvider, _) {
            List<CommentNotoficationModel> likeNotifications = [];
            likeNotifications.clear();
            for (var noti in notiProvider.allNotifications) {
              if (noti.notificationType.contains('like')) {
                likeNotifications.add(noti);
              }
            }
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: likeNotifications.length,
                itemBuilder: (context, index) {
                  CommentNotoficationModel likeNotofication =
                      likeNotifications[index];
                  return SingleLikeNoti(likeNotofication: likeNotofication);
                });
          }),
          Consumer<NotificationProvider>(builder: (context, notiPro, _) {
            List<CommentNotoficationModel> likeNotifications = [];
            likeNotifications.clear();
            for (var noti in notiProvider.allNotifications) {
              if (noti.notificationType.contains('like')) {
                likeNotifications.add(noti);
              }
            }
            return likeNotifications.length > 4
                ? const Icon(
                    Icons.add,
                    size: 35,
                    color: Color.fromARGB(255, 46, 43, 43),
                  )
                : SizedBox();
          }),
          const Divider(
            thickness: 0.5,
          ),
          const SizedBox(
            height: 10,
          ),
        ]),
      ),
    );
  }
}
