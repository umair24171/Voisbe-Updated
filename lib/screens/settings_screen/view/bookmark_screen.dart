import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/search_screen/view/note_details_screen.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/single_bookmark_item.dart';
import 'package:social_notes/screens/upload_sounds/provider/sound_provider.dart';
import 'package:social_notes/screens/bottom_provider.dart';

class BookMarkScreenSettings extends StatefulWidget {
  const BookMarkScreenSettings({super.key});

  @override
  State<BookMarkScreenSettings> createState() => _BookMarkScreenSettingsState();
}

class _BookMarkScreenSettingsState extends State<BookMarkScreenSettings> {
  @override
  void initState() {
    super.initState();

    //  getting the bookmark posts

    Provider.of<DisplayNotesProvider>(context, listen: false)
        .getBookMarkPosts();
  }

  @override
  Widget build(BuildContext context) {
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
          'Bookmarks',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<DisplayNotesProvider>(builder: (context, displayPro, _) {
        //  getting all the the notes and matching the ids of the saved notes

        List<NoteModel> allNotes = [];
        for (var note in displayPro.notes) {
          for (var bookmark in displayPro.bookMarkPosts) {
            if (note.noteId == bookmark.postId) {
              allNotes.add(note);
            }
          }
        }
        return GridView.builder(
          itemCount: allNotes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              mainAxisExtent: 121,
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            //  the template of the bookmark post

            return ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Slidable(
                direction: Axis.horizontal,
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                        padding: const EdgeInsets.all(0),
                        onPressed: (context) async {
                          // deleting the book mark post fucntion

                          Provider.of<DisplayNotesProvider>(context,
                                  listen: false)
                              .deleteBookMark(allNotes[index].noteId);

                          //  after deleting updating the book mark posts

                          Provider.of<DisplayNotesProvider>(context,
                                  listen: false)
                              .getBookMarkPosts();
                        },
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        flex: 4,
                        borderRadius: BorderRadius.zero,
                        autoClose: true,
                        icon: Icons.delete,
                        label: "Delete"),
                  ],
                ),
                child: InkWell(
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                note: allNotes[index],
                              )),
                    );
                  },

                  //  template or widget of the single book mark post

                  child: SingleBookMarkItem(
                    note: allNotes[index],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
