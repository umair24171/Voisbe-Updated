// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';
// import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/navigation.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/profile_screen/model/sound_pack_model.dart';
// import 'package:social_notes/screens/profile_screen/provider.dart/update_profile_provider.dart';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// import 'package:social_notes/spotify/methods/model/provider/tracks_provider.dart';
// import 'package:social_notes/spotify/methods/model/track_model.dart';
// import 'package:social_notes/spotify/methods/spotify_class.dart';

// class SpotifyViewScreen extends StatelessWidget {
//   const SpotifyViewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var tracksPro = Provider.of<TracksProvider>(context).allTracks;

//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//         backgroundColor: whiteColor,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Row(
//             children: [
//               Expanded(
//                 // flex: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 0),
//                   child: TextFormField(
//                     onChanged: (value) {
//                       if (value.isNotEmpty) {
//                         var pro =
//                             Provider.of<TracksProvider>(context, listen: false);
//                         pro.setSearchTrack(true);
//                         pro.searchedTracks.clear();

//                         for (int i = 0; i < tracksPro.length; i++) {
//                           if (tracksPro[i]
//                               .name
//                               .toLowerCase()
//                               .contains(value.toLowerCase())) {
//                             pro.searchedTracks.add(tracksPro[i]);
//                           }
//                         }
//                       } else {
//                         var pro =
//                             Provider.of<TracksProvider>(context, listen: false);
//                         pro.setSearchTrack(false);
//                         pro.searchedTracks.clear();
//                       }
//                     },
//                     decoration: InputDecoration(
//                       constraints: BoxConstraints(
//                           maxHeight: 35, maxWidth: size.width * 0.8),
//                       fillColor: Colors.grey[300],
//                       filled: true,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none),
//                       prefixIcon: const Icon(
//                         Icons.search,
//                         color: Colors.grey,
//                       ),
//                       hintText: 'Search',
//                       hintStyle:
//                           TextStyle(fontFamily: fontFamily, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // actions: [
//           //   Padding(
//           //     padding: const EdgeInsets.only(right: 12),
//           //     child: Icon(
//           //       Icons.more_horiz,
//           //       color: blackColor,
//           //     ),
//           //   ),
//           // ],
//         ),
//         body: Scaffold(
//           body: Column(
//             children: [
//               Expanded(
//                 child:
//                     Consumer<TracksProvider>(builder: (context, trackPro, _) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: trackPro.isSearching
//                         ? trackPro.searchedTracks.length
//                         : tracksPro.length,
//                     itemBuilder: (context, index) {
//                       return SingleAddSound(
//                         track: trackPro.isSearching
//                             ? trackPro.searchedTracks[index]
//                             : tracksPro[index],
//                       );
//                     },
//                   );
//                 }),
//               )
//             ],
//           ),
//         ));
//   }
// }

// class SingleAddSound extends StatelessWidget {
//   const SingleAddSound({Key? key, required this.track}) : super(key: key);
//   final TrackSongs track;

//   @override
//   Widget build(BuildContext context) {
//     var currentUSer = Provider.of<UserProvider>(context, listen: false).user;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Text(
//               track.name,
//               style: TextStyle(
//                   color: blackColor,
//                   fontFamily: fontFamily,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 0),
//                 child: SpotifyPlayer(
//                     noteUrl: track.url,
//                     height: 30,
//                     width: 120,
//                     mainHeight: 60,
//                     mainWidth: 240),
//                 // child: VoiceMessageView(
//                 //   backgroundColor: primaryColor,
//                 //   activeSliderColor: whiteColor,
//                 //   cornerRadius: 50,
//                 //   innerPadding: 0,
//                 //   size: 40,
//                 //   controller: VoiceController(
//                 //     audioSrc: track.trackUrl!,
//                 //     maxDuration: const Duration(seconds: 500),
//                 //     isFile: false,
//                 //     onComplete: () {
//                 //       debugPrint('completed');
//                 //     },
//                 //     onPause: () {
//                 //       debugPrint('paused');
//                 //     },
//                 //     onPlaying: () {
//                 //       debugPrint('playing');
//                 //     },
//                 //     onError: (err) {
//                 //       debugPrint('voice error ${err.toString()}');
//                 //     },
//                 //   ),
//                 // ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Row(
//                 children: [
//                   // Container(
//                   //   padding: const EdgeInsets.all(6),
//                   //   decoration: BoxDecoration(
//                   //       color: blackColor,
//                   //       borderRadius: BorderRadius.circular(16)),
//                   //   child: Icon(
//                   //     Icons.bookmark_border,
//                   //     size: 17,
//                   //     color: whiteColor,
//                   //   ),
//                   // ),
//                   // const SizedBox(
//                   //   width: 5,
//                   // ),
//                   GestureDetector(
//                     onTap: () {
//                       Provider.of<UpdateProfileProvider>(context, listen: false)
//                           .createSoundCollection(
//                               currentUSer!.name,
//                               track.name,
//                               track.url,
//                               SoundPackType.premium,
//                               true,
//                               true);
//                       navPop(context);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                           color: blackColor,
//                           borderRadius: BorderRadius.circular(16)),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.add,
//                             color: whiteColor,
//                             size: 15,
//                           ),
//                           Text(
//                             'Upload',
//                             style: TextStyle(
//                                 color: whiteColor,
//                                 fontFamily: fontFamily,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// // import 'dart:developer';

// class SpotifyPlayer extends StatefulWidget {
//   const SpotifyPlayer({
//     Key? key,
//     required this.noteUrl,
//     required this.height,
//     required this.width,
//     required this.mainWidth,
//     required this.mainHeight,
//     this.backgroundColor = Colors.white,
//   }) : super(key: key);
//   final String noteUrl;
//   final double height;
//   final double width;
//   final double mainWidth;
//   final double mainHeight;
//   final Color backgroundColor;
//   @override
//   State<SpotifyPlayer> createState() => _SpotifyPlayerState();
// }

// class _SpotifyPlayerState extends State<SpotifyPlayer> {
//   late AudioPlayer _audioPlayer;
//   bool _isPlaying = false;
//   PlayerState? _playerState;

//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();
//     _audioPlayer.setReleaseMode(ReleaseMode.stop);
//     _audioPlayer.setSourceUrl(widget.noteUrl);
//     _playerState = _audioPlayer.state;

//     _audioPlayer.onDurationChanged.listen((event) {
//       setState(() {
//         duration = event;
//       });
//     });
//     _audioPlayer.onPositionChanged.listen((event) {
//       setState(() {
//         position = event;
//       });
//     });

//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (state == PlayerState.completed) {
//         setState(() {
//           _isPlaying = false;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   void playPause() async {
//     if (_isPlaying) {
//       _audioPlayer.pause();
//     } else {
//       _audioPlayer.resume();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 5),
//       child: Center(
//         child: Container(
//           height: widget.mainHeight,
//           width: widget.mainWidth,
//           decoration: BoxDecoration(
//             color: widget.backgroundColor,
//             borderRadius: BorderRadius.circular(55),
//           ),
//           child: Row(
//             children: [
//               IconButton(
//                 onPressed: playPause,
//                 icon: Icon(
//                   _isPlaying
//                       ? Icons.pause_circle_filled
//                       : Icons.play_circle_fill,
//                   color: Colors.red,
//                   size: 35,
//                 ),
//               ),
//               SizedBox(
//                 height: widget.height,
//                 width: widget.width,
//                 child: TweenAnimationBuilder<double>(
//                   tween: Tween<double>(begin: 0.0, end: 1.0),
//                   duration: duration,
//                   builder: (context, progress, child) {
//                     final color = duration.inSeconds > 0
//                         ? Color.lerp(primaryColor, Colors.black,
//                             position.inSeconds / duration.inSeconds)!
//                         : primaryColor;
//                     return WaveformProgressbar(
//                       color: primaryColor,
//                       progressColor: color,
//                       progress: duration.inSeconds / position.inSeconds,
//                       onTap: (progress) {
//                         Duration seekPosition = Duration(
//                             seconds: (progress * duration.inSeconds).round());
//                         _audioPlayer.seek(seekPosition);
//                       },
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Text(
//                 '${position.inSeconds}:${duration.inSeconds}',
//                 style: TextStyle(
//                   fontFamily: fontFamily,
//                   fontSize: 14,
//                   color: primaryColor,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getColorForProgress(double progress) {
//     if (progress == 1.0) {
//       return Colors.black;
//     } else {
//       return primaryColor;
//     }
//   }
// }
