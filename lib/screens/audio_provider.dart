// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:mic_stream/mic_stream.dart';
// import 'package:http/http.dart' as http;

// class AudioProvider extends ChangeNotifier {
//   StreamController<Uint8List> _streamController = StreamController();
//   List<Uint8List> _samples = [];
//   late StreamSubscription _streamSubscription;

//   Stream<Uint8List> get audioStream => _streamController.stream;

//   List<Uint8List> get samples => _samples;

//   StreamSubscription get streamSubscription => _streamSubscription;

//   void stopRecording() async {
//     MicStream.microphone();
//     _streamSubscription.cancel();
//     _streamController = StreamController();
//     notifyListeners();
//   }

//   void addStream(Stream<Uint8List> stream) {
//     _samples = [];
//     _streamController.addStream(stream);
//   }

//   void addSample(Uint8List sample) {
//     _samples.add(sample);
//   }

//   void setStreamSubscription(StreamSubscription subscription) {
//     _streamSubscription = subscription;
//   }

//   void loadAudio(String audioUrl) async {
//     try {
//       var response = await http.get(Uri.parse(audioUrl));
//       if (response.statusCode == 200) {
//         _samples = [response.bodyBytes];
//         _streamController.add(Uint8List.fromList(response.bodyBytes));
//       } else {
//         throw Exception('Failed to load audio');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
// }
