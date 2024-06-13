import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:social_notes/screens/settings_screen/view/account_privacy_screen.dart';
import 'package:social_notes/screens/settings_screen/view/blocked_users.dart';
import 'package:social_notes/screens/settings_screen/view/bookmark_screen.dart';
import 'package:social_notes/screens/settings_screen/view/close_friends.dart';
import 'package:social_notes/screens/settings_screen/view/edit_subscriptions_screen.dart';
import 'package:social_notes/screens/settings_screen/view/help_screen.dart';
import 'package:social_notes/screens/settings_screen/view/payment_details_screen.dart';
import 'package:social_notes/screens/settings_screen/view/privacy_policy.dart';
import 'package:social_notes/screens/settings_screen/view/terms_and_conditions.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/settings_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xffEAEAEA),
            height: 1,
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            isMainPro: true,
                          )));
            },
            child: const CustomListTile(
              icon: 'assets/icons/User_box.svg',
              title: 'Edit Profile',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditSubscriptionsScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Star.svg',
              title: 'Edit Subscriptions',
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentDetailsScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Credit card.svg',
              title: 'Payment Details',
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookMarkScreenSettings()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Bookmark.svg',
              title: 'Bookmarks',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountPrivacyScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Unlock.svg',
              title: 'Account Privacy',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CloseFriendsScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Group.svg',
              title: 'Close Friends',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BlockedUsersScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Cancel.svg',
              title: 'Blocked Users',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Question.svg',
              title: 'Help',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicy()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Info.svg',
              title: 'Privacy Policy',
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsAndConditions()));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Info.svg',
              title: 'Terms & Conditions',
            ),
          ),
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return AuthScreen();
                    },
                  ), (route) => false));
            },
            child: const CustomListTile(
              icon: 'assets/icons/Sign_out_squre.svg',
              title: 'Logout',
            ),
          ),
        ],
      ),
    );
  }
}
