import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/settings_screen/model/payment_info.dart';
import 'package:uuid/uuid.dart';

class BankDetails extends StatefulWidget {
  BankDetails(
      {super.key,
      required this.stripeFunction,
      required this.user,
      required this.changeSub});
  final VoidCallback stripeFunction;
  final UserModel user;
  final VoidCallback changeSub;

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  late StreamSubscription<DocumentSnapshot> stream;

  TextEditingController nameController = TextEditingController();

  TextEditingController ibanController = TextEditingController();

  TextEditingController swiftCodeController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  //  get the payment info of the user if already added

  getPaymentInfo() async {
    // var user = Provider.of<UserProvider>(context, listen: false).user;
    stream = FirebaseFirestore.instance
        .collection('paymentInfos')
        .doc(widget.user.uid)
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
    // getting info before building the popup

    getPaymentInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mdWidth = MediaQuery.of(context).size.width;
    double mdHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //  field to show the already added data or change

          Column(
            children: [
              Icon(
                Icons.error_outline,
                size: mdWidth * .09,
                color: Colors.black,
              ),
              SizedBox(
                height: mdHeight * .01,
              ),
              Text(
                'Enter your payout details',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: mdWidth * .05,
                    fontFamily: khulaRegular),
              ),
              SizedBox(
                height: mdHeight * .02,
              ),
              PayFieldWidget(
                  maxLine: 1,
                  hint: 'Full Name*',
                  keyboardType: TextInputType.text,
                  controller: nameController),
              PayFieldWidget(
                  isAccountNum: true,
                  maxLine: 1,
                  hint: 'IBAN or Account Number*',
                  keyboardType: TextInputType.text,
                  controller: ibanController),
              PayFieldWidget(
                  isSwiftCOde: true,
                  maxLine: 1,
                  hint: 'SWIFT Code*',
                  keyboardType: TextInputType.text,
                  controller: swiftCodeController),
              PayFieldWidget(
                  hint: 'Bank Name*',
                  maxLine: 1,
                  keyboardType: TextInputType.text,
                  controller: bankNameController),
              PayFieldWidget(
                  hint: 'Bank Address*',
                  maxLine: 6,
                  keyboardType: TextInputType.text,
                  controller: addressController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  children: [
//  function to update the data of the user bank info

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
                              userId: widget.user.uid,
                              fullName: nameController.text,
                              accountNo: ibanController.text,
                              bankAddress: addressController.text,
                              bankName: bankNameController.text,
                              swiftCode: swiftCodeController.text);
                          Provider.of<SettingsProvider>(context, listen: false)
                              .addPaymentInfo(paymentInfo, context);

                          navPop(context);
                          widget.changeSub();
                          widget.stripeFunction();
                        } else {
                          showWhiteOverlayPopup(
                              context, null, 'assets/icons/Info (1).svg', null,
                              title: "Error",
                              message: "Fields cannot be empty",
                              isUsernameRes: false);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Save Details',
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

class PayFieldWidget extends StatelessWidget {
  PayFieldWidget(
      {super.key,
      required this.hint,
      required this.keyboardType,
      required this.controller,
      this.isSwiftCOde = false,
      this.isAccountNum = false,
      required this.maxLine});
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int maxLine;
  // final String khularegular = '';
  bool isSwiftCOde;
  bool isAccountNum;
  @override
  Widget build(BuildContext context) {
    double mdWidth = MediaQuery.of(context).size.width;
    double mdHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        margin: EdgeInsets.only(top: mdHeight * .02),
        height: maxLine == 6 ? mdHeight * .2 : mdHeight * .06,
        child: TextFormField(
          controller: controller,
          inputFormatters: [
            isSwiftCOde
                ? LengthLimitingTextInputFormatter(9)
                : isAccountNum
                    ? LengthLimitingTextInputFormatter(13)
                    : LengthLimitingTextInputFormatter(60)
          ],
          keyboardType: keyboardType,
          maxLines: maxLine,
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
