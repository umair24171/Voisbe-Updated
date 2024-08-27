import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
// import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';

class ChatProvider with ChangeNotifier {
  //  getting the all the users

  final List<UserModel> _users = [];
  List<UserModel> get users => _users;

  //  getting search text

  String searchText = '';
  // String get searchText => _searchText;

  //  initially the value of the search would be false

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  //  creating the instance of the firestore

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  creating the empty list to get the recent chat user

  List<RecentChatModel> recentChats = [];

  //  creating the list for searched chats

  List<RecentChatModel> searchedChats = [];

  //  creating the list for the searched users

  List<UserModel> searchedUSers = [];

  //  adding the searched users thorugh the function

  addSearchedUsers(UserModel user) {
    searchedUSers.add(user);
    notifyListeners();
  }

//  clearing the seached users

  clearSearchedUser() {
    searchedUSers.clear();
    notifyListeners();
  }

  //  add recent chat

  addOneRecentChat(RecentChatModel recentChat) {
    recentChats.add(recentChat);
    notifyListeners();
  }

  //  getting recent chats based on time

  getRecentChats() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await _firestore
          .collection('chats')
          .orderBy('time', descending: true)
          .get()
          .then((value) {
        List<RecentChatModel> chatModel =
            value.docs.map((e) => RecentChatModel.fromMap(e.data())).toList();
        recentChats.clear();
        for (int i = 0; i < value.docs.length; i++) {
          if (chatModel[i].senderId == currentUserUid ||
              chatModel[i].receiverId == currentUserUid) {
            recentChats.add(chatModel[i]);
          }
        }
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  //   updating the message read status

  updateMessageRead(
    String conversationId,
    String chatId,
  ) async {
    await _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .doc(chatId)
        .update({'messageRead': 'read'}).then((value) async {
      // await _firestore
      //     .collection('chats')
      //     .doc(conversationId)
      //     .update({'seen': true});
      log('message read');
    });
  }

//  changing the value of the search

  void changeSearchStatus(bool status) {
    _isSearching = status;
    notifyListeners();
  }

//  setting the value of the search text

  setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  //  getting all the users to chat with except for the current user

  getAllUsersForChat() async {
    try {
      await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        _users.clear();
        for (var user in value.docs) {
          _users.add(UserModel.fromMap(user.data()));
          notifyListeners();
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  bool isMessageReq = false;

  //  changing the message req status

  void changeMessageReqStatus(bool status) {
    isMessageReq = status;
    notifyListeners();
  }
}
