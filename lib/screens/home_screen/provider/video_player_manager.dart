import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();

  factory VideoCacheManager() {
    return _instance;
  }

  VideoCacheManager._internal();

  Future<File> getCachedVideoFile(String url) async {
    final File file = await _getLocalFile(url);
    if (await file.exists()) {
      return file;
    } else {
      return await _downloadAndCacheVideo(url, file);
    }
  }

  Future<File> _getLocalFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = _generateFilename(url);
    return File('${directory.path}/$filename');
  }

  String _generateFilename(String url) {
    final hash = md5.convert(utf8.encode(url)).toString();
    return '$hash.mp4';
  }

  Future<File> _downloadAndCacheVideo(String url, File file) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download video: ${response.statusCode}');
    }
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';
// import 'dart:convert';

// class GlobalVideoPlayerManager {
//   static final GlobalVideoPlayerManager _instance =
//       GlobalVideoPlayerManager._internal();

//   factory GlobalVideoPlayerManager() {
//     return _instance;
//   }

//   GlobalVideoPlayerManager._internal();

//   final Map<String, VideoPlayerController> _controllers = {};

//   Future<VideoPlayerController> getController(String url) async {
//     if (!_controllers.containsKey(url)) {
//       final File videoFile = await _getCachedVideoFile(url);

//       VideoPlayerController controller;
//       if (await videoFile.exists()) {
//         controller = VideoPlayerController.file(
//           videoFile,
//           videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//         );
//       } else {
//         await _downloadAndCacheVideo(url, videoFile);
//         controller = VideoPlayerController.file(
//           videoFile,
//           videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//         );
//       }

//       await controller.initialize();
//       controller.play();
//       controller.setLooping(true);
//       controller.setVolume(0.0);
//       _controllers[url] = controller;
//     }
//     return _controllers[url]!;
//   }

//   Future<File> _getCachedVideoFile(String url) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final filename = _generateFilename(url);
//     return File('${directory.path}/$filename');
//   }

//   String _generateFilename(String url) {
//     final hash = md5.convert(utf8.encode(url)).toString();
//     return '$hash.mp4';
//   }

//   Future<void> _downloadAndCacheVideo(String url, File file) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       await file.writeAsBytes(response.bodyBytes);
//     } else {
//       throw Exception('Failed to download video: ${response.statusCode}');
//     }
//   }

//   void releaseController(String url) {
//     final controller = _controllers.remove(url);
//     if (controller != null) {
//       controller.dispose();
//     }
//   }

//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     _controllers.clear();
//   }
// }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';
// import 'dart:convert';

// class VideoPlayerManager extends ChangeNotifier {
//   final Map<String, VideoPlayerController> _controllers = {};

//   Future<VideoPlayerController> getController(String url) async {
//     if (!_controllers.containsKey(url)) {
//       final File videoFile = await _getCachedVideoFile(url);

//       VideoPlayerController controller;
//       if (await videoFile.exists()) {
//         controller = VideoPlayerController.file(videoFile,
//             videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
//       } else {
//         await _downloadAndCacheVideo(url, videoFile);
//         controller = VideoPlayerController.file(videoFile,
//             videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
//       }

//       await controller.initialize();
//       controller.play();
//       controller.setLooping(true);
//       controller.setVolume(0.0);
//       _controllers[url] = controller;
//     }
//     return _controllers[url]!;
//   }

//   Future<File> _getCachedVideoFile(String url) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final filename = _generateFilename(url);
//     return File('${directory.path}/$filename');
//   }

//   String _generateFilename(String url) {
//     final hash = md5.convert(utf8.encode(url)).toString();
//     return '$hash.mp4';
//   }

//   Future<void> _downloadAndCacheVideo(String url, File file) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       await file.writeAsBytes(response.bodyBytes);
//     } else {
//       throw Exception('Failed to download video: ${response.statusCode}');
//     }
//   }

//   void releaseController(String url) {
//     final controller = _controllers.remove(url);
//     if (controller != null) {
//       controller.dispose();
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     _controllers.clear();
//     super.dispose();
//   }
// }