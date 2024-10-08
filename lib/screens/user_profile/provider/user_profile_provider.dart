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

//  enabling notification for other user

  addNotification(String userId) {
    otherUser!.notificationsEnable.add(userId);
    notifyListeners();
  }

  //  removing the enabled notification

  removeNotification(String userId) {
    otherUser!.notificationsEnable.remove(userId);
    notifyListeners();
  }

  //  getting the close friend list for the current user

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

  //  getting all the followers of the user

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

  //  getting all the following of the user

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

  // getting current user acoounts

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

  //  getting user posts

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

  //  deleting user post

  deletePost(String postId) async {
    await _firestore.collection('notes').doc(postId).delete();
    userPosts.removeWhere((element) => element.noteId == postId);
    notifyListeners();
  }

  //  follow user function

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
  }
// getting other user posts

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

  //  getting other user profile

  otherUserProfile(String userUid) async {
    final DocumentSnapshot<Map<String, dynamic>> userPostsSnapshot =
        await _firestore.collection('users').doc(userUid).get();
    otherUser = UserModel.fromMap(userPostsSnapshot.data()!);
    notifyListeners();
  }

//   pinning the post logic

  pinPost(String noteId, bool isPinned) async {
    int pinnedCount = userPosts.where((note) => note.isPinned).length;

    if (isPinned && pinnedCount >= 1) {
      // If trying to pin a post and there's already a pinned post, unpin the existing one
      var existingPinnedPost = userPosts.firstWhere((note) => note.isPinned);
      existingPinnedPost.isPinned = false;
      await _firestore
          .collection('notes')
          .doc(existingPinnedPost.noteId)
          .update({'isPinned': false});
    }

    // Update the target post
    var targetPost = userPosts.firstWhere((note) => note.noteId == noteId);
    targetPost.isPinned = isPinned;
    await _firestore
        .collection('notes')
        .doc(noteId)
        .update({'isPinned': isPinned});

    // Re-sort the posts
    userPosts.sort((a, b) {
      if (a.noteId == userPosts[0].noteId) return -1;
      if (b.noteId == userPosts[0].noteId) return 1;
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // If neither is pinned or both are pinned, maintain original order
      return b.publishedDate
          .compareTo(a.publishedDate); // Assuming newer posts should be higher
    });

    notifyListeners();
  }
  // pinPost(String noteId, bool isPinned) async {
  //   int pinnedCount = userPosts.where((note) => note.isPinned).length;

  //   if (isPinned && pinnedCount >= 1) {
  //     // If trying to pin a post and there's already a pinned post, unpin the existing one
  //     var existingPinnedPost = userPosts.firstWhere((note) => note.isPinned);
  //     existingPinnedPost.isPinned = false;
  //     await _firestore
  //         .collection('notes')
  //         .doc(existingPinnedPost.noteId)
  //         .update({'isPinned': false});
  //   }

  //   // Update the target post
  //   var targetPost = userPosts.firstWhere((note) => note.noteId == noteId);
  //   targetPost.isPinned = isPinned;
  //   await _firestore
  //       .collection('notes')
  //       .doc(noteId)
  //       .update({'isPinned': isPinned});

  //   // Re-sort the posts
  //   userPosts.sort((a, b) {
  //     if (a.noteId == userPosts[0].noteId) return -1;
  //     if (b.noteId == userPosts[0].noteId) return 1;
  //     if (a.isPinned && !b.isPinned) return -1;
  //     if (!a.isPinned && b.isPinned) return 1;
  //     return 0;
  //   });

  //   notifyListeners();
  // }

  // pinPost(String noteId, bool isPinned) async {
  //   List<NoteModel> pinnedPosts = [];
  //   for (var note in userPosts) {
  //     if (note.isPinned) {
  //       pinnedPosts.add(note);
  //     }
  //   }

  //   log(pinnedPosts.length.toString());
  //   if (pinnedPosts.isEmpty || isPinned == false) {
  //     for (var element in userPosts) {
  //       if (element.noteId == noteId) {
  //         element.isPinned = isPinned;
  //         // if (isPinned) {
  //         //   userPosts.insert(1, element);
  //         // }
  //       }
  //     }
  //     notifyListeners();
  //     await _firestore
  //         .collection('notes')
  //         .doc(noteId)
  //         .update({'isPinned': isPinned});
  //   }
  // }
}
