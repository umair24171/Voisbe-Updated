import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AddNoteController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  addNote(NoteModel note, String noteId) async {
    try {
      await firestore.collection('notes').doc(noteId).set(note.toMap());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> uploadFile(
      String childName,
      // String name,
      File file,
      BuildContext context) async {
    // Provider.of<UserProvider>(context, listen: false).setUserLogin(true);
    String randomId = const Uuid().v4();
    String imageUrl = '';
    await _storage
        .ref(childName)
        .child(randomId)
        .putFile(file)
        .then((p0) async {
      imageUrl = await p0.ref.getDownloadURL();
    });

    //updating image in firestore database

    return imageUrl;
  }
}
