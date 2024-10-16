// import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';

// class AudioPlayerHandler {
//   final AudioPlayer player = AudioPlayer();
//   bool _initialized = false;

//   AudioPlayerHandler() {
//     _initializePlayer();
//   }

//   void _initializePlayer() {
//     if (_initialized) return;

//     player.playbackEventStream.listen((PlaybackEvent event) {
//       final playing = player.playing;
//       final processingState = {
//         // ProcessingState.idle: AudioProcessingState.idle,
//         // ProcessingState.loading: AudioProcessingState.loading,
//         // ProcessingState.buffering: AudioProcessingState.buffering,
//         // ProcessingState.ready: AudioProcessingState.ready,
//         // ProcessingState.completed: AudioProcessingState.completed,
//       }[player.processingState]!;

//       // You can use this information to update your UI
//       // For example, you might want to call setState() here if this is part of a StatefulWidget
//     });

//     _initialized = true;
//   }

//   Future<void> play() async {
//     await player.play();
//   }

//   Future<void> pause() async {
//     await player.pause();
//   }

//   Future<void> seek(Duration position) async {
//     await player.seek(position);
//   }

//   Future<void> stop() async {
//     await player.stop();
//   }

//   Future<void> setAudioSource(String url,
//       {required String title, required String artist}) async {
//     try {
//       // Set the audio source
//       await player.setAudioSource(
//         AudioSource.uri(
//           Uri.parse(url),
//           tag: MediaItem(
//             id: url,
//             album: 'Voisbe',
//             title: title,
//             artist: artist,
//             artUri: Uri.parse(
//                 'https://example.com/albumart.jpg'), // Replace with actual album art URL
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error setting audio source: $e');
//     }
//   }

//   Stream<Duration> get positionStream => player.positionStream;
//   Stream<Duration?> get durationStream => player.durationStream;
//   Stream<bool> get playingStream => player.playingStream;

//   Future<void> dispose() async {
//     await player.dispose();
//   }
// }
