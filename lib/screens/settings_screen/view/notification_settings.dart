import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late bool isLike = false;
  bool isReply = false;
  bool isFOllows = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          leading: IconButton(
            onPressed: () {
              navPop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: blackColor,
              size: 30,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: khulaBold,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20)
                .copyWith(top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Favorite.svg',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Likes',
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ],
                ),
                Consumer<UserProvider>(builder: (context, userPro, _) {
                  return Switch(
                    value: userPro.user!.isLike,
                    thumbColor: WidgetStatePropertyAll(whiteColor),
                    onChanged: (value) async {
                      currentUser.updateUserLike(value);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userPro.user!.uid)
                          .update({'isLike': value});
                    },
                    activeTrackColor: blackColor,
                    activeColor: const Color(0xffFFA451),
                  );
                })
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                'Receive a push notification whenever someone liked your posts.',
                style: TextStyle(
                    color: Color(0xff6C6C6C),
                    fontFamily: khulaRegular,
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Mic.svg',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Replies',
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ],
                ),
                Consumer<UserProvider>(builder: (context, userPro, _) {
                  return Switch(
                    // activeThumbImage: NetworkImage(''),
                    thumbColor: WidgetStatePropertyAll(whiteColor),
                    value: userPro.user!.isReply,
                    onChanged: (value) async {
                      currentUser.updateUserReply(value);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userPro.user!.uid)
                          .update({'isReply': value});
                    },
                    activeTrackColor: blackColor,
                    activeColor: const Color(0xffFFA451),
                  );
                })
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                'Receive a push notification whenever someone replied to your post.',
                style: TextStyle(
                    fontFamily: khulaRegular,
                    color: Color(0xff6C6C6C),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/User_add_alt.svg',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Follows',
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ],
                ),
                Consumer<UserProvider>(builder: (context, userPro, _) {
                  return Switch(
                    thumbColor: WidgetStatePropertyAll(whiteColor),
                    value: userPro.user!.isFollows,
                    onChanged: (value) async {
                      // userPro.updateUserField(value);
                      currentUser.updateUserFollow(value);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userPro.user!.uid)
                          .update({'isFollows': value});
                    },
                    activeTrackColor: blackColor,
                    activeColor: const Color(0xffFFA451),
                  );
                })
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                'Receive a push notification whenever someone follows you.',
                style: TextStyle(
                    fontFamily: khulaRegular,
                    color: Color(0xff6C6C6C),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
            ),
          ),
        ]));
  }
}
