// import 'dart:async';
// import 'dart:isolate';
// import 'dart:io';
// import 'dart:developer';
// import 'package:path_provider/path_provider.dart';

// class GalleryLoader {
//   Future<List<String>> loadFiles(List<String> dataType) async {
//     return await _runInIsolate(dataType);
//   }

//   Future<List<String>> _runInIsolate(List<String> dataType) async {
//     ReceivePort receivePort = ReceivePort();
//     await Isolate.spawn(_isolateEntry, [receivePort.sendPort, dataType]);

//     SendPort sendPort = await receivePort.first;
//     List<String> files = await _sendReceive(sendPort, 'start');
//     return files;
//   }

//   static Future<void> _isolateEntry(List<dynamic> args) async {
//     SendPort sendPort = args[0];
//     List<String> dataType = args[1];
//     ReceivePort port = ReceivePort();
//     sendPort.send(port.sendPort);

//     await for (var msg in port) {
//       String command = msg[0];
//       SendPort replyPort = msg[1];

//       if (command == 'start') {
//         List<String> files = [];

//         try {
//           if (Platform.isAndroid) {
//             String path = '/storage/emulated/0/';
//             Directory directory = Directory(path);
//             if (await directory.exists()) {
//               await _scanDirectory(directory, files, dataType);
//             }
//           } else if (Platform.isIOS) {
//             Directory documentsDir = await getApplicationDocumentsDirectory();
//             await _scanDirectory(documentsDir, files, dataType);
//           }
//         } catch (e) {
//           log('Error scanning files in isolate: $e');
//         }

//         replyPort.send(files);
//       }
//     }
//   }

//   static Future<void> _scanDirectory(
//       Directory directory, List<String> files, List<String> dataType) async {
//     try {
//       List<FileSystemEntity> entities = directory.listSync(followLinks: false);
//       for (FileSystemEntity entity in entities) {
//         if (entity is File) {
//           final String extension = entity.path.split('.').last.toLowerCase();
//           if (dataType.contains(extension)) {
//             files.add(entity.path);
//           }
//         } else if (entity is Directory) {
//           // Skip directories Android/obb and Android/data
//           if (entity.path.contains('/Android/obb') ||
//               entity.path.contains('/Android/data')) {
//             continue;
//           }

//           try {
//             await _scanDirectory(entity, files, dataType);
//           } catch (e) {
//             log('Skipping directory: ${entity.path} - $e');
//           }
//         }
//       }
//     } catch (e) {
//       log('Skipping directory: ${directory.path} - $e');
//     }
//   }

//   Future<List<String>> _sendReceive(SendPort port, msg) async {
//     ReceivePort response = ReceivePort();
//     port.send([msg, response.sendPort]);
//     return await response.first;
//   }
// }
