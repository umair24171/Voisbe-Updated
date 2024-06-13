import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';

class SingleCommentNotification extends StatefulWidget {
  const SingleCommentNotification(
      {super.key, required this.commentNotificationModel});
  final CommentNotoficationModel commentNotificationModel;

  @override
  State<SingleCommentNotification> createState() =>
      _SingleCommentNotificationState();
}

class _SingleCommentNotificationState extends State<SingleCommentNotification> {
  @override
  void initState() {
    SchedulerBinding.instance.scheduleFrameCallback((timer) {
      Provider.of<NotificationProvider>(context, listen: false)
          .readNotification(widget.commentNotificationModel.notificationId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.commentNotificationModel.currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserModel user = UserModel.fromMap(snapshot.data!.data()!);
                return CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                );
              } else {
                return Text('');
              }
            }),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.commentNotificationModel.currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel user =
                                UserModel.fromMap(snapshot.data!.data()!);
                            return Row(
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: khulaRegular),
                                ),
                                if (user.isVerified) verifiedIcon()
                              ],
                            );
                          } else {
                            return Text('');
                          }
                        }),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'replied',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
              CustomProgressPlayer(
                isChatUserPlayer: true,
                size: 10,
                waveColor: whiteColor,
                backgroundColor: primaryColor,
                noteUrl: widget.commentNotificationModel.notification,
                height: 25,
                width: MediaQuery.of(context).size.width * 0.37,
                mainWidth: MediaQuery.of(context).size.width * 0.65,
                mainHeight: 42,
              ),
              // const Text(
              //   'i regullarly enjoyed to that.i would be great here about it',
              //   style: TextStyle(color: Colors.blueGrey),
              // )
            ],
          ),
        ),
        // const SizedBox(
        //   width: 20,
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
        // Container(
        //   decoration: BoxDecoration(color: primaryColor),
        // ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
