import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:social_notes/screens/add_note_screen/model/saved_note_model.dart';
import 'package:social_notes/screens/profile_screen/model/sound_pack_model.dart';

class SoundProvider extends ChangeNotifier {
  List<SoundPackModel> freeSoundPacks = [];
  List<SoundPackModel> subscribeSoundPacks = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Map<String, List<String>> soundSubscribeUSers = {};

  String soundType = 'free';

  setSoundType(String type) {
    soundType = type;
    notifyListeners();
  }

  String? voiceUrl;

  setVoiceUrl(String url) {
    voiceUrl = url;
    notifyListeners();
  }

  removeVoiceUrl() {
    voiceUrl = null;
    notifyListeners();
  }

  getFreeSoundPacks() async {
    await FirebaseFirestore.instance
        .collection('soundPacks')
        .where('subscriptionEnable', isEqualTo: false)
        .get()
        .then((value) {
      freeSoundPacks =
          value.docs.map((e) => SoundPackModel.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  getSubscribedSoundPacks() async {
    await FirebaseFirestore.instance
        .collection('soundPacks')
        .where('subscriptionEnable', isEqualTo: true)
        .get()
        .then((value) {
      subscribeSoundPacks =
          value.docs.map((e) => SoundPackModel.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  // List<SavedNoteModel> savedNotes = [];

  // getSavedNotes() async {
  //   QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //       .instance
  //       .collection('savedNotes')
  //       .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   savedNotes =
  //       snapshot.docs.map((e) => SavedNoteModel.fromMap(e.data())).toList();
  //   notifyListeners();
  // }

  // addSavedNote(SavedNoteModel note, String saveId) async {
  //   QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //       .instance
  //       .collection('savedNotes')
  //       .where('uid', isEqualTo: note.uid)
  //       .get();
  //   bool isSaved = false;
  //   SavedNoteModel? savedNoteModel;
  //   for (var doc in snapshot.docs) {
  //     SavedNoteModel savedNote = SavedNoteModel.fromMap(doc.data());
  //     if (savedNote.soundId == note.soundId) {
  //       savedNoteModel = savedNote;
  //       isSaved = true;

  //       break;
  //     }
  //   }

  //   if (isSaved) {
  //     // Note exists, update it
  //     await FirebaseFirestore.instance
  //         .collection('savedNotes')
  //         .doc(savedNoteModel!.savedNoteId)
  //         .delete();
  //     savedNotes.removeWhere((element) => element.soundId == note.soundId);
  //     notifyListeners();
  //     log('Note deleted successfully');
  //   } else {
  //     // Note does not exist, save it
  //     await FirebaseFirestore.instance
  //         .collection('savedNotes')
  //         .doc(saveId)
  //         .set(note.toMap());
  //     savedNotes.add(note);
  //     notifyListeners();
  //     log('Note saved successfully');
  //   }
  // }
  // // getSoundPacksFromUsersWithoutSubscription() async {
  //   // Query users with isSubscriptionEnable set to false
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('isSubscriptionEnable', isEqualTo: false)
  //       .get();

  //   // Iterate over the results and extract username and soundPacks
  //   for (var doc in querySnapshot.docs) {
  //     String username = doc['username'];
  //     List<dynamic> soundPacks = doc['soundPacks'];
  //     List<String> soundPacksList =
  //         soundPacks.map((pack) => pack.toString()).toList();
  //     soundPacksMap[username] = soundPacksList;
  //   }

  //   notifyListeners();
  // }

  // getSoundPacksWithSubscription() async {
  //   // Query users with isSubscriptionEnable set to false
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('isSubscriptionEnable', isEqualTo: true)
  //       .get();

  //   // Iterate over the results and extract username and soundPacks
  //   for (var doc in querySnapshot.docs) {
  //     String username = doc['username'];
  //     List<dynamic> soundPacks = doc['soundPacks'];
  //     List<String> soundPacksList =
  //         soundPacks.map((pack) => pack.toString()).toList();
  //     soundSubscribeUSers[username] = soundPacksList;
  //   }

  //   notifyListeners();
  // }
}
