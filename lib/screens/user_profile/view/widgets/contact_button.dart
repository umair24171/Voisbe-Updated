import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
// import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class OtherContactButtons extends StatelessWidget {
  const OtherContactButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // var userProvider = Provider.of<UserProfileProvider>(context);
    var currentUSer = Provider.of<UserProvider>(context).user;
    var otherUser = Provider.of<UserProfileProvider>(context).otherUser;
    String text = '';
    if (otherUser!.isPrivate) {
      if (otherUser.followReq.contains(currentUSer!.uid)) {
        text = 'Requested';
      } else if (otherUser.followers.contains(currentUSer.uid)) {
        text = 'Following';
      } else if (otherUser.following.contains(currentUSer.uid)) {
        text = 'Follow back';
      } else {
        text = 'Follow';
      }
    } else {
      if (otherUser.followers.contains(currentUSer!.uid)) {
        text = 'Following';
      } else if (otherUser.following.contains(currentUSer.uid)) {
        text = 'Follow back';
      } else {
        text = 'Follow';
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // if (FirebaseAuth.instance.currentUser!.uid != otherUser!.uid)
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: CustomContactButton(
              onTap: () {
                String notiID = Uuid().v4();
                CommentNotoficationModel notiModel = CommentNotoficationModel(
                    notificationId: notiID,
                    notification: '',
                    currentUserId: currentUSer.uid,
                    notificationType: 'follow',
                    postBackground: '',
                    postThumbnail: '',
                    isRead: '',
                    noteUrl: '',
                    time: DateTime.now(),
                    postType: '',
                    toId: otherUser.uid);
                Provider.of<UserProfileProvider>(context, listen: false)
                    .followUser(currentUSer, otherUser, notiModel);
              },
              icon: 'assets/images/tagpeople_white.png',
              text: text),
        ),
        const SizedBox(
          width: 10,
        ),
        CustomContactButton(
          onTap: () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: otherUser.email,
              queryParameters: {
                'subject': '',
                'body': '',
              },
            );
            if (await launchUrl(emailLaunchUri)) {
            } else {
              throw 'Could not launch $emailLaunchUri';
            }
          },
          icon: 'assets/images/email_button.png',
          text: 'Email',
        ),
        const SizedBox(
          width: 10,
        ),
        CustomContactButton(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverUser: otherUser,
              ),
            ));
          },
          icon: '',
          isMsg: true,
          text: 'Message',
        ),
      ],
    );
  }
}

class CustomContactButton extends StatelessWidget {
  const CustomContactButton(
      {super.key,
      required this.icon,
      required this.text,
      this.isMsg = false,
      required this.onTap});
  final String icon;
  final String text;
  final bool isMsg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 35,
        // padding: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isMsg
                ? Icon(
                    Icons.mic_none,
                    color: whiteColor,
                    size: 25,
                  )
                : Image.asset(
                    icon,
                    height: 20,
                    width: 20,
                  ),
            SizedBox(
              width: isMsg ? 0 : 5,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, left: isMsg ? 0 : 2),
              child: Text(
                text,
                style: TextStyle(
                    color: whiteColor, fontSize: 11, fontFamily: khulaBold),
              ),
            ),
          ],
        ),
      ),
    );
    // ElevatedButton.icon(
    //   style:
    //       ButtonStyle(backgroundColor: MaterialStatePropertyAll(primaryColor)),
    //   onPressed: () {},
    //   icon: Icon(
    //     icon,
    //     color: whiteColor,
    //     size: 22,
    //   ),
    //   label: Text(
    //     text,
    //     style: TextStyle(
    //         color: whiteColor, fontSize: 11, fontFamily: fontFamilyMedium),
    //   ),
    // );
  }
}
