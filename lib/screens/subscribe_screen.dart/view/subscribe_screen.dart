import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:social_notes/resources/app_constants.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/stripe_controller.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:http/http.dart' as http;

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key, required this.price});
  static const routeName = '/subscribe-screen';
  final double price;

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  static const String backendUrl = 'https://api-yqekgrov4a-uc.a.run.app';
  String? paymentIntentClientSecret;
  bool isLoading = false;
  Future<void> fetchPaymentIntent(double price) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$backendUrl/create-payment-intent');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'price': widget.price}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          paymentIntentClientSecret = json['clientSecret'];
          isLoading = false;
        });
      } else {
        print('Server responded with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch payment intent');
      }
    } catch (e) {
      print('Error fetching payment intent: $e');
      setState(() {
        isLoading = false;
      });
      showWhiteOverlayPopup(context, Icons.subscriptions_outlined, null, null,
          title: 'Error loading page',
          message: 'Failed to fetch payment intent: $e.',
          isUsernameRes: false);
    }
  }

  Future<void> pay(UserModel otherUser, UserModel currentUser) async {
    var currentUser=Provider.of<UserProvider>(context,listen: false).user;
    if (paymentIntentClientSecret == null) return;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret!,
          merchantDisplayName: 'Voisbe',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      var pro = Provider.of<UserProvider>(context, listen: false);
      // if (!otherUser.otherUser!.subscribedUsers
      //     .contains(currentUser.uid)) {
      pro.setUserLoading(true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUser.uid)
          .update({
        'subscribedUsers': FieldValue.arrayUnion([currentUser!.uid])
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'subscribedSoundPacks': FieldValue.arrayUnion([otherUser.uid])
        });
      }).then((value) {
        pro.setUserLoading(false);
        // currentUser.subscribedSoundPacks.add(otherUser.uid);
        Provider.of<UserProfileProvider>(context, listen: false)
            .addSubscription(currentUser.uid);
        showWhiteOverlayPopup(context, Icons.subscriptions_outlined, null, null,
            title: 'Subscription Successful',
            message:
                'You have successfully subscribed to ${otherUser.username}.',
            isUsernameRes: false);
      }).onError((error, stackTrace) {
        pro.setUserLoading(false);
        log('Error: $error');
      });

      // showWhiteOverlayPopup(context, Icons.subscriptions_outlined, null, null,
      //     title: 'Subscription Successful',
      //     message: 'You have successfully subscribed to ${otherUser.username}.',
      //     isUsernameRes: false);
    } catch (e) {
      if (e is StripeException) {
        Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
        // showWhiteOverlayPopup(context, Icons.error, null, null,
        //     title: 'Error', message: e.toString(), isUsernameRes: false);
      } else {
        Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
        showWhiteOverlayPopup(context, Icons.subscriptions_outlined, null, null,
            title: 'Payment Failed',
            message: 'An unexpected error occurred.',
            isUsernameRes: false);
      }
    }
  }

  // ios pay function
  Future<void> payIos(UserModel otherUser, UserModel currentUser) async {
    var pro = Provider.of<UserProvider>(context, listen: false);

    try {
      pro.setUserLoading(true);

      await _purchaseBasedOnPrice(
          otherUser.price.toInt(), otherUser, currentUser);
    } catch (e, stackTrace) {
      log('Error during subscription: $e\n$stackTrace');
      pro.setUserLoading(false);
    }
  }

// Helper function to handle purchases based on price
  Future<void> _purchaseBasedOnPrice(
      int price, UserModel otherUser, UserModel currentUser) async {
    String? productKey;

    switch (price) {
      case 4:
        productKey = AppConstants().userSubscriptionKey4;
        break;
      case 10:
        productKey = AppConstants().userSubscriptionKey10;
        break;
      case 20:
        productKey = AppConstants().userSubscriptionKey20;
        break;
      case 50:
        productKey = AppConstants().userSubscriptionKey50;
        break;
      case 100:
        productKey = AppConstants().userSubscriptionKey100;
        break;
      default:
        throw 'Invalid price';
    }

    if (productKey != null) {
      await Purchases.purchaseProduct(productKey).then((value) async {
        await _updateSubscription(otherUser, currentUser);
        _onSubscriptionSuccess(otherUser, currentUser);
      }).catchError((error) {
        log('Error during purchase: $error');
      });
    }
  }

  Future<void> _updateSubscription(
      UserModel otherUser, UserModel currentUser) async {
    log('other user is ${otherUser.uid}');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUser.uid)
        .update({
      'subscribedUsers': FieldValue.arrayUnion([currentUser.uid])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'subscribedSoundPacks': FieldValue.arrayUnion([otherUser.uid])
    });
     Provider.of<UserProfileProvider>(context, listen: false)
            .addSubscription(currentUser.uid);
  }

  void _onSubscriptionSuccess(UserModel otherUser, UserModel currentUser) {
    var pro = Provider.of<UserProvider>(context, listen: false);

    currentUser.subscribedSoundPacks.add(otherUser.uid);

    pro.setUserLoading(false);

    showWhiteOverlayPopup(
      context,
      Icons.subscriptions_outlined,
      null,
      null,
      title: 'Subscription Successful',
      message: 'You have successfully subscribed to ${otherUser.username}.',
      isUsernameRes: false,
    );
  }

  @override
  void initState() {
    log('price is ${widget.price}');
    fetchPaymentIntent(widget.price);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // var otherUser =
    //     Provider.of<UserProfileProvider>(context, listen: false).otherUser;

    //  getting the current user
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      body: Stack(
        children: [
          // the background of the screen

          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffee856d), Color(0xffed6a5a)])),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10)
                      .copyWith(top: 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 125,
                        child: Stack(
                          children: [
                            //  getting the subsribtion user pic

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
                        //  getting the subsription user name

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Subscribe to ${otherUser.otherUser!.name}',
                              style: TextStyle(
                                  color: whiteColor,
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17),
                            ),
                            if (otherUser.otherUser!.isVerified) verifiedIcon()
                          ],
                        );
                      }),
                      Consumer<UserProfileProvider>(
                          builder: (context, userPro, _) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.14, vertical: 10),

                          //  getting the user monthly subsription price

                          child: Text(
                            'Monthly payment of USD ${userPro.otherUser!.price.toStringAsFixed(2)}\n You receive access to the following specials:',
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
                                padding:
                                    const EdgeInsets.only(top: 1, right: 5),
                                child: Icon(
                                  Icons.check,
                                  color: whiteColor,
                                  size: 18,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Access to exclusive voice messages\nonly for subscribers.',
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
                            .copyWith(left: size.width * 0.13, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.check,
                                color: whiteColor,
                                size: 20,
                              ),
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
                      // Padding(
                      //   padding: const EdgeInsets.all(12)
                      //       .copyWith(left: size.width * 0.13),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.check,
                      //         color: whiteColor,
                      //         size: 20,
                      //       ),
                      //       Expanded(
                      //         child: Text(
                      //           'Access to longer voice messages',
                      //           overflow: TextOverflow.fade,
                      //           style: TextStyle(color: whiteColor),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.all(12)
                            .copyWith(left: size.width * 0.13, right: 5),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.check,
                                color: whiteColor,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Consumer<UserProfileProvider>(
                                  builder: (context, otherUser, _) {
                                //  getting the subsription user name

                                return Text(
                                  'Your replies are shown at the top\nof ${otherUser.otherUser!.username}\'s post',
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
                      onTap: paymentIntentClientSecret==null?null :() async {
                        //  logic if the id exist then remove the current user as a subsriber otherwise add a subsriber

                        if (!otherUser.otherUser!.subscribedUsers
                            .contains(currentUser!.uid)) {
                          log('function running');

                          if (Platform.isIOS) {
                            await payIos(otherUser.otherUser!, currentUser);
                          } else {
                            await pay(otherUser.otherUser!, currentUser);
                          }

                          // Provider.of<PaymentController>(context,
                          //         listen: false)
                          //     .makePayment(
                          //         amount: otherUser.otherUser!.price
                          //             .toInt()
                          //             .toString(),
                          //         currency: 'usd',
                          //         addSubFunction: () async {

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
                            otherUser.removeSubscription(currentUser.uid);
                            // currentUser.subscribedSoundPacks
                            //     .remove(otherUser.otherUser!.uid);
                            showWhiteOverlayPopup(context,
                                Icons.subscriptions_outlined, null, null,
                                title: 'Successful',
                                message:
                                    'You have successfully unsubscribed to ${otherUser.otherUser!.username}.',
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

                          //  showing the loader while the user is being subscribing

                          child: isLoading
                              ? SpinKitThreeBounce(
                                  color: blackColor,
                                  size: 13,
                                )
                              : loadProvider.userLoading
                                  ? SpinKitThreeBounce(
                                      color: blackColor,
                                      size: 13,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star_border,
                                            color: blackColor, size: 22),
                                        const SizedBox(
                                          width: 6,
                                        ),

                                        //  getting the real time text if the user is subscribed or not

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
                                                  subUser.subscribedUsers
                                                          .contains(
                                                              currentUser!.uid)
                                                      ? 'Unsubscribe'
                                                      : 'Subscribe',
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontFamily: fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
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

                      //  agreeing the terms and conditions

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
          ),
        ],
      ),
      // bottomNavigationBar: BottomBar(),
    );
  }
}
