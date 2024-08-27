import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_routine.dart';

class PersonalizeTime extends StatefulWidget {
  const PersonalizeTime({
    super.key,
    required this.language,
    required this.topic,
  });
  final List topic;
  final List<String> language;

  @override
  State<PersonalizeTime> createState() => _PersonalizeTimeState();
}

class _PersonalizeTimeState extends State<PersonalizeTime> {
  String selectedTime = '';
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFEE856D).withOpacity(0.9),
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
                      width: size.width * 0.54,
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
                    "HOW MUCH TIME DO YOU\nTYPICALLY SPEND ON\nSOCIAL MEDIA PER DAY?",
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
                    Container(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTime = 'thirtymin';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTime.contains('thirtymin')
                              ? whiteColor
                              : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "Less than 30 min",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedTime.contains('thirtymin')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedTime = 'one hour thirty minutes';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedTime.contains('one hour thirty minutes')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "30 minutes to 1 hour",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedTime
                                      .contains('one hour thirty minutes')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedTime = 'one more hour';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedTime.contains('one more hour')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "1-2 hours",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedTime.contains('one more hour')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedTime = 'two hours more';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedTime.contains('two hours more')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "2-4 hours",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedTime.contains('two hours more')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.66,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedTime = 'four hours more';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedTime.contains('four hours more')
                                  ? whiteColor
                                  : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        child: Text(
                          "More than 4 hours",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedTime.contains('four hours more')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),

                    // CustomElevatedButton(text: "30 minutes to 1 hour"),
                    // CustomElevatedButton(text: "1-2 hours"),
                    // CustomElevatedButton(text: "2-4 hours"),
                    // CustomElevatedButton(text: "More than 4 hours"),
                  ],
                ),
                SizedBox(height: size.width * 0.4),
                Container(
                  width: size.width * 0.87,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalizeRoutine(
                              selectedLanguage: widget.language,
                              selectedTime: selectedTime,
                              topic: widget.topic,
                            ),
                          ));
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
  CustomElevatedButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
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
          style: TextStyle(color: Color(0xFFEE856D)),
        ),
      ),
    );
  }
}
