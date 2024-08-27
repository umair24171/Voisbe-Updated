import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/search_screen/view/widgets/optimised_grid_view.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart' as rem;

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //empty list of most engaged posts
  List<NoteModel> mostEngagedPosts = [];

  // posts that would be after adding the likes filter
  List<NoteModel> postsAfterFilter = [];

  //  it would be managed through firebase to change the value of the likes

  int likesThreshold = 0;

  @override
  void initState() {
    // initilizing the firebase config
    initializeData();

    super.initState();
  }

  Future<void> initializeData() async {
    await getLikesThreshold();
    await Provider.of<DisplayNotesProvider>(context, listen: false)
        .getAllNotes(context);
    getLikesLogicsAndFilteration();
  }

  // this function is helpful in managing the value of the likes in future without sending the update  through firebase config

  Future<void> getLikesThreshold() async {
    final rem.FirebaseRemoteConfig remoteConfig =
        rem.FirebaseRemoteConfig.instance;

    try {
      // Set a minimum fetch interval (optional, but recommended)
      await remoteConfig.setConfigSettings(rem.RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ));

      // Force fetch (bypasses throttling)
      await remoteConfig.fetchAndActivate();

      likesThreshold = remoteConfig.getInt('likes_threshold');
      log('Likes threshold is $likesThreshold');
    } catch (e) {
      // If fetch fails, use the last activated value
      likesThreshold = remoteConfig.getInt('likes_threshold');
      log('Failed to fetch remote config. Using cached value: $likesThreshold');
    }
  }

  // through this finction we get the posts and filter them based on the likes and update our lists

  void getLikesLogicsAndFilteration() {
    var provider = Provider.of<DisplayNotesProvider>(context, listen: false);
    UserModel? currentUser =
        Provider.of<UserProvider>(context, listen: false).user;

    postsAfterFilter.clear();

    for (int i = 0; i < provider.notes.length; i++) {
      log('likes in condition $likesThreshold');
      if (provider.notes[i].likes.length > likesThreshold) {
        postsAfterFilter.add(provider.notes[i]);
      }
    }

    List<NoteModel> displayPosts = [];

    for (var note in postsAfterFilter) {
      bool isSubscribed =
          currentUser?.subscribedSoundPacks.contains(note.userUid) ?? false;
      bool isPostForSubscriber = note.isPostForSubscribers;

      if (!(isPostForSubscriber && !isSubscribed)) {
        UserModel? user;
        try {
          user = Provider.of<ChatProvider>(context, listen: false)
              .users
              .firstWhere((element) => element.uid == note.userUid);
        } catch (e) {
          continue;
        }

        if (user.isPrivate &&
            !(currentUser?.following.contains(note.userUid) ?? false) &&
            note.userUid != currentUser!.uid) {
          continue;
        }

        displayPosts.add(note);
      }
    }

    postsAfterFilter = displayPosts;
    setState(() {});
  }

//   getLikesLogicsAndFilteration() {
//     var provider = Provider.of<DisplayNotesProvider>(context, listen: false);
//     UserModel? currentUser =
//         Provider.of<UserProvider>(context, listen: false).user;

//     postsAfterFilter.clear();

//     for (int i = 0; i < provider.notes.length; i++) {
//       if (provider.notes[i].likes.isNotEmpty) {
//         postsAfterFilter.add(provider.notes[i]);
//       }
//     }

// // Create a new list to store the posts that will be displayed
//     List<NoteModel> displayPosts = [];

//     for (var note in postsAfterFilter) {
//       bool isSubscribed =
//           currentUser?.subscribedSoundPacks.contains(note.userUid) ?? false;
//       bool isPostForSubscriber = note.isPostForSubscribers;

//       // If the post is for subscribers and the current user is not subscribed, don't add it to the display list
//       if (!(isPostForSubscriber && !isSubscribed)) {
//         // New logic to check for private accounts
//         UserModel? user;
//         try {
//           user = Provider.of<ChatProvider>(context, listen: false)
//               .users
//               .firstWhere(
//                 (element) => element.uid == note.userUid,
//               );
//         } catch (e) {
//           // User not found in the list, skip this post
//           continue;
//         }

//         // Check if the account is private and the current user is not following
//         if (user.isPrivate &&
//             !(currentUser?.following.contains(note.userUid) ?? false) &&
//             note.userUid != currentUser!.uid) {
//           continue; // Skip this post
//         }

//         displayPosts.add(note);
//       }
//     }

// // Assign the displayPosts list to the postsAfterFilter
//     postsAfterFilter = displayPosts;
//     setState(() {});
//   }

//   Future<int> getLikesThreshold() async {
//     final rem.FirebaseRemoteConfig remoteConfig =
//         rem.FirebaseRemoteConfig.instance;
//     await remoteConfig.fetchAndActivate();
//     return remoteConfig.getInt('likes_threshold');
//   }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // var size = MediaQuery.of(context).size;
    // var provider = Provider.of<DisplayNotesProvider>(context, listen: false);
    // UserModel? currentUser =
    //     Provider.of<UserProvider>(context, listen: false).user;

    // var allPosts = provider.notes;
    // postsAfterFilter.clear();

    // for (int i = 0; i < provider.notes.length; i++) {
    //   if (allPosts[i].likes.length >= 10) {
    //     postsAfterFilter.add(allPosts[i]);
    //   }
    // }

    // for (var note in postsAfterFilter) {
    //   bool isSubscribed =
    //       currentUser!.subscribedSoundPacks.contains(note.userUid);
    //   bool isPostForSubscriber = note.isPostForSubscribers;
    //   if (isPostForSubscriber && !isSubscribed) {
    //     postsAfterFilter.remove(note);
    //   }
    // }
// var size = MediaQuery.of(context).size;
//     var provider = Provider.of<DisplayNotesProvider>(context, listen: false);
//     UserModel? currentUser =
//         Provider.of<UserProvider>(context, listen: false).user;

//     // var allPosts = provider.notes;
//     postsAfterFilter.clear();

//     for (int i = 0; i < provider.notes.length; i++) {
//       if (provider.notes[i].likes.isNotEmpty) {
//         postsAfterFilter.add(provider.notes[i]);
//       }
//     }

// // Create a new list to store the posts that will be displayed
//     List<NoteModel> displayPosts = [];

//     for (var note in postsAfterFilter) {
//       bool isSubscribed =
//           currentUser?.subscribedSoundPacks.contains(note.userUid) ?? false;
//       bool isPostForSubscriber = note.isPostForSubscribers;

//       // If the post is for subscribers and the current user is not subscribed, don't add it to the display list
//       if (!(isPostForSubscriber && !isSubscribed)) {
//         displayPosts.add(note);
//       }
//     }

// // Assign the displayPosts list to the postsAfterFilter
//     postsAfterFilter = displayPosts;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(
                // flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        //  the search value is adding to the provider

                        var chatPro =
                            Provider.of<ChatProvider>(context, listen: false);

                        //  changing the search status

                        chatPro.changeSearchStatus(true);

                        // clearing the prevoius search list

                        chatPro.clearSearchedUser();
                        for (var user in chatPro.users) {
                          if (user.name.contains(value)) {
                            //  adding user to the list if the name matches to the value
                            chatPro.addSearchedUsers(user);
                          }
                        }
                      } else {
                        var chatPro =
                            Provider.of<ChatProvider>(context, listen: false);
                        chatPro.changeSearchStatus(false);
                        chatPro.clearSearchedUser();
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                          maxHeight: 35, maxWidth: size.width * 0.8),
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.only(bottom: 18),
                      hintText: 'Search',
                      hintStyle:
                          TextStyle(fontFamily: fontFamily, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // refresh indicator to get the newly posts

        body: RefreshIndicator(
          backgroundColor: whiteColor,
          color: primaryColor,
          onRefresh: () {
            // function to get the newly posts

            return Provider.of<DisplayNotesProvider>(context, listen: false)
                .getAllNotes(context);
          },
          child: Consumer<ChatProvider>(builder: (context, searchPro, _) {
            return searchPro.isSearching

                // if the value of the search is true show the seached users

                ? Container(
                    height: MediaQuery.of(context).size.height,
                    color: whiteColor,
                    child: ListView.builder(
                      itemCount: searchPro.searchedUSers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                searchPro.searchedUSers[index].photoUrl),
                          ),
                          title: Row(
                            children: [
                              Text(
                                searchPro.searchedUSers[index].name,
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              if (searchPro.searchedUSers[index].isVerified)
                                verifiedIcon()
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => OtherUserProfile(
                                  userId: searchPro.searchedUSers[index].uid),
                            ));
                          },
                        );
                      },
                    ),
                  )

                // otherwise show the grid of posts

                : OptimizedSearchGrid(
                    postsAfterFilter: postsAfterFilter, size: size);
          }),
        ));
  }
}
