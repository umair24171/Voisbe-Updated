import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/user_profile/models/user_account.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NoteModel> userPosts = [];
  List<NoteModel> otherUserPosts = [];
  UserModel? otherUser;
  List<UserAccount> userAccounts = [];
  List<UserModel> followers = [];
  List<UserModel> following = [];
  List<UserModel> closeFriends = [];

  getCloseFriends(List closeFriend) async {
    try {
      await _firestore
          .collection('users')
          .where('uid', whereIn: closeFriend)
          .get()
          .then((value) {
        log('value are ${value.docs}');
        closeFriends =
            value.docs.map((e) => UserModel.fromMap(e.data())).toList();
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getFollowers(String userId) async {
    followers.clear();
    final QuerySnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore
            .collection('users')
            .where('following', arrayContains: userId)
            .get();
    followers = userPostsSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            UserModel.fromMap(e.data()))
        .toList();
    notifyListeners();
  }

  Future<void> getFollowing(String userId) async {
    following.clear();
    notifyListeners();
    final QuerySnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore
            .collection('users')
            .where('followers', arrayContains: userId)
            .get();
    following = userPostsSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            UserModel.fromMap(e.data()))
        .toList();
    notifyListeners();
  }

  geUserAccounts() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? userInfo = preferences.getStringList('userAccounts');
    if (userInfo != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .where('uid', whereIn: userInfo)
          .get();
      List<UserModel> users =
          snapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();
      userAccounts.clear();
      for (var user in users) {
        // if (user.uid != FirebaseAuth.instance.currentUser!.uid) {
        userAccounts.add(UserAccount(
            name: user.username,
            password: user.password,
            email: user.email,
            profileImage: user.photoUrl,
            isVerified: user.isVerified));
        // }
      }
      notifyListeners();
    }
  }

  Future<void> getUserPosts(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore
            .collection('notes')
            .where('userUid', isEqualTo: userId)
            .orderBy('publishedDate', descending: true)
            .get();
    userPosts = userPostsSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            NoteModel.fromMap(e.data()))
        .toList();
    notifyListeners();
  }

  deletePost(String postId) async {
    await _firestore.collection('notes').doc(postId).delete();
    userPosts.removeWhere((element) => element.noteId == postId);
    notifyListeners();
  }

  followUser(
    UserModel currentUser,
    UserModel followUser,
  ) async {
    if (followUser.isPrivate) {
      if (followUser.followReq.contains(currentUser.uid)) {
        if (otherUser != null) {
          otherUser!.followReq.remove(currentUser.uid);
          notifyListeners();
        }
        await _firestore.collection('users').doc(followUser.uid).update({
          'followReq': FieldValue.arrayRemove([currentUser.uid])
        });
        await _firestore.collection('users').doc(currentUser.uid).update({
          'followTo': FieldValue.arrayRemove([followUser.uid])
        });
        if (followUser.followers.contains(currentUser.uid)) {
          if (otherUser != null) {
            otherUser!.followers.remove(currentUser.uid);
            notifyListeners();
          }
          await _firestore.collection('users').doc(followUser.uid).update({
            'followers': FieldValue.arrayRemove([currentUser.uid])
          });
          await _firestore.collection('users').doc(currentUser.uid).update({
            'following': FieldValue.arrayRemove([followUser.uid])
          });
        }
      } else {
        if (otherUser != null) {
          otherUser!.followReq.add(currentUser.uid);
          notifyListeners();
        }
        await _firestore.collection('users').doc(followUser.uid).update({
          'followReq': FieldValue.arrayUnion([currentUser.uid])
        });
        await _firestore.collection('users').doc(currentUser.uid).update({
          'followTo': FieldValue.arrayUnion([followUser.uid])
        });
        if (followUser.followers.contains(currentUser.uid)) {
          if (otherUser != null) {
            otherUser!.followers.remove(currentUser.uid);
            notifyListeners();
          }
          await _firestore.collection('users').doc(followUser.uid).update({
            'followers': FieldValue.arrayRemove([currentUser.uid])
          });
          await _firestore.collection('users').doc(currentUser.uid).update({
            'following': FieldValue.arrayRemove([followUser.uid])
          });
        }
      }
    } else {
      if (followUser.followers.contains(currentUser.uid)) {
        if (otherUser != null) {
          otherUser!.followers.remove(currentUser.uid);
          notifyListeners();
        }
        await _firestore.collection('users').doc(followUser.uid).update({
          'followers': FieldValue.arrayRemove([currentUser.uid])
        });
        await _firestore.collection('users').doc(currentUser.uid).update({
          'following': FieldValue.arrayRemove([followUser.uid])
        });

        // otherUser!.followers.remove(FirebaseAuth.instance.currentUser!.uid);
      } else {
        if (otherUser != null) {
          otherUser!.followers.add(currentUser.uid);
          notifyListeners();
        }
        await _firestore.collection('users').doc(followUser.uid).update({
          'followers': FieldValue.arrayUnion([currentUser.uid])
        });
        await _firestore.collection('users').doc(currentUser.uid).update({
          'following': FieldValue.arrayUnion([followUser.uid])
        });
      }
      // otherUser!.followers.remove(currentUser.uid);
    }

    // if (currentUser.following.contains(followUser.uid)) {
    //   await _firestore.collection('users').doc(currentUser.uid).update({
    //     'following': FieldValue.arrayRemove([followUser.uid])
    //   });
    // } else {
    //   await _firestore.collection('users').doc(currentUser.uid).update({
    //     'following': FieldValue.arrayUnion([followUser.uid])
    //   });
    // }

    // notifyListeners();
  }

  // followUserLocally() {}

  Future<void> getOtherUserPosts(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore
            .collection('notes')
            .where('userUid', isEqualTo: userId)
            .get();
    otherUserPosts = userPostsSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            NoteModel.fromMap(e.data()))
        .toList();
    notifyListeners();
  }

  otherUserProfile(String userUid) async {
    final DocumentSnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore.collection('users').doc(userUid).get();
    otherUser = UserModel.fromMap(userPostsSnapshot.data()!);
    notifyListeners();
  }

  pinPost(String noteId, bool isPinned) async {
    List<NoteModel> pinnedPosts = [];
    for (var note in userPosts) {
      if (note.isPinned) {
        pinnedPosts.add(note);
      }
    }

    log(pinnedPosts.length.toString());
    if (pinnedPosts.length < 2 || isPinned == false) {
      await _firestore
          .collection('notes')
          .doc(noteId)
          .update({'isPinned': isPinned});
      for (var element in userPosts) {
        if (element.noteId == noteId) {
          element.isPinned = isPinned;
          // if (isPinned) {
          //   userPosts.insert(1, element);
          // }
        }
      }
      notifyListeners();
    }
  }
}
