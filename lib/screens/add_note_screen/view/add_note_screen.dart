import 'dart:io';
import 'dart:ui';

import 'package:audio_waveforms/audio_waveforms.dart' as audi;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
// import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/add_background_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/select_topic_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/add_note_player.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/recording_player.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/tag_users_modal_sheet.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
// import 'package:social_notes/screens/upload_sounds/view/upload_sound.dart';

import 'package:path_provider/path_provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();

  //  instance of flutter audio waves to generate the waves while recording
  late final audi.RecorderController recorderController;
  // List<String> imageExt = [
  //   'jpg',
  //   'jpeg',
  //   'png',
  // ];
  // fetchGallery() async {
  //   try {
  //     List<String> paths = await GalleryLoader().loadFiles(imageExt);
  //     log('Gallery paths are $paths');
  //     // setState(() {});
  //   } catch (e) {
  //     log('fetch error $e');
  //   }
  // }

//  firstly this init function  would call and the functions inside
  @override
  void initState() {
    SchedulerBinding.instance.scheduleFrameCallback((timer) {
      //  this function to get the directory for waves
      _getDir();

      // initialzing the controller to be used to generate the waves
      _initialiseControllers();

      // function of the pexels api to get the photos
      Provider.of<PexelsProvider>(context, listen: false).fetchPhotos();
      // function of the pexels api to get the videos
      Provider.of<PexelsProvider>(context, listen: false).fetchVideos();
    });

    super.initState();
  }

  // Timer? _timer;

  // void _checkStatusPeriodically() {
  //   _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //     await _checkStatus();
  //   });
  // }

  // Future<void> _checkStatus() async {
  //   const url =
  //       'https://api.edenai.run/v2/audio/speech_to_text_async/303b07a4-95ba-4511-ba05-f7b9c2f9167d'; // Replace with your actual status URL
  //   const token =
  //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTU0MmFjNjctYmY1Mi00NzkyLTk1NTEtZTI3ZmMzMWY4YTIyIiwidHlwZSI6ImFwaV90b2tlbiJ9.OqUDTnzH2SY0MmxwMxJEQfZ54WPBpF4VP85IFMFYyjg';

  //   try {
  //     var response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': token,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       var responseData = response.body;
  //       log('Response data: $responseData');
  //       var status = jsonDecode(responseData)['status'];

  //       if (status == 'finished') {
  //         setState(() {
  //           _status = 'Finished';
  //           _transcription = jsonDecode(responseData)['results']
  //                   ['deepgram/enhanced']['text'] ??
  //               "No transcription available";
  //         });
  //         _timer?.cancel();
  //       } else {
  //         setState(() {
  //           _status = status;
  //         });
  //       }
  //     } else {
  //       log('Failed with status code: ${response.statusCode}');
  //       log('Error response data: ${response.body}');
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  // }

  // getDraft() async {
  //   List<Map<String, dynamic>> data =
  //       await Provider.of<NoteProvider>(context, listen: false).getDrafts();
  //   log('drafts data is $data');
  // }

  void _initialiseControllers() {
    recorderController = audi.RecorderController()
      ..androidEncoder = audi.AndroidEncoder.aac
      ..androidOutputFormat = audi.AndroidOutputFormat.mpeg4
      ..iosEncoder = audi.IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _getDir() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = "${appDirectory.path}/recording.m4a";
    Provider.of<NoteProvider>(context, listen: false).setDirectoryPath(path);
  }

// dispose the controller when we don't further need it
  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // getting the current user data which is saved in provider

    var currentUser = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      body: Stack(
        children: [
          //  background of the screen based on what user has selected
          Consumer<NoteProvider>(builder: (context, noteProvider, _) {
            //  if the user hase not selected anything then the default background which is linear gradient
            return noteProvider.selectedImage.isEmpty &&
                    noteProvider.selectedVideo.isEmpty
                ? Container(
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
                  )

                //  if the user hase selected some pic or video

                : Stack(
                    children: [
                      Consumer<PexelsProvider>(builder: (context, pexelPro, _) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(),
                            child:
                                //  for the video background
                                noteProvider.fileType.contains('video')
                                    ? AddNotePlayer(
                                        videoUrl:
                                            noteProvider.selectedImage.isEmpty
                                                ? noteProvider.selectedVideo
                                                : noteProvider.selectedImage,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width)
                                    // for the image background
                                    : Image.network(noteProvider.selectedImage,
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width));
                      }),

                      // above the image or video there would be a blur filter
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.white
                              .withOpacity(0.1), // Transparent color
                        ),
                      ),

                      // and above that there would be a gradient
                      Container(
                        height: size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // stops: [],
                            colors: [
                              Colors.transparent,
                              const Color(0xff3d3d3d).withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          }),
          // while the video is being sending to firebase storage show this text with loader
          Consumer<NoteProvider>(builder: (context, notePro, _) {
            return notePro.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Wait while the video is loading...',
                          style: TextStyle(
                              color: whiteColor,
                              fontFamily: fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: whiteColor,
                          ),
                        )
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: SizedBox()),

                      // field to get the title of the post
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          controller: titleController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              hintText: 'Add a title (max 10 letters)',
                              hintStyle: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor),
                              fillColor: whiteColor,
                              constraints: BoxConstraints(
                                  maxWidth: size.width * 0.90,
                                  maxHeight: size.width * 0.15),
                              filled: true,
                              contentPadding: const EdgeInsets.only(left: 20),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    top: 1.5, right: 0, left: 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Text(
                                    //   'Max 10 letters',
                                    //   style: TextStyle(
                                    //       fontFamily: fontFamily,
                                    //       color: Colors.grey),
                                    // ),

                                    //  button to navigate to the screen to pic image or video or from gallery
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                              horizontal: 2)
                                          .copyWith(bottom: 1.5),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddBackgroundScreen(),
                                              ));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/icons/Img_box.svg'),
                                              Text(
                                                'Add background',
                                                style: TextStyle(
                                                    fontFamily: fontFamily,
                                                    color: whiteColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(60),
                                  borderSide: BorderSide.none)),
                        ),
                      ),

                      // show the player to play the recorded voice when the recording is finished
                      // also it show up when the voice is picked up from the gallery

                      Consumer<NoteProvider>(
                          builder: (context, noteProvider, _) {
                        return Column(
                          children: [
                            if (noteProvider.voiceNote != null ||
                                noteProvider.audioFiles.isNotEmpty)
                              Container(
                                  width: 300,
                                  child: RecordingPlayer(
                                    isMainPlayer: true,
                                    size: 35,
                                    height: 100,
                                    mainHeight: 100,
                                    mainWidth: 300,
                                    noteUrl: noteProvider.audioFiles.isEmpty
                                        ? noteProvider.voiceNote!.path
                                        : noteProvider.audioFiles.first.path,
                                    width: 140,
                                    backgroundColor: whiteColor,
                                  )),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        );
                      }),
                      const SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // recording button with the real time waves generation

                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Consumer<NoteProvider>(
                                builder: (context, noteProvider, _) {
                              return GestureDetector(
                                onTap: () async {
                                  if (noteProvider.audioFiles.isEmpty) {
                                    if (await noteProvider.recorder
                                        .isRecording()) {
                                      noteProvider.stop(context);
                                      recorderController.stop();
                                    } else {
                                      debugPrint('Recording');

                                      recorderController.record();
                                      noteProvider.record(context);
                                      // noteProvider.startTimer();
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: noteProvider.audioFiles.isEmpty
                                        ? whiteColor
                                        : blackColor,
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: noteProvider.isRecording
                                      ? audi.AudioWaveforms(
                                          size: const Size(55, 55),
                                          recorderController:
                                              recorderController,
                                          // density: 1.5,
                                          waveStyle: audi.WaveStyle(
                                            showMiddleLine: false,
                                            extendWaveform: true,
                                            waveColor: primaryColor,
                                            // scaleFactor: 0.8,
                                            waveCap: StrokeCap.butt,
                                          ),
                                        )
                                      : Image.asset(
                                          noteProvider.audioFiles.isNotEmpty
                                              ? 'assets/icons/recording_inprogress 4.png'
                                              : 'assets/images/recording_inprogress.png',
                                          height: 55,
                                          width: 55,
                                        ),
                                ),
                              );
                            }),
                          ),

                          // picking audio from the gallery
                          Consumer<NoteProvider>(
                              builder: (context, noteProvider, _) {
                            return GestureDetector(
                              onTap: () async {
                                if (noteProvider.voiceNote == null) {
                                  Provider.of<NoteProvider>(context,
                                          listen: false)
                                      .pickAudioFile();
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: noteProvider.voiceNote != null
                                      ? blackColor
                                      : whiteColor,
                                  borderRadius: BorderRadius.circular(55),
                                ),
                                child: SvgPicture.asset(
                                  noteProvider.voiceNote != null
                                      ? 'assets/icons/Upload_greyed.svg'
                                      : 'assets/icons/Upload.svg',
                                  height: 52,
                                  width: 52,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                      // this will show up when the user select video from the gallery to upload thumbnail

                      Consumer<NoteProvider>(builder: (context, notePro, _) {
                        return notePro.isGalleryVideo
                            ? InkWell(
                                onTap: () {
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .pickImage();
                                },
                                child: Consumer<UserProvider>(
                                    builder: (context, imagePro, _) {
                                  return CircleAvatar(
                                    radius: 55,
                                    backgroundColor: imagePro.imageFile != null
                                        ? null
                                        : primaryColor,
                                    backgroundImage: imagePro.imageFile != null
                                        ? FileImage(imagePro.imageFile!)
                                        : null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/Img_box (1).svg',
                                          color: whiteColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Upload Cover Image',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: whiteColor,
                                              fontSize: 13,
                                              fontFamily: khulaRegular,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                              )
                            : SizedBox();
                      }),

                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //  button to show the dialog to either save as draft or cancel the post

                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(blackColor),
                                fixedSize: const WidgetStatePropertyAll(
                                  Size(115, 10),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: whiteColor,
                                    elevation: 0,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                                  vertical: 10)
                                              .copyWith(left: 5),
                                          child: Text(
                                            'Save As Draft?',
                                            style: TextStyle(
                                                fontFamily: fontFamily,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                                  vertical: 10)
                                              .copyWith(left: 5, bottom: 20),
                                          child: Text(
                                            'Do you wish to cancel this post or can we save it in your Drafts?',
                                            style: TextStyle(
                                                fontFamily: fontFamily,
                                                color: const Color(0xff6C6C6C),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Consumer<NoteProvider>(builder:
                                                (context, noteProvider, _) {
                                              return ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        const WidgetStatePropertyAll(
                                                            Colors.transparent),
                                                    elevation:
                                                        const WidgetStatePropertyAll(
                                                            0),
                                                    shape:
                                                        WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                        side: BorderSide(
                                                            color: blackColor,
                                                            width: 1),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    //  on  cancel everything clear which user selected

                                                    noteProvider
                                                        .setEmptySelectedImage();
                                                    noteProvider
                                                        .setEmptySelectedVideo();

                                                    noteProvider
                                                        .removeVoiceNote();
                                                    noteProvider
                                                        .clearAudioFiles();

                                                    Provider.of<UserProvider>(
                                                            context,
                                                            listen: false)
                                                        .removeImage();
                                                    // soundPro.removeVoiceUrl();
                                                    navPop(context);
                                                  },
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: blackColor,
                                                        fontFamily: fontFamily,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ));
                                            }),
                                            Consumer<UserProvider>(builder:
                                                (context, imagePro, _) {
                                              return Consumer<NoteProvider>(
                                                  builder: (context,
                                                      noteProvider, _) {
                                                return ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                blackColor),
                                                        elevation:
                                                            const WidgetStatePropertyAll(
                                                                0)),
                                                    onPressed: () async {
                                                      // shared prefs to save the post in local storage

                                                      String draftId =
                                                          const Uuid().v4();
                                                      Provider.of<NoteProvider>(
                                                              context,
                                                              listen: false)
                                                          .saveDraft(
                                                              noteProvider
                                                                      .audioFiles
                                                                      .isEmpty
                                                                  ? noteProvider
                                                                      .voiceNote!
                                                                  : noteProvider
                                                                      .audioFiles
                                                                      .first,
                                                              noteProvider
                                                                      .selectedImage
                                                                      .isEmpty
                                                                  ? noteProvider
                                                                      .selectedVideo
                                                                  : noteProvider
                                                                      .selectedImage,
                                                              imagePro.imageFile ==
                                                                      null
                                                                  ? ''
                                                                  : imagePro
                                                                      .imageFile!
                                                                      .path,
                                                              noteProvider
                                                                  .isGalleryVideo);
                                                      navPop(context);
                                                      showWhiteOverlayPopup(
                                                          context,
                                                          Icons.check,
                                                          null,
                                                          null,
                                                          title: 'Successful',
                                                          message:
                                                              'Added to draft.',
                                                          isUsernameRes: false);
                                                      noteProvider
                                                          .removeVoiceNote();
                                                      noteProvider
                                                          .clearAudioFiles();
                                                      noteProvider
                                                          .setNullSelectedVideo();
                                                      noteProvider
                                                          .setEmptySelectedImage();
                                                      Provider.of<UserProvider>(
                                                              context,
                                                              listen: false)
                                                          .removeImage();
                                                    },
                                                    child: Text(
                                                      'Save Draft',
                                                      style: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ));
                                              });
                                            })
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              label: Text(
                                'Retake',
                                style: TextStyle(
                                    color: whiteColor,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10),
                              ),
                              icon: Image.asset(
                                'assets/images/retake.png',
                                height: 20,
                                width: 20,
                              ),
                            ),

                            // button to tag the users whom you are following

                            ElevatedButton.icon(
                              style: ButtonStyle(
                                  fixedSize: const WidgetStatePropertyAll(
                                      Size(120, 10)),
                                  backgroundColor:
                                      WidgetStatePropertyAll(blackColor)),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return const TagUsersModalSheet();
                                  },
                                );
                              },
                              label: Text(
                                'Tag people',
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: fontFamily,
                                    fontSize: 10),
                              ),
                              icon: Image.asset(
                                'assets/images/tagpeople_white.png',
                                height: 20,
                                width: 20,
                              ),
                            ),

                            // button to navigate to next screen to select the post topic and also passing user  selected data to next screen
                            Consumer<NoteProvider>(
                                builder: (context, noteProvider, _) {
                              return ElevatedButton.icon(
                                style: ButtonStyle(
                                    fixedSize: const WidgetStatePropertyAll(
                                        Size(110, 10)),
                                    backgroundColor:
                                        WidgetStatePropertyAll(whiteColor)),
                                onPressed: () {
                                  if ((noteProvider.voiceNote != null ||
                                      noteProvider.audioFiles.isNotEmpty)) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>

                                              //  carries data to the next screen
                                              SelectTopicScreen(
                                            backImage: '',
                                            type: '',
                                            path: noteProvider
                                                    .audioFiles.isEmpty
                                                ? noteProvider.voiceNote!.path
                                                : noteProvider
                                                    .audioFiles.first.path,
                                            title: titleController.text.isEmpty
                                                ? ''
                                                : titleController.text,
                                            taggedPeople: const [],
                                          ),
                                        ));
                                  } else {
                                    showWhiteOverlayPopup(context, null,
                                        'assets/icons/Info (1).svg', null,
                                        title: 'Error',
                                        message:
                                            'Please record a voice note first.',
                                        isUsernameRes: false);
                                  }
                                },
                                label: Text(
                                  'Next',
                                  style: TextStyle(
                                      color: blackColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: fontFamily,
                                      fontSize: 10),
                                ),
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: blackColor,
                                  size: 17,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
          }),
        ],
      ),
    );
  }
}
