import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/single_bookmark_item.dart';
import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';

class TaggedPostScreen extends StatelessWidget {
  const TaggedPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //  getting current user data saved in provider

    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton(
          onPressed: () {
            navPop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
            size: 30,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tagged Posts',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),

      //  getting tagged posts

      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('tagPeople', arrayContains: currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //  building the tagged posts

              return GridView.builder(
                itemCount: snapshot.data!.docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    mainAxisExtent: 121,
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  NoteModel note =
                      NoteModel.fromMap(snapshot.data!.docs[index].data());

                  //  returing the template of the tagged post

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Slidable(
                      direction: Axis.horizontal,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          //  slidebale to remove the tagged post

                          SlidableAction(
                              padding: const EdgeInsets.all(0),
                              onPressed: (context) async {
                                await FirebaseFirestore.instance
                                    .collection('notes')
                                    .doc(note.noteId)
                                    .update({
                                  'tagPeople':
                                      FieldValue.arrayRemove([currentUser.uid])
                                });
                              },
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              flex: 4,
                              borderRadius: BorderRadius.zero,
                              autoClose: true,
                              icon: Icons.delete,
                              label: "Remove"),
                        ],
                      ),

                      //
                      child: InkWell(
                        //  on long press navigating to the home screen

                        onLongPress: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      note: note,
                                    )),
                          );
                        },

                        //  how a tagged post will look

                        child: SingleBookMarkItem(
                          note: note,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('');
            }
          }),
    );
  }
}
