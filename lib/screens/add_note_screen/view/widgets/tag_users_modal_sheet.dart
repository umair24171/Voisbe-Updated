import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/add_note_screen.dart/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';

class TagUsersModalSheet extends StatelessWidget {
  const TagUsersModalSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // var allUsers = Provider.of<ChatProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var tagProvider = Provider.of<NoteProvider>(context, listen: false);
    // var chatProvider = Provider.of<ChatProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        children: [
          // Align(
          //   alignment: Alignment.topRight,
          //   child: IconButton(
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       icon: Icon(
          //         Icons.cancel,
          //         size: 30,
          //         color: blackColor,
          //       )),
          // ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            onChanged: (value) {
              var allUsers = Provider.of<ChatProvider>(context, listen: false);
              if (value.isNotEmpty) {
                allUsers.changeSearchStatus(true);
                allUsers.clearSearchedUser();
                for (var user in allUsers.users) {
                  if (user.name.toLowerCase().contains(value)) {
                    allUsers.addSearchedUsers(user);
                  }
                }
              } else {
                allUsers.clearSearchedUser();
                tagProvider.setSearching(false);
              }
            },
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              constraints: BoxConstraints(
                  maxHeight: 45,
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
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
              hintStyle: TextStyle(fontFamily: fontFamily, color: Colors.grey),
              // label: Text(
              //   'Search',
              //   style: TextStyle(
              //       fontFamily: fontFamily, color: Colors.grey),
              // ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none),
          //       filled: true,
          //       fillColor: Colors.grey[300],
          //       constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
          //       hintText: 'Search...',
          //       hintStyle:
          //           TextStyle(fontFamily: fontFamily, color: Colors.grey),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Consumer<ChatProvider>(builder: (context, allUsers, _) {
              List<UserModel> followingUsers = [];
              followingUsers.clear();
              for (var user in allUsers.isSearching
                  ? allUsers.searchedUSers
                  : allUsers.users) {
                if (user.followers.contains(userProvider!.uid)) {
                  followingUsers.add(user);
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemCount: followingUsers.length,
                  itemBuilder: (context, index) {
                    UserModel tagUser = followingUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: GestureDetector(
                        onTap: () {
                          if (!tagProvider.tags.contains(tagUser.uid)) {
                            tagProvider.addTag(tagUser.uid);
                          } else {
                            tagProvider.removeTag(tagUser.uid);
                          }
                        },
                        child: Consumer<NoteProvider>(
                            builder: (context, notePro, _) {
                          return Stack(
                            children: [
                              Column(children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: CachedNetworkImageProvider(
                                      tagUser.photoUrl),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tagUser.name.length > 5
                                          ? '${tagUser.name.substring(0, 5)}...'
                                          : tagUser.name,
                                      style: TextStyle(fontFamily: fontFamily),
                                    ),
                                    if (tagUser.isVerified) verifiedIcon()
                                  ],
                                )
                              ]),
                              if (notePro.tags.contains(tagUser.uid))
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(
                                    Icons.check,
                                    color: whiteColor,
                                    size: 20,
                                  ),
                                )
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
