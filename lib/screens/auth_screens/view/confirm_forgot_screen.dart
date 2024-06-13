import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';

class ConfirmForgotScreen extends StatelessWidget {
  ConfirmForgotScreen({super.key});
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'An email has been sent to your email address to reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff6C6C6C),
                  fontWeight: FontWeight.w400,
                  fontFamily: fontFamily),
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
