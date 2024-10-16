import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';

class SearchUsers extends StatelessWidget {
  const SearchUsers({super.key});

  // @override
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
              // flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 0),
                child: TextFormField(
                  // textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    constraints: BoxConstraints(
                        maxHeight: 35, maxWidth: size.width * 0.8),
                    fillColor: Colors.grey[300],
                    contentPadding: const EdgeInsets.only(bottom: 14),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    hintText: 'Search Users',
                    hintStyle:
                        TextStyle(fontFamily: fontFamily, color: Colors.grey),

                    // label: Text(
                    //   'Search Users',
                    //   style:
                    //       TextStyle(fontFamily: fontFamily, color: Colors.grey),
                    // ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      chatProvider.changeSearchStatus(true);
                      chatProvider.setSearchText(value);
                      chatProvider.clearSearchedUser();
                      for (var user in chatProvider.users) {
                        if (user.name
                            .toLowerCase()
                            .contains(value.toLowerCase())) {
                          chatProvider.addSearchedUsers(user);
                        }
                      }
                      // for (int i = 0; i < chatProvider.users.length; i++) {
                      //   if (chatProvider.users[i].name.contains(value)) {
                      //     chatProvider.addSearchedUsers(chatProvider.users[i]);
                      //   }
                      // }
                    } else {
                      chatProvider.changeSearchStatus(false);
                      chatProvider.clearSearchedUser();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: Icon(
        //       Icons.more_horiz,
        //       color: blackColor,
        //     ),
        //   ),
        // ],
      ),
      body: ListView.builder(
        itemCount: chatProvider.isSearching
            ? chatProvider.searchedUSers.length
            : chatProvider.users.length,
        itemBuilder: (context, index) {
          UserModel user = chatProvider.isSearching
              ? chatProvider.searchedUSers[index]
              : chatProvider.users[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiverUser: user,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                            color: blackColor,
                            fontFamily: fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      if (user.isVerified) verifiedIcon()
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
