import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/view/add_note_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_ask.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_language.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
// import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';
import 'package:social_notes/screens/chat_screen.dart/view/users_screen.dart';
import 'package:social_notes/screens/home_screen/controller/share_services.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/feed_detail_screen.dart';
// import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
// import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/notifications_screen/controller/notification_provider.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
// import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:social_notes/screens/search_screen/view/search_screen.dart';
// import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/user_profile_screen.dart';
// import 'package:service';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';

// import 'add_note_screen/provider/note_provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
    // this.note,
  });
  static const routeName = 'bottom-bar';
  // final NoteModel? note;
  // final int? screenChange;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  PageController pageController = PageController(initialPage: 0);

  void onPageChanged(int page) {
    // Provider.of<BottomProvider>(context, listen: false).setCurrentIndex(page);
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    stopMainPlayer();
    Provider.of<CircleCommentsProvider>(context, listen: false).pausePlayer();
  }

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

  @override
  void initState() {
    SchedulerBinding.instance.scheduleFrameCallback(
      (timeStamp) {
        updateUserToken();
        Provider.of<DisplayNotesProvider>(context, listen: false)
            .getAllNotes(context);
        Provider.of<UserProvider>(context, listen: false).getUserData();

        Provider.of<UserProfileProvider>(context, listen: false)
            .geUserAccounts();
        Provider.of<ChatProvider>(context, listen: false).getAllUsersForChat();

        DeepLinkPostService().initDynamicLinks(context);
        DeepLinkPostService().initDynamicLinksForProfile(context);
      },
    );

    super.initState();
  }

  updateUserToken() async {
    String token = await NotificationMethods().getFirebaseMessagingToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'token': token});
    log("updated");
  }

  // setIndex() {
  //   Provider.of<BottomProvider>(context, listen: false).setCurrentIndex(1);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: PopScope(
        onPopInvoked: (value) {
          // setIndex();
        },
        child: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: onPageChanged,
          children: [
            HomeScreen(),
            SearchScreen(),
            const AddNoteScreen(),
            const UsersScreen(),
            UserProfileScreen()
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: BottomNavigationBar(
          fixedColor: whiteColor,

          // landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          elevation: 0,
          type: BottomNavigationBarType.fixed,

          onTap: navigationTapped,
          currentIndex: _page,
          backgroundColor: whiteColor,
          selectedIconTheme: IconThemeData(color: blackColor),
          unselectedIconTheme: IconThemeData(color: blackColor),
          items: [
            BottomNavigationBarItem(
              backgroundColor: whiteColor,
              icon: Padding(
                padding: const EdgeInsets.only(left: 20, top: 5),
                child: SvgPicture.asset(
                  _page == 0
                      ? 'assets/icons/home icon active.svg'
                      : 'assets/icons/home.svg',
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
              ),
              // Image.asset(
              //   'assets/images/home_nav.png',
              //   height: 40,
              //   width: 40,
              // ),
              // backgroundColor: primaryColor,
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  _page == 1
                      ? 'assets/icons/Search icon active.svg'
                      : 'assets/icons/Search.svg',
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
              ),
              label: '',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  _page == 2
                      ? 'assets/icons/new post icon active.svg'
                      : 'assets/icons/Add_ring.svg',
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
              ),
              label: '',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  'assets/icons/Subtract.svg',
                  // height: 30,
                  // width: 30,
                  color: _page == 3 ? primaryColor : null,
                  fit: BoxFit.cover,
                ),
              ),
              label: '',
              // backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Consumer<UserProvider>(builder: (context, userPro, _) {
                  return CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(userPro.user != null
                        ? userPro.user!.photoUrl
                        : 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                  );
                }),
              ),
              label: '',
              // backgroundColor: primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
