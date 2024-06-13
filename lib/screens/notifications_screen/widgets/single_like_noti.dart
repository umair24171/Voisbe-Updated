import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';

class SingleLikeNoti extends StatelessWidget {
  const SingleLikeNoti({
    super.key,
    required this.likeNotofication,
  });

  final CommentNotoficationModel likeNotofication;

  @override
  Widget build(BuildContext context) {
    Provider.of<NotificationProvider>(context, listen: false)
        .readNotification(likeNotofication.notificationId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(
          //   width: 15,
          // ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(likeNotofication.currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel userModel =
                      UserModel.fromMap(snapshot.data!.data()!);
                  return CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(userModel.photoUrl),
                  );
                } else {
                  return const Text('');
                }
              }),
          // const SizedBox(
          //   width: 10,
          // ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(likeNotofication.currentUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        UserModel userModel =
                            UserModel.fromMap(snapshot.data!.data()!);
                        return Row(
                          children: [
                            Text(
                              userModel.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: khulaRegular),
                            ),
                            if (userModel.isVerified) verifiedIcon()
                          ],
                        );
                      } else {
                        return const Text('');
                      }
                    }),
              ),
              // const SizedBox(
              //   width: 5,
              // ),
              const Text(
                ' liked your post',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          // const SizedBox(
          //   width: 65,
          // ),
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor,
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.play_arrow,
                  color: whiteColor,
                  size: 25,
                )),
          ),
        ],
      ),
    );
  }
}
