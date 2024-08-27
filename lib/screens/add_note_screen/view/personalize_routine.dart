import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_content.dart';

class PersonalizeRoutine extends StatefulWidget {
  const PersonalizeRoutine(
      {super.key,
      required this.topic,
      required this.selectedLanguage,
      required this.selectedTime});
  final List topic;
  final List<String> selectedLanguage;
  final String selectedTime;

  @override
  State<PersonalizeRoutine> createState() => _PersonalizeRoutineState();
}

class _PersonalizeRoutineState extends State<PersonalizeRoutine> {
  String selectedRoutine = '';
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Color(0xFFEE856D).withOpacity(0.9),
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
                      width: size.width * 0.72,
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
                    "WHAT IS YOUR PREFERRED\nTIME OF DAY FOR LISTENING\nTO CONTENT ON VOISBE?",
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
                          selectedRoutine = 'morning';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRoutine.contains('morning')
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
                          "Morning",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedRoutine.contains('morning')
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
                          selectedRoutine = 'afternoon';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRoutine.contains('afternoon')
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
                          "Afternoon",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedRoutine.contains('afternoon')
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
                          selectedRoutine = 'evening';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRoutine.contains('evening')
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
                          "Evening",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedRoutine.contains('evening')
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
                          selectedRoutine = 'night';
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRoutine.contains('night')
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
                          "Night",
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: selectedRoutine.contains('night')
                                  ? primaryColor
                                  : whiteColor,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    // CustomElevatedButton(text: "Afternoon"),
                    // CustomElevatedButton(text: "Evening"),
                    // CustomElevatedButton(text: "Night"),
                  ],
                ),
                SizedBox(height: size.width * 0.47),
                Container(
                  width: size.width * 0.87,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalizeContent(
                              selectedRoutine: selectedRoutine,
                              language: widget.selectedLanguage,
                              selectedTime: widget.selectedTime,
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
