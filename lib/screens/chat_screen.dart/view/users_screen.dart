// import 'package:flutter/cupertino.dart';

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';
// import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';

import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';
import 'package:social_notes/screens/chat_screen.dart/view/search_users.dart';
import 'package:social_notes/screens/chat_screen.dart/view/widgets/recent_chats.dart';
import 'package:social_notes/screens/chat_screen.dart/view/widgets/single_chat_user.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late StreamSubscription<QuerySnapshot> _subscription;
  List<RecentChatModel> recentChats = [];

  var allMesag = [];
  var messageReq = [];
  @override
  void initState() {
    getStreamChats();
    Provider.of<ChatProvider>(context, listen: false).getAllUsersForChat();
    // Provider.of<ChatProvider>(context, listen: false).getRecentChats();
    super.initState();
  }

  getStreamChats() async {
    _subscription = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<RecentChatModel> chatModel = snapshot.docs
            .map((e) => RecentChatModel.fromMap(e.data()))
            .toList();
        List<RecentChatModel> allChatoo = [];
        var currentUser =
            Provider.of<UserProvider>(context, listen: false).user;
        allChatoo.clear();

        for (int i = 0; i < snapshot.docs.length; i++) {
          if (chatModel[i].senderId == currentUser!.uid ||
              chatModel[i].receiverId == currentUser.uid) {
            allChatoo.add(chatModel[i]);
          }
        }
        List<RecentChatModel> allChats = allChatoo.where((chato) {
          return !chato.deletedChat!.contains(currentUser!.uid);
        }).toList();
        var allMesages = [];
        var messageRequests = [];
        allMesages.clear();
        messageRequests.clear();
        for (var chat in allChats) {
          if (currentUser!.following.contains(chat.senderId == currentUser.uid
                  ? chat.receiverId
                  : chat.senderId) ||
              chat.senderId == currentUser.uid) {
            allMesages.add(chat);
          } else {
            messageRequests.add(chat);
          }
        }
        // var allMesages = allChats.where((chat) {
        //   // Check if the sender ID is in the current user's followers
        //   return currentUser!.following.contains(
        //           chat.senderId == currentUser.uid
        //               ? chat.receiverId
        //               : chat.senderId) ||
        //       chat.senderId == currentUser.uid;
        // }).toList();
        // var messageRequests = allChats.where((chat) {
        //   // Check if the sender ID is not in the current user's followers
        //   return !currentUser!.following.contains(
        //           chat.senderId == currentUser.uid
        //               ? chat.receiverId
        //               : chat.senderId) &&
        //       chat.senderId != currentUser.uid;
        // }).toList();
        setState(() {
          recentChats = allChats;
          allMesag = allMesages;
          messageReq = messageRequests;
          // Update the local list with the sorted list

          // indexNewComment = indexOfNewComent;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var reqPro = Provider.of<ChatProvider>(context, listen: false);

    var user = Provider.of<UserProvider>(context, listen: false).user;

    // var messageRequests = reqPro.recentChats.where((chat) {
    //   // Check if the sender ID is not in the current user's followers
    //   return !user!.followers.contains(
    //       chat.senderId == user.uid ? chat.receiverId : chat.senderId);
    // }).toList();
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pushReplacementNamed(context, BottomBar.routeName);
        //   },
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     color: blackColor,
        //   ),
        // ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: whiteColor,
                                  )),
                            ),
                            Consumer<UserProfileProvider>(
                                builder: (context, provider, _) {
                              return Expanded(
                                child: Card(
                                  color: blackColor.withOpacity(0.2),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: provider.userAccounts.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 6),
                                          child: InkWell(
                                            onTap: () async {
                                              FirebaseAuth auth =
                                                  FirebaseAuth.instance;
                                              UserCredential credential =
                                                  await auth
                                                      .signInWithEmailAndPassword(
                                                          email: provider
                                                              .userAccounts[
                                                                  index]
                                                              .email,
                                                          password:
                                                              provider
                                                                  .userAccounts[
                                                                      index]
                                                                  .password);
                                              if (credential.user != null) {
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
                                                  backgroundImage: NetworkImage(
                                                      provider
                                                          .userAccounts[index]
                                                          .profileImage),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  provider
                                                      .userAccounts[index].name,
                                                  style: TextStyle(
                                                      fontFamily: fontFamily,
                                                      color: whiteColor),
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
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
            child: Consumer<UserProvider>(builder: (context, userPro, _) {
              return Row(
                children: [
                  Text(
                    userPro.user!.name,
                    style: TextStyle(
                        color: blackColor,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w600),
                  ),
                  if (userPro.user!.isVerified) verifiedIcon(),
                  // Image.network(
                  //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                  //   height: 20,
                  //   width: 20,
                  // ),
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: blackColor,
                  )
                ],
              );
            }),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUsers(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SvgPicture.asset(
                'assets/icons/Subtract.svg',
                height: 25,
                width: 25,
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: whiteColor,
        color: primaryColor,
        onRefresh: () {
          return getStreamChats();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    reqPro.changeSearchStatus(true);
                    reqPro.searchedChats.clear();
                    var allMessages = recentChats.where((chat) {
                      // Check if the sender ID is in the current user's followers
                      return user!.followers.contains(chat.senderId == user.uid
                          ? chat.receiverId
                          : chat.senderId);
                    }).toList();
                    for (var recentChat in allMessages) {
                      if (recentChat.senderName!
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          recentChat.receiverName!
                              .toLowerCase()
                              .contains(value.toLowerCase())) {
                        reqPro.searchedChats.add(recentChat);
                        break;
                      }
                    }
                  } else {
                    reqPro.changeSearchStatus(false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  contentPadding: const EdgeInsets.only(top: 1, bottom: 5),
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  constraints: BoxConstraints(
                    maxHeight: 40,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14).copyWith(top: 15),
              child: Text(
                'Recent Chats',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 22,
                    color: primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            RecentChats(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      reqPro.changeMessageReqStatus(false);
                    },
                    child: Consumer<ChatProvider>(builder: (context, chat, _) {
                      // var allMesag = chat.recentChats.where((chat) {
                      //   // Check if the sender ID is in the current user's followers
                      //   return user.followers.contains(chat.senderId == user.uid
                      //       ? chat.receiverId
                      //       : chat.senderId);
                      // }).toList();

                      return Text(
                        'All Messages (${allMesag.length})',
                        style: TextStyle(
                            color: chat.isMessageReq
                                ? Colors.grey[600]
                                : blackColor,
                            fontFamily: fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                  InkWell(
                    onTap: () => reqPro.changeMessageReqStatus(true),
                    child: Consumer<ChatProvider>(builder: (context, chat, _) {
                      // messageReq
                      //     .removeWhere((element) => element.senderId == user.uid);
                      return Text(
                        'Message Requests (${messageReq.length})',
                        style: TextStyle(
                            color: chat.isMessageReq
                                ? blackColor
                                : Colors.grey[600],
                            fontSize: 16,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Consumer<ChatProvider>(builder: (context, chatPro, _) {
              // List<int> allMessagesIndex = [];
              // List<int> messageRequestsIndex = [];
              // allMessagesIndex.clear();
              // messageRequestsIndex.clear();

              // for (int i = 0; i < chatPro.recentChats.length; i++) {
              //   if (user!.followers.contains(
              //           chatPro.recentChats[i].senderId == user.uid
              //               ? chatPro.recentChats[i].receiverId
              //               : chatPro.recentChats[i].senderId) ||
              //       user.following.contains(
              //           chatPro.recentChats[i].senderId == user.uid
              //               ? chatPro.recentChats[i].receiverId
              //               : chatPro.recentChats[i].senderId)) {
              //     allMessagesIndex.add(i);
              //   } else {
              //     messageRequestsIndex.add(i);
              //   }
              // }

              // var allMessages = recentChats.where((chat) {
              //   // Check if the sender ID is in the current user's followers
              //   return user!.following.contains(chat.senderId == user.uid
              //           ? chat.receiverId
              //           : chat.senderId) ||
              //       chat.senderId == user.uid;
              // }).toList();

              // // var messageRequests = chatPro.recentChats.where((chat) {
              // //   // Check if the sender ID is not in the current user's followers
              // //   return !user.followers.contains(
              // //       chat.senderId == user.uid ? chat.receiverId : chat.senderId);
              // // }).toList();
              // var messageRequests = recentChats.where((chat) {
              //   // Check if the sender ID is not in the current user's followers
              //   return !user!.following.contains(chat.senderId == user.uid
              //           ? chat.receiverId
              //           : chat.senderId) &&
              //       chat.senderId != user.uid;
              // }).toList();
              // log('All message req $allMessages');
              // log('All message req $messageRequests');
              return ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: reqPro.isSearching
                    ? reqPro.searchedChats.length
                    : chatPro.isMessageReq
                        ? messageReq.length
                        : allMesag.length,
                itemBuilder: (context, index) {
                  bool isSeen = false;
                  if (reqPro.isSearching) {
                    isSeen = chatPro.searchedChats[index].seen!;
                  } else if (chatPro.isMessageReq) {
                    isSeen = messageReq[index].seen!;
                  } else {
                    isSeen = allMesag[index].seen!;
                  }
                  var recentChats = reqPro.isSearching
                      ? reqPro.searchedChats
                      : chatPro.isMessageReq
                          ? messageReq
                          : allMesag;

                  var rec = recentChats[index].senderId == user!.uid
                      ? recentChats[index].receiverId
                      : recentChats[index].senderId;
                  var recName = recentChats[index].senderId == user.uid
                      ? recentChats[index].receiverName
                      : recentChats[index].senderName;
                  var recPhotoUrl = recentChats[index].senderId == user.uid
                      ? recentChats[index].receiverImage
                      : recentChats[index].senderImage;
                  var recToken = recentChats[index].senderId == user.uid
                      ? recentChats[index].receiverToken
                      : recentChats[index].senderToken;
                  var color = user.following.contains(rec)
                      ? isSeen
                          ? greenColor.withOpacity(0.5)
                          : greenColor
                      : isSeen
                          ? const Color(0xffefa69d)
                          : primaryColor;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  receiverId: rec,
                                  receiverName: recName,
                                  receiverPhotoUrl: recPhotoUrl,
                                  rectoken: recToken,
                                )),
                      );
                    },
                    child: SingleChatUser(
                        recId: rec!,
                        chatModel: recentChats[index],
                        isSearching: reqPro.isSearching,
                        // messageReqIndex: messageRequestsIndex,
                        index: index,
                        // allMessgaesIndex: allMessagesIndex,
                        color: color,
                        // allMessagesIndex.contains(index)
                        //     ? isSeen
                        //         ? greenColor.withOpacity(0.5)
                        //         : greenColor
                        //     : messageRequestsIndex.contains(index)
                        //         ? isSeen
                        //             ? const Color(0xffefa69d)
                        //             : primaryColor
                        //         : primaryColor,
                        isSeen: isSeen),
                  );
                },
              );
            }))
          ],
        ),
      ),
    );
  }
}
