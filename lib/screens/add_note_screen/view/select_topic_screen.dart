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
      required this.backImage,
      required this.type,
      required this.taggedPeople,
      this.isGalleryThumbnail,
      this.thumbnailPath,
      required this.path});
  static const routeName = '/select-topic';
  final String title;
  final List<String> taggedPeople;
  final String path;
  final String backImage;
  final String type;
  final String? thumbnailPath;
  final bool? isGalleryThumbnail;

  @override
  State<SelectTopicScreen> createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<SelectTopicScreen> {
  String _selectedOption = '';

  List<String> topics = [
    'Need Support',
    'Relationship & Love',
    'Confession & Secret',
    'Inspiration & Motivation',
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
    'Music',
    'Podcasts & Interviews',
    'Other'
  ];

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
    const Color(0xff9D3558),
    const Color(0xffC08EE1),
    const Color(0xff83949F)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Stack(
          children: [
            //  background static gradient
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffee856d), Color(0xffed6a5a)])),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Column(
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing:
                              MediaQuery.of(context).size.width > 400 ? 10 : 3,
                          // runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: topics.asMap().entries.map((entry) {
                            int index = entry.key;
                            String topic = entry.value;
                            Color color = colors[index % colors.length];

                            return ChoiceChip(
                              selectedColor: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  width: 2,
                                  color: _selectedOption == topic
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                              label: Text(
                                topic,
                                style: TextStyle(
                                  color: whiteColor,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              backgroundColor: color,
                              labelStyle: TextStyle(color: blackColor),
                              showCheckmark: false,
                              selected: false,
                              pressElevation: 0,
                              surfaceTintColor: Colors.transparent,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedOption = selected ? topic : '';
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // const Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ).copyWith(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //  back button to to move to back screen
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(blackColor),
                            fixedSize: const WidgetStatePropertyAll(
                              Size(100, 10),
                            ),
                          ),
                          onPressed: () {
                            navPop(context);
                          },
                          label: Text(
                            'Back',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
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
                            const SizedBox(
                              width: 5,
                            ),

                            // button to move to next screen

                            Consumer<NoteProvider>(
                                builder: (context, notePro, _) {
                              return ElevatedButton.icon(
                                style: ButtonStyle(
                                    fixedSize: const WidgetStatePropertyAll(
                                      Size(100, 10),
                                    ),
                                    backgroundColor:
                                        WidgetStatePropertyAll(whiteColor)),
                                onPressed: () {
                                  if (_selectedOption.isNotEmpty) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        //  it would carry some data to the hashtag screen to create the post in a final step

                                        return AddHashtagsScreen(
                                          isGalleryThumbnail:
                                              widget.isGalleryThumbnail,
                                          thumbnailPath: widget.thumbnailPath,
                                          filePath: widget.path,
                                          backgroundType: widget.type.isNotEmpty
                                              ? widget.type
                                              : notePro.fileType,
                                          backGroundImage: widget
                                                  .backImage.isNotEmpty
                                              ? widget.backImage
                                              : notePro.selectedImage.isEmpty
                                                  ? notePro.selectedVideo
                                                  : notePro.selectedImage,
                                          title: widget.title,
                                          taggedPeople: widget.taggedPeople,
                                          // waveformdata: waveformData,
                                          topicColor: colors[
                                              topics.indexOf(_selectedOption)],
                                          selectedTopic: _selectedOption,
                                        );
                                      },
                                    ));
                                  } else {
                                    //  if the user has not selected the topic

                                    showWhiteOverlayPopup(context, null,
                                        'assets/icons/Info (1).svg', null,
                                        title: 'Error',
                                        message: 'Please select a topic.',
                                        isUsernameRes: false);
                                  }
                                },
                                label: Text(
                                  'Next',
                                  style: TextStyle(
                                      color: blackColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: fontFamily,
                                      fontSize: 12),
                                ),
                                icon: Image.asset(
                                  'assets/images/next_black.png',
                                  height: 15,
                                  width: 15,
                                ),
                              );
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
