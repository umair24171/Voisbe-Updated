import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;

  @override
  void initState() {
    timer = Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => FirebaseAuth.instance.currentUser == null
                  ? AuthScreen()
                  : const BottomBar()),
          (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Image.asset(
          'assets/images/splashscreen.jpg',
          fit: BoxFit.fill,
          // alignment: Alignment.center,
        ),
      ),
    );
  }
}
