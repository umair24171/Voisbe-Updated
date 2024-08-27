// import 'package:flutter/material.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/auth_screens/controller/auth_controller.dart';

// class OTPScreen extends StatelessWidget {
//   const OTPScreen({super.key, required this.verificationId});
//   final String verificationId;

//   static const routeName = 'otp-screen';

//   verifyOTP(
//     String Otp,
//     BuildContext context,
//   ) {
//     AuthController().verifyOTP(
//         context: context, userOTP: Otp, verificationID: verificationId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whiteColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: whiteColor,
//         title: const Text(
//           'Verify your phone number',
//         ),
//         centerTitle: false,
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 20,
//             ),
//             const Text('We have sent an SMS with a code'),
//             const SizedBox(
//               height: 20,
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: TextField(
//                 textAlign: TextAlign.center,
//                 decoration: const InputDecoration(
//                   hintText: '- - - - - -',
//                   hintStyle: TextStyle(fontSize: 30),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   if (value.length == 6) {
//                     verifyOTP(value.trim(), context);
//                   }
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
