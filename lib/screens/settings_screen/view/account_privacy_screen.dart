import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/settings_screen/view/widgets/subscription_list_tile.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  // @override
  @override
  Widget build(BuildContext context) {
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
          'Account Privacy',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Unlock.svg',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Private Account',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: khulaRegular,
                          color: blackColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              // SvgPicture.asset(
              //   'assets/icons/Toggle.svg',
              //   height: 30,
              //   width: 30,
              // ),
              Consumer<UserProvider>(builder: (context, userPro, _) {
                return Switch(
                  value: userPro.user!.isPrivate,
                  onChanged: (value) async {
                    userPro.updateUserField(value);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userPro.user!.uid)
                        .update({'isPrivate': value});
                  },
                  activeTrackColor: const Color(0xffFFD3A5),
                  activeColor: const Color(0xffFFA451),
                );
              }),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: Text(
              'When your account is public, your profile and posts can be seen by anyone, on or off VOISBE, even if they don\'t have a VOISBE account. When your account is private, only the followers you approve can see what you share, and your followers and following lists.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                  color: const Color(0xff6C6C6C),
                  fontFamily: khulaRegular,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
