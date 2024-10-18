// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_ask.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/auth_screens/view/otp_screen.dart';
import 'package:social_notes/screens/auth_screens/view/phone_number_screen.dart';
import 'package:social_notes/screens/auth_screens/view/widgets/verify_email.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  // instance of FirebaseAuth which is being used by firebaseauth package
  //  this auth is used to register the user and then login the user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // the registeration data of the user to save in the firestore database we use cloud firestore package and here's the instance of the that
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// this is the function to register the user
  userSignup({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    try {
      // shared prefs to save the user account
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userPro = Provider.of<UserProvider>(context, listen: false);
      userPro.setUserLoading(true);

      //  user registeration
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        NotificationMethods notificationMethods = NotificationMethods();
        String token = await notificationMethods.getFirebaseMessagingToken();

        UserModel userModel = UserModel(
            notificationsEnable: [],
            isTwoFa: false,
            // deactivate: false,
            isFollows: true,
            isLike: true,
            isReply: true,
            mutedAccouts: [],
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
            isOtpVerified: false,
            link: '',
            price: 0.00,
            soundPacks: []);

        // user data saving in the firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());
        // prefs.getString('userAccounts');
        if (prefs.getStringList('userAccounts') != null) {
          List<String>? allUsers = prefs.getStringList('userAccounts');
          allUsers == null
              ? await prefs
                  .setStringList('userAccounts', [credential.user!.uid])
              : await prefs.setStringList(
                  'userAccounts', [credential.user!.uid, ...allUsers]);
        } else {
          await prefs.setStringList('userAccounts', [credential.user!.uid]);
        }

        Provider.of<UserProvider>(context, listen: false).setUserNull();

        userPro.setUserLoading(false);

        log('User Registered Successfully');

        // Otp to confirm the email

        EmailOTP.config(
          appEmail: 'umairbilal207@gmail.com',
          appName: "VOISBE",
          otpLength: 6,
          expiry: 120000,
          otpType: OTPType.numeric,
        );
        // var result = await EmailOTP.sendOTP(email: email);
        EmailOTP.setTemplate(
          template: '''
  <div style="background-color: #f9f9f9; padding: 20px; font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);">
    <div style="text-align: center;">
      <h1 style="color: #EC6A5A; margin-bottom: 20px;">{{appName}}</h1>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 18px; color: #333333;">Hello,</p>
      <p style="font-size: 16px; color: #666666;">Your OTP code is:</p>
      <div style="font-size: 24px; font-weight: bold; color: #EC6A5A; margin: 20px 0;">
        {{otp}}
      </div>
      <p style="font-size: 14px; color: #999999;">This OTP is valid for 2 minutes.</p>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 14px; color: #666666;">If you did not request this OTP, please ignore this email.</p>
      <p style="font-size: 14px; color: #666666;">Thank you for using our service.</p>
    </div>
  </div>
  <div style="text-align: center; margin-top: 20px;">
    <p style="font-size: 12px; color: #999999;">&copy; {{appName}}. All rights reserved.</p>
  </div>
</div>

    ''',
        );

        var result = await EmailOTP.sendOTP(email: email);

        //  if otp successfully sent then show the dialog to enter the otp

        if (result) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: whiteColor,
              contentPadding: EdgeInsets.all(0),
              // insetPadding: EdgeInsets.all(0),
              elevation: 0,
              content: OtpField(
                uid: userModel.uid,
                email: email,
              ),
            ),
          );
        }
      }

      //  show the exceptions if the user is entering something wrong or wrong credentials
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
            title: 'Error Occurred',
            message: 'The password provided is too weak.',
            isUsernameRes: false);
      } else if (e.code == 'email-already-in-use') {
        showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
            title: 'Error Occurred',
            message: 'The account already exists for that email.',
            isUsernameRes: false);
      }
      return null;
    } catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
      showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
          title: 'Error Occurred', message: e.toString(), isUsernameRes: false);
      // showSnackBar(context, e.toString());
      log(e.toString());
    }
  }

  // The function to login the user based on credentials user were registered

  Future<void> userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userPro = Provider.of<UserProvider>(context, listen: false);
      userPro.setUserLoading(true);

      // Log email and password before attempting to sign in
      log('Attempting to sign in with email: $email');

      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credential.user != null) {
        // if the user is authenticated then get the data from the firestore database
        DocumentSnapshot<Map<String, dynamic>> currentUser =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(credential.user!.uid)
                .get();

        if (currentUser.exists) {
          UserModel userModel = UserModel.fromMap(currentUser.data()!);
          log('User Data: $userModel');

          // if the user has enabled the 2fa then reaunthenticate

          if (userModel.isTwoFa) {
            EmailOTP.config(
              appEmail: 'umairbilal207@gmail.com',
              appName: "VOISBE",
              otpLength: 6,
              expiry: 120000,
              otpType: OTPType.numeric,
            );

            EmailOTP.setTemplate(
                template:
                    ''' <div style="background-color: #f9f9f9; padding: 20px; font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);">
    <div style="text-align: center;">
      <h1 style="color: #EC6A5A; margin-bottom: 20px;">{{appName}}</h1>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 18px; color: #333333;">Hello,</p>
      <p style="font-size: 16px; color: #666666;">Your OTP code is:</p>
      <div style="font-size: 24px; font-weight: bold; color: #EC6A5A; margin: 20px 0;">
        {{otp}}
      </div>
      <p style="font-size: 14px; color: #999999;">This OTP is valid for 2 minutes.</p>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 14px; color: #666666;">If you did not request this OTP, please ignore this email.</p>
      <p style="font-size: 14px; color: #666666;">Thank you for using our service.</p>
    </div>
  </div>
  <div style="text-align: center; margin-top: 20px;">
    <p style="font-size: 12px; color: #999999;">&copy; {{appName}}. All rights reserved.</p>
  </div>
</div>''');

            var result = await EmailOTP.sendOTP(email: email);

            if (result) {
              List<String>? allUsers = prefs.getStringList('userAccounts');
              if (allUsers == null) {
                await prefs
                    .setStringList('userAccounts', [credential.user!.uid]);
              } else {
                allUsers.add(credential.user!.uid);
                await prefs.setStringList('userAccounts', allUsers);
              }

              userPro.setUserLoading(false);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: whiteColor,
                  contentPadding: EdgeInsets.all(0),
                  elevation: 0,
                  content: OtpField(
                    isLogin: true,
                    uid: credential.user!.uid,
                    email: email,
                  ),
                ),
              );
              String token =
                  await NotificationMethods().getFirebaseMessagingToken();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(credential.user!.uid)
                  .update({'token': token});
            } else {
              FirebaseAuth.instance.signOut();
            }
          } else {
            if (userModel.isOtpVerified) {
              //  if user otp verified then save the account info for the next time account changing feature
              List<String>? allUsers = prefs.getStringList('userAccounts');
              if (allUsers == null) {
                await prefs
                    .setStringList('userAccounts', [credential.user!.uid]);
              } else {
                allUsers.add(credential.user!.uid);
                await prefs.setStringList('userAccounts', allUsers);
              }
              userPro.setUserLoading(false);
              showWhiteOverlayPopup(context, Icons.check_box, null, null,
                  title: 'Login Successful',
                  message: 'You have successfully logged in.',
                  isUsernameRes: false);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomBar(),
                ),
                (route) => false,
              );

              //  getting user token and saving in database to send the push notifications
              String token =
                  await NotificationMethods().getFirebaseMessagingToken();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(credential.user!.uid)
                  .update({'token': token});
            } else {
              EmailOTP.config(
                appEmail: 'umairbilal207@gmail.com',
                appName: "Voisbe",
                otpLength: 6,
                expiry: 120000,
                otpType: OTPType.numeric,
              );

              EmailOTP.setTemplate(
                  template:
                      ''' <div style="background-color: #f9f9f9; padding: 20px; font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);">
    <div style="text-align: center;">
      <h1 style="color: #EC6A5A; margin-bottom: 20px;">{{appName}}</h1>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 18px; color: #333333;">Hello,</p>
      <p style="font-size: 16px; color: #666666;">Your OTP code is:</p>
      <div style="font-size: 24px; font-weight: bold; color: #EC6A5A; margin: 20px 0;">
        {{otp}}
      </div>
      <p style="font-size: 14px; color: #999999;">This OTP is valid for 2 minutes.</p>
      <hr style="border: none; height: 1px; background-color: #eeeeee; margin: 20px 0;">
      <p style="font-size: 14px; color: #666666;">If you did not request this OTP, please ignore this email.</p>
      <p style="font-size: 14px; color: #666666;">Thank you for using our service.</p>
    </div>
  </div>
  <div style="text-align: center; margin-top: 20px;">
    <p style="font-size: 12px; color: #999999;">&copy; {{appName}}. All rights reserved.</p>
  </div>
</div>''');

              var result = await EmailOTP.sendOTP(email: email);

              if (result) {
                List<String>? allUsers = prefs.getStringList('userAccounts');
                if (allUsers == null) {
                  await prefs
                      .setStringList('userAccounts', [credential.user!.uid]);
                } else {
                  allUsers.add(credential.user!.uid);
                  await prefs.setStringList('userAccounts', allUsers);
                }

                userPro.setUserLoading(false);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: whiteColor,
                    contentPadding: EdgeInsets.all(0),
                    elevation: 0,
                    content: OtpField(
                      isNotOtpVerified: true,
                      isLogin: true,
                      uid: userModel.uid,
                      email: email,
                    ),
                  ),
                );

                //  getting user token and saving in database to send the push notifications
                String token =
                    await NotificationMethods().getFirebaseMessagingToken();
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(credential.user!.uid)
                    .update({'token': token});
              }
            }
          }
        } else {
          // signout the user if the user account has been deleted
          await FirebaseAuth.instance.signOut();
          Provider.of<UserProvider>(context, listen: false)
              .setUserLoading(false);
          showWhiteOverlayPopup(
              context, null, 'assets/icons/Info (1).svg', null,
              title: 'Error Occurred',
              message: 'Account deleted.',
              isUsernameRes: false);
        }
      }
      //  show the exceptions if the user is entering something wrong or wrong credentials
    } on FirebaseAuthException catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);

      if (e.code == 'user-not-found') {
        showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
            title: 'Error Occurred',
            message: 'No user found for that email.',
            isUsernameRes: false);
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
        showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
            title: 'Error Occurred',
            message: 'The password provided is wrong.',
            isUsernameRes: false);
      }
    }
    //  show the exceptions if the user is entering something wrong or wrong credentials
    catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
      log(e.toString());
      showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
          title: 'Error Occurred', message: e.toString(), isUsernameRes: false);
    }
  }

  signInWithGoogle(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    try {
      // creating the instance of googlesignin which is coming from googlesignin package
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if(googleUser == null) return;
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      final UserCredential userCredential =
          await auth.signInWithCredential(credentials);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          //  getting user token and saving in database to send the push notifications
          NotificationMethods notificationMethods = NotificationMethods();
          String token = await notificationMethods.getFirebaseMessagingToken();

          UserModel userModel = UserModel(
              isOtpVerified: true,
              notificationsEnable: [],
              isTwoFa: false,
              // deactivate: false,
              isFollows: true,
              isLike: true,
              isReply: true,
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
              mutedAccouts: [],
              contact: '',
              isSubscriptionEnable: false,
              link: '',
              price: 0.00,
              soundPacks: []);

          //  saving the required data of user throgh user model in the firestore database
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());

          // after saving the data.. pushing the user to the profile screen if it is is first time the user is using the email for google

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfileScreen()));
        } else {
          //if not the first time user using the email for google then just directly push the user to bottombar screen which is home
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BottomBar()));
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  signInWithApple(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    try {
      final appleAuthProvider = AppleAuthProvider();
      final UserCredential userCredential =
          await auth.signInWithProvider(appleAuthProvider);
      // creating the instance of googlesignin which is coming from googlesignin package
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          //  getting user token and saving in database to send the push notifications
          NotificationMethods notificationMethods = NotificationMethods();
          String token = await notificationMethods.getFirebaseMessagingToken();

          UserModel userModel = UserModel(
              isOtpVerified: true,
              notificationsEnable: [],
              isTwoFa: false,
              // deactivate: false,
              isFollows: true,
              isLike: true,
              isReply: true,
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
              mutedAccouts: [],
              contact: '',
              isSubscriptionEnable: false,
              link: '',
              price: 0.00,
              soundPacks: []);

          //  saving the required data of user throgh user model in the firestore database
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());

          // after saving the data.. pushing the user to the profile screen if it is is first time the user is using the email for google

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfileScreen()));
        } else {
          //if not the first time user using the email for google then just directly push the user to bottombar screen which is home
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BottomBar()));
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // // void signInWithPhone(
  // //   BuildContext context,
  // //   String phoneNumber,
  // // ) async {
  // //   try {
  // //     await _auth.verifyPhoneNumber(
  // //         phoneNumber: phoneNumber,
  // //         verificationCompleted: (PhoneAuthCredential credential) async {
  // //           await _auth.signInWithCredential(credential);
  // //         },
  // //         verificationFailed: (FirebaseAuthException e) {
  // //           FirebaseAuth.instance.signOut();
  // //           log('error is $e');
  // //           showWhiteOverlayPopup(context, Icons.error, null,
  // //               title: 'Error Occurred',
  // //               message: e.toString(),
  // //               isUsernameRes: false);
  // //         },
  // //         codeSent: (String verificationId, int? resendToken) {
  // //           Navigator.push(
  // //               context,
  // //               MaterialPageRoute(
  // //                 builder: (context) =>
  // //                     OTPScreen(verificationId: verificationId),
  // //               ));
  // //         },
  // //         codeAutoRetrievalTimeout: (String varificationId) {});
  // //   } catch (e) {
  // //     // showSnackBar(context, e.toString());
  // //     log(e.toString());
  // //   }
  // // }

  // // function to verify the otp that send

  // void verifyOTP(
  //     {required BuildContext context,
  //     required String verificationID,
  //     required String userOTP}) async {
  //   try {
  //     PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
  //         verificationId: verificationID, smsCode: userOTP);
  //     await _auth.signInWithCredential(phoneAuthCredential);
  //     Navigator.of(context)
  //         .pushNamedAndRemoveUntil(BottomBar.routeName, (route) => false);
  //   } on FirebaseAuthException catch (e) {
  //     log(e.toString());
  //   }
  // }
}
