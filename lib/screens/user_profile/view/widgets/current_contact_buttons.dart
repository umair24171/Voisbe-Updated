import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class CurrentContact extends StatelessWidget {
  const CurrentContact({super.key});

  @override
  Widget build(BuildContext context) {
    // var userProvider = Provider.of<UserProfileProvider>(context);
    var currentUSer = Provider.of<UserProvider>(context).user;
    // var otherUser = Provider.of<UserProfileProvider>(context).otherUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // if (FirebaseAuth.instance.currentUser!.uid != otherUser!.uid)
        // CustomContactButton(
        //     onTap: () {
        //       Provider.of<UserProfileProvider>(context, listen: false)
        //           .followUser(currentUSer, otherUser);
        //     },
        //     icon: 'assets/images/tagpeople_white.png',
        //     text: otherUser!.followers.contains(currentUSer!.uid)
        //         ? 'Following'
        //         : 'Follow'),
        CustomContactButton(
          onTap: () {},
          icon: 'assets/images/email_button.png',
          text: 'Email',
        ),
        CustomContactButton(
          onTap: () {},
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
        width: 110,
        height: 35,
        // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isMsg
                ? Icon(
                    Icons.mic_none,
                    color: whiteColor,
                  )
                : Image.asset(
                    icon,
                    height: 20,
                    width: 20,
                  ),
            SizedBox(
              width: 5,
            ),
            Text(
              text,
              style: TextStyle(
                  color: whiteColor,
                  fontSize: 11,
                  fontFamily: fontFamilyMedium),
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
