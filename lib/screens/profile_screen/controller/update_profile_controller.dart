import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
// import 'package:firebase_core/firebase_core.dart';

class UpdateProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  updateProfile(
    String name,
    String username,
    String bio,
    String link,
    String contact,
    bool subscritpion,
    double price,
    List soundPacks,
    String photoUrl,
    DateTime dateOfBirth,
    context,
    String currentUid,
  ) async {
    try {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(true);
      _firestore.collection('users').doc(currentUid).update({
        'photoUrl': photoUrl,
        'username': name,
        'name': username,
        'bio': bio,
        'link': link,
        'contact': contact,
        'isSubscriptionEnable': subscritpion,
        'price': price,
        'soundPacks': soundPacks,
        'dateOfBirth': dateOfBirth
      });
      Provider.of<UserProvider>(context, listen: false).setUserLoading(false);
    } catch (e) {
      Provider.of<UserProvider>(context, listen: false).setUserLoading(true);
      log(e.toString());
    }
  }

  Future<String> uploadImage(File file) async {
    String url = '';
    try {
      var ref =
          FirebaseStorage.instance.ref().child('profile/${currentUser!.uid}');
      ref.putFile(file);
      await ref.getDownloadURL().then((value) {
        url = value;
      });
    } catch (e) {
      log(e.toString());
    }
    return url;
  }

  Future<List<String>> fetchUsers(String query) async {
    // Replace with actual Firebase query
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs.map((doc) => doc['username'] as String).toList();
  }
}
