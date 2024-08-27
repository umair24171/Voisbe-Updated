import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/auth_screens/view/widgets/verify_email.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:social_notes/screens/settings_screen/view/account_privacy_screen.dart';
import 'package:social_notes/screens/settings_screen/view/blocked_users.dart';
import 'package:social_notes/screens/settings_screen/view/bookmark_screen.dart';
import 'package:social_notes/screens/settings_screen/view/close_friends.dart';
import 'package:social_notes/screens/settings_screen/view/drafts_screen.dart';
import 'package:social_notes/screens/settings_screen/view/edit_subscriptions_screen.dart';
import 'package:social_notes/screens/settings_screen/view/help_screen.dart';
import 'package:social_notes/screens/settings_screen/view/notification_settings.dart';
import 'package:social_notes/screens/settings_screen/view/payment_details_screen.dart';
import 'package:social_notes/screens/settings_screen/view/privacy_policy.dart';
import 'package:social_notes/screens/settings_screen/view/tagged_post_screen.dart';
import 'package:social_notes/screens/settings_screen/view/terms_and_conditions.dart';
import 'package:social_notes/screens/settings_screen/view/two_fa_screen.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/settings_list_tile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final TextEditingController emailCOnt = TextEditingController();
  final TextEditingController passCOnt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var userPro = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: whiteColor,
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
      body: SingleChildScrollView(
        child: Column(
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
                    builder: (context) => const EditSubscriptionsScreen(),
                  ),
                );
              },
              child: const CustomListTile(
                icon: 'assets/icons/Star.svg',
                title: 'Edit Subscriptions',
              ),
            ),
            if (userPro!.isVerified)
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
                        builder: (context) => const DraftsScreen()));
              },
              child: const CustomListTile(
                icon: 'assets/icons/Edit.svg',
                title: 'Drafts',
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
                        builder: (context) => const NotificationSettings()));
              },
              child: const CustomListTile(
                icon: 'assets/icons/Bell.svg',
                title: 'Notifications',
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TaggedPostScreen()));
              },
              child: const CustomListTile(
                icon: 'assets/icons/User_cicrle_light.svg',
                title: 'Tagged Posts',
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TwoFaScreen()));
              },
              child: const CustomListTile(
                icon: 'assets/icons/Key_alt.svg',
                title: 'Two-Factor Authentication',
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
                // showDialog(
                //   context: context,
                //   builder: (context) => AlertDialog(
                //     backgroundColor: whiteColor,
                //     contentPadding: EdgeInsets.all(0),
                //     // insetPadding: EdgeInsets.all(0),
                //     elevation: 0,
                //     content: OtpField(
                //       uid: '',
                //       email: 'umairbilalbzu@gmail.com',
                //     ),
                //   ),
                // );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HelpScreen()));
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
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      backgroundColor: whiteColor,
                      elevation: 0,
                      content: DeleteLoginPopup(
                          emailCOnt: emailCOnt,
                          passCOnt: passCOnt,
                          userPro: userPro)
                      // Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(vertical: 20)
                      //           .copyWith(left: 5),
                      //       child: Text(
                      //         'Are you sure you want to delete?',
                      //         style: TextStyle(
                      //             fontFamily: fontFamily,
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w600),
                      //       ),
                      //     ),
                      //     Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         ElevatedButton(
                      //             style: ButtonStyle(
                      //               backgroundColor: const WidgetStatePropertyAll(
                      //                   Colors.transparent),
                      //               elevation: const WidgetStatePropertyAll(0),
                      //               shape: WidgetStatePropertyAll(
                      //                 RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(18),
                      //                   side: BorderSide(
                      //                       color: blackColor, width: 1),
                      //                 ),
                      //               ),
                      //             ),
                      //             onPressed: () {
                      //               navPop(context);
                      //             },
                      //             child: Text(
                      //               'Cancel',
                      //               style: TextStyle(
                      //                   fontFamily: fontFamily,
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w600),
                      //             )),
                      //         ElevatedButton(
                      //             style: ButtonStyle(
                      //                 backgroundColor:
                      //                     WidgetStatePropertyAll(blackColor),
                      //                 elevation: const WidgetStatePropertyAll(0)),
                      //             onPressed: () async {
                      //               showDialog(
                      //                 context: context,
                      //                 builder: (context) => AlertDialog(
                      //                   elevation: 0,
                      //                   backgroundColor: whiteColor,
                      //                   content: ,
                      //                 ),
                      //               );
                      //             },
                      //             child: Text(
                      //               'Confirm',
                      //               style: TextStyle(
                      //                   color: whiteColor,
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w400),
                      //             ))
                      //       ],
                      //     )
                      //   ],
                      // ),

                      ),
                );
              },
              child: const CustomListTile(
                icon: 'assets/icons/Trash.svg',
                title: 'Delete Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteLoginPopup extends StatelessWidget {
  const DeleteLoginPopup({
    super.key,
    required this.emailCOnt,
    required this.passCOnt,
    required this.userPro,
  });

  final TextEditingController emailCOnt;
  final TextEditingController passCOnt;
  final UserModel? userPro;

  @override
  Widget build(BuildContext context) {
    double mdHeight = MediaQuery.of(context).size.height;
    double mdWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Delete Account?',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: double.infinity,
            height: 1,
            color: Color(0xffEAEAEA),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Please enter your email address and password again to delete your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: const Color(0xff6C6C6C),
                fontWeight: FontWeight.w400,
                fontFamily: fontFamily),
          ),
        ),
        PayFieldWidget(
          controller: emailCOnt,
          hint: 'Email*',
          keyboardType: TextInputType.emailAddress,
          maxLine: 1,
          isAccountNum: false,
          isSwiftCOde: false,
        ),
        // TextFormField(
        //   decoration: InputDecoration(
        //     hintText: 'Password*',
        //     hintStyle: TextStyle(fontFamily: khulaRegular),
        //     constraints: BoxConstraints(
        //         maxHeight: mdHeight * .06, maxWidth: mdWidth * 0.7),
        //     border: OutlineInputBorder(
        //       borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
        //     ),
        //     enabledBorder: OutlineInputBorder(
        //       borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
        //     ),
        //     focusedBorder: OutlineInputBorder(
        //       borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
        //     ),
        //   ),
        // ),
        PayFieldWidget(
          controller: passCOnt,
          hint: 'Password*',
          keyboardType: TextInputType.text,
          isPass: true,
          maxLine: 1,
          isAccountNum: false,
          isSwiftCOde: false,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10).copyWith(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: blackColor, width: 1)),
                  ),
                  onPressed: () {
                    navPop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w700),
                  )),
              const SizedBox(
                width: 15,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(90, 20),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(90, 35),
                    elevation: 0,
                    backgroundColor: blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:
                          const BorderSide(color: Colors.transparent, width: 1),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: emailCOnt.text, password: passCOnt.text)
                        .then((userCred) async {
                      if (userCred.user != null) {
                        await FirebaseAuth.instance.currentUser!.delete();
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userPro!.uid)
                            .delete();
                        var userPosts = Provider.of<UserProfileProvider>(
                                context,
                                listen: false)
                            .userPosts;

                        for (var note in userPosts) {
                          await FirebaseFirestore.instance
                              .collection('notes')
                              .doc(note.noteId)
                              .delete();
                        }

                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        List<String>? users =
                            sharedPreferences.getStringList('userAccounts');
                        if (users != null) {
                          sharedPreferences.setStringList('userAccounts', []);
                        }
                        FirebaseAuth auth = FirebaseAuth.instance;

                        auth.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(),
                            ));
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .orderBy('time', descending: true)
                            .get()
                            .then((value) async {
                          List<RecentChatModel> allChatoo = [];
                          List<RecentChatModel> chatModel = value.docs
                              .map((e) => RecentChatModel.fromMap(e.data()))
                              .toList();
                          var currentUser =
                              Provider.of<UserProvider>(context, listen: false)
                                  .user;
                          allChatoo.clear();

                          for (int i = 0; i < chatModel.length; i++) {
                            if (chatModel[i].senderId == currentUser!.uid ||
                                chatModel[i].receiverId == currentUser.uid) {
                              allChatoo.add(chatModel[i]);
                            }
                          }
                          for (var chat in allChatoo) {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chat.usersId)
                                .delete();
                          }
                        });
                      }
                    });
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                        color: whiteColor,
                        fontSize: 14,
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w700),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
