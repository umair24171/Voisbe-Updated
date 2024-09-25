import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/main.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
// import 'package:record/record.dart';
import 'package:social_notes/screens/home_screen/model/sub_comment_model.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class NoteProvider with ChangeNotifier {
  //  variable to show loading while searching user

  bool isSearchingUser = false;

  //  list of searchedUsers

  List<UserModel> searchedUsers = [];

  // show loading to while doing something

  bool isLoading = false;

  // these varibales are used in sending replies in main feed

  bool isSending = false;
  bool isReplying = false;
  bool isSubCommentReplying = false;
  SubCommentModel? subCommentModel;
  List<double> waveformData = [];

  //  variable to store the image

  String _selectedImage = '';

  String _fileType = '';

  //  variable to manage if the file is picked from the gallery or not

  bool isGalleryVideo = false;

//  changing the gallery video value

  setIsGalleryVideo(bool value) {
    isGalleryVideo = value;
    notifyListeners();
  }

  //  variable to select the video

  String selectedVideo = '';
  // Future<void> postSpeechToText(String url) async {
  //   const url = 'https://api.edenai.run/v2/audio/speech_to_text_async';
  //   const token =
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTU0MmFjNjctYmY1Mi00NzkyLTk1NTEtZTI3ZmMzMWY4YTIyIiwidHlwZSI6ImFwaV90b2tlbiJ9.OqUDTnzH2SY0MmxwMxJEQfZ54WPBpF4VP85IFMFYyjg';
  //   const fileUrl = url;

  //   final headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final body = jsonEncode({
  //     'providers': 'deepgram/enhanced',
  //     'language': 'en',
  //     'file_url': fileUrl,
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: body,
  //     );

  //     if (response.statusCode == 200) {
  //       log('Response data: ${response.body}');
  //     } else {
  //       log('Failed with status code: ${response.statusCode}');
  //       log('Error response data: ${response.body}');
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  // }
  //  static const List<String> inappropriateWords = [
  //   "bastard", "idiot", "fucking", "shit", "asshole", "cunt", "motherfucker", "dick", "piss", "cock"
  //   // Add more words as needed
  // ];
  bool _containsInappropriateWords(String text) {
    text = text.toLowerCase();
    for (String word in inappropriateWords) {
      if (text.contains(word)) {
        return true;
      }
    }
    return false;
  }

  void _handleInappropriateContent(context) {
    // Handle inappropriate content: show popup, set voice note to null, etc.
    // Example: Show a popup
    showWhiteOverlayPopup(
        navigatorKey.currentContext, null, 'assets/icons/Info (1).svg', null,
        title: 'Warning!',
        message: 'You cannot add inappropriate words.',
        isUsernameRes: false);
    voiceNote = null;

    notifyListeners();

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Inappropriate Content'),
    //       content: Text('You cannot add inappropriate words.'),
    //       actions: <Widget>[
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             // Set voice note to null, or handle other logic as needed
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    // },
    // );
  }

  Future<void> _checkStatus(String publicId, context) async {
    var url =
        'https://api.edenai.run/v2/audio/speech_to_text_async/$publicId'; // Replace with your actual status URL
    const token =
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTU0MmFjNjctYmY1Mi00NzkyLTk1NTEtZTI3ZmMzMWY4YTIyIiwidHlwZSI6ImFwaV90b2tlbiJ9.OqUDTnzH2SY0MmxwMxJEQfZ54WPBpF4VP85IFMFYyjg';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        var responseData = response.body;
        log('Response data: $responseData');
        var status = jsonDecode(responseData)['status'];

        if (status == 'finished') {
          String text = jsonDecode(responseData)['results']['deepgram/enhanced']
                  ['text'] ??
              "No transcription available";

          if (_containsInappropriateWords(text)) {
            _handleInappropriateContent(context);
          } else {
            // Process the text as needed
            log('Transcription: $text');
          }
        }
      } else {
        log('Failed with status code: ${response.statusCode}');
        log('Error response data: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> postSpeechToText(File audioFile) async {
    const url = 'https://api.edenai.run/v2/audio/speech_to_text_async';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTU0MmFjNjctYmY1Mi00NzkyLTk1NTEtZTI3ZmMzMWY4YTIyIiwidHlwZSI6ImFwaV90b2tlbiJ9.OqUDTnzH2SY0MmxwMxJEQfZ54WPBpF4VP85IFMFYyjg';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['providers'] = 'deepgram/enhanced'
      ..fields['language'] = 'en'
      ..fields['profanity_filter'] = 'true'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'mpeg'),
      ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        log('Response data: ${responseData.body}');
        var res = jsonDecode(responseData.body);
        _checkStatus(res['public_id'], context);
      } else {
        var responseData = await http.Response.fromStream(response);
        log('Failed with status code: ${response.statusCode}');
        log('Error response data: ${responseData.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

// List of common inappropriate words
  List<String> inappropriateWords = [
    'fucking',
    'idiot',
    'bitch',
    'shit',
    'damn',
    'asshole',
    'bastard',
    'crap',
    'douchebag',
    'dick',
    'dumbass',
    'jackass',
    'motherfucker',
    'nigger',
    'prick',
    'pussy',
    'slut',
    'whore'
  ];

  // Future<void> postSpeechToText(File file, BuildContext context) async {
  //   const url = 'https://api.edenai.run/v2/audio/speech_to_text_async';
  //   const token =
  //       'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTU0MmFjNjctYmY1Mi00NzkyLTk1NTEtZTI3ZmMzMWY4YTIyIiwidHlwZSI6ImFwaV90b2tlbiJ9.OqUDTnzH2SY0MmxwMxJEQfZ54WPBpF4VP85IFMFYyjg';

  //   var request = http.MultipartRequest('POST', Uri.parse(url));
  //   request.headers['Authorization'] = token;
  //   request.files.add(await http.MultipartFile.fromPath('file', file.path));
  //   request.fields['providers'] = 'deepgram/enhanced';
  //   request.fields['language'] = 'en';

  //   var response = await request.send();
  //   var responseData = await response.stream.bytesToString();

  //   if (response.statusCode == 200) {
  //     var responseJson = jsonDecode(responseData);
  //     String status = responseJson['status'];
  //     String text = responseJson['results']['deepgram/enhanced']['text'];

  //     if (status == 'finished') {
  //       // Check for inappropriate words
  //       bool containsInappropriateWords =
  //           inappropriateWords.any((word) => text.contains(word));

  //       if (containsInappropriateWords) {
  //         // Show a popup and set the voice note to null
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: Text('Inappropriate Content'),
  //             content: Text('You cannot add inappropriate words.'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           ),
  //         );

  //         voiceNote = null;
  //         notifyListeners();
  //       } else {
  //         // Process the voice note as usual
  //         setVoiceNote(file);
  //       }
  //     }
  //   } else {
  //     print('Failed with status code: ${response.statusCode}');
  //     print('Error response data: $responseData');
  //   }
  // }

  //  changing the value of the variable and adding the video in it

  setSelectedVideo(String video) {
    selectedVideo = video;

    notifyListeners();
  }

  // removing the selected video

  setNullSelectedVideo() {
    selectedVideo = '';
    notifyListeners();
  }

  String get selectedImage => _selectedImage;
  String get fileType => _fileType;

  List<File> audioFiles = [];
  Timer? _timer;
  int start = 0;
  // setTimerCancel() {
  //   _timer!.cancel();
  //   notifyListeners();
  // }

  // increaseTimer() {
  //   start++;
  // }

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (start == 60) {
  //         setTimerCancel();
  //       } else {
  //         increaseTimer();
  //       }
  //     },
  //   );
  // }

  // picking audio file from the gallery and saving the file in the audioFiles variable

  Future<void> pickAudioFile() async {
    // Allow the user to pick files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac'],
    );

    if (result != null) {
      audioFiles = result.paths.map((path) => File(path!)).toList();
      // File audioFIle=result.p

      // Upload selected files to Firebase Storage
      // FirebaseStorage storage = FirebaseStorage.instance;

      // for (var file in files) {
      //   String fileName = file.path.split('/').last;
      //   Reference ref = storage.ref().child('mp3_files/$fileName');
      //   await ref.putFile(file);
      //   String downloadUrl = await ref.getDownloadURL();
      //   fileUrls.add(downloadUrl);
      // }

      notifyListeners();
    }
  }

// removing the picked audio files

  clearAudioFiles() {
    audioFiles.clear();
    notifyListeners();
  }

  // setting file type of the selected file either its video or image

  setFileType(String type) {
    _fileType = type;
    notifyListeners();
  }

  // setting the selected image that is the background image

  setSelectedImage(String image) {
    // setEmptySelectedImage();

    _selectedImage = image;
    notifyListeners();
  }

  // removing the background either its video or image

  setEmptySelectedImage() {
    _selectedImage = '';
    notifyListeners();
  }

  // removing the selected video

  setEmptySelectedVideo() {
    selectedVideo = '';
    notifyListeners();
  }

  // setWaveFormData(List<double> waveform) {
  //   waveformData = waveform;
  //   notifyListeners();
  // }

  // RecorderState _recorderState = RecorderState.stopped;
  // final StreamController<RecorderState> _recorderStateController =
  //     StreamController.broadcast();
  String directoryPath = '';
  final FlutterSoundRecord recorder = FlutterSoundRecord();

  // getting the path of file to save

  setDirectoryPath(String path) {
    directoryPath = path;
    notifyListeners();
  }

  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  // changing the value in replies section during recording

  setIsReplying(bool value) {
    isReplying = value;
    notifyListeners();
  }

  // changing the value in replies section if its  a  subcomment of the comment

  setSubCOmmentReplying(bool value) {
    isSubCommentReplying = value;
  }

// changing the value in replies section

  setSubComment(SubCommentModel subComment) {
    subCommentModel = subComment;
    notifyListeners();
  }

// changing the value in replies section if its loading

  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Future<String> getOutputPath() async {
  //   final directory = await getExternalStorageDirectory();
  //   final outputPath = '${directory?.path}/output_audio.wav';
  //   return outputPath;
  // }

  // Future<String> requestPermissionsAndReduceNoise(String inputPath) async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     status = await Permission.storage.request();
  //     return '';
  //   }
  //   if (status.isGranted) {
  //     return reduceNoise(inputPath);
  //   } else {
  //     print("Storage permission denied");
  //     return '';
  //   }
  // }

  // Future<String> reduceNoise(String inputPath) async {
  //   String outputPath = await getOutputPath();
  //   String command = '-y -i "$inputPath" -af afftdn=nr=10:nf=-40 "$outputPath"';

  //   print('Executing command: $command');
  //   int result = await _flutterFFmpeg.execute(command);
  //   if (result == 0) {
  //     print('Noise reduction completed successfully. at $outputPath');
  //     return outputPath;
  //   } else {
  //     print('Error: Noise reduction failed.');
  //     return outputPath;
  //   }
  // }

  // optimiseFunction(String path) async {
  //   String optimisedPath = await reduceNoise(path);
  //   setVoiceNote(File(optimisedPath));
  //   log('File path is ${voiceNote!.path}');
  // }

  setIsSending(bool value) {
    isSending = value;
    notifyListeners();
  }

  //  files to save the recording  either its main recording or comment recording files

  File? voiceNote;
  File? commentNoteFile;
  File? subCommentNoteFile;
  CommentModel? commentModel;

  bool isRecording = false;
  bool isCancellingReply = false; // New property to track cancel reply state

  List<String> tags = [];

  // tag user in the add note screen

  addTag(String user) {
    tags.add(user);
    notifyListeners();
  }

  //  after recording comment in reply section save the recording comment

  setCommentNoteFile(File file) {
    commentNoteFile = file;
    notifyListeners();
  }

  // after recording the subcomment save the recorded file in the subcomment file

  setSubCommentNoteFile(File file) {
    subCommentNoteFile = file;
    notifyListeners();
  }

  //  for replying saving the main comment to be used for sub commment

  setCommentModel(CommentModel model) {
    commentModel = model;
    notifyListeners();
  }

  //  removing tags during the post creation in add note screen

  removeTag(String user) {
    tags.remove(user);
    notifyListeners();
  }

  // setting the recording file to the voice note variable

  setVoiceNote(File file) async {
    // String path = await removeNoise(file.path);
    voiceNote = file;
    notifyListeners();
  }

  //  removing the recorded file

  removeVoiceNote() {
    voiceNote = null;
    notifyListeners();
  }

  //  changing the value of the recording if its being recording or not

  setRecording(bool value) {
    isRecording = value;
    notifyListeners();
  }

  // setting the value of subreply

  setCancellingReply(bool value) {
    isCancellingReply = value;
    notifyListeners();
  }

  // initRecorder() async {
  //   final status = await Permission.microphone.request();
  //   if (status.isGranted) {
  //     await recoder.openRecorder();
  //     isRecorderReady = true;
  //     recoder.setSubscriptionDuration(const Duration(milliseconds: 500));
  //   }
  // }

  // initializedRecorder() {
  //   initRecorder();
  //   notifyListeners();
  // }

  // closeRecorder() {
  //   recoder.closeRecorder();
  //   notifyListeners();
  // }
  // void _setRecorderState(RecorderState state) {
  //   _recorderStateController.add(state);
  //   _recorderState = state;
  // }

  // Future<void> _initRecorder({
  //   String? path,
  // }) async {
  //   final initialized = await AudioWaveformsInterface.instance.initRecorder(
  //     path: path,
  //     encoder: 3,
  //     outputFormat: 2,
  //     sampleRate: 44100,
  //     bitRate: 128000,
  //   );
  //   if (initialized) {
  //     log('Recorder initialized');
  //     // _setRecorderState(RecorderState.initialized);
  //   } else {
  //     throw "Failed to initialize recorder";
  //   }
  //   notifyListeners();
  // }

  //  function to record the reply

  commentRecord() async {
    String? path;
    var id = const Uuid().v4();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    path = '$appDocPath/$id.flac';

    if (await Permission.microphone.request().isGranted) {
      if (await recorder.hasPermission()) {
        // await _initRecorder();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        path = '$appDocPath/$id.flac';
        // await _initRecorder();
        setRecording(true);
        await recorder.start(
          path: path,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100.0,
        );
        // notifyListeners();
      }
    }
  }

  //  when function reply stops recording save that in  a variable

  commentStop() async {
    setRecording(false);
    final path = await recorder.stop();
    // notifyListeners();
    setCommentNoteFile(File(path!));
  }

  // recording the subcomment

  subCommentRecord() async {
    String? path;
    var id = const Uuid().v4();

    if (await Permission.microphone.request().isGranted) {
      if (await recorder.hasPermission()) {
        // await _initRecorder();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        path = '$appDocPath/$id.flac';
        // await _initRecorder();
        setRecording(true);
        await recorder.start(
          path: path,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100.0,
        );
        // notifyListeners();
      }
    }
  }

  //  stopping the subcomment record and saving that into the variable

  subCommentStop() async {
    setRecording(false);
    final path = await recorder.stop();
    // notifyListeners();
    setSubCommentNoteFile(File(path!));
  }

  // removing the recorded sub reply

  removeSubCommentNote() {
    subCommentNoteFile = null;
    notifyListeners();
  }

  // removing the recorded  reply

  removeCommentNote() {
    commentNoteFile = null;
    notifyListeners();
  }

  // removing the main reply model

  removeCommentModel() {
    commentModel = null;
    notifyListeners();
  }

  // removing the main sub reply model

  removeSubCommentModel() {
    subCommentModel = null;
    notifyListeners();
  }

  // startRecording() async {
  //   String? path;
  //   var id = const Uuid().v4();

  //   // if (await Permission.microphone.request().isGranted) {
  //   //   if (await recorder.hasPermission()) {
  //   //     isRecording = true;
  //   //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //   //     String appDocPath = appDocDir.path;
  //   //     path = '$appDocPath/$id.flac';
  //   //     await recorder.start(
  //   //       // const RecordConfig(
  //   //       //   echoCancel: true,
  //   //       //   noiseSuppress: true,
  //   //       // ),
  //   //       path: path,
  //   //     );
  //   //   }
  //   // }
  // }

//  function to record during the add note post

  Future record(context) async {
    String? path;
    var id = const Uuid().v4();
    try {
      if (await Permission.microphone.request().isGranted) {
        if (await recorder.hasPermission()) {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          path = '$appDocPath/$id.flac';
          // await _initRecorder();
          setRecording(true);
          await recorder.start(
            path: path,
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100.0,
          );
          _timer = Timer(
              Duration(
                  hours: Provider.of<UserProvider>(context, listen: false)
                          .user!
                          .isVerified
                      ? 5
                      : 1), () {
            stop(context);
          });
          // notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error in recording $e");
    }
  }

  bool isChecking = false;

  setIsChecking(bool value) {
    isChecking = value;
    notifyListeners();
  }

  //  stopping the recording of the add note post recording and saving into the variable

  Future stop(context) async {
    setRecording(false);
    final path = await recorder.stop();

    setVoiceNote(File(path!));
  }

  //  canceling the reply

  cancelReply() {
    // Remove the voice note and set cancelling reply to false
    removeVoiceNote();
    setCancellingReply(false);
  }

  //  changing the search value

  setSearching(bool value) {
    isSearchingUser = value;
    notifyListeners();
  }

  // static const MethodChannel _channel = MethodChannel('noise_removal');

  // static Future<String> removeNoise(String audioFilePath) async {
  //   try {
  //     final String result =
  //         await _channel.invokeMethod('removeNoise', audioFilePath);

  //     return result;
  //   } on PlatformException catch (e) {
  //     return "Error: '${e.message}'.";
  //   }
  // }

//  saving the posts as draft

  Future<void> saveDraft(File file, String backImage, String thumbnailImageFile,
      bool isGalleryThumbnail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? drafts = prefs.getStringList('draft');

    String draftInfo =
        '${file.path},$backImage,$thumbnailImageFile,$isGalleryThumbnail';

    if (drafts != null) {
      drafts.add(draftInfo);
    } else {
      drafts = [draftInfo];
    }

    await prefs.setStringList('draft', drafts);
  }

  //  getting the drafts posts

  Future<List<Map<String, dynamic>>> getDrafts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? drafts = prefs.getStringList('draft');

    List<Map<String, dynamic>> draftList = [];

    if (drafts != null) {
      for (String draft in drafts) {
        List<String> draftInfo = draft.split(',');
        draftList.add({
          'filePath': draftInfo[0],
          'backImage': draftInfo[1],
          'thumbnailImageFile': draftInfo[2],
          'isGalleryThumbnail': draftInfo[3] == 'true',
        });
      }
    }

    return draftList;
  }

//   deleting the saved draft post

  Future<void> deleteDraft(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? drafts = prefs.getStringList('draft');

    if (drafts != null) {
      drafts.removeWhere((draft) => draft.startsWith(filePath));
      await prefs.setStringList('draft', drafts);
    }
  }
}
