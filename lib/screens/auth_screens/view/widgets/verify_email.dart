// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/add_note_screen/view/personalize_ask.dart';

// class VerifyEmail extends StatefulWidget {
//   VerifyEmail({super.key});

//   @override
//   State<VerifyEmail> createState() => _VerifyEmailState();
// }

// class _VerifyEmailState extends State<VerifyEmail> {
//   // final TextEditingController emailController = TextEditingController();
//   bool isEmailVerified = false;
//   bool isLoading = false;
//   Timer? timer;
//   @override
//   void initState() {
// // TODO: implement initState
//     super.initState();
//     FirebaseAuth.instance.currentUser?.sendEmailVerification();
//     timer =
//         Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
//   }

//   checkEmailVerified() async {
//     await FirebaseAuth.instance.currentUser?.reload();

//     setState(() {
//       isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
//     });

//     if (isEmailVerified) {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PersonalizeAsk(),
//           ));
// // TODO: implement your code after email verification
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));

//       timer?.cancel();
//     }
//   }

//   @override
//   void dispose() {
// // TODO: implement dispose
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 0),
//               child: SvgPicture.asset(
//                 'assets/icons/Check_ring.svg',
//                 height: 30,
//                 width: 30,
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
// Text(
//   'Verify your email address',
//   style: TextStyle(
//       fontSize: 18,
//       fontWeight: FontWeight.w600,
//       fontFamily: fontFamily),
// ),
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Container(
//                 width: double.infinity,
//                 height: 1,
//                 color: Color(0xffEAEAEA),
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Column(
//                 children: [
//                   Text(
//                     'Please verify your email address. You can complete your signup by clicking the link sent to:',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 12,
//                         color: const Color(0xffC7C7C7),
//                         fontWeight: FontWeight.w400,
//                         fontFamily: fontFamily),
//                   ),
//                   Text(
//                     'youremail@address.com',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 12,
//                         color: const Color(0xff6C6C6C),
//                         fontWeight: FontWeight.w600,
//                         fontFamily: fontFamily),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             // const SizedBox(
//             //   height: 15,
//             // ),
//             ElevatedButton(
//                 style: ButtonStyle(
//                     backgroundColor: WidgetStatePropertyAll(blackColor)),
//                 onPressed: () async {
//                   try {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     FirebaseAuth.instance.currentUser?.sendEmailVerification();
//                     setState(() {
//                       isLoading = false;
//                     });
//                   } catch (e) {
//                     debugPrint('$e');
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//                 child: isLoading
//                     ? SpinKitThreeBounce(
//                         color: whiteColor,
//                         size: 14,
//                       )
//                     : Text(
//                         'Resend Email',
//                         style: TextStyle(
//                             fontFamily: fontFamily, color: whiteColor),
//                       )),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_ask.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';

class OtpField extends StatefulWidget {
  OtpField(
      {super.key,
      this.isLogin = false,
      required this.uid,
      this.isNotOtpVerified = false,
      required this.email});
  bool isLogin;
  final String uid;
  final String email;
  bool isNotOtpVerified;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
          fontSize: 20, color: blackColor, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border.all(color: blackColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: SvgPicture.asset(
                'assets/icons/Check_ring.svg',
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Enter your One-Time Password',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontFamily),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Color(0xffEAEAEA),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Please enter the One-Time Password that was sent to your email address to complete the signup.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xff6C6C6C),
                    fontWeight: FontWeight.w400,
                    fontFamily: fontFamily),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme,

                // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                showCursor: true,
                onCompleted: (pin) async {
                  bool isVerify = EmailOTP.verifyOTP(otp: pin);
                  if (isVerify) {
                    if (widget.isLogin) {
                      if (widget.isNotOtpVerified) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalizeAsk(),
                            ));
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BottomBar(),
                            ));
                      }
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalizeAsk(),
                          ));
                    }
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .update({'isOtpVerified': true});
                  } else {
                    // FirebaseAuth.instance.signOut();
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .update({'isOtpVerified': false});
                    showWhiteOverlayPopup(
                        context, null, 'assets/icons/Info (1).svg', null,
                        title: 'Error Occurred',
                        message: 'Otp is incorrect.',
                        isUsernameRes: false);
                  }
                },
              ),
            ),
            // const SizedBox(
            //   height: 15,
            // ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor, fixedSize: Size(130, 30)),
                onPressed: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
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

                    var result = await EmailOTP.sendOTP(email: widget.email);

                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {
                    debugPrint('$e');
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: isLoading
                    ? SpinKitThreeBounce(
                        color: whiteColor,
                        size: 14,
                      )
                    : Text(
                        'Resend OTP',
                        style: TextStyle(
                            fontFamily: fontFamily, color: whiteColor),
                      )),
          ],
        ),
      ),
    );
  }
}

    //  Padding(
    //   padding: EdgeInsets.only(
    //       top: MediaQuery.of(context).size.height * 0.06,
    //       bottom: MediaQuery.of(context).size.height * 0.07),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(bottom: 30),
    //         child: Text(
    //           'Verify OTP',
    //           style: TextStyle(
    //               fontSize: 18,
    //               fontWeight: FontWeight.w600,
    //               fontFamily: fontFamily),
    //         ),
    //       );
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    //         child: Pinput(
    //           length: 6,
    //           defaultPinTheme: defaultPinTheme,
    //           focusedPinTheme: defaultPinTheme,

    //           // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
    //           showCursor: true,
    //           onCompleted: (pin) async {
    //             bool isVerify = EmailOTP.verifyOTP(otp: pin);
    //             if (isVerify) {
    //               if (isLogin) {
    //                 Navigator.pushReplacement(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder: (context) => const BottomBar(),
    //                     ));
    //               } else {
    //                 Navigator.pushReplacement(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder: (context) => const PersonalizeAsk(),
    //                     ));
    //               }
    //               await FirebaseFirestore.instance
    //                   .collection('users')
    //                   .doc(uid)
    //                   .update({'isOtpVerified': true});
    //             } else {
    //               // FirebaseAuth.instance.signOut();
    //               await FirebaseFirestore.instance
    //                   .collection('users')
    //                   .doc(uid)
    //                   .update({'isOtpVerified': false});
    //               showWhiteOverlayPopup(context, Icons.error, null,
    //                   title: 'Error Occurred',
    //                   message: 'Otp is incorrect',
    //                   isUsernameRes: false);
    //             }
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // 
  


// final VerifyOtpCreateProfileCubit _createProfileCubit =
//     Di().sl<VerifyOtpCreateProfileCubit>();
