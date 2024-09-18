import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';

class UserProvider with ChangeNotifier {
  bool userLoading = false;
  bool isLogin = false;
  File? imageFile;
  File? userImage;
  bool isSubscription = false;
  UserModel? user;
  bool isNotificationEnabled = false;
  updateUserField(bool value) {
    user!.toMap()['isPrivate'] = value;
    notifyListeners();
  }

  addMuteAccount(String otherId) {
    user!.mutedAccouts.add(otherId);
    notifyListeners();
  }

  updateUserLike(bool value) {
    user!.isLike = value;
    notifyListeners();
  }

  updateUserFollow(bool value) {
    user!.isFollows = value;
    notifyListeners();
  }

  updateUserReply(bool value) {
    user!.isReply = value;
    notifyListeners();
  }

  removeMuteAccount(String otherId) {
    user!.mutedAccouts.remove(otherId);
    notifyListeners();
  }

  updateUserFieldForCloseFriends(String value) {
    user!.toMap()['closeFriends'].add(value);
    notifyListeners();
  }

  removeUSerFieldForCloseFriends(String value) {
    user!.toMap()['closeFriends'].remove(value);
    notifyListeners();
  }

  unblockField(String value) {
    user!.toMap()['blockedUsers'].remove(value);
    notifyListeners();
  }

  setUserNull() {
    user = null;
    notifyListeners();
  }

  setIsNotificationEnabled() {
    isNotificationEnabled = !isNotificationEnabled;
    notifyListeners();
  }

  removeImage() {
    imageFile = null;
    notifyListeners();
  }

  removeUserImage() {
    userImage = null;
    notifyListeners();
  }

  setUserLoading(bool value) {
    userLoading = value;
    notifyListeners();
  }

  getUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        user = UserModel.fromMap(value.data()!);
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  setIsSubscription() {
    isSubscription = !isSubscription;
    notifyListeners();
  }

  setIslogin(bool value) {
    isLogin = value;
    notifyListeners();
  }

  pickImage() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        notifyListeners();
      }
    });
  }

  pickUserImage() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        userImage = File(value.path);
        notifyListeners();
      }
    });
  }

  pickVideo() {
    ImagePicker().pickVideo(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        notifyListeners();
      }
    });
  }
}
