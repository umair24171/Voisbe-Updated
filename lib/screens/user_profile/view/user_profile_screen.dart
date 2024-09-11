// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

// import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
// import 'package:social_notes/resources/custom_popup.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
// import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:social_notes/screens/settings_screen/view/settings_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
// import 'package:social_notes/screens/upload_sounds/view/upload_sound.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/followers_screen.dart';
import 'package:social_notes/screens/user_profile/view/following_screen.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_drawer.dart';
import 'package:social_notes/screens/user_profile/view/widgets/custom_following_container.dart';
import 'package:social_notes/screens/user_profile/view/widgets/user_posts.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  //  building text span to navigate to the mentioned user profile in bio

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TextSpan> _buildTextSpans(BuildContext context, String bio) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'@(\w+)');
    int start = 0;

    for (final match in regExp.allMatches(bio)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: bio.substring(start, match.start),
          style: TextStyle(
              color: whiteColor, fontSize: 13, fontFamily: fontFamily),
        ));
      }
      final username = match.group(0);
      spans.add(
        TextSpan(
          text: username,
          style: TextStyle(
              color: whiteColor, fontSize: 13, fontFamily: fontFamily),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _navigateToUserProfile(context, username),
        ),
      );
      start = match.end;
    }
    if (start < bio.length) {
      spans.add(TextSpan(
        text: bio.substring(start),
        style:
            TextStyle(color: whiteColor, fontSize: 13, fontFamily: fontFamily),
      ));
    }

    return spans;
  }

  //  navigate to profile from bio

  void _navigateToUserProfile(BuildContext context, String? username) async {
    if (username != null && username.startsWith('@')) {
      final cleanUsername = username.substring(1); // Remove the '@' symbol
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: cleanUsername)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userId =
            userDoc['uid']; // Assuming you store the user ID in the 'uid' field
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfile(userId: userId),
          ),
        );
      } else {
        // Handle user not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'User not found',
            style: TextStyle(color: whiteColor, fontFamily: fontFamily),
          )),
        );
      }
    }
  }

  //  refreshing the posts

  Future<void> _refreshPosts() async {
    // Call the method to fetch updated posts
    await Provider.of<UserProfileProvider>(context, listen: false)
        .getUserPosts(FirebaseAuth.instance.currentUser!.uid);
  }

  //  format to display the length of posts or followers or following

  String formatCount(int count) {
    if (count >= 1000000) {
      double millions = count / 1000000;
      return '${millions.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    //  getting current user posts

    Provider.of<UserProfileProvider>(context, listen: false)
        .getUserPosts(FirebaseAuth.instance.currentUser!.uid);

    //  getting current user data

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserData();
    return userProvider.user == null
        ? SpinKitThreeBounce(
            color: primaryColor,
            size: 20,
          )
        : Scaffold(
            key: _scaffoldKey,
            // drawer: const CustomDrawer(),
            appBar: AppBar(
              backgroundColor: whiteColor,
              surfaceTintColor: whiteColor,
              automaticallyImplyLeading: false,
              title: Row(children: [
                Row(
                  children: [
                    //  showing the current user name

                    Text(
                      userProvider.user!.name,
                      style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 19,
                          fontWeight: FontWeight.w600),
                    ),

                    //  checking if the user is verified

                    if (userProvider.user!.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: SvgPicture.asset(
                          verifiedPath,
                          fit: BoxFit.cover,
                          // color: Colors.blue,
                          height: 13,
                          width: 13,
                        ),
                      )
                    // Image.network(
                    //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                    //   height: 20,
                    //   width: 20,
                    // ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    //  showing the user changing account sheet

                    showModalBottomSheet(
                        useSafeArea: true,
                        enableDrag: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 250,
                            decoration: const BoxDecoration(
                                color: Color(0xff11232f),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  //  building user accounts stored in prefs

                                  Consumer<UserProfileProvider>(
                                      builder: (context, provider, _) {
                                    return Expanded(
                                      child: Card(
                                        color: blackColor.withOpacity(0.2),
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                provider.userAccounts.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 6),
                                                child: InkWell(
                                                  onTap: () async {
                                                    FirebaseAuth auth =
                                                        FirebaseAuth.instance;
                                                    auth.signOut();
                                                    UserCredential credential =
                                                        await auth.signInWithEmailAndPassword(
                                                            email: provider
                                                                .userAccounts[
                                                                    index]
                                                                .email,
                                                            password: provider
                                                                .userAccounts[
                                                                    index]
                                                                .password);
                                                    if (credential.user !=
                                                        null) {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const BottomBar()),
                                                          (route) => false);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(provider
                                                                .userAccounts[
                                                                    index]
                                                                .profileImage),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            provider
                                                                .userAccounts[
                                                                    index]
                                                                .name,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    fontFamily,
                                                                color:
                                                                    whiteColor),
                                                          ),
                                                          if (provider
                                                              .userAccounts[
                                                                  index]
                                                              .isVerified)
                                                            verifiedIcon()
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    );
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: InkWell(
                                      onTap: () {
                                        FirebaseAuth.instance.signOut();

                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return AuthScreen();
                                          },
                                        ));
                                      },
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.add_circle_outline_outlined,
                                            color: whiteColor,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Add VOISBE account',
                                            style: TextStyle(
                                                color: whiteColor,
                                                fontFamily: fontFamily),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: blackColor,
                  ),
                )
              ]),
              actions: [
                //  move to settings screen

                IconButton(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return SettingsScreen();
                      },
                    ));
                  },
                  icon: Icon(
                    Icons.menu,
                    color: blackColor,
                    size: 30,
                  ),
                )
              ],
            ),
            body: Stack(
              children: [
                // background of the screen
                Container(
                  height: size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(userProvider.user!.photoUrl),
                    ),
                  ),
                ),

                //  above that there is a drop filter

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.white.withOpacity(0.1), // Transparent color
                  ),
                ),

                //  refresh the posts

                RefreshIndicator(
                  backgroundColor: whiteColor,
                  color: primaryColor,
                  onRefresh: _refreshPosts,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Stack(
                      children: [
                        //  background gradient pic of the screen

                        Container(
                          child: Image.asset(
                            'assets/icons/profilepage_backgroundgradient 1.png',
                            fit: BoxFit.cover,
                            height: size.height,
                            width: size.width,
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10)
                                  .copyWith(top: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: NetworkImage(
                                              userProvider.user!.photoUrl),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          userProvider.user!.name,
                                          style: TextStyle(
                                              fontFamily: fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        if (userProvider.user!.isVerified)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 4),
                                            child: SvgPicture.asset(
                                              verifiedPath,
                                              fit: BoxFit.cover,
                                              height: 13,
                                              width: 13,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              // height: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  //  getting the username

                                  Text(
                                    userProvider.user!.username,
                                    style: TextStyle(
                                        color: whiteColor,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  //  getting the user bio

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.1,
                                            vertical: 5)
                                        .copyWith(top: 0, bottom: 0),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: _buildTextSpans(
                                              context, userProvider.user!.bio),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            //  showing the user link

                            if (userProvider.user!.link.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      var url =
                                          'https://${userProvider.user!.link}';
                                      if (await launchUrl(Uri.parse(url))) {
                                      } else {
                                        throw Exception(
                                            'Could not launch $url');
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: blackColor,
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Text(
                                        userProvider.user!.link,
                                        style: TextStyle(
                                            color: whiteColor,
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.06)
                                  .copyWith(top: 15, bottom: 5),
                              child: Container(
                                // alignment: Alignment.center,
                                // height: 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35, vertical: 15),
                                decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //  displaying total posts of the user

                                    Consumer<UserProfileProvider>(
                                        builder: (context, userPro, _) {
                                      return CustomFollowing(
                                        number: formatCount(
                                            userPro.userPosts.length),
                                        text: 'Posts',
                                      );
                                    }),
                                    const SizedBox(
                                      width: 30,
                                    ),

                                    //  displaying the total followers of the current user

                                    InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowersScreen(
                                                      userId: userProvider
                                                          .user!.uid),
                                            ));
                                      },
                                      child: CustomFollowing(
                                        number: formatCount(userProvider
                                            .user!.followers.length),
                                        text: 'Followers',
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),

                                    //  displaying the total followings

                                    InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowingScreen(
                                                      userId: userProvider
                                                          .user!.uid),
                                            ));
                                      },
                                      child: CustomFollowing(
                                        number: formatCount(userProvider
                                            .user!.following.length),
                                        text: 'Followings',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const CurrentContact(),
                            const SizedBox(
                              height: 20,
                            ),

                            //  displaying user posts

                            UserPosts(),
                            // SizedBox(height: size.height),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
