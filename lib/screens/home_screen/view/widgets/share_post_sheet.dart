import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/add_note_screen.dart/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/controller/chat_controller.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:uuid/uuid.dart';

class SharePostSheet extends StatefulWidget {
  const SharePostSheet({super.key, required this.note});
  final NoteModel note;

  @override
  State<SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends State<SharePostSheet> {
  late StreamSubscription<QuerySnapshot> userSubscription;
  List<UserModel> allUser = [];

  @override
  void initState() {
    getStreamData();
    super.initState();
  }

  getStreamData() {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    userSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: userProvider!.following)
        .snapshots()
        .listen(
      (snapshot) {
        List<UserModel> users =
            snapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();
        setState(() {
          allUser = users;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // var allUsers = Provider.of<ChatProvider>(context).users;
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    String getConversationId(String receiverId) {
      return userProvider!.uid.hashCode <= receiverId.hashCode
          ? '${userProvider.uid}_${receiverId}'
          : '${receiverId}_${userProvider.uid}';
    }

    return Container(
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              onChanged: (value) {
                var searchPro =
                    Provider.of<DisplayNotesProvider>(context, listen: false);
                if (value.isNotEmpty) {
                  searchPro.setIsSearching(true);
                  searchPro.clearSearchedUsers();
                  for (var user in allUser) {
                    if (user.name.toLowerCase().contains(value.toLowerCase())) {
                      searchPro.searchedUsers.add(user);
                    }
                  }
                } else {
                  searchPro.setIsSearching(false);
                  searchPro.clearSearchedUsers();
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[300],
                constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
                hintText: 'Search...',
                hintStyle:
                    TextStyle(fontFamily: fontFamily, color: Colors.grey),
              ),
            ),
          ),
          Expanded(child:
              Consumer<DisplayNotesProvider>(builder: (context, displayPro, _) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              itemCount: displayPro.isSearching
                  ? displayPro.searchedUsers.length
                  : allUser.length,
              itemBuilder: (context, index) {
                UserModel allUsers = displayPro.isSearching
                    ? displayPro.searchedUsers[index]
                    : allUser[index];
                //     UserModel.fromMap(snapshot.data!.docs[index].data());
                return GestureDetector(
                  onTap: () {
                    String chatId = const Uuid().v4();

                    ChatModel chat = ChatModel(
                        name: userProvider!.name,
                        message: widget.note.noteUrl,
                        senderId: userProvider.uid,
                        isShare: true,
                        postOwner: widget.note.username,
                        chatId: chatId,
                        time: DateTime.now(),
                        receiverId: allUsers.uid,
                        messageRead: '',
                        avatarUrl: userProvider.photoUrl);
                    ChatController().sendMessage(
                        chat,
                        chatId,
                        getConversationId(allUsers.uid),
                        allUsers.username,
                        allUsers.photoUrl,
                        userProvider.token,
                        allUsers.token,
                        context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverUser: allUsers,
                        ),
                      ),
                    );
                  },
                  child: Column(children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(allUsers.photoUrl),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          allUsers.name.length > 5
                              ? '${allUsers.name.substring(0, 5)}...'
                              : allUsers.name,
                          style: TextStyle(fontFamily: fontFamily),
                        ),
                        if (allUsers.isVerified) verifiedIcon()
                      ],
                    )
                  ]),
                );
              },
            );
          }))
        ],
      ),
    );
  }
}
