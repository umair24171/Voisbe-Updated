import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';

class PersonalizeSuccess extends StatelessWidget {
  const PersonalizeSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffee856d),
                    Color(0xffed6a5a),
                  ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'GREAT!\n VOISBE WILL OFFER YOU A MORE PERSONALIZED\n EXPERIENCE NOW.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: fontFamily,
                        color: whiteColor,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 4, horizontal: 18)),
                    backgroundColor: WidgetStatePropertyAll(blackColor),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, ProfileScreen.routeName);
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                        fontFamily: fontFamily,
                        color: whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
