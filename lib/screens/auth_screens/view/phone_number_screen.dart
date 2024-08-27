  // // ignore_for_file: prefer_typing_uninitialized_variables

  // import 'dart:developer';

  // import 'package:country_picker/country_picker.dart';
  // import 'package:flutter/material.dart';
  // import 'package:social_notes/resources/colors.dart';
  // import 'package:social_notes/screens/auth_screens/controller/auth_controller.dart';

  // class PhoneNumberScreen extends StatefulWidget {
  //   const PhoneNumberScreen({super.key});
  //   static const routeName = 'login-screen';

  //   @override
  //   State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
  // }

  // class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  //   var _country;

  //   pickupCountry() {
  //     showCountryPicker(
  //         context: context,
  //         onSelect: (Country country) {
  //           setState(() {
  //             _country = country;
  //           });
  //         });
  //   }

  //   void sendPhoneNumber() {
  //     String phoneNumber = phoneController.text.trim();
  //     if (phoneNumber.isNotEmpty && _country != null) {
  //       AuthController()
  //           .signInWithPhone(context, '+${_country.phoneCode}$phoneNumber');
  //     } else {
  //       // showSnackBar(context, 'Put all fields');
  //       log('error');
  //     }
  //   }

  //   final TextEditingController phoneController = TextEditingController();

  //   @override
  //   Widget build(BuildContext context) {
  //     var size = MediaQuery.of(context).size;
  //     return Scaffold(
  //       backgroundColor: whiteColor,
  //       appBar: AppBar(
  //         elevation: 0,
  //         backgroundColor: whiteColor,
  //         title: const Text(
  //           'Enter your phone number',
  //         ),
  //         centerTitle: false,
  //       ),
  //       body: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               const Text('WhatsApp will need to verify your phone number'),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               TextButton(
  //                   onPressed: pickupCountry, child: const Text('Pick Country')),
  //               Row(
  //                 children: [
  //                   if (_country != null) Text('+${_country!.phoneCode}'),
  //                   const SizedBox(
  //                     height: 10,
  //                   ),
  //                   const SizedBox(
  //                     width: 10,
  //                   ),
  //                   SizedBox(
  //                     width: size.width * 0.7,
  //                     child: TextField(
  //                       controller: phoneController,
  //                       decoration:
  //                           const InputDecoration(hintText: 'phone number'),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               SizedBox(
  //                 height: size.height * 0.6,
  //               ),
  //               ElevatedButton(
  //                   onPressed: sendPhoneNumber,
  //                   child: Text(
  //                     'Next',
  //                     style: TextStyle(fontFamily: fontFamily),
  //                   ))
  //               // SizedBox(
  //               //   width: 90,
  //               //   child: CustomButton(text: 'Next', onPressed: sendPhoneNumber),
  //               // )
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
