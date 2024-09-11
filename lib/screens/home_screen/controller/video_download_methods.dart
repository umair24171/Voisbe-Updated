import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class VideoDownloadMethods {
  Future<void> downloadPostWithLogo({
    required String videoUrl,
    required String audioUrl,
    required String logoVideoPath,
    required String logo2AssetPath,
    required String username,
    required String outputFileName,
    required bool isVerified,
    String? backgroundVideoUrl,
    String? backgroundPhotoUrl,
    required bool hasBackgroundVideo,
    required bool hasBackgroundPhoto,
  }) async {
    // Request storage permission
    if (!await Permission.storage.request().isGranted) {
      log('Storage permission not granted');
      return;
    }

    // Download video and audio files

    final audioFile = await _downloadFile(audioUrl, '${const Uuid().v4()}.mp3');

    if (audioFile == null) {
      log('Error downloading video or audio');
      return;
    }

    // Download background video or photo if provided
    File? backgroundFile;
    String? backgroundType;
    if (hasBackgroundVideo && backgroundVideoUrl != null) {
      backgroundFile = await _downloadFile(
          backgroundVideoUrl, '${const Uuid().v4()}_bg.mp4');
      backgroundType = 'video';
    } else if (hasBackgroundPhoto && backgroundPhotoUrl != null) {
      backgroundFile = await _downloadFile(
          backgroundPhotoUrl, '${const Uuid().v4()}_bg.jpg');
      backgroundType = 'photo';
    }

    // Create the output path in a temporary directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final outputPath = '${appDocDir.path}/output_video.mp4';

    // Copy logo assets to files and verify their existence
    final logoVideoFile =
        await _copyAndVerifyAssetFile(logoVideoPath, 'logo1.mp4');
    final logo2File =
        await _copyAndVerifyAssetFile(logo2AssetPath, 'logo2.png');
    if (logoVideoFile == null || logo2File == null) {
      log('Error copying or verifying logo assets');
      return;
    }

    // Create username image
    final usernameImagePath = await createUsernameImage(username, isVerified);
    if (usernameImagePath == null) {
      log('Error creating username image');
      return;
    }

    final audioDuration = await _getAudioDuration(audioFile.path);
    log('Audio duration: $audioDuration seconds');

    // Use the audio duration as the total video duration
    final totalDuration = audioDuration > 0 ? audioDuration : 10.0;

    // Prepare FFmpeg command
    String ffmpegCommand = '';
    if (backgroundFile != null) {
      if (backgroundType == 'video') {
        final videoFile =
            await _downloadFile(videoUrl, '${const Uuid().v4()}.mp4');
        ffmpegCommand = '''
-y -stream_loop -1 -i "${backgroundFile.path}" -stream_loop -1 -i "${videoFile!.path}" -i "${audioFile.path}" -stream_loop -1 -i "${logoVideoFile.path}" -i "${usernameImagePath}" -i "${logo2File.path}"
-filter_complex "
[0:v]scale=720:1280,setsar=1:1,trim=duration=$totalDuration[bg];
[1:v]scale=720:1280,setsar=1:1,trim=duration=$totalDuration[fg];
[bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
[3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
[v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
[5:v]scale=iw*1.5:-1[biggerlogo2];
[v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -shortest "${outputPath}"
''';
      } else if (backgroundType == 'photo') {
        final videoFile =
            await _downloadFile(videoUrl, '${const Uuid().v4()}.mp4');
        ffmpegCommand = '''
-y -loop 1 -i "${backgroundFile.path}" -stream_loop -1 -i "${videoFile!.path}" -i "${audioFile.path}" -stream_loop -1 -i "${logoVideoFile.path}" -i "${usernameImagePath}" -i "${logo2File.path}"
-filter_complex "
[0:v]scale=720:1280,setsar=1:1,trim=duration=$totalDuration[bg];
[1:v]scale=720:1280,setsar=1:1,trim=duration=$totalDuration[fg];
[bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
[3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
[v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
[5:v]scale=iw*1.5:-1[biggerlogo2];
[v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $totalDuration "${outputPath}"
''';
      }
    } else {
      // Use solid color background
      // Use solid color background
      ffmpegCommand = '''
-y -f lavfi -i color=c=#ed6a5a:s=720x1280:d=$totalDuration -i "${audioFile.path}" -stream_loop -1 -i "${logoVideoFile.path}" -i "${usernameImagePath}" -i "${logo2File.path}"
-filter_complex "
[0:v]setsar=1:1[bg];
[2:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[bg][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v1];
[v1][3:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v2];
[4:v]scale=iw*1.5:-1[biggerlogo2];
[v2][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 1:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $totalDuration "${outputPath}""
''';
    }

    ffmpegCommand = ffmpegCommand.replaceAll('\n', ' ').trim();
    // Log the exact command
    log('FFmpeg command: $ffmpegCommand');

    try {
      log('Executing FFmpeg command');
      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        log('Video processing completed successfully');
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          log('Output file exists: ${outputFile.path}');

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final uniqueFileName = '${outputFileName}_$timestamp.mp4';

          // Save the video to the gallery using SaverGallery
          try {
            final result = await SaverGallery.saveFile(
              file: outputPath,
              androidExistNotSave: true,
              name: uniqueFileName,
              androidRelativePath: "Movies/Voisbe",
            );
            if (result.isSuccess) {
              log('Video saved to gallery successfully');
            } else {
              log('Failed to save video to gallery');
              throw Exception('SaverGallery returned false or null');
            }
          } catch (e) {
            log('Error saving video to gallery: $e');
            // Fallback: Copy the file to the Downloads directory
            final downloadsDir = Directory('/storage/emulated/0/Download');
            final savedFilePath = '${downloadsDir.path}/$uniqueFileName';
            await outputFile.copy(savedFilePath);
            log('Video copied to Downloads directory: $savedFilePath');
          }

          // Delete the temporary output file
          await outputFile.delete();
          log('Temporary output file deleted');
        } else {
          log('Output file does not exist');
        }
      } else if (ReturnCode.isCancel(returnCode)) {
        log('Video processing was cancelled');
      } else {
        log('Video processing failed. Please check the logs for more details');
        final logs = await session.getAllLogs();
        logs.forEach((logMessage) => log(logMessage.getMessage()));
      }
    } catch (e) {
      log('Error during FFmpeg execution: $e');
    }

    log('Download and logo overlay process completed. Check the output at $outputPath');
  }

//   Future<void> downloadPostWithLogo(
//       {required String videoUrl,
//       required String audioUrl,
//       required String logoVideoPath,
//       required String logo2AssetPath,
//       required String username,
//       required String outputFileName,
//       required bool isVerified}) async {
//     // Request storage permission
//     if (!await Permission.storage.request().isGranted) {
//       log('Storage permission not granted');
//       return;
//     }

//     // Download video and audio files
//     final videoFile = await _downloadFile(videoUrl, '${const Uuid().v4()}.mp4');
//     final audioFile = await _downloadFile(audioUrl, '${const Uuid().v4()}.mp3');

//     if (videoFile == null || audioFile == null) {
//       log('Error downloading video or audio');
//       return;
//     }

//     // Create the output path in a temporary directory
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final outputPath = '${appDocDir.path}/output_video.mp4';

//     // Copy logo assets to files and verify their existence
//     final logoVideoFile =
//         await _copyAndVerifyAssetFile(logoVideoPath, 'logo1.mp4');
//     final logo2File =
//         await _copyAndVerifyAssetFile(logo2AssetPath, 'logo2.png');
//     if (logoVideoFile == null || logo2File == null) {
//       log('Error copying or verifying logo assets');
//       return;
//     }

//     // Create username image
//     final usernameImagePath = await createUsernameImage(username, isVerified);
//     if (usernameImagePath == null) {
//       log('Error creating username image');
//       return;
//     }

//     // Get audio duration
//     final audioDuration = await _getAudioDuration(audioFile.path);
//     log('Audio duration: $audioDuration seconds');

//     // Use a default duration if audio duration extraction fails
//     final effectiveDuration = audioDuration > 0 ? audioDuration : 10.0;

//     // Prepare FFmpeg command
//     final String ffmpegCommand = '''
// -y -stream_loop -1 -i "${videoFile.path}" -i "${audioFile.path}" -stream_loop -1 -i "${logoVideoFile.path}" -i "${usernameImagePath}" -i "${logo2File.path}"
// -filter_complex "
// [0:v]loop=loop=-1:size=32767:start=0,setpts=N/FRAME_RATE/TB[loopedvideo];
// [2:v]scale=iw/2:-1,
//     colorkey=0x000000:0.1:0.2,
//     colorkey=0x000000:0.3:0.1,
//     colorkey=0x000000:0.5:0.0[transparentlogo];
// [loopedvideo][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:shortest=1[v1];
// [v1][3:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v2];
// [4:v]scale=iw*1.5:-1[biggerlogo2];
// [v2][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
// "
// -map "[outv]" -map 1:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -shortest -t $effectiveDuration "${outputPath}"
// '''
//         .replaceAll('\n', ' ')
//         .trim();
//     // Log the exact command
//     log('FFmpeg command: $ffmpegCommand');

//     try {
//       log('Executing FFmpeg command');
//       final session = await FFmpegKit.execute(ffmpegCommand);
//       final returnCode = await session.getReturnCode();

//       if (ReturnCode.isSuccess(returnCode)) {
//         log('Video processing completed successfully');
//         final outputFile = File(outputPath);
//         if (await outputFile.exists()) {
//           log('Output file exists: ${outputFile.path}');

//           // Save the video to the gallery using saver_gallery
  // final result = await SaverGallery.saveFile(
  //   file: outputPath,
  //   androidExistNotSave: true,
  //   name: '$outputFileName.mp4',
  //   androidRelativePath: "Movies/Voisbe",
  // );
//           log('Video saved to gallery: $result');
//         } else {
//           log('Output file does not exist');
//         }
//       } else if (ReturnCode.isCancel(returnCode)) {
//         log('Video processing was cancelled');
//       } else {
//         log('Video processing failed. Please check the logs for more details');
//         final logs = await session.getAllLogs();
//         logs.forEach((logMessage) => log(logMessage.getMessage()));
//       }
//     } catch (e) {
//       log('Error during FFmpeg execution: $e');
//     }

//     log('Download and logo overlay process completed. Check the output at $outputPath');
//   }

  Future<File?> _copyAndVerifyAssetFile(
      String assetPath, String fileName) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer;
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      // Verify file was created successfully
      if (await file.exists()) {
        log('Successfully copied and verified asset file: $filePath');
        return file;
      } else {
        log('Failed to create or verify file: $filePath');
        return null;
      }
    } catch (e) {
      log('Error copying or verifying asset file: $e');
      return null;
    }
  }

  Future<bool> _verifyAllFilesExist(List<String> filePaths) async {
    for (final path in filePaths) {
      final file = File(path);
      if (!await file.exists()) {
        log('File does not exist: $path');
        return false;
      }
      log('File exists: $path');
    }
    return true;
  }

  Future<void> _checkFilePermissions(List<String> filePaths) async {
    for (final path in filePaths) {
      final file = File(path);
      try {
        final stat = await file.stat();
        log('File permissions for $path: ${stat.modeString()}');
      } catch (e) {
        log('Error checking file permissions for $path: $e');
      }
    }
  }

  Future<File?> _downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final downloadedFile = File(filePath);
        await downloadedFile.writeAsBytes(response.bodyBytes);
        return downloadedFile;
      } else {
        log('Error: Failed to download file. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error downloading file: $e');
      return null;
    }
  }

  Future<String?> createUsernameImage(String username, bool isVerified) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(300, 70);
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    String displayUsername =
        username.length > 30 ? '${username.substring(0, 27)}...' : username;

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayUsername,
        style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontFamily: khulaRegular,
            fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    double totalWidth = textPainter.width;
    double iconSize = 16;
    if (isVerified) {
      totalWidth += iconSize + 4; // Icon size + padding
    }

    double startX = (size.width - totalWidth) / 2;

    // Draw the username
    textPainter.paint(
        canvas, Offset(startX, (size.height - textPainter.height) / 2));

    // If verified, draw the verified icon
    if (isVerified) {
      final iconPosition = Offset(startX + textPainter.width + 4,
          (size.height - iconSize) / 2 - 2 // Moved up by 2 pixels
          );
      await _drawSvgIcon(canvas, iconPosition, iconSize);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/username.png');
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return file.path;
    }
    return null;
  }

  Future<void> _drawSvgIcon(Canvas canvas, Offset position, double size) async {
    const String verifiedPath = 'assets/icons/verified (1).svg';
    final svgString = await rootBundle.loadString(verifiedPath);
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    final matrix = Matrix4.identity()
      ..translate(position.dx, position.dy)
      ..scale(size / pictureInfo.size.width);

    canvas.save();
    canvas.transform(matrix.storage);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
  }

  Future<double> _getAudioDuration(String audioPath) async {
    try {
      log('Attempting to get duration for audio file: $audioPath');
      final session = await FFprobeKit.getMediaInformation(audioPath);
      final information = session.getMediaInformation();

      if (information != null) {
        final duration = information.getDuration();
        log('Raw FFprobe duration output: $duration');

        if (duration != null && duration.isNotEmpty) {
          final durationSeconds = double.parse(duration);
          log('Parsed duration: $durationSeconds seconds');
          return durationSeconds;
        }
      }

      log('Unable to extract duration from FFprobe output');
      return 0.0;
    } catch (e) {
      log('Error getting audio duration: $e');
      return 0.0;
    }
  }
}
