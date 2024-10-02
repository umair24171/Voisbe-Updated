import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/settings_screen/model/payment_info.dart';
import 'package:uuid/uuid.dart';

class PaymentDetailsScreen extends StatefulWidget {
  PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  late StreamSubscription<DocumentSnapshot> stream;

//  controllers to get the value entered

  TextEditingController nameController = TextEditingController();

  TextEditingController ibanController = TextEditingController();

  TextEditingController swiftCodeController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  //  get the payment info if already entered by the user and saved in database

  getPaymentInfo() async {
    var user = Provider.of<UserProvider>(context, listen: false).user;
    stream = FirebaseFirestore.instance
        .collection('paymentInfos')
        .doc(user!.uid)
        .snapshots()
        .listen((snapshot) {
      PaymentInfoModel paymentInfoModel =
          PaymentInfoModel.fromMap(snapshot.data()!);

      setState(() {
        nameController = TextEditingController(text: paymentInfoModel.fullName);
        ibanController =
            TextEditingController(text: paymentInfoModel.accountNo);
        swiftCodeController =
            TextEditingController(text: paymentInfoModel.swiftCode);
        bankNameController =
            TextEditingController(text: paymentInfoModel.bankName);
        addressController =
            TextEditingController(text: paymentInfoModel.bankAddress);
      });
    });
  }

  @override
  void initState() {
    getPaymentInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mdWidth = MediaQuery.of(context).size.width;
    double mdHeight = MediaQuery.of(context).size.height;
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton(
          onPressed: () {
            navPop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
            size: 25,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Payment Details',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Credit card (1).svg',
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(
                      width: mdWidth * .03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'Your bank details',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: mdWidth * .055,
                            fontFamily: khulaRegular),
                      ),
                    ),
                  ],
                ),
              ),

              //  user full name field

              PayFieldWidget(
                  maxLine: 1,
                  hint: 'Full Name*',
                  keyboardType: TextInputType.text,
                  controller: nameController),

              //  user account or iban number

              PayFieldWidget(
                  isAccountNum: true,
                  maxLine: 1,
                  hint: 'IBAN or Account Number*',
                  keyboardType: TextInputType.text,
                  controller: ibanController),

              //  users swift code

              PayFieldWidget(
                  isSwiftCOde: true,
                  maxLine: 1,
                  hint: 'SWIFT Code*',
                  keyboardType: TextInputType.text,
                  controller: swiftCodeController),

              //  users bank name field

              PayFieldWidget(
                  hint: 'Bank Name*',
                  maxLine: 1,
                  keyboardType: TextInputType.text,
                  controller: bankNameController),

              //  users bank address

              PayFieldWidget(
                  hint: 'Bank Address*',
                  maxLine: 6,
                  keyboardType: TextInputType.text,
                  controller: addressController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(blackColor),
                          elevation: const WidgetStatePropertyAll(0),
                        ),

                        //  function to remove the paymnent info

                        onPressed: () {
                          Provider.of<SettingsProvider>(context, listen: false)
                              .removePaymentInfo(currentUser!.uid, context);
                          nameController.clear();
                          ibanController.clear();
                          swiftCodeController.clear();
                          bankNameController.clear();
                          addressController.clear();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                fontFamily: khulaRegular),
                          ),
                        ),
                      ),
                    ),

                    //  fucntion to add the payment info after getting the required data

                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(blackColor),
                        elevation: const WidgetStatePropertyAll(0),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            ibanController.text.isNotEmpty &&
                            swiftCodeController.text.isNotEmpty &&
                            bankNameController.text.isNotEmpty &&
                            addressController.text.isNotEmpty) {
                          String paymentId = const Uuid().v4();
                          PaymentInfoModel paymentInfo = PaymentInfoModel(
                              paymentId: paymentId,
                              userId: currentUser!.uid,
                              fullName: nameController.text,
                              accountNo: ibanController.text,
                              bankAddress: addressController.text,
                              bankName: bankNameController.text,
                              swiftCode: swiftCodeController.text);
                          Provider.of<SettingsProvider>(context, listen: false)
                              .addPaymentInfo(paymentInfo, context);
                        } else {
                          //  showing the error popup

                          showWhiteOverlayPopup(
                              context, null, 'assets/icons/Info (1).svg', null,
                              title: "Error",
                              message: "Fields cannot be empty.",
                              isUsernameRes: false);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Save New Details',
                          style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              fontFamily: khulaRegular),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

//  field layout or widget

class PayFieldWidget extends StatelessWidget {
  PayFieldWidget(
      {super.key,
      required this.hint,
      required this.keyboardType,
      required this.controller,
      this.isSwiftCOde = false,
      this.isAccountNum = false,
      this.isPass = false,
      required this.maxLine});
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int maxLine;
  // final String khularegular = '';
  bool isSwiftCOde;
  bool isAccountNum;
  bool isPass;
  @override
  Widget build(BuildContext context) {
    double mdWidth = MediaQuery.of(context).size.width;
    double mdHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: EdgeInsets.only(top: mdHeight * .02),
        height: maxLine == 6 ? mdHeight * .2 : mdHeight * .06,
        child: TextFormField(
          controller: controller,
          // inputFormatters: [
          //   isSwiftCOde
          //       ? LengthLimitingTextInputFormatter(9)
          //       : isAccountNum
          //           ? LengthLimitingTextInputFormatter(1000)
          //           : LengthLimitingTextInputFormatter(60)
          // ],
          keyboardType: keyboardType,
          maxLines: maxLine,
          obscureText: isPass ? true : false,
          style: TextStyle(fontFamily: khulaRegular, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
                top: mdHeight * .01, left: mdWidth * .03, right: mdWidth * .03),
            hintText: hint,
            hintStyle: TextStyle(fontFamily: khulaRegular, color: Colors.black),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: mdWidth * .005, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

// class CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     // Remove all non-digit characters
//     String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

//     // Format card number with spaces every 4 digits
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i % 4 == 0 && i != 0) {
//         formatted += ' ';
//       }
//       formatted += digitsOnly[i];
//     }

//     // Return the formatted value
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

// class CardExpiryDateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 2) {
//         formatted += '/';
//       }
//       formatted += digitsOnly[i];
//     }

//     // Return the formatted value
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

// class PaymentDetailsScreen extends StatefulWidget {
//   const PaymentDetailsScreen({super.key});

//   @override
//   State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
// }

// class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
//   late StreamSubscription<DocumentSnapshot> stream;
//   TextEditingController cardNumberCont = TextEditingController();
//   TextEditingController cardDateCont = TextEditingController();
//   TextEditingController securityCodeCont = TextEditingController();

// getPaymentInfo() async {
//   var user = Provider.of<UserProvider>(context, listen: false).user;
//   stream = FirebaseFirestore.instance
//       .collection('paymentInfos')
//       .doc(user!.uid)
//       .snapshots()
//       .listen((snapshot) {
//     PaymentInfoModel paymentInfoModel =
//         PaymentInfoModel.fromMap(snapshot.data()!);

//     setState(() {
//       cardNumberCont =
//           TextEditingController(text: paymentInfoModel.cardNumber);
//       cardDateCont = TextEditingController(text: paymentInfoModel.cardDate);
//       securityCodeCont =
//           TextEditingController(text: paymentInfoModel.securityCode);
//     });
//   });
// }

// @override
// void initState() {
//   getPaymentInfo();
//   super.initState();
// }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var currentUser = Provider.of<UserProvider>(context, listen: false).user;

//     return Scaffold(
//       backgroundColor: whiteColor,
//       appBar: AppBar(
//         backgroundColor: whiteColor,
//         leading: IconButton(
//           onPressed: () {
//             navPop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: blackColor,
//             size: 30,
//           ),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Payment Details',
//           style: TextStyle(
//               color: blackColor,
//               fontSize: 18,
//               fontFamily: khulaBold,
//               fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 14.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
// SvgPicture.asset(
//   'assets/icons/Credit card (1).svg',
//   height: 30,
//   width: 30,
// ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Text(
//                   'Credit Card Details',
//                   style: TextStyle(
//                       color: blackColor,
//                       fontSize: 18,
//                       fontFamily: khulaBold,
//                       fontWeight: FontWeight.w700),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           TextFormField(
//             controller: cardNumberCont,
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(
//                   19), // Max length with spaces: 16 digits + 3 spaces
//               CardNumberInputFormatter(),
//             ],
//             decoration: InputDecoration(
//               hintText: 'Card Number*',
//               hintStyle: TextStyle(
//                   color: blackColor,
//                   fontSize: 16,
//                   fontFamily: khulaRegular,
//                   fontWeight: FontWeight.w600),
//               constraints: BoxConstraints(
//                 maxWidth: size.width * 0.9,
//               ),
//               contentPadding: const EdgeInsets.all(0).copyWith(left: 14),
//               fillColor: whiteColor,
//               filled: true,
//               border: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0xffC8C8C8)),
//               ),
//               enabledBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0xffC8C8C8)),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0xffC8C8C8)),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               TextFormField(
//                 controller: cardDateCont,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(4), // MM/YY format
//                   CardExpiryDateInputFormatter(),
//                 ],
//                 decoration: InputDecoration(
//                   hintText: 'MM/YY*',
//                   hintStyle: TextStyle(
//                       color: blackColor,
//                       fontSize: 16,
//                       fontFamily: khulaRegular,
//                       fontWeight: FontWeight.w600),
//                   constraints: BoxConstraints(
//                     maxWidth: size.width * 0.3,
//                   ),
//                   contentPadding: const EdgeInsets.all(0).copyWith(left: 14),
//                   fillColor: whiteColor,
//                   filled: true,
//                   border: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                   enabledBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                 ),
//               ),
//               TextFormField(
//                 controller: securityCodeCont,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(4), // MMYY digits only
//                 ],
//                 decoration: InputDecoration(
//                   hintText: 'Security Code*',
//                   hintStyle: TextStyle(
//                       color: blackColor,
//                       fontSize: 16,
//                       fontFamily: khulaRegular,
//                       fontWeight: FontWeight.w600),
//                   constraints: BoxConstraints(
//                     maxWidth: size.width * 0.5,
//                   ),
//                   contentPadding: const EdgeInsets.all(0).copyWith(left: 14),
//                   fillColor: whiteColor,
//                   filled: true,
//                   border: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                   enabledBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xffC8C8C8)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
// Row(
//   children: [
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       child: ElevatedButton(
//         style: ButtonStyle(
//           backgroundColor: WidgetStatePropertyAll(blackColor),
//           elevation: const WidgetStatePropertyAll(0),
//         ),
//         onPressed: () {
//           if (cardNumberCont.text.isNotEmpty &&
//               cardDateCont.text.isNotEmpty &&
//               securityCodeCont.text.isNotEmpty) {
//             String paymentId = const Uuid().v4();
//             PaymentInfoModel paymentInfo = PaymentInfoModel(
//                 paymentId: paymentId,
//                 userId: currentUser!.uid,
//                 cardNumber: cardNumberCont.text,
//                 cardDate: cardDateCont.text,
//                 securityCode: securityCodeCont.text);
//             Provider.of<SettingsProvider>(context, listen: false)
//                 .addPaymentInfo(paymentInfo, context);
//           } else {
//             showWhiteOverlayPopup(context, Icons.error, null,
//                 title: "Error",
//                 message: "Fields cannot be empty",
//                 isUsernameRes: false);
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(
//             'Update',
//             style: TextStyle(
//                 color: whiteColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 17,
//                 fontFamily: khulaRegular),
//           ),
//         ),
//       ),
//     ),
//     ElevatedButton(
//       style: ButtonStyle(
//         backgroundColor: WidgetStatePropertyAll(blackColor),
//         elevation: const WidgetStatePropertyAll(0),
//       ),
//       onPressed: () {
//         String paymentId = const Uuid().v4();
//         PaymentInfoModel paymentInfo = PaymentInfoModel(
//             paymentId: paymentId,
//             userId: currentUser!.uid,
//             cardNumber: '',
//             cardDate: '',
//             securityCode: '');
//         Provider.of<SettingsProvider>(context, listen: false)
//             .addPaymentInfo(paymentInfo, context);
//         cardNumberCont.clear();
//         cardDateCont.clear();
//         securityCodeCont.clear();
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Text(
//           'Delete',
//           style: TextStyle(
//               color: whiteColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 17,
//               fontFamily: khulaRegular),
//         ),
//       ),
//     )
//   ],
// )
//         ],
//       ),
//     );
//   }
// }
