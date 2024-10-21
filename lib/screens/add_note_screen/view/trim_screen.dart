import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:uuid/uuid.dart';
// import 'package:video_compress_plus/video_compress_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path/path.dart' as path;
// import 'package:light_compressor/light_compressor.dart';
import 'package:video_compress/video_compress.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  final String videoName;

  //  getting video path to trim

  TrimmerView(this.file, this.videoName);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  //  creating the instance of trimmer

  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;
  String? _value;
  // var _flutterFFmpeg = FlutterFFmpeg();

  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    await _trimmer
        .saveTrimmedVideo(
            startValue: _startValue,
            endValue: _endValue,
            customVideoFormat: '.mp4',
            onSave: (outputPath) async {
              var pexelPro =
                  Provider.of<PexelsProvider>(context, listen: false);
              var notePro = Provider.of<NoteProvider>(context, listen: false);
              notePro.setIsGalleryVideo(true);

              navPop(context);
              navPop(context);
              notePro.setIsLoading(true);
              log('video path is $outputPath');

              String url = await AddNoteController()
                  .uploadFile('backgroundVideos', File(outputPath!), context);
              notePro.setFileType('video');
              notePro.setSelectedImage(url);
              pexelPro.setIsLoading(false);
              pexelPro.setEditedVideoNull();
              notePro.setIsLoading(false);
            })
        .then((value) {
      setState(() {
        _progressVisibility = false;
      });
    });
  }

  Future<String> getOutputPath() async {
    final appDirectory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final externalPath = '${appDirectory?.path}/${const Uuid().v4()}.mp4';
    return externalPath;
  }

//  this function loads the video before to trim it

  void _loadVideo() async {
    //  before loading the video we need to compress

    //  compressing the video with the video compression package

    File originalFile = widget.file;
    int originalFileSize = await originalFile.length();
    double originalFileSizeMB = originalFileSize / (1024 * 1024);
    log('Original video size: $originalFileSizeMB MB');

    if (originalFileSize > 500 * 1024) {
      // 500KB in bytes
      try {
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          widget.file.path,
          quality: VideoQuality.Res960x540Quality,
          deleteOrigin: false,
        );

        if (mediaInfo != null && mediaInfo.file != null) {
          File compressedFile = mediaInfo.file!;
          int compressedFileSize = await compressedFile.length();
          log('Compressed video size: ${compressedFileSize / (1024 * 1024)} MB');
          _trimmer.loadVideo(videoFile: compressedFile);
        } else {
          log('Compression failed, using original file');

          // after compressing done just load the compress file

          _trimmer.loadVideo(videoFile: originalFile);
        }
      } catch (e) {
        log('Error during compression: $e');
        log('Using original file due to compression error');
        _trimmer.loadVideo(videoFile: originalFile);
      }
    } else {
      log('File size is 500KB or less, skipping compression');
      _trimmer.loadVideo(videoFile: originalFile);
    }
  }

  @override
  void initState() {
    super.initState();

//   calling it in init state so that it loads when the user see the screen

    _loadVideo();
  }

  @override
  void dispose() {
    // disposing it when we no longer needs it

    _trimmer.videoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text("Video Trimmer"),
      // ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(whiteColor),
                      ),
                      onPressed: () {
                        Provider.of<PexelsProvider>(context, listen: false)
                            .setEditedVideoNull();
                        navPop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: khulaRegular, color: blackColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(whiteColor),
                        ),
                        onPressed: _progressVisibility
                            ? null
                            : () async {
                                // Calling the save video function to trim the video

                                _saveVideo().then((outputPath) {});
                              },
                        child: Consumer<NoteProvider>(
                            builder: (context, pexelPro, _) {
                          //  showing the loader while the video is trimming

                          return pexelPro.isLoading
                              ? SpinKitThreeBounce(
                                  color: blackColor,
                                  size: 13,
                                )
                              : Text(
                                  "Confirm",
                                  style: TextStyle(
                                      fontFamily: khulaRegular,
                                      color: blackColor),
                                );
                        }),
                      ),
                    ),
                  ],
                ),

                //  widget to show the trimmer design its prebuilt widget of trimmer package

                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 10),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                    areaProperties:
                        const TrimAreaProperties(thumbnailFit: BoxFit.fitWidth),
                  ),
                ),

                // button to play or pause the video

                TextButton(
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
