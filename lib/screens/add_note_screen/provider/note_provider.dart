import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
// import 'package:record/record.dart';
import 'package:social_notes/screens/home_screen/model/sub_comment_model.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';

class NoteProvider with ChangeNotifier {
  bool isSearchingUser = false;
  List<UserModel> searchedUsers = [];
  bool isLoading = false;
  bool isSending = false;
  bool isReplying = false;
  bool isSubCommentReplying = false;
  SubCommentModel? subCommentModel;
  List<double> waveformData = [];

  setWaveFormData(List<double> waveform) {
    waveformData = waveform;
    notifyListeners();
  }

  // RecorderState _recorderState = RecorderState.stopped;
  // final StreamController<RecorderState> _recorderStateController =
  //     StreamController.broadcast();
  String directoryPath = '';
  final FlutterSoundRecord recorder = FlutterSoundRecord();

  setDirectoryPath(String path) {
    directoryPath = path;
    notifyListeners();
  }

  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  setIsReplying(bool value) {
    isReplying = value;
    notifyListeners();
  }

  setSubCOmmentReplying(bool value) {
    isSubCommentReplying = value;
  }

  setSubComment(SubCommentModel subComment) {
    subCommentModel = subComment;
    notifyListeners();
  }

  // path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES);

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

  File? voiceNote;
  File? commentNoteFile;
  File? subCommentNoteFile;
  CommentModel? commentModel;
  // bool isRecorderReady = false;
  // final recoder = FlutterSoundRecorder();

  // RecorderController controller = RecorderController();
  bool isRecording = false;
  bool isCancellingReply = false; // New property to track cancel reply state

  List<UserModel> tags = [];

  addTag(UserModel user) {
    tags.add(user);
    notifyListeners();
  }

  setCommentNoteFile(File file) {
    commentNoteFile = file;
    notifyListeners();
  }

  setSubCommentNoteFile(File file) {
    subCommentNoteFile = file;
    notifyListeners();
  }

  setCommentModel(CommentModel model) {
    commentModel = model;
    notifyListeners();
  }

  removeTag(UserModel user) {
    tags.remove(user);
    notifyListeners();
  }

  setVoiceNote(File file) async {
    // String path = await removeNoise(file.path);
    voiceNote = file;
    notifyListeners();
  }

  removeVoiceNote() {
    voiceNote = null;
    notifyListeners();
  }

  setRecording(bool value) {
    isRecording = value;
    notifyListeners();
  }

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

  Future<void> _initRecorder({
    String? path,
  }) async {
    final initialized = await AudioWaveformsInterface.instance.initRecorder(
      path: path,
      encoder: 3,
      outputFormat: 2,
      sampleRate: 44100,
      bitRate: 128000,
    );
    if (initialized) {
      log('Recorder initialized');
      // _setRecorderState(RecorderState.initialized);
    } else {
      throw "Failed to initialize recorder";
    }
    notifyListeners();
  }

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
      // if (await recorder.hasPermission()) {
      //   setRecording(true);
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // String appDocPath = appDocDir.path;
      // path = '$appDocPath/$id.flac';
      //   // await recorder.start(
      //   //   // const RecordConfig(
      //   //   //   echoCancel: true,
      //   //   //   noiseSuppress: true,
      //   //   //   bitRate: 128000,
      //   //   //   sampleRate: 44100,
      //   //   //   numChannels: 2,
      //   //   // ),
      //   //   path: path,
      //   // );
      // }
    }
  }

  commentStop() async {
    setRecording(false);
    final path = await recorder.stop();
    // notifyListeners();
    setCommentNoteFile(File(path!));
  }

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
      // if (await recorder.hasPermission()) {
      //   setRecording(true);
      //   Directory appDocDir = await getApplicationDocumentsDirectory();
      //   String appDocPath = appDocDir.path;
      //   path = '$appDocPath/$id.flac';
      //   await recorder.start(
      //     // const RecordConfig(
      //     //   echoCancel: true,
      //     //   noiseSuppress: true,
      //     //   bitRate: 128000,
      //     //   sampleRate: 44100,
      //     //   numChannels: 2,
      //     // ),
      //     path: path,
      //   );
      // }
    }
  }

  subCommentStop() async {
    setRecording(false);
    final path = await recorder.stop();
    // notifyListeners();
    setSubCommentNoteFile(File(path!));
  }

  removeSubCommentNote() {
    subCommentNoteFile = null;
    notifyListeners();
  }

  removeCommentNote() {
    commentNoteFile = null;
    notifyListeners();
  }

  removeCommentModel() {
    commentModel = null;
    notifyListeners();
  }

  removeSubCommentModel() {
    subCommentModel = null;
    notifyListeners();
  }

  startRecording() async {
    String? path;
    var id = const Uuid().v4();

    // if (await Permission.microphone.request().isGranted) {
    //   if (await recorder.hasPermission()) {
    //     isRecording = true;
    //     Directory appDocDir = await getApplicationDocumentsDirectory();
    //     String appDocPath = appDocDir.path;
    //     path = '$appDocPath/$id.flac';
    //     await recorder.start(
    //       // const RecordConfig(
    //       //   echoCancel: true,
    //       //   noiseSuppress: true,
    //       // ),
    //       path: path,
    //     );
    //   }
    // }
  }

  Future record() async {
    String? path;
    var id = const Uuid().v4();

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
        // notifyListeners();
      }
      //   if (await recorder.hasPermission()) {
      //     setRecording(true);
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // String appDocPath = appDocDir.path;
      // path = '$appDocPath/$id.flac';
      //     await recorder.start(
      //       // const RecordConfig(
      //       //   echoCancel: true,
      //       //   noiseSuppress: true,
      //       //   bitRate: 128000,
      //       //   sampleRate: 44100,
      //       //   numChannels: 2,
      //       // ),
      //       path: path,
      //     );
      //   }
    }
    // if (!await recorder.hasPermission()) return;
    // setRecording(true);
    // await recorder.start(
    //     // const RecordConfig(
    //     //   echoCancel: true,
    //     //   noiseSuppress: true,
    //     // ),
    //     path: 'audio');
  }

  Future stop() async {
    setRecording(false);
    final path = await recorder.stop();
    // controller.refresh(); // Refresh waveform to original position
    // controller.dispose();
    // notifyListeners();

    // final path = await recorder.stop();

    setVoiceNote(File(path!));
  }

  cancelReply() {
    // Remove the voice note and set cancelling reply to false
    removeVoiceNote();
    setCancellingReply(false);
  }

  setSearching(bool value) {
    isSearchingUser = value;
    notifyListeners();
  }

  static const MethodChannel _channel = MethodChannel('noise_removal');

  static Future<String> removeNoise(String audioFilePath) async {
    try {
      final String result =
          await _channel.invokeMethod('removeNoise', audioFilePath);

      return result;
    } on PlatformException catch (e) {
      return "Error: '${e.message}'.";
    }
  }
}
