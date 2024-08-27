// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// // import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// // import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/navigation.dart';
// // import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:social_notes/screens/profile_screen/model/sound_pack_model.dart';
// import 'package:social_notes/screens/profile_screen/provider.dart/update_profile_provider.dart';
// import 'package:social_notes/screens/user_profile/view/widgets/custom_player.dart';
// // import 'package:social_notes/screens/upload_sounds/view/add_sound.dart';

// class UploadSound extends StatelessWidget {
//   const UploadSound({super.key, required this.username});

//   final String username;

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
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
//               'Upload Sound',
//               style: TextStyle(
//                   fontFamily: fontFamily,
//                   color: blackColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//           Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Container(
//                   width: size.width * 0.8,
//                   // height: size.height * 0.02,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: blackColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10),
//                     child: Text(
//                       'Upload your sound pack',
//                       style:
//                           TextStyle(fontFamily: fontFamily, color: whiteColor),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: size.width * 0.65,
//                 child: GestureDetector(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           backgroundColor: whiteColor,
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: IconButton(
//                                     onPressed: () {
//                                       navPop(context);
//                                     },
//                                     icon: Icon(
//                                       Icons.close,
//                                       color: blackColor,
//                                       size: 30,
//                                     )),
//                               ),
//                               Text(
//                                 'How would you like to upload your audio files',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     fontFamily: fontFamily,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor:
//                                         MaterialStateProperty.all<Color>(
//                                             blackColor)),
//                                 onPressed: () {
//                                   // Provider.of<UpdateProfileProvider>(context,
//                                   //         listen: false)
//                                   //     .pickAndUploadFiles()
//                                   //     .then((value) =>
//                                   //         Provider.of<UpdateProfileProvider>(
//                                   //                 context,
//                                   //                 listen: false)
//                                   //             .createSoundCollection(
//                                   //                 username,
//                                   //                 'Ice on cake',
//                                   //                 '',
//                                   //                 SoundPackType.premium,
//                                   //                 true,
//                                   //                 false));
//                                 },
//                                 child: Text(
//                                   'Via Mobile Upload',
//                                   style: TextStyle(
//                                       fontFamily: fontFamily,
//                                       color: whiteColor),
//                                 ),
//                               ),
//                               ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor:
//                                         MaterialStateProperty.all<Color>(
//                                             blackColor)),
//                                 onPressed: () {
//                                   // Navigator.of(context).push(
//                                   //     MaterialPageRoute(builder: (context) {
//                                   //   return const SpotifyViewScreen();
//                                   // }));
//                                 },
//                                 child: Text(
//                                   'Via Spotify',
//                                   style: TextStyle(
//                                       fontFamily: fontFamily,
//                                       color: whiteColor),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: size.width * 0.25,
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
//                     decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           'assets/images/uploadsound.png',
//                           height: 20,
//                           width: 20,
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         Text(
//                           'Upload',
//                           style: TextStyle(
//                               fontFamily: fontFamily,
//                               fontSize: 13,
//                               color: whiteColor),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//           Text(
//             'Accepted files: MP3, ZIP | Max file size 20 MB',
//             style: TextStyle(
//                 fontSize: 10, color: blackColor, fontFamily: fontFamily),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           TextFormField(
//             decoration: InputDecoration(
//                 constraints:
//                     BoxConstraints(maxHeight: 35, maxWidth: size.width * 0.8),
//                 fillColor: Colors.grey[300],
//                 filled: true,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: Colors.grey,
//                 ),
//                 hintText: 'Search',
//                 hintStyle:
//                     TextStyle(fontFamily: fontFamily, color: Colors.grey),
//                 contentPadding: EdgeInsets.only(top: 10)
//                 // label: Text(
//                 //   'Search',
//                 //   style: TextStyle(fontFamily: fontFamily, color: Colors.grey),
//                 // ),
//                 ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('soundPacks')
//                   .where('userId',
//                       isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       SoundPackModel soundPack = SoundPackModel.fromMap(
//                           snapshot.data!.docs[index].data());
//                       return SingleUploadSoundContainer(
//                         soundPackModel: soundPack,
//                       );
//                     },
//                   );
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               }),
//         ],
//       ),
//     );
//   }
// }

// class SingleUploadSoundContainer extends StatefulWidget {
//   const SingleUploadSoundContainer({super.key, required this.soundPackModel});
//   final SoundPackModel soundPackModel;

//   @override
//   State<SingleUploadSoundContainer> createState() =>
//       _SingleUploadSoundContainerState();
// }

// class _SingleUploadSoundContainerState
//     extends State<SingleUploadSoundContainer> {
//   bool isEditing = false;
//   final TextEditingController nameController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     nameController.text = widget.soundPackModel.soundPackName;

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: SizedBox(
//               height: 25,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Row(
//                       children: [
//                         //
//                         isEditing
//                             ? Expanded(
//                                 flex: 2,
//                                 child: Container(
//                                   width: 80,
//                                   height: 100,
//                                   child: TextFormField(
//                                     focusNode: _focusNode,
//                                     controller: nameController,
//                                     style: TextStyle(
//                                       color: blackColor,
//                                       fontFamily: fontFamily,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                     decoration: InputDecoration(
//                                       constraints:
//                                           const BoxConstraints(maxHeight: 100),
//                                       contentPadding:
//                                           const EdgeInsets.only(bottom: 0),
//                                       // fillColor: Colors.grey[300],
//                                       // contentPadding:
//                                       //     const EdgeInsets.symmetric(
//                                       //   vertical: 12,
//                                       //   horizontal: 10,
//                                       // ),
//                                       // filled: false,
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : Expanded(
//                                 flex: 2,
//                                 child: Text(
//                                   widget.soundPackModel.soundPackName,
//                                   overflow: TextOverflow.fade,
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                       // overflow: TextOverflow.ellipsis,
//                                       color: blackColor,
//                                       fontFamily: fontFamily,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                         // const SizedBox(
//                         //   width: 5,
//                         // ),
//                         Expanded(
//                           child: Text(
//                             widget.soundPackModel.soundPackType.name,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(color: primaryColor, fontSize: 12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () async {
//                         setState(() {
//                           isEditing = !isEditing;
//                         });
//                         // if (isEditing) {
//                         //   FocusScope.of(context).requestFocus(_focusNode);
//                         // }
//                         if (!isEditing) {
//                           await FirebaseFirestore.instance
//                               .collection('soundPacks')
//                               .doc(widget.soundPackModel.soundId)
//                               .update({'soundPackName': nameController.text});
//                         } else {
//                           nameController.text =
//                               widget.soundPackModel.soundPackName;
//                         }
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 3, horizontal: 8),
//                         // color: Colors.grey[300],
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             color: Colors.grey[300]),
//                         child: Row(
//                           children: [
//                             Icon(
//                               isEditing ? Icons.check : Icons.edit,
//                               color: whiteColor,
//                               size: 15,
//                             ),
//                             Text(
//                               isEditing ? 'Save' : 'Edit Name',
//                               style: TextStyle(
//                                   color: whiteColor, fontFamily: fontFamily),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Text(widget.soundPackModel.username,
//                 style: TextStyle(color: primaryColor)),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 0),
//                 child: CustomProgressPlayer(
//                     noteUrl: widget.soundPackModel.soundPackUrl,
//                     backgroundColor: Colors.transparent,
//                     height: 30,
//                     width: 120,
//                     mainHeight: 60,
//                     mainWidth: 240),
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
//               GestureDetector(
//                 onTap: () {
//                   FirebaseFirestore.instance
//                       .collection('soundPacks')
//                       .doc(widget.soundPackModel.soundId)
//                       .update({
//                     'subscriptionEnable':
//                         !widget.soundPackModel.subscriptionEnable,
//                     'soundPackType': widget.soundPackModel.subscriptionEnable
//                         ? 'free'
//                         : 'premium'
//                   });
//                 },
//                 child: Container(
//                   // padding: const EdgeInsets.all(10),
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(10)),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 0),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 7, vertical: 7),
//                           decoration: BoxDecoration(
//                               color: widget.soundPackModel.subscriptionEnable
//                                   ? primaryColor
//                                   : blackColor,
//                               borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(18),
//                                   bottomLeft: Radius.circular(18))),
//                           child: Text(
//                             'ON',
//                             style: TextStyle(color: whiteColor),
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                               color: widget.soundPackModel.subscriptionEnable
//                                   ? blackColor
//                                   : primaryColor,
//                               borderRadius: const BorderRadius.only(
//                                   topRight: Radius.circular(18),
//                                   bottomRight: Radius.circular(18))),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 7, vertical: 7),
//                           child: Text(
//                             'OFF',
//                             style: TextStyle(color: whiteColor),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
