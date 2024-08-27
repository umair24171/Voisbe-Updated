import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
// import 'package:social_notes/screens/settings_screen/view/widgets/subscription_list_tile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class CloseFriendsScreen extends StatefulWidget {
  const CloseFriendsScreen({super.key});

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  @override
  void initState() {
    // getting the close friends list and saving in the provider

    log('close firends ids ${Provider.of<UserProvider>(context, listen: false).user!.closeFriends}');
    Provider.of<UserProfileProvider>(context, listen: false).getCloseFriends(
        Provider.of<UserProvider>(context, listen: false).user!.closeFriends);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
          'Close Friends',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),

            //  searching the friend

            child: TextFormField(
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: blackColor,
                  ),
                  contentPadding: const EdgeInsets.all(0).copyWith(left: 14),
                  constraints: BoxConstraints(
                      maxWidth: size.width * 0.9, minHeight: 36, maxHeight: 36),
                  hintText: 'Search',
                  fillColor: const Color(0xffD9D9D9),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(
                    color: const Color(0xff3C3C43),
                    fontFamily: khulaRegular,
                    fontSize: 17,
                  )),
            ),
          ),

//  building the close friend list

          Consumer<UserProfileProvider>(builder: (context, userPro, _) {
            //  getting the close friend list saved in the provider

            log('close friends ${userPro.closeFriends}');
            return ListView.builder(
                shrinkWrap: true,
                itemCount: userPro.closeFriends.length,
                itemBuilder: (context, index) {
                  UserModel user = userPro.closeFriends[index];

                  //  template of the close friend

                  return CloseFriendListTile(
                    user: user,
                  );
                });
          }),
        ],
      ),
    );
  }
}

class CloseFriendListTile extends StatelessWidget {
  const CloseFriendListTile({
    super.key,
    required this.user,
  });
  final UserModel user;

  //  getting the user model from the constructor

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    return ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherUserProfile(userId: user.uid),
              ));
        },

        //  image of the user

        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            user.photoUrl,
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //  name of the user

            Text(
              user.name,
              style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
                  fontFamily: khulaRegular,
                  fontWeight: FontWeight.w600),
            ),

            //  if the user is verified or nott

            if (user.isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: verifiedIcon(),
              )
            // Image.network(
            //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
            //   height: 20,
            //   width: 20,
            // )
          ],
        ),
        trailing: Consumer<UserProvider>(builder: (context, userPro, _) {
          return InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              if (userPro.user!.closeFriends.contains(user.uid)) {
                //  removing user as  a closing friend

                userPro.removeUSerFieldForCloseFriends(user.uid);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userProvider!.uid)
                    .update({
                  'closeFriends': FieldValue.arrayRemove([user.uid])
                });
              } else {
                //  adding user as a close friend

                userPro.updateUserFieldForCloseFriends(user.uid);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userProvider!.uid)
                    .update({
                  'closeFriends': FieldValue.arrayUnion([user.uid])
                });
              }
            },
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                // height: 33,
                // width: 33,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: userPro.user!.closeFriends.contains(user.uid)
                      ? whiteColor
                      : blackColor,
                  border: Border.all(
                    width: 1,
                    color: const Color(0xff868686),
                  ),
                ),

                //  showing the icon based on the close friend or nott

                child: userPro.user!.closeFriends.contains(user.uid)
                    ? SvgPicture.asset(
                        'assets/icons/x.svg',
                        height: 25,
                        width: 25,
                      )
                    // Icon(Icons.cancel, color: blackColor, size: 20)
                    : SvgPicture.asset(
                        'assets/icons/check.svg',
                        height: 25,
                        width: 25,
                      )
                // Icon(Icons.check, color: whiteColor, size: 20),
                ),
          );
        }));
  }
}
