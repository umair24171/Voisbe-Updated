import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/view/personalize_time.dart';

class PersonalizeLanguage extends StatefulWidget {
  const PersonalizeLanguage({Key? key, required this.topic}) : super(key: key);
  final List topic;

  @override
  State<PersonalizeLanguage> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<PersonalizeLanguage> {
  final List<String> _languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Chinese",
    "Japanese",
    "Russian",
    "Portuguese",
    "Arabic",
    "Hindi",
  ];
  List<String> selectedLanguage = [];
  List<String> languageAdd = [];
  TextEditingController languageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: const Color(0xFFEE856D).withOpacity(0.9),
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
            padding:
                EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 0)
                    .copyWith(top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 20,
                  ),
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
                        width: size.width * 0.36,
                        height: 20,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.11),
                  Text(
                    "WHAT LANGUAGES DO YOU\nSPEAK OR UNDERSTAND?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  Wrap(
                    spacing: size.width * 0.03,
                    runSpacing: size.width * 0.03,
                    children: _languages
                        .map((language) => Container(
                              width: size.width * 0.35,
                              height: size.height * 0.05,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedLanguage.contains(language)) {
                                    selectedLanguage.remove(language);
                                    setState(() {});
                                  } else {
                                    selectedLanguage.add(language);
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      selectedLanguage.contains(language)
                                          ? whiteColor
                                          : primaryColor,
                                  side: BorderSide(color: whiteColor),
                                  textStyle: TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.w500,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                child: Text(
                                  language,
                                  style: TextStyle(
                                      fontFamily: fontFamily,
                                      color: selectedLanguage.contains(language)
                                          ? primaryColor
                                          : whiteColor),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: size.width * 0.10),

                  Text(
                    "ADD ANOTHER LANGUAGE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.048,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  //TextField for search language

                  Row(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.03),
                        child: Container(
                          height: size.height * 0.05,
                          width: size.width * 0.8,
                          child: TextField(
                            controller: languageController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.search,
                                  size: size.width * 0.05,
                                  color: const Color(0xFFEE856D)),
                              suffixIcon: ElevatedButton(
                                onPressed: () {
                                  // if (selectedLanguage.isEmpty) {
                                  if (!languageAdd
                                      .contains(languageController.text)) {
                                    languageAdd.add(languageController.text);
                                    selectedLanguage
                                        .add(languageController.text);
                                    setState(() {});
                                    languageController.clear();
                                  } else {
                                    showWhiteOverlayPopup(context, null,
                                        'assets/icons/Info (1).svg', null,
                                        title: 'Error',
                                        message: 'Language already added ',
                                        isUsernameRes: false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.045,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.06,
                                    vertical: size.height * 0.01,
                                  ),
                                ),
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              hintText: "Search for language",
                              hintStyle: TextStyle(
                                  color: const Color(0xFFEE856D),
                                  fontWeight: FontWeight.w400,
                                  fontSize: size.width * 0.035),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (languageAdd.isNotEmpty)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: languageAdd
                            .map((e) => ElevatedButton(
                                  onPressed: () {
                                    languageAdd.remove(e);
                                    selectedLanguage.remove(e);
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: whiteColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                          color: Colors.white, width: 1),
                                    ),
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.045,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.12,
                                      vertical: size.height * 0.01,
                                    ),
                                  ),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontSize: size.width * 0.035,
                                        color: primaryColor,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ))
                            .toList()),

                  SizedBox(
                      height: languageAdd.isNotEmpty
                          ? size.height * 0.147
                          : size.height * 0.21),
                  SizedBox(
                    width: size.width * 0.87,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalizeTime(
                                language: selectedLanguage.isNotEmpty
                                    ? selectedLanguage
                                    : languageAdd,
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
          ),
        ],
      ),
    );
  }
}
