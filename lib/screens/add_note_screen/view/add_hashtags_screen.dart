// import 'package:firebase_core/firebase_core.dart';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
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
import 'package:social_notes/screens/add_note_screen/provider/player_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/list_hashtag_widget.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/recommended_hastags.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
// import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddHashtagsScreen extends StatefulWidget {
  const AddHashtagsScreen(
      {super.key,
      required this.title,
      required this.taggedPeople,
      required this.topicColor,
      required this.backgroundType,
      this.thumbnailPath,
      this.isGalleryThumbnail,
      // required this.waveformdata,
      required this.backGroundImage,
      this.filePath,
      required this.selectedTopic});

  //  getting the required data from the previous screen

  final String title;
  final List<String> taggedPeople;
  final String selectedTopic;
  final Color topicColor;
  // final List<double> waveformdata;
  final String backGroundImage;
  final String backgroundType;
  static const routeName = '/add-hastags';
  final String? filePath;
  final String? thumbnailPath;
  final bool? isGalleryThumbnail;

  @override
  State<AddHashtagsScreen> createState() => _AddHashtagsScreenState();
}

class _AddHashtagsScreenState extends State<AddHashtagsScreen> {
  //  varibale to store the data for hashtags
  final List<String> _selectedOptions = [];

  // if the post is public or not
  bool isPublic = false;

  //  if the post is for subscriber

  bool forSubscribers = false;

  //  function to get the trending hashtags

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

  List<String> userAddedHasthtags = [];
  List<String> recommended = [];

//  getting recommended hashtags based on the user selected topic

  getRecommendedHashtagsBasedOnTopic() {
    if (widget.selectedTopic.contains('Need Support')) {
      recommended = needSupport;
    } else if (widget.selectedTopic.contains('Relationship & Love')) {
      recommended = relationShiplove;
    } else if (widget.selectedTopic.contains('Confession & Secret')) {
      recommended = confessionSecret;
    } else if (widget.selectedTopic.contains('Inspiration & Motivation')) {
      recommended = inspirationMotivation;
    } else if (widget.selectedTopic.contains('Food & Cooking')) {
      recommended = foodCooking;
    } else if (widget.selectedTopic.contains('Personal Story')) {
      recommended = personalStory;
    } else if (widget.selectedTopic.contains('Business')) {
      recommended = business;
    } else if (widget.selectedTopic.contains('Something I learned')) {
      recommended = somethingILearned;
    } else if (widget.selectedTopic.contains('Education & Learning')) {
      recommended = educationLearning;
    } else if (widget.selectedTopic.contains('Books & Literature')) {
      recommended = booksAndLiterature;
    } else if (widget.selectedTopic.contains('Spirit & Mind')) {
      recommended = spiritAndMind;
    } else if (widget.selectedTopic.contains('Travel & Adventure')) {
      recommended = travelAndAdventure;
    } else if (widget.selectedTopic.contains('Fashion & Style')) {
      recommended = fashionAndStyle;
    } else if (widget.selectedTopic.contains('Creativity & Art')) {
      recommended = creativityAndArt;
    } else if (widget.selectedTopic.contains('Humor & Comedy')) {
      recommended = humorAndComedy;
    } else if (widget.selectedTopic.contains('Sports & Fitness')) {
      recommended = sportsAndFitness;
    } else if (widget.selectedTopic.contains('Technology & Innovation')) {
      recommended = technologyAndInnovation;
    } else if (widget.selectedTopic.contains('Current Events & News')) {
      recommended = currentEventsAndNews;
    } else if (widget.selectedTopic.contains('Health & Wellness')) {
      recommended = healthAndWellness;
    } else if (widget.selectedTopic.contains('Hobbies & Interests')) {
      recommended = hobbiesAndInterests;
    } else if (widget.selectedTopic.contains('Music')) {
      recommended = musicHashtags;
    } else if (widget.selectedTopic.contains('Podcasts & Interviews')) {
      recommended = podcastsHast;
    } else if (widget.selectedTopic.contains('other')) {
      recommended = other;
    }
    setState(() {});
  }

  List<String> trendings = [];
  TextEditingController addHasgtagController = TextEditingController();

  @override
  void initState() {
    // calling the functions before the screen build
    getRecommendedHashtagsBasedOnTopic();
    getTrendingHastags();
    super.initState();
  }

  PlayerController controller = PlayerController();

  getWavesData() async {
    // Extract waveform data
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    //  getting the current user data
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;

    // getting note provider to use specific functions
    var noteProvider = Provider.of<NoteProvider>(context, listen: false);

    //  also the provider to use some functions
    var soundPro = Provider.of<SoundProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // background of the screen
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
                padding: const EdgeInsets.only(top: 80),
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
              const SizedBox(
                height: 10,
              ),

              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    //  field to add hashtag  by the user

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

                    //  button to add the hashatg if the certain conditions met

                    Positioned(
                      left: size.width * 0.55,
                      bottom: 6,
                      child: ElevatedButton(
                        onPressed: () {
                          if (addHasgtagController.text.isNotEmpty) {
                            if (_selectedOptions.length < 10) {
                              if (!userAddedHasthtags
                                  .contains('#${addHasgtagController.text}')) {
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
                                // error to show if the hashtag already exist

                                showWhiteOverlayPopup(context, null,
                                    'assets/icons/Info (1).svg', null,
                                    title: 'Error',
                                    message: 'Hastag already added.',
                                    isUsernameRes: false);
                              }
                            } else {
                              //  error to show if the hashtags exceeds the limit of 10

                              showWhiteOverlayPopup(context, null,
                                  'assets/icons/Info (1).svg', null,
                                  title: 'Error',
                                  message: 'You can only select 10 hashtags.',
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

              // showing the user added hashtags which are saved in the list

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: List.generate(userAddedHasthtags.length, (index) {
                      return InkWell(
                        onTap: () {
                          // select to add or unselect to remove the user added hashtags

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
                              //  error to show if the limit exceeds

                              showWhiteOverlayPopup(context, null,
                                  'assets/icons/Info (1).svg', null,
                                  title: 'Error',
                                  message: 'You can only select 10 hashtags.',
                                  isUsernameRes: false);
                            }
                          });
                        },
                        child: Container(
                          width: 150,
                          // height: ,
                          // height: ,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 0),
                          decoration: BoxDecoration(
                              color: _selectedOptions
                                      .contains(userAddedHasthtags[index])
                                  ? whiteColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: whiteColor, width: 1)),
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
                      );
                    }),
                  ),
                ),
              ),

              //  recommend topic based on user selected topic

              Text(
                'TOPIC RECOMMENDED',
                style: TextStyle(
                    color: whiteColor,
                    fontFamily: fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: SizedBox(
                  height: 100, // Increased height to accommodate two lines
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: _buildHashtagRows(recommended),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //trending  hashtags to show

              Text(
                'TRENDING',
                style: TextStyle(
                    color: whiteColor,
                    fontFamily: fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: SizedBox(
                      height: 100, // Increased height to accommodate two lines
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: _buildHashtagRows(trendings),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))),
              // Padding(
              //   padding: const EdgeInsets.only(top: 15, bottom: 15),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 85,
              //     child: CustomScrollView(
              //       scrollDirection: Axis.horizontal,
              //       slivers: [
              //         SliverPadding(
              //           padding: const EdgeInsets.only(left: 35),
              //           sliver: SliverGrid(
              //             gridDelegate:
              //                 const SliverGridDelegateWithFixedCrossAxisCount(
              //               childAspectRatio: 2.2 / 10,
              //               crossAxisCount: 2,
              //               mainAxisSpacing: 10,
              //               crossAxisSpacing: 12,
              //             ),
              //             delegate: SliverChildBuilderDelegate(
              //               (context, index) {
              //                 return InkWell(
              //                   onTap: () {
              //                     setState(() {
              //                       if (_selectedOptions.length < 10) {
              //                         if (_selectedOptions
              //                             .contains(trendings[index])) {
              //                           _selectedOptions
              //                               .remove(trendings[index]);
              //                         } else {
              //                           _selectedOptions.add(trendings[index]);
              //                         }
              //                       } else {
              //                         showWhiteOverlayPopup(
              //                           context,
              //                           null,
              //                           'assets/icons/Info (1).svg',
              //                           null,
              //                           title: 'Error',
              //                           message:
              //                               'You can only select 10 hashtags.',
              //                           isUsernameRes: false,
              //                         );
              //                       }
              //                     });
              //                   },
              //                   child: Container(
              //                     padding: const EdgeInsets.symmetric(
              //                         vertical: 8, horizontal: 0),
              //                     decoration: BoxDecoration(
              //                       color: _selectedOptions
              //                               .contains(trendings[index])
              //                           ? whiteColor
              //                           : Colors.transparent,
              //                       borderRadius: BorderRadius.circular(20),
              //                       border:
              //                           Border.all(color: whiteColor, width: 1),
              //                     ),
              //                     child: Text(
              //                       trendings[index],
              //                       textAlign: TextAlign.center,
              //                       style: TextStyle(
              //                         color: _selectedOptions
              //                                 .contains(trendings[index])
              //                             ? blackColor
              //                             : whiteColor,
              //                         fontFamily: khulaRegular,
              //                         fontSize: 16,
              //                         fontWeight: FontWeight.w600,
              //                       ),
              //                     ),
              //                   ),
              //                 );
              //               },
              //               childCount: trendings.length,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const Expanded(child: SizedBox()),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: userProvider!.isVerified ? 10 : 20,
                    vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(blackColor),
                      ),
                      onPressed: () {
                        // go back to the prevoius screen

                        navPop(context);
                      },
                      label: Text(
                        'Back',
                        style: TextStyle(
                            color: whiteColor,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      icon: Image.asset(
                        'assets/images/back.png',
                        height: 13,
                        width: 13,
                      ),
                    ),
                    if (userProvider.isVerified)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //  toggle to show if the user is verified and if subscripton is enable

                                Text(
                                  forSubscribers ? '  Subscribers' : '  Public',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: fontFamily,
                                      color: blackColor),
                                ),

                                // switch to enable or disable the toggle only show up if the user has enabled the subscription

                                Switch(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: const Color(0xffA562CB),
                                    value: forSubscribers,
                                    trackOutlineColor:
                                        MaterialStateProperty.all(
                                            Colors.transparent),
                                    onChanged: (value) {
                                      setState(() {
                                        forSubscribers = value;
                                      });
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Consumer<UserProvider>(builder: (context, loadingPro, _) {
                      return ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(whiteColor)),
                        onPressed: () async {
                          // while the post adding show the loading true

                          loadingPro.setUserLoading(true);
                          String noteId = const Uuid().v4();

                          //  uploading voice to the storage

                          String noteUrl = soundPro.voiceUrl == null
                              ? await AddNoteController().uploadFile(
                                  'voices',
                                  widget.filePath != null
                                      ? File(widget.filePath!)
                                      : noteProvider.audioFiles.isEmpty
                                          ? noteProvider.voiceNote!
                                          : noteProvider.audioFiles.first,
                                  context)
                              : soundPro.voiceUrl!;

                          List<double> waveformData =
                              await controller.extractWaveformData(
                            path: widget.filePath != null
                                ? widget.filePath!
                                : noteProvider.audioFiles.isEmpty
                                    ? noteProvider.voiceNote!.path
                                    : noteProvider.audioFiles.first.path,
                            noOfSamples: 200,
                          );

                          // uploading thumbail if the certain conditions met

                          String? videoThumbnail;
                          if (widget.backgroundType.contains('video') &&
                                  widget.isGalleryThumbnail != null
                              ? widget.isGalleryThumbnail!
                              : noteProvider.isGalleryVideo) {
                            videoThumbnail = await AddNoteController()
                                .uploadFile(
                                    'galleryThumbnails',
                                    widget.thumbnailPath != null
                                        ? File(widget.thumbnailPath!)
                                        : loadingPro.imageFile!,
                                    context);
                          } else if (widget.backgroundType.contains('video') &&
                              widget.backGroundImage.isNotEmpty) {
                            final uint8list =
                                await VideoThumbnail.thumbnailData(
                              video: widget.backGroundImage,
                              imageFormat: ImageFormat.JPEG,
                              maxHeight:
                                  (MediaQuery.of(context).size.height * 1.5)
                                      .toInt(), // Further reduced dimensions
                              maxWidth:
                                  (MediaQuery.of(context).size.width * 1.5)
                                      .toInt(), // Further reduced dimensions
                              quality:
                                  100, // Reduced quality for faster generation
                            );
                            videoThumbnail = await AddNoteController()
                                .uploadUint('Thumbnails', uint8list!, context);
                          }

                          //  creating the post model with the requird data to craete the post

                          NoteModel note = NoteModel(
                              waveforms: waveformData,
                              videoThumbnail: videoThumbnail ?? '',
                              mostListenedWaves: [],
                              backgroundType: widget.backgroundType,
                              backgroundImage: widget.backGroundImage,
                              isPostForSubscribers: forSubscribers,
                              topicColor: widget.topicColor,
                              userToken: userProvider.token,
                              isPinned: false,
                              noteId: noteId,
                              username: userProvider.name,
                              photoUrl: userProvider.photoUrl,
                              title: widget.title,
                              userUid: userProvider.uid,
                              tagPeople: noteProvider.tags,
                              likes: [],
                              noteUrl: noteUrl,
                              publishedDate: DateTime.now(),
                              comments: [],
                              topic: widget.selectedTopic,
                              hashtags: _selectedOptions);

                          //  adding the post to the firestore

                          AddNoteController()
                              .addNote(note, noteId, context)
                              .then((value) async {
                            //clearing everything from providers

                            noteProvider.removeVoiceNote();
                            noteProvider.clearAudioFiles();
                            loadingPro.setUserLoading(false);
                            noteProvider.setEmptySelectedImage();
                            noteProvider.setEmptySelectedVideo();
                            noteProvider.setIsGalleryVideo(false);
                            noteProvider.setClearTags();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BottomBar()),
                                (route) => false);

                            // navPush(BottomBar.routeName, context);

                            //  after adding the post and navigating
                            //  notifiying the users who enabled the user notification icon

                            for (var id in userProvider.notificationsEnable) {
                              NotificationMethods.sendPushNotification(
                                  id,
                                  '',
                                  'Added a Post',
                                  userProvider.username,
                                  'home',
                                  noteId,
                                  context);
                            }
                            log('Noti send');
                          });
                        },
                        label:

                            // showing the loading when the post is adding

                            loadingPro.userLoading
                                ? SpinKitThreeBounce(
                                    color: blackColor,
                                    size: 12,
                                  )
                                : Text(
                                    'Share',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
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
    );
  }

  List<Widget> _buildHashtagRows(List<String> hashtags) {
    final int halfLength = (hashtags.length / 2).ceil();
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHashtagRow(hashtags.sublist(0, halfLength)),
          const SizedBox(height: 10),
          _buildHashtagRow(hashtags.sublist(halfLength)),
        ],
      ),
    ];
  }

  Widget _buildHashtagRow(List<String> hashtags) {
    return Row(
      children: hashtags.map((hashtag) {
        final isSelected = _selectedOptions.contains(hashtag);
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IntrinsicWidth(
            child: InkWell(
              onTap: () => _toggleHashtag(hashtag),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? whiteColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: whiteColor, width: 1),
                ),
                child: Text(
                  hashtag,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? blackColor : whiteColor,
                    fontFamily: khulaRegular,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleHashtag(String hashtag) {
    setState(() {
      if (_selectedOptions.contains(hashtag)) {
        _selectedOptions.remove(hashtag);
      } else if (_selectedOptions.length < 10) {
        _selectedOptions.add(hashtag);
      } else {
        showWhiteOverlayPopup(
          context,
          null,
          'assets/icons/Info (1).svg',
          null,
          title: 'Error',
          message: 'You can only select ${10} hashtags.',
          isUsernameRes: false,
        );
      }
    });
  }
}
