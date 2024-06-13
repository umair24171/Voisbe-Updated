// import 'dart:io';

import 'dart:developer' as dev;
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
// import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/view/add_hashtags_screen.dart';

class SelectTopicScreen extends StatefulWidget {
  const SelectTopicScreen(
      {super.key,
      required this.title,
      required this.taggedPeople,
      required this.path});
  static const routeName = '/select-topic';
  final String title;
  final List<String> taggedPeople;
  final String path;

  @override
  State<SelectTopicScreen> createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<SelectTopicScreen> {
  PlayerController controller = PlayerController();
  List<double> waveformData = [];
  String _selectedOption = '';
  @override
  void initState() {
    super.initState();
    preparePlayer();
  }

  preparePlayer() async {
    waveformData = await controller.extractWaveformData(
      path: widget.path,
      noOfSamples: 100,
    );
    setState(() {});
  }

  List<String> topics = [
    'Need support',
    'Relationship & love',
    'Confession & secret',
    'Inspiration & motivation',
    'Food & Cooking',
    'Personal Story',
    'Business',
    'Something I learned',
    'Education & Learning',
    'Books & Literature',
    'Spirit & Mind',
    'Travel & Adventure',
    'Fashion & Style',
    'Creativity & Art',
    'Humor & Comedy',
    'Sports & Fitness',
    'Technology & Innovation',
    'Current Events & News',
    'Health & Wellness',
    'Hobbies & Interests',
    'Other'
  ];
  // Color _randomColor() {
  //   return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
  //       .withOpacity(1.0);
  // }
  List<Color> colors = [
    const Color(0xff503e3b),
    const Color(0xffcd3826),
    const Color(0xffcf4736),
    const Color(0xffe6b619),
    const Color(0xff8ab756),
    const Color(0xffeb6447),
    const Color(0xff3694de),
    const Color(0xffe69319),
    const Color(0xff7c69de),
    const Color(0xff885341),
    const Color(0xff9235a2),
    const Color(0xff56a559),
    const Color(0xffd53269),
    const Color(0xff6a46ab),
    const Color(0xffe154a1),
    const Color(0xff15acbf),
    const Color(0xff45897a),
    const Color(0xff472861),
    const Color(0xff37728c),
    const Color(0xff6cb57f),
    const Color(0xff83949F)
  ];

  @override
  Widget build(BuildContext context) {
    dev.log('taggedPeople: ${Provider.of<NoteProvider>(context).tags}');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffee856d), Color(0xffed6a5a)])),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'ADD 1 TOPIC',
                      style: TextStyle(
                          color: whiteColor,
                          fontFamily: fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Wrap(
                          spacing: 3,
                          alignment: WrapAlignment.center,
                          children: topics.asMap().entries.map((entry) {
                            int index = entry.key;
                            String topic = entry.value;
                            Color color = colors[index %
                                colors
                                    .length]; // Use modulo to repeat colors if topics exceed colors
                            return ChoiceChip(
                              selectedColor: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  width: 2,
                                  color: _selectedOption.contains(topic)
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                              label: Text(topic,
                                  style: TextStyle(
                                      color: whiteColor,
                                      fontFamily: fontFamily)),
                              backgroundColor: color,
                              labelStyle: TextStyle(color: blackColor),
                              showCheckmark: false,
                              selected: false,
                              pressElevation: 0,
                              surfaceTintColor: Colors.transparent,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedOption = topic;
                                  } else {
                                    _selectedOption = '';
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ).copyWith(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(blackColor),
                          fixedSize: const MaterialStatePropertyAll(
                            Size(100, 10),
                          ),
                        ),
                        onPressed: () {
                          navPop(context);
                        },
                        label: Text(
                          'Back',
                          style: TextStyle(
                              color: whiteColor,
                              fontFamily: fontFamily,
                              fontSize: 12),
                        ),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: whiteColor,
                          size: 15,
                        ),
                      ),
                      Row(
                        children: [
                          // ElevatedButton.icon(
                          //   style: ButtonStyle(
                          //       fixedSize: const MaterialStatePropertyAll(
                          //           Size(100, 10)),
                          //       backgroundColor:
                          //           MaterialStatePropertyAll(whiteColor)),
                          //   onPressed: () {
                          //     navPush(AddHashtagsScreen.routeName, context);
                          //   },
                          //   label: Text(
                          //     'Skip',
                          //     style: TextStyle(
                          //         color: blackColor,
                          //         fontFamily: fontFamily,
                          //         fontSize: 12),
                          //   ),
                          //   icon: Image.asset(
                          //     'assets/images/skip.png',
                          //     height: 15,
                          //     width: 15,
                          //   ),
                          // ),

                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                fixedSize: const MaterialStatePropertyAll(
                                  Size(100, 10),
                                ),
                                backgroundColor:
                                    MaterialStatePropertyAll(whiteColor)),
                            onPressed: () {
                              if (_selectedOption.isNotEmpty) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return AddHashtagsScreen(
                                      title: widget.title,
                                      taggedPeople: widget.taggedPeople,
                                      waveformdata: waveformData,
                                      topicColor: colors[
                                          topics.indexOf(_selectedOption)],
                                      selectedTopic: _selectedOption,
                                    );
                                  },
                                ));
                              } else {
                                showWhiteOverlayPopup(
                                    context, Icons.error_outline, null,
                                    title: 'Error',
                                    message: 'Please select a topic',
                                    isUsernameRes: false);
                              }
                            },
                            label: Text(
                              'Next',
                              style: TextStyle(
                                  color: blackColor,
                                  fontFamily: fontFamily,
                                  fontSize: 12),
                            ),
                            icon: Image.asset(
                              'assets/images/next_black.png',
                              height: 15,
                              width: 15,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
