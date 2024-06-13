import 'package:flutter/material.dart';

import 'package:social_notes/resources/colors.dart';

import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// import 'package:social_notes/screens/add_note_screen.dart/controllers/add_note_controller.dart';

import 'package:social_notes/screens/chat_screen.dart/view/chat_screen.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class ShowTaggedUsers extends StatelessWidget {
  const ShowTaggedUsers({super.key, required this.noteModel});
  final NoteModel noteModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        children: [
          // Align(
          //   alignment: Alignment.topRight,
          //   child: IconButton(
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       icon: Icon(
          //         Icons.cancel,
          //         size: 30,
          //         color: blackColor,
          //       )),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),

          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none),
          //       filled: true,
          //       fillColor: Colors.grey[300],
          //       constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
          //       hintText: 'Search...',
          //       hintStyle:
          //           TextStyle(fontFamily: fontFamily, color: Colors.grey),
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 4),
              itemCount: noteModel.tagPeople.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return OtherUserProfile(
                          userId: noteModel.tagPeople[index].uid);
                    }));
                  },
                  child: Column(
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              NetworkImage(noteModel.tagPeople[index].photoUrl),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              noteModel.tagPeople[index].username,
                              style: TextStyle(
                                  fontFamily: fontFamily, fontSize: 18),
                            ),
                            if (noteModel.tagPeople[index].isVerified)
                              verifiedIcon()
                          ],
                        ),
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        endIndent: 10,
                        indent: 10,
                        height: 1,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
