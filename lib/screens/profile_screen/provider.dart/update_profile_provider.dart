import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';

class UpdateProfileProvider with ChangeNotifier {
  List<String> fileUrls = [];
  List<String> userNames = [];
  String price = '';

  //  setting price in profile screen

  setPrice(String price1) {
    price = price1;
    notifyListeners();
  }
//   getting all the usernames to add checks in the profile screen username field

  getAllUserNames() async {
    await FirebaseFirestore.instance.collection('users').get().then((value) {
      List<UserModel> userModel =
          value.docs.map((e) => UserModel.fromMap(e.data())).toList();
      userNames = userModel.map((e) => e.name).toList();
      notifyListeners();
    });
  }
  // Future<void> pickAndUploadFiles() async {
  //   // Allow the user to pick files
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.audio,
  //   );

  //   if (result != null) {
  //     List<File> files = result.paths.map((path) => File(path!)).toList();

  //     // Upload selected files to Firebase Storage
  //     FirebaseStorage storage = FirebaseStorage.instance;

  //     for (var file in files) {
  //       String fileName = file.path.split('/').last;
  //       Reference ref = storage.ref().child('mp3_files/$fileName');
  //       await ref.putFile(file);
  //       String downloadUrl = await ref.getDownloadURL();
  //       fileUrls.add(downloadUrl);
  //     }

  //     notifyListeners();
  //   }
  // }

  // Future<void> createSoundCollection(
  //     String username,
  //     String soundPackName,
  //     String spotifyUrl,
  //     SoundPackType type,
  //     bool isSubscribed,
  //     bool isSpotify) async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   if (!isSpotify) {
  //     for (var i in fileUrls) {
  //       var id = const Uuid().v4();
  //       var data = SoundPackModel(
  //           userId: auth.currentUser!.uid,
  //           soundId: id,
  //           username: username,
  //           soundPackName: soundPackName,
  //           soundPackUrl: i,
  //           soundPackType: type,
  //           subscriptionEnable: isSubscribed);
  //       await firestore.collection('soundPacks').doc(id).set(data.toMap());
  //     }
  //   } else {
  //     var id = const Uuid().v4();
  //     var data = SoundPackModel(
  //         userId: auth.currentUser!.uid,
  //         soundId: id,
  //         username: username,
  //         soundPackName: soundPackName,
  //         soundPackUrl: spotifyUrl,
  //         soundPackType: type,
  //         subscriptionEnable: isSubscribed);
  //     await firestore.collection('soundPacks').doc(id).set(data.toMap());
  //   }
  // }

  // Future<void> pickAndZipFiles() async {
  //   // Allow the user to pick files
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.audio,
  //   );

  //   if (result != null) {
  //     List<File> files = result.paths.map((path) => File(path!)).toList();

  //     // Create a temporary directory to store the zip file
  //     Directory tempDir = await Directory.systemTemp.createTemp('temp_dir');
  //     String zipPath = '${tempDir.path}/mp3_files.zip';

  //     // Add files to the zip
  //     await ZipFile.createFromFiles(
  //       sourceDir: tempDir,
  //       files: files.map((file) => file).toList(),
  //       zipFile: File(zipPath),
  //     );

  //     // Extract the zip file
  //     await ZipFile.extractToDirectory(
  //       zipFile: File(zipPath),
  //       destinationDir: tempDir,
  //     );

  //     // Upload extracted files to Firebase Storage
  //     FirebaseStorage storage = FirebaseStorage.instance;

  //     for (var entry in tempDir.listSync()) {
  //       if (entry is File) {
  //         String fileName = entry.path.split('/').last;
  //         Reference ref = storage.ref().child('mp3_files/$fileName');
  //         await ref.putFile(entry);
  //         String downloadUrl = await ref.getDownloadURL();
  //         fileUrls.add(downloadUrl);
  //       }
  //       notifyListeners();
  //     }

  //     // // Save URLs to Firestore
  //     // CollectionReference filesRef =
  //     //     FirebaseFirestore.instance.collection('files');
  //     // for (String url in fileUrls) {
  //     //   await filesRef.add({'url': url});
  //     // }

  //     // Clean up temp directory
  //     // await tempDir.delete(recursive: true);
  //   }
  // }

  //  File? pickedFile;

  // Future<void> pickMp3File() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['mp3'],
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.first;
  //     File choosenFile = File(file.path!);
  //     pickedFile = choosenFile;
  //     notifyListeners();
  //     log('Picked MP3 file: ${file.name}');
  //     // Handle the selected file here
  //   } else {
  //     // User canceled the picker
  //     log('User canceled the picker');
  //   }
  // }

  // setNullPickedFile() {
  //   pickedFile = null;
  //   notifyListeners();
  // }
}
