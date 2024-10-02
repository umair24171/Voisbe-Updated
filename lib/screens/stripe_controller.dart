import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:http/http.dart' as http;

class PaymentController with ChangeNotifier {
  // Map<String, dynamic>? paymentIntentData;

  // // Future<void> makePayment(
  // //     {required String amount,
  // //     required String currency,
  // //     required VoidCallback addSubFunction}) async {
  // //   try {
  // //     // var balanceProvider =
  // //     //     Provider.of<BalanceProvider>(Get.context!, listen: false);
  // //     // balanceProvider.setBalanceLoading = true;
  // //     paymentIntentData = await createPaymentIntent(amount, currency);
  // //     if (paymentIntentData != null) {
  // //       await Stripe.instance.initPaymentSheet(
  // //           paymentSheetParameters: SetupPaymentSheetParameters(
  // //         merchantDisplayName: 'Prospects',
  // //         customerId: paymentIntentData!['customer'],
  // //         paymentIntentClientSecret: paymentIntentData!['client_secret'],
  // //         customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
  // //       ));

  // //       displayPaymentSheet(addSubFunction);
  // //       // balanceProvider.setBalanceLoading = false;
  // //     }
  // //   } catch (e) {
  // //     // showSnackBar('Error', e.toString());
  // //   }
  // // }
  // Future<void> makePayment({
  //   required String amount,
  //   required String currency,
  //   required VoidCallback addSubFunction,
  // }) async {
  //   try {
  //     paymentIntentData = await createPaymentIntent(amount, currency);
  //     if (paymentIntentData != null) {
  //       await Stripe.instance.initPaymentSheet(
  //         paymentSheetParameters: SetupPaymentSheetParameters(
  //           merchantDisplayName: 'Prospects',
  //           customerId: paymentIntentData!['customer'],
  //           paymentIntentClientSecret: paymentIntentData!['client_secret'],
  //           customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
  //         ),
  //       );

  //       // Only call displayPaymentSheet after initPaymentSheet has completed
  //       await displayPaymentSheet(addSubFunction);
  //     }
  //   } catch (e) {
  //     // Handle the error appropriately
  //     log('Error in makePayment: $e');
  //   }
  // }

  // // displayPaymentSheet(VoidCallback addSubFunction) async {
  // //   try {
  // //     await Stripe.instance.presentPaymentSheet();

  // //     // Get.snackbar('Payment', 'Payment Successful',
  // //     //     snackPosition: SnackPosition.BOTTOM,
  // //     //     backgroundColor: Colors.green,
  // //     //     colorText: Colors.white,
  // //     //     margin: const EdgeInsets.all(10),
  // //     //     duration: const Duration(seconds: 2));
  // //     addSubFunction();
  // //     // double totalAmount = oldAmount + double.parse(amount);
  // //     // await FirebaseFirestore.instance
  // //     //     .collection('users')
  // //     //     .doc(FirebaseAuth.instance.currentUser!.uid)
  // //     //     .update({'userBalance': totalAmount});
  // //   } on Exception catch (e) {
  // //     if (e is StripeException) {
  // //       log("Error from Stripe: ${e.error.localizedMessage}");
  // //     } else {
  // //       log("Unforeseen error: $e");
  // //     }
  // //   } catch (e) {
  // //     log("exception:$e");
  // //   }
  // // }
  // Future<void> displayPaymentSheet(VoidCallback addSubFunction) async {
  //   try {
  //     await Stripe.instance.presentPaymentSheet();
  //     addSubFunction();
  //   } on StripeException catch (e) {
  //     log("Error from Stripe: ${e.error.localizedMessage}");
  //   } catch (e) {
  //     log("Unforeseen error: $e");
  //   }
  // }

  // //  Future<Map<String, dynamic>>
  // createPaymentIntent(String amount, String currency) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': calculateAmount(amount),
  //       'currency': currency,
  //       'payment_method_types[]': 'card'
  //     };
  //     var response = await http.post(
  //         Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //         body: body,
  //         headers: {
  //           'Authorization':
  //               'Bearer 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',
  //           'Content-Type': 'application/x-www-form-urlencoded'
  //         });

  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     log('err charging user: ${err.toString()}');
  //   }
  // }

  // calculateAmount(String amount) {
  //   final a = (int.parse(amount)) * 100;
  //   return a.toString();
  // }
}
