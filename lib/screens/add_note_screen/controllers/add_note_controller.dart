import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
// import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AddNoteController {
  //  instance of firestore to save the post data in database
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //  storage instance to store files

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // function to add post in notes collection getting the note model from the paramter

  addNote(NoteModel note, String noteId, context) async {
    try {
      Provider.of<DisplayNotesProvider>(context, listen: false)
          .addOneNote(note);
      await firestore.collection('notes').doc(noteId).set(note.toMap());
    } catch (e) {
      log(e.toString());
    }
  }

  // function to upload images files to the storage

  Future<String> uploadImage(
      String childName,
      // String name,
      File file,
      BuildContext context) async {
    // Provider.of<UserProvider>(context, listen: false).setUserLogin(true);

    final storageRef =
        FirebaseStorage.instance.ref(childName).child(Uuid().v4());

    final uploadTask = storageRef.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      final progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      Provider.of<PexelsProvider>(context, listen: false)
          .setUploadProgress(progress);
    });

    final taskSnapshot = await uploadTask;
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
    // } catch (e) {
    //   log(e.toString());
    // }
  }

// same function to upload the files just the return type is different

  Future<String> uploadFile(
      String childName, File file, BuildContext context) async {
    final storageRef =
        FirebaseStorage.instance.ref(childName).child(Uuid().v4());
    final uploadTask = storageRef.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      final progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      Provider.of<PexelsProvider>(context, listen: false)
          .setUploadProgress(progress);
    });

    final taskSnapshot = await uploadTask;
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

// same function to upload the files to the storage just the return type is different

  Future<String> uploadUint(
      String childName,
      // String name,
      Uint8List file,
      BuildContext context) async {
    // Provider.of<UserProvider>(context, listen: false).setUserLogin(true);

    final storageRef =
        FirebaseStorage.instance.ref(childName).child(Uuid().v4());
    final uploadTask = storageRef.putData(file);

    uploadTask.snapshotEvents.listen((event) {
      final progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      Provider.of<PexelsProvider>(context, listen: false)
          .setUploadProgress(progress);
    });

    final taskSnapshot = await uploadTask;
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
    // } catch (e) {
    //   log(e.toString());
    // }
  }
}
