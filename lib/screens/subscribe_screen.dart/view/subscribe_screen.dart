import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/stripe_controller.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:social_notes/screens/custom_bottom_bar.dart';

class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});
  static const routeName = '/subscribe-screen';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // var otherUser =
    //     Provider.of<UserProfileProvider>(context, listen: false).otherUser;
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffee856d), Color(0xffed6a5a)])),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10)
                      .copyWith(top: 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Consumer<UserProfileProvider>(
                              builder: (context, otherUser, _) {
                            return CircleAvatar(
                              radius: 55,
                              backgroundImage: NetworkImage(otherUser
                                      .otherUser!.photoUrl.isEmpty
                                  ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D'
                                  : otherUser.otherUser!.photoUrl),
                            );
                          }),
                          Positioned(
                            bottom: size.width * 0.01,
                            left: size.width * 0.19,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(40)),
                              child: Icon(
                                Icons.star_border,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  // height: 156,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Consumer<UserProfileProvider>(
                          builder: (context, otherUser, _) {
                        return Text(
                          'Subscribe to ${otherUser.otherUser!.username}',
                          style: TextStyle(
                              color: whiteColor,
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 17),
                        );
                      }),
                      Consumer<UserProfileProvider>(
                          builder: (context, userPro, _) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.14, vertical: 10),
                          child: Text(
                            'Monthly payment of USD ${userPro.otherUser!.price} You receive access to the following specials:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: whiteColor,
                                fontSize: 12,
                                fontFamily: fontFamily),
                          ),
                        );
                      }),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12)
                            .copyWith(left: size.width * 0.13),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.check,
                                  color: whiteColor,
                                  size: 18,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Access to exclusive voice messages only for subscribers.',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: whiteColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12)
                            .copyWith(left: size.width * 0.13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              color: whiteColor,
                              size: 20,
                            ),
                            Expanded(
                              child: Text(
                                'Subscriber badge',
                                overflow: TextOverflow.fade,
                                style: TextStyle(color: whiteColor),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12)
                            .copyWith(left: size.width * 0.13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              color: whiteColor,
                              size: 20,
                            ),
                            Expanded(
                              child: Text(
                                'Access to longer voice messages',
                                overflow: TextOverflow.fade,
                                style: TextStyle(color: whiteColor),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12)
                            .copyWith(left: size.width * 0.13),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check,
                              color: whiteColor,
                              size: 20,
                            ),
                            Expanded(
                              child: Consumer<UserProfileProvider>(
                                  builder: (context, otherUser, _) {
                                return Text(
                                  'Your replies are shown  at the top of ${otherUser.otherUser!.username}\'s post',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: whiteColor),
                                );
                              }),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                Consumer<UserProfileProvider>(builder: (context, otherUser, _) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () async {
                        if (!otherUser.otherUser!.subscribedUsers
                            .contains(currentUser!.uid)) {
                          // Provider.of<PaymentController>(context, listen: false)
                          //     .makePayment(
                          //         amount: otherUser.otherUser!.price
                          //             .toInt()
                          //             .toString(),
                          //         currency: 'usd',
                          //         addSubFunction: () async {
                          //           var pro = Provider.of<UserProvider>(context,
                          //               listen: false);
                          //           // if (!otherUser.otherUser!.subscribedUsers
                          //           //     .contains(currentUser.uid)) {
                          //           pro.setUserLoading(true);
                          //           await FirebaseFirestore.instance
                          //               .collection('users')
                          //               .doc(otherUser.otherUser!.uid)
                          //               .update({
                          //             'subscribedUsers': FieldValue.arrayUnion(
                          //                 [currentUser.uid])
                          //           }).then((value) async {
                          //             await FirebaseFirestore.instance
                          //                 .collection('users')
                          //                 .doc(currentUser.uid)
                          //                 .update({
                          //               'subscribedSoundPacks':
                          //                   FieldValue.arrayUnion(
                          //                       [otherUser.otherUser!.uid])
                          //             });
                          //           }).then((value) {
                          //             pro.setUserLoading(false);
                          //             currentUser.subscribedSoundPacks
                          //                 .add(otherUser.otherUser!.uid);
                          //             showWhiteOverlayPopup(context,
                          //                 Icons.subscriptions_outlined, null,
                          //                 title: 'Subscription Successful',
                          //                 message:
                          //                     'You have successfully subscribed to ${otherUser.otherUser!.username}',
                          //                 isUsernameRes: false);
                          //           }).onError((error, stackTrace) {
                          //             pro.setUserLoading(false);
                          //             log('Error: $error');
                          //           });
                          //         });
                        } else {
                          var pro =
                              Provider.of<UserProvider>(context, listen: false);
                          pro.setUserLoading(true);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherUser.otherUser!.uid)
                              .update({
                            'subscribedUsers':
                                FieldValue.arrayRemove([currentUser.uid])
                          }).then((value) async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .update({
                              'subscribedSoundPacks': FieldValue.arrayRemove(
                                  [otherUser.otherUser!.uid])
                            });
                          }).then((value) {
                            pro.setUserLoading(false);
                            currentUser.subscribedSoundPacks
                                .add(otherUser.otherUser!.uid);
                            showWhiteOverlayPopup(
                                context, Icons.subscriptions_outlined, null,
                                title: 'Successful',
                                message:
                                    'You have successfully unsubscribed to ${otherUser.otherUser!.username}',
                                isUsernameRes: false);
                          }).onError((error, stackTrace) {
                            pro.setUserLoading(false);
                            log('Error: $error');
                          });
                        }
                      },
                      child: Consumer<UserProvider>(
                          builder: (context, loadProvider, _) {
                        return Container(
                          width: size.width * 0.8,
                          height: 35,
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(40)),
                          child: loadProvider.userLoading
                              ? SpinKitThreeBounce(
                                  color: blackColor,
                                  size: 13,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star_border,
                                        color: blackColor, size: 22),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(otherUser.otherUser!.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            UserModel subUser =
                                                UserModel.fromMap(
                                                    snapshot.data!.data()!);
                                            return Text(
                                              subUser.subscribedUsers.contains(
                                                      currentUser!.uid)
                                                  ? 'Unsubscribe'
                                                  : 'Subscribe',
                                              style: TextStyle(
                                                  color: blackColor,
                                                  fontFamily: fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            );
                                          } else {
                                            return const Text('');
                                          }
                                        }),
                                  ],
                                ),
                        );
                      }),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'By tapping Subscribe, you agree to the ',
                        style: TextStyle(
                            color: whiteColor,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          var url = 'https://www.voisbe.com/subscriptionterms';
                          if (await launchUrl(Uri.parse(url))) {
                          } else {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text(
                          'Subscription Terms',
                          style: TextStyle(
                              color: blackColor,
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomBar(),
    );
  }
}
