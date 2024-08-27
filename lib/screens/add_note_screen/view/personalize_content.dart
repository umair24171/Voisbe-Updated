import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/personalize_model.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_success.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';

class PersonalizeContent extends StatefulWidget {
  const PersonalizeContent(
      {super.key,
      required this.language,
      required this.selectedTime,
      required this.selectedRoutine,
      required this.topic});

  final List topic;
  final List<String> language;
  final String selectedTime;
  final String selectedRoutine;

  @override
  State<PersonalizeContent> createState() => _PersonalizeContentState();
}

class _PersonalizeContentState extends State<PersonalizeContent> {
  String selectedContent = '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      // backgroundColor: const Color(0xFFEE856D).withOpacity(0.9),
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
          Padding(
            padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05, vertical: 20)
                .copyWith(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.9,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xffED6A5A),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Container(
                      width: size.width * 0.90,
                      height: 20,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.14),
                Center(
                  child: Text(
                    "DO YOU PREFER SHORT OR\nLONG-FORM CONTENT?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedContent = 'Short (under 5 minutes)';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedContent
                                  .contains('Short (under 5 minutes)')
                              ? whiteColor
                              : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                const BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "Short (under 5 minutes)",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedContent
                                      .contains('Short (under 5 minutes)')
                                  ? primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedContent = 'Medium (5-15 minutes)';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedContent.contains('Medium (5-15 minutes)')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                const BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "Medium (5-15 minutes)",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedContent
                                      .contains('Medium (5-15 minutes)')
                                  ? primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedContent = 'Long (over 15 minutes)';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedContent.contains('Long (over 15 minutes)')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                const BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "Long (over 15 minutes)",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedContent
                                      .contains('Long (over 15 minutes)')
                                  ? primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    // const CustomElevatedButton(text: "Medium (5-15 minutes)"),
                    // const CustomElevatedButton(text: "Long (over 15 minutes)"),
                  ],
                ),
                SizedBox(height: size.width * 0.47),
                SizedBox(
                  width: size.width * 0.87,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        PersonalizeModel model = PersonalizeModel(
                            interest: widget.topic,
                            language: widget.language,
                            timeRange: widget.selectedTime,
                            timeOfDay: widget.selectedRoutine,
                            contentDuration: selectedContent,
                            uid: FirebaseAuth.instance.currentUser!.uid);
                        await FirebaseFirestore.instance
                            .collection('user_interests')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set(model.toMap());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalizeSuccess(),
                            ));
                      } catch (e) {
                        log(e.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                    child: Text("Continue",
                        style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w400)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.66,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: size.width * 0.04,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFFEE856D)),
        ),
      ),
    );
  }
}
