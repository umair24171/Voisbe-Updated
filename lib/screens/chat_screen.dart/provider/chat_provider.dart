import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
// import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/recent_chat_model.dart';

class ChatProvider with ChangeNotifier {
  final List<UserModel> _users = [];
  List<UserModel> get users => _users;
  String searchText = '';
  // String get searchText => _searchText;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String messageRead = '';
  List<RecentChatModel> recentChats = [];
  List<RecentChatModel> searchedChats = [];

  List<UserModel> searchedUSers = [];

  addSearchedUsers(UserModel user) {
    searchedUSers.add(user);
    notifyListeners();
  }

  clearSearchedUser() {
    searchedUSers.clear();
    notifyListeners();
  }

  addOneRecentChat(RecentChatModel recentChat) {
    recentChats.add(recentChat);
    notifyListeners();
  }

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

  void changeSearchStatus(bool status) {
    _isSearching = status;
    notifyListeners();
  }

  setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

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

  void changeMessageReqStatus(bool status) {
    isMessageReq = status;
    notifyListeners();
  }
}
