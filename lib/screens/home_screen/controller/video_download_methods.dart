import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:social_notes/main.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class VideoDownloadMethods {
  static SnackBar? _currentSnackBar;

  static void showProgressSnackBar(Stream<double> progressStream) {
    final broadcastStream = progressStream.asBroadcastStream();
    _currentSnackBar = SnackBar(
      padding: const EdgeInsets.all(0),
      backgroundColor: const Color(0xffdbdbdb),
      content: StreamBuilder<double>(
        stream: broadcastStream,
        builder: (context, snapshot) {
          final progress = snapshot.data ?? 0.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: progress,
                color: const Color(0xffec6b56),
              ),
            ],
          );
        },
      ),
      duration: const Duration(days: 1),
    );
    _showSnackBar();
  }

  static void hideSnackBar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _currentSnackBar = null;
  }

  static void showCompletionSnackBar() {
    showWhiteOverlayPopup(
        navigatorKey.currentState!.context, Icons.check_box, null, null,
        title: 'Successful',
        message: 'Post downloaded successfully.',
        isUsernameRes: false);
  }

  static void _showSnackBar() {
    if (_currentSnackBar != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(_currentSnackBar!);
    }
  }

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
    final progressController = StreamController<double>.broadcast();
    bool isCompleted = false;
    bool isCancelled = false;

    VideoDownloadMethods.showProgressSnackBar(
        progressController.stream.asBroadcastStream());

    try {
      if (!await _requestPermissions()) {
        print('Required permissions not granted');
        return;
      }

      int totalSteps = 3; // Base steps: audio, processing, saving
      if (hasBackgroundVideo || hasBackgroundPhoto) totalSteps++;
      if (backgroundVideoUrl != null || backgroundPhotoUrl != null)
        totalSteps++;

      int currentStep = 0;

      final receivePort = ReceivePort();
      receivePort.listen((progress) {
        if (progress is double) {
          double overallProgress = (currentStep + progress) / totalSteps;
          progressController.add(overallProgress.clamp(0.0, 0.99));
        }
      });

      // Use Isolate.spawn for background processing
      final audioFile = await _spawnIsolate(
        _downloadFileWithProgress,
        DownloadParams(
          url: audioUrl,
          fileName: '${const Uuid().v4()}.mp3',
          progressPort: receivePort.sendPort,
        ),
      );
      if (audioFile == null || isCancelled) {
        print('Error downloading audio or cancelled');
        return;
      }
      currentStep++;

      File? backgroundFile;
      String? backgroundType;
      if (hasBackgroundVideo && backgroundVideoUrl != null) {
        backgroundFile = await _spawnIsolate(
          _downloadFileWithProgress,
          DownloadParams(
              url: backgroundVideoUrl,
              fileName: '${const Uuid().v4()}_bg.mp4',
              progressPort: receivePort.sendPort
              // updateProgress: updateProgress,
              // isCancelled: isCancelled,
              ),
        );
        backgroundType = 'video';
      } else if (hasBackgroundPhoto && backgroundPhotoUrl != null) {
        backgroundFile = await _spawnIsolate(
          _downloadFileWithProgress,
          DownloadParams(
              url: backgroundPhotoUrl,
              fileName: '${const Uuid().v4()}_bg.jpg',
              progressPort: receivePort.sendPort
              // updateProgress: updateProgress,
              // isCancelled: isCancelled,
              ),
        );
        backgroundType = 'photo';
      }
      if (backgroundFile != null) currentStep++;

      final outputPath = await _getTemporaryFilePath('output_video.mp4');

      final logoVideoFile =
          await _copyAndVerifyAssetFile(logoVideoPath, 'logo1.mp4');
      final logo2File =
          await _copyAndVerifyAssetFile(logo2AssetPath, 'logo2.png');
      if (logoVideoFile == null || logo2File == null) {
        print('Error copying or verifying logo assets');
        return;
      }

      final usernameImagePath = await createUsernameImage(username, isVerified);
      if (usernameImagePath == null) {
        print('Error creating username image');
        return;
      }

      final audioDuration = await _getAudioDuration(audioFile.path);
      print('Audio duration: $audioDuration seconds');

      final totalDuration = audioDuration > 0 ? audioDuration : 10.0;

      String ffmpegCommand = '';
      if (backgroundFile != null) {
        if (backgroundType == 'video') {
          final videoFile = await _spawnIsolate(
            _downloadFileWithProgress,
            DownloadParams(
              progressPort: receivePort.sendPort,
              url: videoUrl,
              fileName: '${const Uuid().v4()}.mp4',
              // updateProgress: updateProgress,
              // isCancelled: isCancelled,
            ),
          );
          if (videoFile == null) {
            print('Error downloading video file');
            return;
          }
          ffmpegCommand = _buildFFmpegCommandForVideoBackground(
            backgroundFile.path,
            videoFile.path,
            audioFile.path,
            logoVideoFile.path,
            usernameImagePath,
            logo2File.path,
            totalDuration,
            outputPath,
          );
        } else if (backgroundType == 'photo') {
          final videoFile = await _spawnIsolate(
            _downloadFileWithProgress,
            DownloadParams(
                url: videoUrl,
                fileName: '${const Uuid().v4()}.mp4',
                // updateProgress: updateProgress,
                // isCancelled: isCancelled,
                progressPort: receivePort.sendPort),
          );
          if (videoFile == null) {
            print('Error downloading video file');
            return;
          }
          ffmpegCommand = _buildFFmpegCommandForPhotoBackground(
            backgroundFile.path,
            videoFile.path,
            audioFile.path,
            logoVideoFile.path,
            usernameImagePath,
            logo2File.path,
            totalDuration,
            outputPath,
          );
        }
      } else {
        ffmpegCommand = _buildFFmpegCommandForSolidBackground(
          audioFile.path,
          logoVideoFile.path,
          usernameImagePath,
          logo2File.path,
          totalDuration,
          outputPath,
        );
      }

      ffmpegCommand = ffmpegCommand.replaceAll('\n', ' ').trim();
      print('FFmpeg command: $ffmpegCommand');

      final completer = Completer<void>();

      final session = await FFmpegKit.executeAsync(
        ffmpegCommand,
        (Session session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode) && !isCancelled) {
            print('Video processing completed successfully');
            final outputFile = File(outputPath);
            if (await outputFile.exists()) {
              print('Output file exists: ${outputFile.path}');

              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final uniqueFileName = '${outputFileName}_$timestamp.mp4';

              try {
                final savedPath = await _spawnIsolate(
                  _saveVideoToGallery,
                  SaveVideoParams(
                    videoFile: outputFile,
                    fileName: uniqueFileName,
                  ),
                );
                if (savedPath != null) {
                  print('Video saved to gallery successfully: $savedPath');
                } else {
                  throw Exception('Failed to save video to gallery');
                }
              } catch (e) {
                print('Error saving video to gallery: $e');
                // Fallback to saving in Downloads directory
                final downloadsDir = await getExternalStorageDirectory();
                if (downloadsDir != null) {
                  final savedFilePath =
                      path.join(downloadsDir.path, uniqueFileName);
                  await outputFile.copy(savedFilePath);
                  print('Video copied to Downloads directory: $savedFilePath');
                } else {
                  print('Unable to access external storage');
                }
              }

              await outputFile.delete();
              print('Temporary output file deleted');
            }
            VideoDownloadMethods.hideSnackBar();
            VideoDownloadMethods.showCompletionSnackBar();
          } else {
            VideoDownloadMethods.hideSnackBar();
          }

          completer.complete();
        },
        (Log log) {
          print(log.getMessage());
        },
        (Statistics statistics) {
          final timeInMilliseconds = statistics.getTime();
          if (timeInMilliseconds > 0 && !isCompleted && !isCancelled) {
            final progress = timeInMilliseconds / (totalDuration * 1000);
            progressController.add(progress.clamp(0.0, 0.99));
          }
        },
      );

      await completer.future;
    } catch (e) {
      print('Error during download and processing: $e');
      VideoDownloadMethods.hideSnackBar();
    } finally {
      VideoDownloadMethods.hideSnackBar();
      isCompleted = true;
      if (!progressController.isClosed) {
        await progressController.close();
      }
    }
  }

// Helper method to spawn isolate
  Future<T> _spawnIsolate<T, P>(
      Future<T> Function(P) function, P params) async {
    final receivePort = ReceivePort();
    final token = RootIsolateToken.instance!;
    await Isolate.spawn<_IsolateParams<P>>(
      _isolateWrapper,
      _IsolateParams(function, params, receivePort.sendPort, token),
    );
    return await receivePort.first as T;
  }

// Wrapper function for isolate
  void _isolateWrapper<P>(_IsolateParams<P> params) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);
    final result = await params.function(params.params);
    params.sendPort.send(result);
  }
  // Future<void> downloadPostWithLogo({
  //   required String videoUrl,
  //   required String audioUrl,
  //   required String logoVideoPath,
  //   required String logo2AssetPath,
  //   required String username,
  //   required String outputFileName,
  //   required bool isVerified,
  //   String? backgroundVideoUrl,
  //   String? backgroundPhotoUrl,
  //   required bool hasBackgroundVideo,
  //   required bool hasBackgroundPhoto,
  // }) async {
  //   final progressController = StreamController<double>();
  //   bool isCompleted = false;
  //   bool isCancelled = false;
  //   bool isProcessing = false;

  //   VideoDownloadMethods.showProgressSnackBar(progressController.stream);

  //   try {
  //     if (!await _requestPermissions()) {
  //       print('Required permissions not granted');
  //       return;
  //     }

  //     int totalSteps = 3; // Base steps: audio, processing, saving
  //     if (hasBackgroundVideo || hasBackgroundPhoto) totalSteps++;
  //     if (backgroundVideoUrl != null || backgroundPhotoUrl != null)
  //       totalSteps++;

  //     int currentStep = 0;

  //     void updateProgress(double stepProgress) {
  //       double overallProgress = (currentStep + stepProgress) / totalSteps;
  //       progressController.add(overallProgress.clamp(0.0, 0.99));
  //     }

  //     final audioFile = await _downloadFileWithProgress(
  //       audioUrl,
  //       '${const Uuid().v4()}.mp3',
  //       (progress) => updateProgress(progress),
  //       () => isCancelled,
  //     );
  //     if (audioFile == null || isCancelled) {
  //       print('Error downloading audio or cancelled');
  //       return;
  //     }
  //     currentStep++;

  //     File? backgroundFile;
  //     String? backgroundType;
  //     if (hasBackgroundVideo && backgroundVideoUrl != null) {
  //       backgroundFile = await _downloadFileWithProgress(
  //         backgroundVideoUrl,
  //         '${const Uuid().v4()}_bg.mp4',
  //         (progress) => updateProgress(progress),
  //         () => isCancelled,
  //       );
  //       backgroundType = 'video';
  //     } else if (hasBackgroundPhoto && backgroundPhotoUrl != null) {
  //       backgroundFile = await _downloadFileWithProgress(
  //         backgroundPhotoUrl,
  //         '${const Uuid().v4()}_bg.jpg',
  //         (progress) => updateProgress(progress),
  //         () => isCancelled,
  //       );
  //       backgroundType = 'photo';
  //     }
  //     if (backgroundFile != null) currentStep++;

  //     final outputPath = await _getTemporaryFilePath('output_video.mp4');

  //     final logoVideoFile =
  //         await _copyAndVerifyAssetFile(logoVideoPath, 'logo1.mp4');
  //     final logo2File =
  //         await _copyAndVerifyAssetFile(logo2AssetPath, 'logo2.png');
  //     if (logoVideoFile == null || logo2File == null) {
  //       print('Error copying or verifying logo assets');
  //       return;
  //     }

  //     final usernameImagePath = await createUsernameImage(username, isVerified);
  //     if (usernameImagePath == null) {
  //       print('Error creating username image');
  //       return;
  //     }

  //     final audioDuration = await _getAudioDuration(audioFile.path);
  //     print('Audio duration: $audioDuration seconds');

  //     final totalDuration = audioDuration > 0 ? audioDuration : 10.0;

  //     String ffmpegCommand = '';
  //     if (backgroundFile != null) {
  //       if (backgroundType == 'video') {
  //         final videoFile = await _downloadFileWithProgress(
  //           videoUrl,
  //           '${const Uuid().v4()}.mp4',
  //           (progress) => updateProgress(progress),
  //           () => isCancelled,
  //         );
  //         if (videoFile == null) {
  //           print('Error downloading video file');
  //           return;
  //         }
  //         ffmpegCommand = _buildFFmpegCommandForVideoBackground(
  //           backgroundFile.path,
  //           videoFile.path,
  //           audioFile.path,
  //           logoVideoFile.path,
  //           usernameImagePath,
  //           logo2File.path,
  //           totalDuration,
  //           outputPath,
  //         );
  //       } else if (backgroundType == 'photo') {
  //         final videoFile = await _downloadFileWithProgress(
  //           videoUrl,
  //           '${const Uuid().v4()}.mp4',
  //           (progress) => updateProgress(progress),
  //           () => isCancelled,
  //         );
  //         if (videoFile == null) {
  //           print('Error downloading video file');
  //           return;
  //         }
  //         ffmpegCommand = _buildFFmpegCommandForPhotoBackground(
  //           backgroundFile.path,
  //           videoFile.path,
  //           audioFile.path,
  //           logoVideoFile.path,
  //           usernameImagePath,
  //           logo2File.path,
  //           totalDuration,
  //           outputPath,
  //         );
  //       }
  //     } else {
  //       ffmpegCommand = _buildFFmpegCommandForSolidBackground(
  //         audioFile.path,
  //         logoVideoFile.path,
  //         usernameImagePath,
  //         logo2File.path,
  //         totalDuration,
  //         outputPath,
  //       );
  //     }

  //     ffmpegCommand = ffmpegCommand.replaceAll('\n', ' ').trim();
  //     print('FFmpeg command: $ffmpegCommand');

  //     isProcessing = true;
  //     final completer = Completer<void>();

  //     final session = await FFmpegKit.executeAsync(
  //       ffmpegCommand,
  //       (Session session) async {
  //         final returnCode = await session.getReturnCode();
  //         isProcessing = false;

  //         if (ReturnCode.isSuccess(returnCode) && !isCancelled) {
  //           print('Video processing completed successfully');
  //           final outputFile = File(outputPath);
  //           if (await outputFile.exists()) {
  //             print('Output file exists: ${outputFile.path}');

  //             final timestamp = DateTime.now().millisecondsSinceEpoch;
  //             final uniqueFileName = '${outputFileName}_$timestamp.mp4';

  //             try {
  //               final savedPath =
  //                   await saveVideoToGallery(outputFile, uniqueFileName);
  //               if (savedPath != null) {
  //                 print('Video saved to gallery successfully: $savedPath');
  //               } else {
  //                 throw Exception('Failed to save video to gallery');
  //               }
  //             } catch (e) {
  //               print('Error saving video to gallery: $e');
  //               // Fallback to saving in Downloads directory
  //               final downloadsDir = await getExternalStorageDirectory();
  //               if (downloadsDir != null) {
  //                 final savedFilePath =
  //                     path.join(downloadsDir.path, uniqueFileName);
  //                 await outputFile.copy(savedFilePath);
  //                 print('Video copied to Downloads directory: $savedFilePath');
  //               } else {
  //                 print('Unable to access external storage');
  //               }
  //             }

  //             await outputFile.delete();
  //             print('Temporary output file deleted');
  //           }
  //           VideoDownloadMethods.hideSnackBar();
  //           VideoDownloadMethods.showCompletionSnackBar();
  //         } else {
  //           VideoDownloadMethods.hideSnackBar();
  //         }

  //         completer.complete();
  //       },
  //       (Log log) {
  //         print(log.getMessage());
  //       },
  //       (Statistics statistics) {
  //         final timeInMilliseconds = statistics.getTime();
  //         if (timeInMilliseconds > 0 && !isCompleted && !isCancelled) {
  //           final progress = timeInMilliseconds / (totalDuration * 1000);
  //           progressController.add(progress.clamp(0.0, 0.99));
  //         }
  //       },
  //     );

  //     await completer.future;
  //   } catch (e) {
  //     print('Error during download and processing: $e');
  //     VideoDownloadMethods.hideSnackBar();
  //   } finally {
  //     VideoDownloadMethods.hideSnackBar();
  //     isCompleted = true;
  //     if (!progressController.isClosed) {
  //       await progressController.close();
  //     }
  //   }
  // }

  Future<String> _getTemporaryFilePath(String fileName) async {
    final directory = await getTemporaryDirectory();
    return path.join(directory.path, fileName);
  }

  // Helper method to run in isolate
  static Future<String?> _saveVideoToGallery(SaveVideoParams params) async {
    if (Platform.isAndroid) {
      if (await _requestPermissions()) {
        try {
          final result = await SaverGallery.saveFile(
            file: params.videoFile.path,
            name: params.fileName,
            androidRelativePath: "Movies/Voisbe",
            androidExistNotSave: true,
          );

          if (result.isSuccess) {
            print('Video saved to gallery successfully');
            return params.videoFile.path;
          } else {
            throw Exception('SaverGallery returned false');
          }
        } catch (e) {
          print('Error saving to gallery: $e');
          // Fallback saving logic here if needed
        }
      } else {
        print('Storage permission not granted');
      }
    } else if (Platform.isIOS) {
      try {
        final result = await SaverGallery.saveFile(
          file: params.videoFile.path,
          name: params.fileName,
          androidRelativePath: "Movies/Voisbe",
          androidExistNotSave: true,
        );

        if (result.isSuccess) {
          print('Video saved to iOS gallery successfully');
          return params.videoFile.path;
        } else {
          throw Exception('SaverGallery returned false for iOS');
        }
      } catch (e) {
        print('Error saving to iOS gallery: $e');
      }
    }
    return null;
  }
  // Future<String?> saveVideoToGallery(File videoFile, String fileName) async {
  //   if (Platform.isAndroid) {
  //     if (await _requestPermissions()) {
  //       try {
  //         // First, try to save using Saver Gallery
  //         final result = await SaverGallery.saveFile(
  //           file: videoFile.path,
  //           name: fileName,
  //           androidRelativePath: "Movies/Voisbe",
  //           androidExistNotSave: true,
  //         );

  //         if (result.isSuccess) {
  //           print('Video saved to gallery successfully');
  //           return videoFile
  //               .path; // Return the original file path as it's now in the gallery
  //         } else {
  //           throw Exception('SaverGallery returned false');
  //         }
  //       } catch (e) {
  //         print('Error saving to gallery: $e');

  //         // If saving with Saver Gallery fails, try saving to the app's external storage
  //         try {
  //           final directory = await getExternalStorageDirectory();
  //           if (directory != null) {
  //             final appDir = Directory('${directory.path}/Voisbe');
  //             if (!await appDir.exists()) {
  //               await appDir.create(recursive: true);
  //             }
  //             final savedFilePath = path.join(appDir.path, fileName);
  //             final savedFile = await videoFile.copy(savedFilePath);

  //             print('Video saved to app directory: ${savedFile.path}');
  //             return savedFile.path;
  //           }
  //         } catch (e) {
  //           print('Error saving to app directory: $e');
  //         }
  //       }
  //     } else {
  //       print('Storage permission not granted');
  //     }
  //   } else if (Platform.isIOS) {
  //     try {
  //       final result = await SaverGallery.saveFile(
  //           file: videoFile.path,
  //           name: fileName,
  //           androidRelativePath: "Movies/Voisbe",
  //           androidExistNotSave: true);

  //       if (result.isSuccess) {
  //         print('Video saved to iOS gallery successfully');
  //         return videoFile.path;
  //       } else {
  //         throw Exception('SaverGallery returned false for iOS');
  //       }
  //     } catch (e) {
  //       print('Error saving to iOS gallery: $e');
  //     }
  //   }
  //   return null;
  // }

  // Updated helper methods to run in isolate
  static Future<File?> _downloadFileWithProgress(DownloadParams params) async {
    try {
      final request = http.Request('GET', Uri.parse(params.url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/${params.fileName}';
        final downloadedFile = File(filePath);

        final totalBytes = response.contentLength ?? 0;
        var downloadedBytes = 0;

        final fileStream = downloadedFile.openWrite();

        await for (final chunk in response.stream) {
          fileStream.add(chunk);
          downloadedBytes += chunk.length;
          final progress = totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
          params.progressPort.send(progress);
        }

        await fileStream.close();
        return downloadedFile;
      } else {
        print(
            'Error: Failed to download file. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
  // Future<File?> _downloadFileWithProgress(
  //   String url,
  //   String fileName,
  //   void Function(double) updateProgress,
  //   bool Function() isCancelled,
  // ) async {
  //   try {
  //     final request = http.Request('GET', Uri.parse(url));
  //     final response = await http.Client().send(request);

  //     if (response.statusCode == 200) {
  //       final directory = await getTemporaryDirectory();
  //       final filePath = '${directory.path}/$fileName';
  //       final downloadedFile = File(filePath);

  //       final totalBytes = response.contentLength ?? 0;
  //       var downloadedBytes = 0;

  //       final fileStream = downloadedFile.openWrite();

  //       await for (final chunk in response.stream) {
  //         if (isCancelled()) {
  //           await fileStream.close();
  //           await downloadedFile.delete();
  //           return null;
  //         }
  //         fileStream.add(chunk);
  //         downloadedBytes += chunk.length;
  //         final progress = totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
  //         updateProgress(progress);
  //       }

  //       await fileStream.close();
  //       return downloadedFile;
  //     } else {
  //       log('Error: Failed to download file. Status code: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     log('Error downloading file: $e');
  //     return null;
  //   }
  // }

  String _buildFFmpegCommandForVideoBackground(
      String backgroundPath,
      String videoPath,
      String audioPath,
      String logoPath,
      String usernamePath,
      String logo2Path,
      double duration,
      String outputPath) {
    return '''
-y -stream_loop -1 -i "${backgroundPath}" -stream_loop -1 -i "${videoPath}" -i "${audioPath}" -stream_loop -1 -i "${logoPath}" -i "${usernamePath}" -i "${logo2Path}"
-filter_complex "
[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,setsar=1:1,trim=duration=$duration[bg];
[1:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,setsar=1:1,trim=duration=$duration[fg];
[bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
[3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
[v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
[5:v]scale=iw*1.5:-1[biggerlogo2];
[v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -shortest "${outputPath}"
''';
  }

  String _buildFFmpegCommandForPhotoBackground(
      String backgroundPath,
      String videoPath,
      String audioPath,
      String logoPath,
      String usernamePath,
      String logo2Path,
      double duration,
      String outputPath) {
    return '''
-y -loop 1 -i "${backgroundPath}" -stream_loop -1 -i "${videoPath}" -i "${audioPath}" -stream_loop -1 -i "${logoPath}" -i "${usernamePath}" -i "${logo2Path}"
-filter_complex "
[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,setsar=1:1,trim=duration=$duration[bg];
[1:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,setsar=1:1,trim=duration=$duration[fg];
[bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
[3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
[v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
[5:v]scale=iw*1.5:-1[biggerlogo2];
[v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $duration "${outputPath}"
''';
  }

// // Helper functions to build FFmpeg commands
//   String _buildFFmpegCommandForVideoBackground(
//       String backgroundPath,
//       String videoPath,
//       String audioPath,
//       String logoPath,
//       String usernamePath,
//       String logo2Path,
//       double duration,
//       String outputPath) {
//     return '''
// -y -stream_loop -1 -i "${backgroundPath}" -stream_loop -1 -i "${videoPath}" -i "${audioPath}" -stream_loop -1 -i "${logoPath}" -i "${usernamePath}" -i "${logo2Path}"
// -filter_complex "
// [0:v]scale=720:1280,setsar=1:1,trim=duration=$duration[bg];
// [1:v]scale=720:1280,setsar=1:1,trim=duration=$duration[fg];
// [bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
// [3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
// [v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
// [v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
// [5:v]scale=iw*1.5:-1[biggerlogo2];
// [v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
// "
// -map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -shortest "${outputPath}"
// ''';
//     // Implement the FFmpeg command for video background
//     // ...
//   }

//   String _buildFFmpegCommandForPhotoBackground(
//       String backgroundPath,
//       String videoPath,
//       String audioPath,
//       String logoPath,
//       String usernamePath,
//       String logo2Path,
//       double duration,
//       String outputPath) {
//     return '''
// -y -loop 1 -i "${backgroundPath}" -stream_loop -1 -i "${videoPath}" -i "${audioPath}" -stream_loop -1 -i "${logoPath}" -i "${usernamePath}" -i "${logoPath}"
// -filter_complex "
// [0:v]scale=720:1280,setsar=1:1,trim=duration=$duration[bg];
// [1:v]scale=720:1280,setsar=1:1,trim=duration=$duration[fg];
// [bg][fg]overlay=(W-w)/2:(H-h)/2[v1];
// [3:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
// [v1][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v2];
// [v2][4:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v3];
// [5:v]scale=iw*1.5:-1[biggerlogo2];
// [v3][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
// "
// -map "[outv]" -map 2:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $duration "${outputPath}"
// ''';
//     // Implement the FFmpeg command for photo background
//     // ...
//   }
  String _buildFFmpegCommandForSolidBackground(
      String audioPath,
      String logoPath,
      String usernamePath,
      String logo2Path,
      double duration,
      String outputPath) {
    return '''
-y -f lavfi -i color=c=#ed6a5a:s=720x1280:d=$duration -i "$audioPath" -stream_loop -1 -i "$logoPath" -i "$usernamePath" -i "$logo2Path"
-filter_complex "
[0:v]setsar=1:1[bg];
[2:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
[bg][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v1];
[v1][3:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v2];
[4:v]scale=iw*1.5:-1[biggerlogo2];
[v2][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
"
-map "[outv]" -map 1:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $duration "$outputPath"
''';
  }

//   String _buildFFmpegCommandForSolidBackground(
//       String audioPath,
//       String logoPath,
//       String usernamePath,
//       String logo2Path,
//       double duration,
//       String outputPath) {
//     return '''
// -y -f lavfi -i color=c=#ed6a5a:s=720x1280:d=$duration -i "${audioPath}" -stream_loop -1 -i "${logoPath}" -i "${usernamePath}" -i "${logoPath}"
// -filter_complex "
// [0:v]setsar=1:1[bg];
// [2:v]scale=iw/2:-1,colorkey=0x000000:0.1:0.2,colorkey=0x000000:0.3:0.1,colorkey=0x000000:0.5:0.0[transparentlogo];
// [bg][transparentlogo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[v1];
// [v1][3:v]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+215[v2];
// [4:v]scale=iw*1.5:-1[biggerlogo2];
// [v2][biggerlogo2]overlay=(main_w-overlay_w)/2:((main_h-overlay_h)/2)+250,format=yuv420p[outv]
// "
// -map "[outv]" -map 1:a -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k -t $duration "${outputPath}"
// ''';
//     // Implement the FFmpeg command for solid background
//     // ...
//   }

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // For Android 13 and above
      if (Platform.isAndroid &&
          await DeviceInfoPlugin()
                  .androidInfo
                  .then((info) => info.version.sdkInt) >=
              33) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        return statuses[Permission.photos]!.isGranted &&
            statuses[Permission.videos]!.isGranted &&
            statuses[Permission.audio]!.isGranted;
      } else {
        // For Android 12 and below
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

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

// Helper classes for isolate parameters
class _IsolateParams<P> {
  final Future<dynamic> Function(P) function;
  final P params;
  final SendPort sendPort;
  final RootIsolateToken token;

  _IsolateParams(this.function, this.params, this.sendPort, this.token);
}

class DownloadParams {
  final String url;
  final String fileName;
  final SendPort progressPort;

  DownloadParams({
    required this.url,
    required this.fileName,
    required this.progressPort,
  });
}

class SaveVideoParams {
  final File videoFile;
  final String fileName;

  SaveVideoParams({
    required this.videoFile,
    required this.fileName,
  });
}
