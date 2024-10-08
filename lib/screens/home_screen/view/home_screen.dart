import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';

import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/users_screen.dart';

import 'package:social_notes/screens/home_screen/model/feed_detail_model.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/home_screen/provider/video_player_manager.dart';
import 'package:social_notes/screens/home_screen/view/feed_detail_screen.dart';
import 'package:social_notes/screens/home_screen/view/widgets/single_post_note.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
import 'package:social_notes/screens/notifications_screen/notifications_screen.dart';
import 'package:social_notes/screens/search_screen/view/widgets/search_player.dart';
import 'package:social_notes/screens/search_screen/view/widgets/search_player_two.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, this.note, this.noteId});
  static const routeName = '/home';

  // getting data from the construtor if not coming from the login screen

  NoteModel? note;
  final String? noteId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController = PageController();
  void _initializeHomeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // getting specific post if the user is coming from the notification
        getNoteUsingId();

        final displayNotesProvider =
            Provider.of<DisplayNotesProvider>(context, listen: false);

        //  setting the value of home to true
        displayNotesProvider.setHomeActive(true);

        // getting all the chat users

        Provider.of<ChatProvider>(context, listen: false).getAllUsersForChat();

        //  setting the default filter to for you

        Provider.of<FilterProvider>(context, listen: false)
            .setSelectedFilter('For you');

        //  getting the user data and saving into the provider

        Provider.of<UserProvider>(context, listen: false).getUserData();

        // getting all the users

        Provider.of<DisplayNotesProvider>(context, listen: false).getAllUsers();

        // getting personalization data of the user

        Provider.of<FilterProvider>(context, listen: false)
            .getPersoanlizeData();
        // Other initialization logic
      }
    });
  }

  getNoteUsingId() async {
    if (widget.noteId != null) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.noteId)
          .get()
          .then((value) {
        widget.note = NoteModel.fromMap(value.data()!);
        setState(() {});
      });
    }
  }

  getAllNotesWithUsers() async {
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .getAllNotes(context);
    Provider.of<ChatProvider>(context, listen: false).getAllUsersForChat();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    //  calling it in init before the screen builds

    _initializeHomeScreen();
  }

  //  getting all the topics for the filter

  List<String> topics = [
    'Need support',
    'Relationship & love',
    'Confession & secret',
    'Inspiration & motivation',
    'Food & Cooking',
    'Personal Story',
    'Business',
    'Something I learned',
    'Education & Learning',
    'Books & Literature',
    'Spirit & Mind',
    'Travel & Adventure',
    'Fashion & Style',
    'Creativity & Art',
    'Humor & Comedy',
    'Sports & Fitness',
    'Technology & Innovation',
    'Current Events & News',
    'Health & Wellness',
    'Hobbies & Interests'
  ];

  //  getting all the colors of the topics

  List<Color> topicColors = [
    const Color(0xff503e3b), // color1
    const Color(0xffcd3826), // color2
    const Color(0xffcf4736), // color3
    const Color(0xffe6b619), // color4
    const Color(0xff8ab756), // color5
    const Color(0xffeb6447), // color6
    const Color(0xff3694de), // color7
    const Color(0xffe69319), // color8
    const Color(0xff7c69de), // color9
    const Color(0xff885341), // color10
    const Color(0xff9235a2), // color11
    const Color(0xff56a559), // color12
    const Color(0xffd53269), // color13
    const Color(0xff6a46ab), // color14
    const Color(0xffe154a1), // color15
    const Color(0xff15acbf), // color16
    const Color(0xff45897a), // color17
    const Color(0xff472861), // color18
    const Color(0xff37728c), // color19
    const Color(0xff6cb57f), // color20
  ];

  Color _getColor(int index) {
    return topicColors[index % topicColors.length];
  }

// stopping main player while adding the reply

  stopMainPlayer() {
    Provider.of<DisplayNotesProvider>(context, listen: false).pausePlayer();
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setIsPlaying(false);
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setChangeIndex(-1);
  }

// disposing the player when no longer needs it
  @override
  void dispose() {
    Provider.of<DisplayNotesProvider>(context, listen: false)
        .setHomeActive(false);

    super.dispose();
  }

  andhi() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;

    //  get prvider for displaying posts
    var provider = Provider.of<DisplayNotesProvider>(
      context,
    );

    // get provider ofr changing the filter

    var filterProvider = Provider.of<FilterProvider>(context, listen: false);

    //  getting current user data ]

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    // userProvider.getUserData();

    return Scaffold(
        extendBody: widget.note == null ? false : true,
        extendBodyBehindAppBar: widget.note == null ? false : true,
        appBar: AppBar(
          elevation: 0,
          bottomOpacity: 0,
          foregroundColor:
              widget.note == null ? whiteColor : Colors.transparent,
          shadowColor: widget.note == null ? whiteColor : Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: whiteColor,
          backgroundColor:
              widget.note == null ? whiteColor : Colors.transparent,
          forceMaterialTransparency: false,
          automaticallyImplyLeading: false,
          title: widget.note != null
              ? null
              : Row(
                  children: [
                    //  getting the selected filter and managing by provider

                    Consumer<FilterProvider>(builder: (context, filterPro, _) {
                      return Text(
                        filterPro.selectedFilter,
                        style: TextStyle(
                            color: blackColor,
                            fontFamily: fontFamilyMedium,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      child: Consumer<FilterProvider>(
                          builder: (context, filPro, _) {
                        return IconButton(
                          onPressed: () {
                            showMenu(
                                elevation: 0,
                                color: whiteColor,
                                surfaceTintColor: whiteColor,
                                shadowColor: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                context: context,
                                position:
                                    const RelativeRect.fromLTRB(0, 80, 0, 0),
                                items: [
                                  if (!filPro.selectedFilter
                                      .contains('Close Friends'))
                                    PopupMenuItem(
                                      onTap: () {
                                        filterProvider
                                            .setSelectedFilter('Close Friends');
                                      },
                                      value: 'Close Friends',
                                      child: Row(
                                        children: [
                                          Icon(Icons.group_outlined,
                                              color: blackColor),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'Close Friends',
                                            style: TextStyle(
                                                fontFamily: fontFamily),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!filPro.selectedFilter
                                      .contains('Filter Topics'))
                                    PopupMenuItem(
                                      onTap: () {
                                        filterProvider
                                            .setSelectedFilter('Filter Topics');
                                      },
                                      value: 'Filter Topics',
                                      child: Row(
                                        children: [
                                          Icon(Icons.filter_list,
                                              color: blackColor),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'Filter Topics',
                                            style: TextStyle(
                                                fontFamily: fontFamily),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (filPro.selectedFilter
                                          .contains('Filter Topics') ||
                                      filPro.selectedFilter
                                          .contains('Close Friends'))
                                    PopupMenuItem(
                                      onTap: () {
                                        filterProvider
                                            .setSelectedFilter('For you');
                                      },
                                      value: 'For you',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              color: blackColor),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'For you',
                                            style: TextStyle(
                                                fontFamily: fontFamily),
                                          ),
                                        ],
                                      ),
                                    ),
                                ]);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: blackColor,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
          actions: [
            if (widget.note == null) const CustomNotificationIcon(),
            if (widget.note == null)

              //  navigating to chat screen

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14)
                    .copyWith(left: 2),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const UsersScreen();
                      },
                    ));
                  },
                  child: SvgPicture.asset(
                    'assets/icons/Subtract.svg',
                    height: 22,
                    width: 22,
                    // color: _page == 3 ? primaryColor : null,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            //  ui hide screen logics

            Consumer<FilterProvider>(builder: (context, filPro, _) {
              List<NoteModel> filteredNotes = provider.notes.where((note) {
                // Always show the post to its owner
                if (note.userUid == userProvider.user!.uid) {
                  return true;
                }

                // Check other conditions
                if (userProvider.user!.blockedUsers.contains(note.userUid) ||
                    (note.isPostForSubscribers &&
                        !userProvider.user!.subscribedSoundPacks
                            .contains(note.userUid)) ||
                    userProvider.user!.mutedAccouts.contains(note.userUid)) {
                  return false;
                }
                UserModel user =
                    Provider.of<ChatProvider>(context, listen: false)
                        .users
                        .firstWhere(
                          (element) => element.uid == note.userUid,
                        );

                bool isContains =
                    userProvider.user!.following.contains(note.userUid);

                bool isAccountPrivate = user.isPrivate;

                log('is contains $isContains');
                log('is private $isAccountPrivate');
                // New check for private accounts
                if (user.isPrivate &&
                    !userProvider.user!.following.contains(note.userUid) &&
                    note.userUid != userProvider.user!.uid) {
                  return false;
                }

                return true;
              }).toList();

              List<NoteModel> personalizedNotes = [];
              personalizedNotes.clear();
              if (filPro.userPersonalizeData != null &&
                  !filPro.selectedFilter.contains('Close Friends') &&
                  !filPro.selectedFilter.contains('Filter Topics')) {
                log('Person data ${filPro.userPersonalizeData!.interest}');
                for (var note in filteredNotes) {
                  if (filPro.userPersonalizeData!.interest
                          .contains(note.topic) ||
                      note.userUid == userProvider.user!.uid ||
                      userProvider.user!.following.contains(note.userUid)) {
                    personalizedNotes.add(note);
                  }
                }
              } else if (filPro.selectedFilter.contains('Close Friends')) {
                filPro.closeFriendsPosts.clear();

                for (var element in userProvider.user!.closeFriends) {
                  for (var note in filteredNotes) {
                    if (element.contains(note.userUid)) {
                      filPro.closeFriendsPosts.add(note);
                    }
                  }
                }
              } else if (filPro.selectedFilter.contains('Filter Topics')) {
                filPro.searcheNote.clear();
                for (var note in filteredNotes) {
                  if (note.topic.contains(filPro.searchValue)) {
                    filPro.searcheNote.add(note);
                  }
                }
              }

              return InkWell(
                onTap: () {
                  int page = _pageController.page!.round();
                  log('currentPage ${_pageController.page!.round()}');
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      FeedDetailModel feedDetailModel = FeedDetailModel(
                          note: widget.note != null
                              ? widget.note!
                              : filPro.userPersonalizeData != null &&
                                      !filPro.selectedFilter
                                          .contains('Close Friends') &&
                                      !filPro.selectedFilter
                                          .contains('Filter Topics')
                                  ? personalizedNotes[page]
                                  : filPro.selectedFilter
                                          .contains('Close Friends')
                                      ? filPro.closeFriendsPosts[page]
                                      : filPro.selectedFilter
                                              .contains('Filter Topics')
                                          ? filPro.searcheNote[page]
                                          : filteredNotes[page],
                          duration: provider.duration,
                          position: provider.position,
                          playPause: () {
                            provider.playPause(
                                filPro.userPersonalizeData != null &&
                                        !filPro.selectedFilter
                                            .contains('Close Friends') &&
                                        !filPro.selectedFilter
                                            .contains('Filter Topics')
                                    ? personalizedNotes[page].noteUrl
                                    : filPro.selectedFilter
                                            .contains('Close Friends')
                                        ? filPro.closeFriendsPosts[page].noteUrl
                                        : filPro.selectedFilter
                                                .contains('Filter Topics')
                                            ? filPro.searcheNote[page].noteUrl
                                            : widget.note != null
                                                ? widget.note!.noteUrl
                                                : filteredNotes[page].noteUrl,
                                0);
                          },
                          audioPlayer: provider.audioPlayer,
                          changeIndex: provider.changeIndex,
                          isPlaying: provider.isPlaying,
                          pageController: _pageController,
                          currentIndex: page,
                          isMainPlayer: true);

                      // Navigating to UI hide screen

                      return FeedDetailScreen(
                        feedModel: feedDetailModel,
                      );
                    },
                  ));
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14)
                          .copyWith(left: 2),
                      child: SvgPicture.asset(
                        'assets/icons/mobile.svg',
                        height: 28,
                        width: 28,
                        color: widget.note == null ? null : whiteColor,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 11,
                      top: 9.5,
                      child: SvgPicture.asset(
                        'assets/icons/minus.svg',
                        height: 10,
                        width: 10,
                        color: widget.note == null ? null : whiteColor,
                        // color: _page == 3 ? primaryColor : null,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
        ),

        //  body starts

        body:
            //  while the posts are loading show loader
            provider.notes.isEmpty
                ? Center(
                    child: SpinKitThreeBounce(
                      color: whiteColor,
                      size: 20,
                    ),
                  )

                //  refresh the posts to fetch the latest posts

                : RefreshIndicator(
                    backgroundColor: whiteColor,
                    color: primaryColor,
                    onRefresh: () {
                      return widget.note == null
                          ? getAllNotesWithUsers()
                          : andhi();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: [
                          //  default background color

                          Consumer<FilterProvider>(
                              builder: (context, filterpro, _) {
                            return Container(
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [
                                        0.25,
                                        0.75,
                                      ],
                                      colors: filterpro.selectedFilter
                                              .contains('Close Friends')
                                          ? [greenColor, greenColor]
                                          : [
                                              const Color(0xffee856d),
                                              const Color(0xffed6a5a)
                                            ])),
                            );
                          }),

                          //  show the topics if the selected filter is filter topics

                          SizedBox(
                            height: size.height,
                            child: Column(
                              children: [
                                Consumer<FilterProvider>(
                                  builder: (context, filterPro, _) {
                                    return !filterProvider.selectedFilter
                                            .contains('Filter Topics')
                                        ? const SizedBox()
                                        : SizedBox(
                                            height: 50,
                                            width: double.infinity,
                                            child: ListView.builder(
                                              itemCount: topics.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) =>
                                                  Stack(
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    height: 50,
                                                    color: _getColor(index + 1 <
                                                            topics.length
                                                        ? index + 1
                                                        : index),
                                                  ),
                                                  Container(
                                                    width: 150,
                                                    height: 50,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      color: _getColor(index),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(40),
                                                        bottomRight:
                                                            Radius.circular(40),
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        filterPro.searchValue =
                                                            '';
                                                        filterPro
                                                            .setSearchingValue(
                                                                topics[index]);
                                                      },
                                                      child: Text(
                                                        topics[index],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                  },
                                ),

                                //  building the notes or posts through the page builder

                                Expanded(
                                  child: Consumer<FilterProvider>(
                                      builder: (context, filPro, _) {
                                    final userProvider =
                                        Provider.of<UserProvider>(context,
                                            listen: false);

                                    // filtering the posts
                                    // certain checks

                                    List<NoteModel> getFilteredNotes() {
                                      return provider.notes.where((note) {
                                        // Always show the post to its owner
                                        if (note.userUid ==
                                            userProvider.user!.uid) {
                                          return true;
                                        }

                                        // Check other conditions
                                        if (userProvider.user!.blockedUsers
                                                .contains(note.userUid) ||
                                            (note.isPostForSubscribers &&
                                                !userProvider
                                                    .user!.subscribedSoundPacks
                                                    .contains(note.userUid)) ||
                                            userProvider.user!.mutedAccouts
                                                .contains(note.userUid)) {
                                          return false;
                                        }
                                        UserModel user =
                                            Provider.of<ChatProvider>(context,
                                                    listen: false)
                                                .users
                                                .firstWhere(
                                                  (element) =>
                                                      element.uid ==
                                                      note.userUid,
                                                );

                                        bool isContains = userProvider
                                            .user!.following
                                            .contains(note.userUid);

                                        bool isAccountPrivate = user.isPrivate;

                                        log('is contains $isContains');
                                        log('is private $isAccountPrivate');
                                        // New check for private accounts
                                        if (user.isPrivate &&
                                            !userProvider.user!.following
                                                .contains(note.userUid) &&
                                            note.userUid !=
                                                userProvider.user!.uid) {
                                          return false;
                                        }
                                        return true;
                                      }).toList();
                                    }

                                    //  get personalized posts

                                    List<NoteModel> getPersonalizedNotes(
                                        List<NoteModel> filteredNotes) {
                                      if (filPro.userPersonalizeData == null ||
                                          filPro.selectedFilter
                                              .contains('Close Friends') ||
                                          filPro.selectedFilter
                                              .contains('Filter Topics')) {
                                        return [];
                                      }
                                      return filteredNotes
                                          .where((note) =>
                                              filPro
                                                  .userPersonalizeData!.interest
                                                  .contains(note.topic) ||
                                              note.userUid ==
                                                  userProvider.user!.uid ||
                                              userProvider.user!.following
                                                  .contains(note.userUid))
                                          .toList();
                                    }

                                    //  get close friend posts

                                    List<NoteModel> getCloseFriendsPosts(
                                        List<NoteModel> filteredNotes) {
                                      if (!filPro.selectedFilter
                                          .contains('Close Friends')) return [];
                                      return filteredNotes
                                          .where((note) => userProvider
                                              .user!.closeFriends
                                              .contains(note.userUid))
                                          .toList();
                                    }

// get posts based on the selected filter

                                    List<NoteModel> getFilteredTopicNotes(
                                        List<NoteModel> filteredNotes) {
                                      if (!filPro.selectedFilter
                                          .contains('Filter Topics')) return [];
                                      return filteredNotes
                                          .where((note) => note.topic
                                              .contains(filPro.searchValue))
                                          .toList();
                                    }

                                    final filteredNotes = getFilteredNotes();
                                    final personalizedNotes =
                                        getPersonalizedNotes(filteredNotes);
                                    final closeFriendsPosts =
                                        getCloseFriendsPosts(filteredNotes);
                                    final filteredTopicNotes =
                                        getFilteredTopicNotes(filteredNotes);

                                    List<NoteModel> getCurrentNotes() {
                                      if (widget.note != null) {
                                        return [widget.note!];
                                      }
                                      if (personalizedNotes.isNotEmpty) {
                                        return personalizedNotes;
                                      }
                                      if (closeFriendsPosts.isNotEmpty) {
                                        return closeFriendsPosts;
                                      }
                                      if (filteredTopicNotes.isNotEmpty) {
                                        return filteredTopicNotes;
                                      }
                                      return filteredNotes;
                                    }

                                    final currentNotes = getCurrentNotes();

                                    if (filPro.detailsNote == null &&
                                        currentNotes.isNotEmpty) {
                                      Provider.of<FilterProvider>(context,
                                              listen: false)
                                          .setFirstDetailNote(
                                              currentNotes.first);
                                    }

                                    //  building the posts after the filteration

                                    return PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (value) {
                                          final currentNote =
                                              currentNotes[value];
                                          provider.playPause(
                                              currentNote.noteUrl, value);
                                        },
                                        itemCount: filPro.userPersonalizeData !=
                                                    null &&
                                                !filPro.selectedFilter.contains(
                                                    'Close Friends') &&
                                                !filPro.selectedFilter
                                                    .contains('Filter Topics')
                                            ? personalizedNotes.length
                                            : filPro.selectedFilter
                                                    .contains('Close Friends')
                                                ? filPro
                                                    .closeFriendsPosts.length
                                                : filPro.selectedFilter
                                                        .contains(
                                                            'Filter Topics')
                                                    ? filPro.searcheNote.length
                                                    : widget.note != null
                                                        ? 1
                                                        : filteredNotes.length,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (context, index) {
                                          final note = widget.note ??
                                              (filPro.userPersonalizeData !=
                                                          null &&
                                                      !filPro.selectedFilter
                                                          .contains(
                                                              'Close Friends') &&
                                                      !filPro.selectedFilter
                                                          .contains(
                                                              'Filter Topics')
                                                  ? personalizedNotes[index]
                                                  : filPro.selectedFilter
                                                          .contains(
                                                              'Close Friends')
                                                      ? filPro.closeFriendsPosts[
                                                          index]
                                                      : filPro.selectedFilter
                                                              .contains(
                                                                  'Filter Topics')
                                                          ? filPro.searcheNote[
                                                              index]
                                                          : filteredNotes[
                                                              index]);

                                          final key = ValueKey<String>(
                                              'comment_${note.noteId}');
                                          return Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Stack(
                                              children: [
                                                //  background of the post
                                                note.backgroundImage.isNotEmpty
                                                    ? Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        child: Stack(
                                                          children: [
                                                            //showing the drop filter above the image or video

                                                            ClipRRect(
                                                                child:
                                                                    BackdropFilter(
                                                                        filter: ImageFilter.blur(
                                                                            sigmaX:
                                                                                3,
                                                                            tileMode: TileMode
                                                                                .mirror,
                                                                            sigmaY:
                                                                                3),
                                                                        child:
                                                                            Container(
                                                                          color: Colors
                                                                              .white
                                                                              .withOpacity(0.15), // Transparent color

                                                                          child: Container(
                                                                              height: MediaQuery.of(context).size.height,
                                                                              child: _buildBackgroundContent(
                                                                                note,
                                                                                context,
                                                                                // index,
                                                                                // provider.changeIndex
                                                                              )),
                                                                        ))),
                                                            Container(
                                                              child: ClipRRect(
                                                                child:
                                                                    BackdropFilter(
                                                                  filter: ImageFilter.blur(
                                                                      sigmaX: 3,
                                                                      tileMode:
                                                                          TileMode
                                                                              .mirror,
                                                                      sigmaY:
                                                                          3),
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.15), // Transparent color
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            //  showing the gradient above the blur filter
                                                            Container(
                                                              height:
                                                                  size.height,
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter,
                                                                  stops: const [
                                                                    0.25,
                                                                    0.75
                                                                  ],
                                                                  colors: [
                                                                    Colors
                                                                        .transparent,
                                                                    Colors.black
                                                                        .withOpacity(
                                                                            0.5)
                                                                    // const Color(
                                                                    //         0xff3d3d3d)
                                                                    //     .withOpacity(
                                                                    //         0.5),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )

                                                    //  default background color

                                                    : Consumer<FilterProvider>(
                                                        builder: (context,
                                                            filterpro, _) {
                                                        return Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                          begin: Alignment
                                                                              .topCenter,
                                                                          end: Alignment
                                                                              .bottomCenter,
                                                                          stops: const [
                                                                            0.25,
                                                                            0.75,
                                                                          ],
                                                                          colors: filterpro.selectedFilter.contains('Close Friends')
                                                                              ? [
                                                                                  greenColor,
                                                                                  greenColor
                                                                                ]
                                                                              : [
                                                                                  const Color(0xffee856d),
                                                                                  const Color(0xffed6a5a)
                                                                                ])),
                                                        );
                                                      }),

                                                //  building the post and passing the data to the template or widget of the post

                                                KeyedSubtree(
                                                  key: key,
                                                  child: SingleNotePost(
                                                    isSecondHome:
                                                        widget.note != null,
                                                    duration: provider.duration,
                                                    stopMainPlayer:
                                                        stopMainPlayer,
                                                    playPause: () {
                                                      provider.playPause(
                                                        note.noteUrl,
                                                        index,
                                                      );
                                                    },
                                                    audioPlayer:
                                                        provider.audioPlayer,
                                                    position: provider.position,
                                                    changeIndex:
                                                        provider.changeIndex,
                                                    isPlaying:
                                                        provider.isPlaying,
                                                    postIndex: index,
                                                    pageController:
                                                        _pageController,
                                                    currentIndex: index,
                                                    size: size,
                                                    note: note,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
  }

  Widget _buildBackgroundContent(NoteModel note, BuildContext context) {
    if (note.backgroundType.contains('video')) {
      return VisibilityDetector(
        key: Key(note.noteId),
        onVisibilityChanged: (VisibilityInfo info) {
          // This will be handled within the SearchPlayer
        },
        child: SearchPlayerTwo(
          videoUrl: note.backgroundImage,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: note.backgroundImage,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomNotificationIcon extends StatefulWidget {
  const CustomNotificationIcon({
    super.key,
  });

  @override
  State<CustomNotificationIcon> createState() => _CustomNotificationIconState();
}

class _CustomNotificationIconState extends State<CustomNotificationIcon> {
  @override
  void initState() {
    SchedulerBinding.instance.scheduleFrameCallback((timer) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const NotificationScreen();
            },
          ));
        },
        icon: Stack(
          children: [
            Icon(
              Icons.favorite_border_outlined,
              color: blackColor,
              size: 27,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('commentNotifications')
                    .where('toId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<CommentNotoficationModel> notoficationModel = snapshot
                        .data!.docs
                        .map((e) => CommentNotoficationModel.fromMap(e.data()))
                        .toList();
                    List<CommentNotoficationModel> unreadNotifications = [];
                    unreadNotifications.clear();
                    for (var noti in notoficationModel) {
                      if (noti.isRead.isEmpty) {
                        unreadNotifications.add(noti);
                      }
                    }
                    return unreadNotifications.isNotEmpty
                        ? Consumer<UserProvider>(
                            builder: (context, userPro, _) {
                            return Positioned(
                              left: 13,
                              top: 2,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            );
                          })
                        : const SizedBox();
                  } else {
                    return const SizedBox();
                  }
                }),
          ],
        ));
  }
}
