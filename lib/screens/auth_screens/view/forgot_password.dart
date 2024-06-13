import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/view/confirm_forgot_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/lock_icon.png',
            height: 22,
            width: 20,
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            'Forgot your password?',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Enter your username or email address and we will send you a link to get back into your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff6C6C6C),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: fontFamily),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: 'Username or email address*',
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: fontFamily),
                constraints: BoxConstraints(
                    maxHeight: 50,
                    maxWidth: MediaQuery.of(context).size.width * 0.85),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: Colors.grey)),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: Colors.grey)),
                contentPadding: const EdgeInsets.only(top: 5, left: 8)),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(blackColor)),
              onPressed: () async {
                FirebaseAuth auth = FirebaseAuth.instance;
                await auth
                    .sendPasswordResetEmail(email: emailController.text)
                    .then((value) {
                  navPop(context);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: whiteColor,
                          elevation: 0,
                          content: ConfirmForgotScreen(),
                        );
                      });
                });
              },
              child: Text(
                'Reset Password',
                style: TextStyle(fontFamily: fontFamily, color: whiteColor),
              )),
        ],
      ),
    );
  }
}
