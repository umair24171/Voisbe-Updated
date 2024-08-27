import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/single_draft.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List<Map<String, dynamic>> drafts = [];
  @override
  void initState() {
    //  getting the drafts list before showing on the screen

    getDrafts();
    super.initState();
  }

  getDrafts() async {
    List<Map<String, dynamic>> data =
        await Provider.of<NoteProvider>(context, listen: false).getDrafts();
    setState(() {
      drafts = data;
    });
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
            'Drafts',
            style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: khulaBold,
                fontWeight: FontWeight.w700),
          ),
        ),

        //  building the drafts through grid

        body: GridView.builder(
          itemCount: drafts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              mainAxisExtent: 121,
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            //  getting the current user

            var provider =
                Provider.of<UserProvider>(context, listen: false).user;

            // gettting the drafts data one by one

            String file = drafts[index]['filePath']!;
            String backImage = drafts[index]['backImage']!;
            bool isGalleryThumbnail =
                drafts[index]['isGalleryThumbnail'] ?? false;
            String thumbnailPath = drafts[index]['thumbnailImageFile'] ?? '';

            log('back image $backImage');
            log('isGallery $isGalleryThumbnail');
            log('thumbnailPath $thumbnailPath');

            //  returning or building the widget for the draft

            return ClipRRect(
              borderRadius: BorderRadius.circular(0),

              //  slideable to delete the draft

              child: Slidable(
                direction: Axis.horizontal,
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                        padding: const EdgeInsets.all(0),
                        onPressed: (context) async {
                          //  deleting the draft function

                          Provider.of<NoteProvider>(context, listen: false)
                              .deleteDraft(file);
                          getDrafts();
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

                //  single draft widget

                child: SingleDraft(
                  file: file,
                  userImage: provider!.photoUrl,
                  backImage: backImage,
                  isGalleryThumbnail: isGalleryThumbnail,
                  thumbnailPath: thumbnailPath,
                ),
              ),
            );
          },
        ));
  }
}
