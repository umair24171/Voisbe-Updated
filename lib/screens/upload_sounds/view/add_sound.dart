// // import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/navigation.dart';
// // import 'package:social_notes/resources/show_snack.dart';
// import 'package:social_notes/screens/add_note_screen/model/saved_note_model.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/profile_screen/model/sound_pack_model.dart';
// // import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
// import 'package:social_notes/screens/user_profile/other_user_profile.dart';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// import 'package:uuid/uuid.dart';

// class AddSound extends StatelessWidget {
//   const AddSound({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;

//     // var soundProvider = Provider.of<SoundProvider>(context, listen: false);

//     return Container(
//       height: size.height * 0.8,
//       width: double.infinity,
//       child: Column(
//         children: [
//           // Divider(
//           //   color: blackColor,
//           //   thickness: 4,
//           //   indent: size.width * 0.8,
//           //   endIndent: size.width * 0.8,
//           // ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Text(
//               'Add Sound',
//               style: TextStyle(
//                   fontFamily: fontFamily,
//                   color: blackColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//           Consumer<SoundProvider>(builder: (context, soundPro, _) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     soundPro.setSoundType('free');
//                   },
//                   child: Text(
//                     'Free',
//                     style: TextStyle(
//                         color: soundPro.soundType.contains('free')
//                             ? primaryColor
//                             : blackColor,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: fontFamily),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     soundPro.setSoundType('Saved');
//                   },
//                   child: Text(
//                     'Saved',
//                     style: TextStyle(
//                         color: soundPro.soundType.contains('Saved')
//                             ? primaryColor
//                             : blackColor,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: fontFamily),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     soundPro.setSoundType('Subscribed');
//                   },
//                   child: Text(
//                     'Subscribed',
//                     style: TextStyle(
//                       color: soundPro.soundType.contains('Subscribed')
//                           ? primaryColor
//                           : Colors.purple,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: fontFamily,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//           const SizedBox(
//             height: 20,
//           ),
//           TextFormField(
//             decoration: InputDecoration(
//               constraints:
//                   BoxConstraints(maxHeight: 35, maxWidth: size.width * 0.8),
//               fillColor: Colors.grey[300],
//               filled: true,
//               contentPadding: const EdgeInsets.only(top: 10),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none),
//               prefixIcon: const Icon(
//                 Icons.search,
//                 color: Colors.grey,
//                 size: 20,
//               ),
//               hintText: 'Search',
//               hintStyle: TextStyle(fontFamily: fontFamily, color: Colors.grey),
//               // label: Text(
//               //   'Search',
//               //   style: TextStyle(fontFamily: fontFamily, color: Colors.grey),
//               // ),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Consumer<SoundProvider>(builder: (context, soundPro, _) {
//             if (soundPro.soundType.contains('free')) {
//               return Expanded(
//                 child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: soundPro.freeSoundPacks.length,
//                     itemBuilder: (context, index) {
//                       SoundPackModel soundPackModel =
//                           soundPro.freeSoundPacks[index];

//                       return SingleAddSound(
//                         soundPackModel: soundPackModel,
//                         // Remove [index]
//                       );
//                     }),
//               );
//             } else {
//               return soundPro.soundType.contains('Subscribed')
//                   ? Expanded(
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: soundPro.subscribeSoundPacks.length,
//                           itemBuilder: (context, index) {
//                             // String username =
//                             //     soundPro.subscribeSoundPacks[index].username;
//                             // String soundPacks =
//                             //     soundPro.subscribeSoundPacks[index].soundPackUrl;
//                             return SingleAddSound(
//                               soundPackModel:
//                                   soundPro.subscribeSoundPacks[index],
//                               // Remove [index]
//                             );
//                           }),
//                     )
//                   : soundPro.soundType.contains('Saved')
//                       ? ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: soundPro.savedNotes.length,
//                           itemBuilder: (context, index) {
//                             for (var soundPackModel in soundPro.freeSoundPacks +
//                                 soundPro.subscribeSoundPacks) {
//                               if (soundPackModel.soundId ==
//                                   soundPro.savedNotes[index].soundId) {
//                                 return SingleAddSound(
//                                     soundPackModel: soundPackModel);
//                               }
//                             }
//                             return Container();
//                           },
//                         )
//                       : Container();
//             }
//           }),
//           // const SingleAddSound(),
//         ],
//       ),
//     );
//   }
// }

// class SingleAddSound extends StatelessWidget {
//   const SingleAddSound({
//     Key? key,
//     required this.soundPackModel,
//   }) : super(key: key);
//   final SoundPackModel soundPackModel;

//   @override
//   Widget build(BuildContext context) {
//     var currentUSer = Provider.of<UserProvider>(context, listen: false).user;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Row(
//               children: [
//                 Text(
//                   soundPackModel.soundPackName,
//                   style: TextStyle(
//                       color: blackColor,
//                       fontFamily: fontFamily,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 if (soundPackModel.soundPackType.name.contains('premium'))
//                   Text(
//                     soundPackModel.soundPackType.name,
//                     style: TextStyle(color: primaryColor),
//                   )
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 4,
//           ),
//           InkWell(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         OtherUserProfile(userId: soundPackModel.userId),
//                   ));
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Text(
//                 soundPackModel.username,
//                 style: TextStyle(
//                     color: primaryColor,
//                     fontFamily: fontFamily,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 0),
//                 child: CustomProgressPlayer(

//                   noteUrl: soundPackModel.soundPackUrl,
//                   height: 35,
//                   width: 130,
//                   mainWidth: 250,
//                   mainHeight: 70,
//                   backgroundColor: Colors.transparent,
//                 ),
//                 // VoiceMessageView(
//                 //   backgroundColor: whiteColor.withOpacity(0.01),
//                 //   activeSliderColor: primaryColor,
//                 //   cornerRadius: 50,
//                 //   innerPadding: 0,
//                 //   size: 25,
//                 //   controller: VoiceController(
//                 //     audioSrc: soundPackModel.soundPackUrl,
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
//               Expanded(
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         String saveId = const Uuid().v4();
//                         SavedNoteModel savedNoteModel = SavedNoteModel(
//                             savedNoteId: saveId,
//                             uid: currentUSer!.uid,
//                             soundId: soundPackModel.soundId);
//                         Provider.of<SoundProvider>(context, listen: false)
//                             .addSavedNote(savedNoteModel, saveId);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                             color: blackColor,
//                             borderRadius: BorderRadius.circular(16)),
//                         child: Consumer<SoundProvider>(
//                             builder: (context, soundPro, _) {
//                           var isAdded = false;
//                           soundPro.savedNotes.forEach((element) {
//                             if (element.soundId == soundPackModel.soundId) {
//                               isAdded = true;
//                             }
//                           });
//                           return Icon(
//                             isAdded ? Icons.bookmark : Icons.bookmark_border,
//                             size: 17,
//                             color: whiteColor,
//                           );
//                         }),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (currentUSer!.subscribedSoundPacks
//                                 .contains(soundPackModel.userId) ||
//                             soundPackModel.soundPackType.name
//                                 .contains('free') ||
//                             soundPackModel.userId == currentUSer.uid) {
//                           Provider.of<SoundProvider>(context, listen: false)
//                               .setVoiceUrl(soundPackModel.soundPackUrl);
//                           navPop(context);
//                         } else {
//                           // showSnackBar(context,
//                           //     'Please subscribe to the user to access this sound');
//                         }
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 6, horizontal: 9),
//                         decoration: BoxDecoration(
//                             color: blackColor,
//                             borderRadius: BorderRadius.circular(16)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add,
//                               color: whiteColor,
//                               size: 15,
//                             ),
//                             Text(
//                               'Add',
//                               style: TextStyle(
//                                   color: whiteColor,
//                                   fontFamily: fontFamily,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
