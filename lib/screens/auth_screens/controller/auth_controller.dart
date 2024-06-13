// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  userSignup({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userPro = Provider.of<UserProvider>(context, listen: false);
      userPro.setUserLoading(true);
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        NotificationMethods notificationMethods = NotificationMethods();
        String token = await notificationMethods.getFirebaseMessagingToken();

        UserModel userModel = UserModel(
            followTo: [],
            followReq: [],
            dateOfBirth: DateTime.now(),
            isVerified: false,
            blockedByUsers: [],
            closeFriends: [],
            blockedUsers: [],
            token: token,
            name: '',
            uid: credential.user!.uid,
            isPrivate: false,
            subscribedSoundPacks: [],
            username: username,
            password: password,
            email: email,
            photoUrl: '',
            following: [],
            pushToken: '',
            followers: [],
            subscribedUsers: [],
            bio: '',
            contact: '',
            isSubscriptionEnable: false,
            link: '',
            price: 0,
            soundPacks: []);
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());
        // prefs.getString('userAccounts');
        if (prefs.getStringList('userAccounts') != null) {
          List<String>? allUsers = prefs.getStringList('userAccounts');
          allUsers == null
              ? prefs.setStringList('userAccounts', [credential.user!.uid])
              : prefs.setStringList(
                  'userAccounts', [credential.user!.uid, ...allUsers]);
        } else {
          prefs.setStringList('userAccounts', [credential.user!.uid]);
        }

        // prefs.setStringList('userAccounts', [credential.user!.uid]);
        Provider.of<UserProvider>(context, listen: false).setUserNull();

        userPro.setUserLoading(false);
        showWhiteOverlayPopup(context, Icons.check_circle, null,
            title: 'Registeration Successful',
            message: 'You have successfully registered',
            isUsernameRes: false);
        // showSnackBar(context, 'Registeration Successful');
        log('User Registered Successfully');
        Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
        // navPush(ProfileScreen.routeName, context);
      }
    } catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
      showWhiteOverlayPopup(context, Icons.error, null,
          title: 'Error Accured', message: e.toString(), isUsernameRes: false);
      // showSnackBar(context, e.toString());
      log(e.toString());
    }
  }

  userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userPro = Provider.of<UserProvider>(context, listen: false);
      userPro.setUserLoading(true);
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        prefs.getStringList('userAccounts');
        if (prefs.getStringList('userAccounts') != null) {
          List<String>? allUsers = prefs.getStringList('userAccounts');
          allUsers == null
              ? prefs.setStringList('userAccounts', [credential.user!.uid])
              : allUsers.add(credential.user!.uid);
          prefs.setStringList('userAccounts', allUsers!);
        } else {
          prefs.setStringList('userAccounts', [credential.user!.uid]);
        }

        // prefs.setStringList('userAccounts', [credential.user!.uid]);

        // if (prefs.getStringList('user') == null) {
        //   prefs.setStringList('user', []);
        // }
        userPro.setUserLoading(false);
        showWhiteOverlayPopup(context, Icons.check_circle, null,
            title: 'Login Successful',
            message: 'You have successfully logged in',
            isUsernameRes: false);
        log('User Logged in Successfully');
        // navPush(BottomBar.routeName, context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomBar(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
      log(e.toString());
      showWhiteOverlayPopup(context, Icons.error, null,
          title: 'Error Accured', message: e.toString(), isUsernameRes: false);
      // log(e.toString());
    }
  }

  signInWithGoogle(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      final UserCredential userCredential =
          await auth.signInWithCredential(credentials);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          NotificationMethods notificationMethods = NotificationMethods();
          String token = await notificationMethods.getFirebaseMessagingToken();

          UserModel userModel = UserModel(
              followTo: [],
              followReq: [],
              dateOfBirth: DateTime.now(),
              isVerified: false,
              blockedByUsers: [],
              closeFriends: [],
              isPrivate: false,
              blockedUsers: [],
              token: token,
              name: '',
              uid: userCredential.user!.uid,
              subscribedSoundPacks: [],
              username: userCredential.user!.displayName!,
              password: '',
              email: userCredential.user!.email!,
              photoUrl: userCredential.user!.photoURL!,
              following: [],
              pushToken: '',
              followers: [],
              subscribedUsers: [],
              bio: '',
              contact: '',
              isSubscriptionEnable: false,
              link: '',
              price: 0,
              soundPacks: []);
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfileScreen()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BottomBar()));
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
