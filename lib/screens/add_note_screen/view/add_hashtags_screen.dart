// import 'package:firebase_core/firebase_core.dart';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
// import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:uuid/uuid.dart';

class AddHashtagsScreen extends StatefulWidget {
  const AddHashtagsScreen(
      {super.key,
      required this.title,
      required this.taggedPeople,
      required this.topicColor,
      required this.waveformdata,
      required this.selectedTopic});

  final String title;
  final List<String> taggedPeople;
  final String selectedTopic;
  final Color topicColor;
  final List<double> waveformdata;
  static const routeName = '/add-hastags';

  @override
  State<AddHashtagsScreen> createState() => _AddHashtagsScreenState();
}

class _AddHashtagsScreenState extends State<AddHashtagsScreen> {
  final List<String> _selectedOptions = [];

  getTrendingHastags() async {
    List<NoteModel> allPosts =
        Provider.of<DisplayNotesProvider>(context, listen: false).notes;
    // Assume `postsCollection` is your collection reference

    /// Step 1: Extract hashtags from each document
    Map<String, int> hashtagsMap = {};

    for (var doc in allPosts) {
      List<dynamic>? hashtagsList = doc.hashtags; // Add a null check here
      for (var hashtag in hashtagsList) {
        // Add a null check here
        if (hashtag != null) {
          hashtagsMap.update(hashtag, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

// Step 2: Sort hashtags by count to get top trending hashtags
    List<String> trendingHashtags = hashtagsMap.keys.toList();
    trendingHashtags.sort((a, b) => hashtagsMap[b]!.compareTo(hashtagsMap[a]!));

// Step 3: Display top 9 trending hashtags
    trendings = trendingHashtags.sublist(0, 9);
    setState(() {});
    log('Top Trending Hashtags: $trendings');
  }

  List<String> userAddedHasthtags = [
    // '#Partnership',
    // '#Momhacks',
    // '#Trends24',
    // '#Adventure',
    // '#Sharingmyideas',
    // '#Foodlover',
    // '#Dreamingbig',
    // '#Businesshack',
  ];
  List<String> recommended = [
    '#Travel',
    '#Foodie',
    '#Fitness',
    '#Fashion',
    '#Photography',
    '#Music',
    '#Art',
    '#Technology',
    '#Books',
    '#Nature',
    // '#Relationship',
    // '#Partnership',
    // '#Lovelife',
    // '#BestFriend',
    // '#Happiness',
    // '#Smiling',
    // '#Soulmate',
    // '#Passionate',
  ];
  List<String> trendings = [
    // '#Thoughts',
    // '#Momhacks',
    // '#Trends24',
    // '#Mymine',
    // '#MySecret',
    // '#Tipps',
    // '#Though',
    // '#Passion',
  ];
  TextEditingController addHasgtagController = TextEditingController();

  @override
  void initState() {
    getTrendingHastags();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    var noteProvider = Provider.of<NoteProvider>(context, listen: false);
    var soundPro = Provider.of<SoundProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
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
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    'ADD #HASHTAGS',
                    style: TextStyle(
                        color: whiteColor,
                        fontFamily: fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Select up to 10',
                  style: TextStyle(
                      fontFamily: fontFamily, color: whiteColor, fontSize: 12),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: TextFormField(
                          controller: addHasgtagController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Add Hashtags',
                            hintStyle: TextStyle(
                                fontFamily: fontFamily,
                                color: primaryColor,
                                fontSize: 12),
                            // label: Text(
                            //   'Search for Hashtags',
                            //   style: TextStyle(
                            //       fontFamily: fontFamily,
                            //       color: primaryColor,
                            //       fontSize: 12),
                            // ),
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: Icon(
                              Icons.add,
                              size: 20,
                              color: primaryColor,
                            ),
                            constraints: BoxConstraints(
                                maxHeight: 40, maxWidth: size.width * 0.7),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      Positioned(
                        left: size.width * 0.55,
                        bottom: 6,
                        child: ElevatedButton(
                          onPressed: () {
                            if (addHasgtagController.text.isNotEmpty) {
                              if (_selectedOptions.length < 10) {
                                if (!userAddedHasthtags.contains(
                                    '#${addHasgtagController.text}')) {
                                  setState(() {
                                    userAddedHasthtags.add(!addHasgtagController
                                            .text
                                            .startsWith('#')
                                        ? '#${addHasgtagController.text.trim()}'
                                        : addHasgtagController.text.trim());
                                    _selectedOptions.add(!addHasgtagController
                                            .text
                                            .startsWith('#')
                                        ? '#${addHasgtagController.text.trim()}'
                                        : addHasgtagController.text.trim());

                                    addHasgtagController.clear();
                                  });
                                } else {
                                  showWhiteOverlayPopup(
                                      context, Icons.error_outline, null,
                                      title: 'Error',
                                      message: 'Hastag already added',
                                      isUsernameRes: false);
                                }
                              } else {
                                showWhiteOverlayPopup(
                                    context, Icons.error_outline, null,
                                    title: 'Error',
                                    message: 'You can only select 10 hashtags',
                                    isUsernameRes: false);
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(blackColor)),
                          child: Text(
                            'Add',
                            style: TextStyle(
                                color: whiteColor, fontFamily: fontFamily),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 10, vertical: 10),
                //   child: TextFormField(
                //     autovalidateMode: AutovalidateMode.onUserInteraction,
                //     controller: addHasgtagController,
                //     // validator: (value) {
                //     //   if (!value!.startsWith('#')) {
                //     //     return 'hashtag should starts with #';
                //     //   }
                //     //   return null;
                //     // },
                //     onFieldSubmitted: (value) {
                //       if (value.isNotEmpty) {
                //         if (userAddedHasthtags.length < 10) {
                //           setState(() {
                //             userAddedHasthtags.add(!value.startsWith('#')
                //                 ? '#${value.trim()}'
                //                 : value.trim());
                //             addHasgtagController.clear();
                //           });
                //         }
                //       }
                //     },
                //     style: TextStyle(
                //         fontFamily: fontFamily,
                //         color: primaryColor,
                //         fontSize: 12),
                //     decoration: InputDecoration(
                //       contentPadding: const EdgeInsets.only(left: 14),
                //       hintText: 'Add Hashtags',
                //       errorStyle:
                //           TextStyle(color: color14, fontFamily: fontFamily),
                //       hintStyle: TextStyle(
                //           fontFamily: fontFamily,
                //           color: primaryColor,
                //           fontSize: 12),
                //       filled: true,
                //       fillColor: whiteColor,
                // prefixIcon: Icon(
                //   Icons.add,
                //   size: 20,
                //   color: primaryColor,
                // ),
                //       constraints: BoxConstraints(
                //           maxHeight: 40,
                //           minHeight: 40,
                //           maxWidth: size.width * 0.7),
                //       border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(20),
                //           borderSide: BorderSide.none),
                //     ),
                //   ),
                // ),

                // SizedBox(
                //   height: 85,
                //   child: GridView.builder(
                //     gridDelegate:
                //         const SliverGridDelegateWithFixedCrossAxisCount(

                //             // childAspectRatio: 3 / 2,
                //             crossAxisCount: 2,
                //             mainAxisExtent: 120,
                //             mainAxisSpacing: 10,
                //             crossAxisSpacing: 12),
                //     itemCount: userAddedHasthtags.length,
                //     scrollDirection: Axis.horizontal,
                //     itemBuilder: (context, index) {
                //       return InkWell(
                //         onTap: () {
                //           setState(() {
                //             if (_selectedOptions.length < 10) {
                //               if (_selectedOptions.contains(trendings[index])) {
                //                 _selectedOptions.remove(trendings[index]);
                //               } else {
                //                 _selectedOptions.add(trendings[index]);
                //               }
                //             } else {
                //               showWhiteOverlayPopup(
                //                   context, Icons.error_outline, null,
                //                   title: 'Error',
                //                   message: 'You can only select 10 hashtags',
                //                   isUsernameRes: false);
                //             }
                //           });
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 0,
                //           ),
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(
                //                 vertical: 8, horizontal: 0),
                //             decoration: BoxDecoration(
                //                 color:
                //                     _selectedOptions.contains(trendings[index])
                //                         ? whiteColor
                //                         : Colors.transparent,
                //                 borderRadius: BorderRadius.circular(20),
                //                 border:
                //                     Border.all(color: whiteColor, width: 1)),
                //             child: Text(
                //               trendings[index],
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   color: _selectedOptions
                //                           .contains(trendings[index])
                //                       ? blackColor
                //                       : whiteColor,
                //                   fontFamily: khulaRegular,
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.w600),
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(

                            // childAspectRatio: 3 / 2,
                            crossAxisCount: 3,
                            mainAxisExtent: 37,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 12),
                    itemCount: userAddedHasthtags.length,
                    // scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (_selectedOptions.length < 10) {
                              if (_selectedOptions
                                  .contains(userAddedHasthtags[index])) {
                                _selectedOptions
                                    .remove(userAddedHasthtags[index]);
                              } else {
                                _selectedOptions.add(userAddedHasthtags[index]);
                              }
                            } else {
                              showWhiteOverlayPopup(
                                  context, Icons.error_outline, null,
                                  title: 'Error',
                                  message: 'You can only select 10 hashtags',
                                  isUsernameRes: false);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: Container(
                            width: 38,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 0),
                            decoration: BoxDecoration(
                                color: _selectedOptions
                                        .contains(userAddedHasthtags[index])
                                    ? whiteColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: whiteColor, width: 1)),
                            child: Text(
                              userAddedHasthtags[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _selectedOptions
                                          .contains(userAddedHasthtags[index])
                                      ? blackColor
                                      : whiteColor,
                                  fontFamily: khulaRegular,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 12, vertical: 15)
                //           .copyWith(right: 4),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Container(
                //       alignment: Alignment.center,
                //       child: Wrap(
                //         alignment: WrapAlignment.center,
                //         spacing: 8,
                //         children: userAddedHasthtags
                //             .map((e) => ChoiceChip(
                //                   elevation: 0,
                //                   labelPadding: const EdgeInsets.only(
                //                       left: 8, right: 8, top: 0, bottom: 0),
                //                   showCheckmark: false,
                //                   // avatarBorder: RoundedRectangleBorder(
                //                   //     borderRadius:
                //                   //         BorderRadius.circular(10)),
                //                   selectedColor: whiteColor,

                //                   label: Text(
                //                     e,
                //                     style: TextStyle(
                //                         fontFamily: khulaRegular,
                //                         fontSize: 15,
                //                         fontWeight: FontWeight.w600,
                //                         color: _selectedOptions.contains(e)
                //                             ? blackColor
                //                             : whiteColor),
                //                   ),
                //                   shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(30),
                //                       side: BorderSide(color: whiteColor)),
                //                   backgroundColor: primaryColor,

                //                   labelStyle: TextStyle(
                //                       fontFamily: khulaRegular,
                //                       fontSize: 15,
                //                       fontWeight: FontWeight.w600,
                //                       color: _selectedOptions.contains(e)
                //                           ? blackColor
                //                           : whiteColor),
                //                   selected: _selectedOptions.contains(e),
                //                   onSelected: (bool selected) {
                //                     setState(() {
                //                       if (selected) {
                //                         if (_selectedOptions.length < 10) {
                //                           _selectedOptions.add(e);
                //                         } else {
                //                           showWhiteOverlayPopup(context,
                //                               Icons.error_outline, null,
                //                               title: 'Error',
                //                               message: 'Hastag already added',
                //                               isUsernameRes: false);
                //                         }
                //                       } else {
                //                         _selectedOptions.remove(e);
                //                       }
                //                     });
                //                   },
                //                 ))
                //             .toList(),
                //       ),
                //     ),
                //   ),
                // ),

                Text(
                  'TOPIC RECOMMENDED',
                  style: TextStyle(
                      color: whiteColor,
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, top: 15, bottom: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        // height: 40,
                        width: double.infinity,
                        height: 85,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 3 / 10,
                                  crossAxisCount: 2,
                                  // mainAxisExtent: 120,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 12),
                          itemCount: recommended.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (_selectedOptions.length < 10) {
                                    if (_selectedOptions
                                        .contains(recommended[index])) {
                                      _selectedOptions
                                          .remove(recommended[index]);
                                    } else {
                                      _selectedOptions.add(recommended[index]);
                                    }
                                  } else {
                                    showWhiteOverlayPopup(
                                        context, Icons.error_outline, null,
                                        title: 'Error',
                                        message:
                                            'You can only select 10 hashtags',
                                        isUsernameRes: false);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 0),
                                  decoration: BoxDecoration(
                                      color: _selectedOptions
                                              .contains(recommended[index])
                                          ? whiteColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: whiteColor, width: 1)),
                                  child: Text(
                                    recommended[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _selectedOptions
                                                .contains(recommended[index])
                                            ? blackColor
                                            : whiteColor,
                                        fontFamily: khulaRegular,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 15),
                      //   child: SizedBox(
                      //     height: 40,
                      //     child: ListView.builder(
                      //       itemCount: recommended.length - 5,
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (context, index) {
                      //         return InkWell(
                      //           onTap: () {
                      //             setState(() {
                      //               if (_selectedOptions.length < 10) {
                      //                 if (_selectedOptions
                      //                     .contains(recommended[index + 5])) {
                      //                   _selectedOptions
                      //                       .remove(recommended[index + 5]);
                      //                 } else {
                      //                   _selectedOptions
                      //                       .add(recommended[index + 5]);
                      //                 }
                      //               } else {
                      //                 showWhiteOverlayPopup(
                      //                     context, Icons.error_outline, null,
                      //                     title: 'Error',
                      //                     message:
                      //                         'You can only select 10 hashtags',
                      //                     isUsernameRes: false);
                      //               }
                      //             });
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //               horizontal: 3,
                      //             ),
                      //             child: Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 8, horizontal: 12),
                      //               decoration: BoxDecoration(
                      //                   color: _selectedOptions.contains(
                      //                           recommended[index + 5])
                      //                       ? whiteColor
                      //                       : Colors.transparent,
                      //                   borderRadius: BorderRadius.circular(20),
                      //                   border: Border.all(
                      //                       color: whiteColor, width: 1)),
                      //               child: Text(
                      //                 recommended[index + 5],
                      //                 style: TextStyle(
                      //                     color: _selectedOptions.contains(
                      //                             recommended[index + 5])
                      //                         ? blackColor
                      //                         : whiteColor,
                      //                     fontFamily: khulaRegular,
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.w600),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 12, vertical: 15),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Container(
                //       alignment: Alignment.center,
                //       child: Wrap(
                //         spacing: 15,
                //         children: recommended
                //             .map((e) => ChoiceChip(
                //                   showCheckmark: false,
                //                   selectedColor: whiteColor,
                //                   shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(18),
                //                       side: BorderSide(color: whiteColor)),
                //                   label: Text(
                //                     e,
                //                     style: TextStyle(
                //                         color: _selectedOptions.contains(e)
                //                             ? blackColor
                //                             : whiteColor),
                //                   ),
                //                   backgroundColor: primaryColor,
                //                   labelStyle: TextStyle(
                //                       color: _selectedOptions.contains(e)
                //                           ? blackColor
                //                           : whiteColor),
                //                   selected: _selectedOptions.contains(e),
                //                   onSelected: (bool selected) {
                //                     setState(() {
                //                       if (selected) {
                //                         if (_selectedOptions.length < 10) {
                //                           _selectedOptions.add(e);
                //                         } else {
                //                           showWhiteOverlayPopup(context,
                //                               Icons.error_outline, null,
                //                               title: 'Error',
                //                               message:
                //                                   'You can only select 10 hashtags',
                //                               isUsernameRes: false);
                //                         }
                //                       } else {
                //                         _selectedOptions.remove(e);
                //                       }
                //                     });
                //                   },
                //                 ))
                //             .toList(),
                //       ),
                //     ),
                //   ),
                // ),

                Text(
                  'TRENDING',
                  style: TextStyle(
                      color: whiteColor,
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, top: 15, bottom: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 85,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(

                                  // childAspectRatio: 3 / 2,
                                  crossAxisCount: 2,
                                  mainAxisExtent: 120,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 12),
                          itemCount: trendings.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (_selectedOptions.length < 10) {
                                    if (_selectedOptions
                                        .contains(trendings[index])) {
                                      _selectedOptions.remove(trendings[index]);
                                    } else {
                                      _selectedOptions.add(trendings[index]);
                                    }
                                  } else {
                                    showWhiteOverlayPopup(
                                        context, Icons.error_outline, null,
                                        title: 'Error',
                                        message:
                                            'You can only select 10 hashtags',
                                        isUsernameRes: false);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 0),
                                  decoration: BoxDecoration(
                                      color: _selectedOptions
                                              .contains(trendings[index])
                                          ? whiteColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: whiteColor, width: 1)),
                                  child: Text(
                                    trendings[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _selectedOptions
                                                .contains(trendings[index])
                                            ? blackColor
                                            : whiteColor,
                                        fontFamily: khulaRegular,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 15),
                      //   child: SizedBox(
                      //     height: 40,
                      //     child: ListView.builder(
                      //       itemCount: trendings.length - 5,
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (context, index) {
                      //         return InkWell(
                      //           onTap: () {
                      //             setState(() {
                      //               if (_selectedOptions.length < 10) {
                      //                 if (_selectedOptions
                      //                     .contains(trendings[index + 5])) {
                      //                   _selectedOptions
                      //                       .remove(trendings[index + 5]);
                      //                 } else {
                      //                   _selectedOptions
                      //                       .add(trendings[index + 5]);
                      //                 }
                      //               } else {
                      //                 showWhiteOverlayPopup(
                      //                     context, Icons.error_outline, null,
                      //                     title: 'Error',
                      //                     message:
                      //                         'You can only select 10 hashtags',
                      //                     isUsernameRes: false);
                      //               }
                      //             });
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //               horizontal: 3,
                      //             ),
                      //             child: Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 8, horizontal: 12),
                      //               decoration: BoxDecoration(
                      //                   color: _selectedOptions
                      //                           .contains(trendings[index + 5])
                      //                       ? whiteColor
                      //                       : Colors.transparent,
                      //                   borderRadius: BorderRadius.circular(20),
                      //                   border: Border.all(
                      //                       color: whiteColor, width: 1)),
                      //               child: Text(
                      //                 trendings[index + 5],
                      //                 style: TextStyle(
                      //                     color: _selectedOptions.contains(
                      //                             trendings[index + 5])
                      //                         ? blackColor
                      //                         : whiteColor,
                      //                     fontFamily: khulaRegular,
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.w600),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 12, vertical: 15),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Container(
                //       alignment: Alignment.center,
                //       child: Wrap(
                //         spacing: 15,
                //         children: trendings
                //             .map((e) => ChoiceChip(
                //                   showCheckmark: false,
                //                   selectedColor: whiteColor,
                //                   shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(18),
                //                       side: BorderSide(color: whiteColor)),
                //                   label: Text(
                //                     e,
                //                     style: TextStyle(
                //                         color: _selectedOptions.contains(e)
                //                             ? blackColor
                //                             : whiteColor),
                //                   ),
                //                   backgroundColor: primaryColor,
                //                   labelStyle: TextStyle(
                //                       color: _selectedOptions.contains(e)
                //                           ? blackColor
                //                           : whiteColor),
                //                   selected: _selectedOptions.contains(e),
                //                   onSelected: (bool selected) {
                //                     setState(() {
                //                       if (selected) {
                //                         if (_selectedOptions.length < 10) {
                //                           _selectedOptions.add(e);
                //                         } else {
                //                           showWhiteOverlayPopup(context,
                //                               Icons.error_outline, null,
                //                               title: 'Error',
                //                               message:
                //                                   'You can only select 10 hashtags',
                //                               isUsernameRes: false);
                //                         }
                //                       } else {
                //                         _selectedOptions.remove(e);
                //                       }
                //                     });
                //                   },
                //                 ))
                //             .toList(),
                //       ),
                //     ),
                //   ),
                // ),
                const Expanded(child: SizedBox()),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        icon: Image.asset(
                          'assets/images/back.png',
                          height: 13,
                          width: 13,
                        ),
                      ),
                      Consumer<UserProvider>(builder: (context, loadingPro, _) {
                        return ElevatedButton.icon(
                          style: ButtonStyle(
                              fixedSize: const MaterialStatePropertyAll(
                                Size(100, 10),
                              ),
                              backgroundColor:
                                  MaterialStatePropertyAll(whiteColor)),
                          onPressed: () async {
                            loadingPro.setUserLoading(true);
                            String noteId = const Uuid().v4();
                            String noteUrl = soundPro.voiceUrl == null
                                ? await AddNoteController().uploadFile(
                                    'voices', noteProvider.voiceNote!, context)
                                : soundPro.voiceUrl!;
                            NoteModel note = NoteModel(
                                topicColor: widget.topicColor,
                                userToken: userProvider!.token,
                                isPinned: false,
                                noteId: noteId,
                                username: userProvider.name,
                                photoUrl: userProvider.photoUrl,
                                title: widget.title,
                                userUid: userProvider.uid,
                                tagPeople: noteProvider.tags,
                                waveformData: widget.waveformdata,
                                likes: [],
                                noteUrl: noteUrl,
                                publishedDate: DateTime.now(),
                                comments: [],
                                topic: widget.selectedTopic,
                                hashtags: _selectedOptions);
                            AddNoteController()
                                .addNote(note, noteId)
                                .then((value) {
                              noteProvider.removeVoiceNote();
                              loadingPro.setUserLoading(false);

                              navPush(BottomBar.routeName, context);
                            });
                          },
                          label: loadingPro.userLoading
                              ? SpinKitThreeBounce(
                                  color: blackColor,
                                  size: 12,
                                )
                              : Text(
                                  'Share',
                                  style: TextStyle(
                                      color: blackColor,
                                      fontFamily: fontFamily,
                                      fontSize: 12),
                                ),
                          icon: Image.asset(
                            'assets/images/share.png',
                            height: 15,
                            width: 15,
                          ),
                        );
                      }),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
