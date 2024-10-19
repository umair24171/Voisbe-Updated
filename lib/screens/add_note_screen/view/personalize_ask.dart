import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/view/add_note_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_interest.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_language.dart';
import 'package:social_notes/screens/profile_screen/profile_screen.dart';

class PersonalizeAsk extends StatelessWidget {
  const PersonalizeAsk({super.key});

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
                    'WOULD YOU LIKE TO PERSONALIZE YOUR APP EXPERIENCE?',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStatePropertyAll(Size(30, 40)),
                              fixedSize: MaterialStatePropertyAll(Size(110, 40)),
                              backgroundColor:
                                  MaterialStatePropertyAll(whiteColor),
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.all(0)),
                              elevation: const MaterialStatePropertyAll(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(),
                                ));
                          },
                          child: Text(
                            'No thanks',
                            style: TextStyle(
                                color: blackColor,
                                fontFamily: fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          )),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            // minimumSize: MaterialStatePropertyAll(Size(20, 40)),
                            fixedSize: MaterialStatePropertyAll(Size(120, 40)),
                            padding:
                                const MaterialStatePropertyAll(EdgeInsets.all(0)),
                            backgroundColor: MaterialStatePropertyAll(blackColor),
                            elevation: const MaterialStatePropertyAll(0),
                            alignment: Alignment.center),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PersonalizeInterest(),
                          ));
                        },
                        child: Text(
                          'Yes please',
                          style: TextStyle(
                              fontFamily: fontFamily,
                              color: whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ))
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
