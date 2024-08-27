import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/add_note_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/trim_screen.dart';
// import 'package:video_compress/video_compress.dart';

class CustomGallery extends StatefulWidget {
  @override
  _CustomGalleryState createState() => _CustomGalleryState();
}

class _CustomGalleryState extends State<CustomGallery> {
  List<Widget> _mediaList = [];
  int currentPage = 0;
  int? lastPage;

  @override
  void initState() {
    super.initState();

    //  function to get the custom gallery

    _fetchNewMedia();
  }

  //  function to load data from gallery after reaching to certain position

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
    return false;
  }

  Future<File> convertUint8ListToFile(
      Uint8List uint8List, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    log("File path: $filePath");
    return await file.writeAsBytes(uint8List).catchError((error) {
      log("Error writing file: $error");
      throw error;
    });
  }

  _fetchNewMedia() async {
    var size = MediaQuery.of(context).size;
    lastPage = currentPage;
    var result = await PhotoManager.requestPermissionExtend();
    if (result.hasAccess) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
      );
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: currentPage, size: 60);
      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(420, 800)),
            builder:
                (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return SizedBox(
                    height: size.height * 0.18,
                    width: size.width * 0.32,
                    child: InkWell(
                      onTap: () async {
                        var pexelPro =
                            Provider.of<PexelsProvider>(context, listen: false);
                        var notePro =
                            Provider.of<NoteProvider>(context, listen: false);
                        File file = await convertUint8ListToFile(
                            snapshot.data!, asset.title!);
                        if (asset.type == AssetType.video) {
                          // if the selected file is video then got to trim screen

                          File? videoFile = await asset.file;
                          log('video file is $videoFile');

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TrimmerView(videoFile!, asset.title!),
                              ));
                        } else {
                          // if the selected file is photo then uplaod it in storage and move back to the add note screen

                          navPop(context);
                          pexelPro.setIsLoading(true);

                          String url = await AddNoteController()
                              .uploadImage('backgroundImage', file, context);
                          notePro.setFileType('photo');
                          notePro.setSelectedImage(url);
                          pexelPro.setIsLoading(false);
                        }
                      },
                      child: Container(
                        height: size.height * 0.18,
                        // width: 120,
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.memory(
                                snapshot.data!,
                                height: size.height * 0.18,
                                width: size.width * 0.32,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (asset.type == AssetType.video)
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5, bottom: 5),
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('Error loading thumbnail'));
                }
              }
              //  showing the loader while the data is loading

              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        return _handleScrollEvent(scroll);
      },
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: _mediaList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // mainAxisSpacing: 3,
            // crossAxisSpacing: 3,
            crossAxisCount: 3,
            mainAxisExtent: size.height * 0.18),
        itemBuilder: (BuildContext context, int index) {
          //  showing the gallery grid

          return Padding(
            padding: const EdgeInsets.all(3),
            child: _mediaList[index],
          );
        },
      ),
    );
  }
}
