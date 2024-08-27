import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/add_note_screen/model/gallery_loader.dart';
import 'package:social_notes/screens/add_note_screen/model/video_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/pexels_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_notes/screens/add_note_screen/provider/player_provider.dart';
import 'package:social_notes/screens/add_note_screen/view/add_note_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/custom_gallery.dart';
import 'package:social_notes/screens/add_note_screen/view/trim_screen.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/custom_video_player.dart';
import 'package:social_notes/screens/add_note_screen/view/widgets/file_video_player.dart';

class AddBackgroundScreen extends StatefulWidget {
  const AddBackgroundScreen({super.key});

  @override
  State<AddBackgroundScreen> createState() => _AddBackgroundScreenState();
}

class _AddBackgroundScreenState extends State<AddBackgroundScreen> {
  final ScrollController _photoController = ScrollController();
  final ScrollController _videoController = ScrollController();
  List<String> imageExt = [
    'jpg',
    'jpeg',
    'png',
  ];
  List<String> mediaExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'mp4',
    'm4v',
    'mov',
    'avi',
    'flv',
  ];

  @override
  void initState() {
    super.initState();
    // fetchGallery();
    SchedulerBinding.instance.scheduleFrameCallback((timer) {
      //  making the previously selected video null so it dispose properly

      Provider.of<NoteProvider>(context, listen: false).setNullSelectedVideo();
      if (Provider.of<NoteProvider>(context, listen: false)
          .selectedVideo
          .isNotEmpty) {
        Provider.of<PlayerProvider>(context, listen: false)
            .disposeVideoPlayer();
      }
      //   function to load more videos after  a limit reached

      Provider.of<PexelsProvider>(context, listen: false).loadMoreVideos();

      // functions to add listener when the certain position reaches

      _photoController.addListener(_onScroll);
      _videoController.addListener(_onVideoScroll);
    });
  }

  //  on scroll after loading 20 images laod more

  void _onScroll() {
    if (_photoController.position.atEdge) {
      if (_photoController.position.pixels != 0) {
        Provider.of<PexelsProvider>(context, listen: false).loadMore();
      }
    }
  }

  //  on scroll to load more videos after loading the previously set limit reached

  void _onVideoScroll() {
    if (_videoController.position.atEdge) {
      if (_videoController.position.pixels != 0) {
        Provider.of<PexelsProvider>(context, listen: false).loadMoreVideos();
      }
    }
  }

  // _handleScrollEvent(ScrollNotification scroll) {
  //   if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
  //     Provider.of<PexelsProvider>(context, listen: false).loadMoreVideos();

  //   }
  //   return false;
  // }

  //  dispose the every single controller when we no longer needs it

  @override
  void dispose() {
    _photoController.removeListener(_onScroll);
    _videoController.removeListener(_onVideoScroll);
    _photoController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  getting the providers to call the functions

    var pexelPro = Provider.of<PexelsProvider>(context, listen: false);
    var notePro = Provider.of<NoteProvider>(context, listen: false);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              Provider.of<PexelsProvider>(context, listen: false)
                  .setSearching(false);
              navPop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 30,
            )),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Background',
          style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: PopScope(
        onPopInvoked: (value) {
          if (value) {
            // when we go back to the prevoius screen the search should be removed

            Provider.of<PexelsProvider>(context, listen: false)
                .setSearching(false);
          }
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //  tabs to show the data

                //  tab to show the custom gallery managed through provider

                InkWell(
                  onTap: () {
                    pexelPro.setSelectedFilter('upload');
                  },
                  child:
                      Consumer<PexelsProvider>(builder: (context, pexelPro, _) {
                    return Text(
                      'My Media',
                      style: TextStyle(
                          color: pexelPro.selectedFilter.contains('upload')
                              ? primaryColor
                              : blackColor,
                          fontFamily: fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    );
                  }),
                ),

                //  tab to show api images
                InkWell(
                  onTap: () {
                    Provider.of<PexelsProvider>(context, listen: false)
                        .setSelectedFilter('photos');
                  },
                  child:
                      Consumer<PexelsProvider>(builder: (context, pexelPro, _) {
                    return Text(
                      'Stock Photos',
                      style: TextStyle(
                          color: pexelPro.selectedFilter.contains('photos')
                              ? primaryColor
                              : blackColor,
                          fontFamily: fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    );
                  }),
                ),

                //  tab to show the videos

                InkWell(
                  onTap: () {
                    pexelPro.setSelectedFilter('videos');
                  },
                  child:
                      Consumer<PexelsProvider>(builder: (context, pexelPro, _) {
                    return Text(
                      'Stock Videos',
                      style: TextStyle(
                          color: pexelPro.selectedFilter.contains('videos')
                              ? primaryColor
                              : blackColor,
                          fontFamily: fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    );
                  }),
                ),
              ],
            ),

            //  on gallery show the text

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10).copyWith(bottom: 10),
              child: Consumer<PexelsProvider>(builder: (context, apiPro, _) {
                return apiPro.selectedFilter.contains('upload')
                    ? Text(
                        'Images & Videos should be 9:16 format',
                        style: TextStyle(
                            fontFamily: fontFamily,
                            color: const Color(0xff868686),
                            fontWeight: FontWeight.w600),
                      )

                    //  on photos and videos tabs show the search field

                    : TextFormField(
                        onChanged: (value) {
                          if (apiPro.selectedFilter.contains('photos')) {
                            if (value.isNotEmpty) {
                              var pexelPro = Provider.of<PexelsProvider>(
                                  context,
                                  listen: false);

                              pexelPro.setSearching(true);
                              pexelPro.clearSearchImages();

                              //  hitting api function to get the photos on user searched text

                              pexelPro.searchPhotos(value);
                            } else {
                              var pexelPro = Provider.of<PexelsProvider>(
                                  context,
                                  listen: false);
                              pexelPro.setSearching(false);
                              pexelPro.clearSearchImages();
                            }
                          } else {
                            if (value.isNotEmpty) {
                              var pexelPro = Provider.of<PexelsProvider>(
                                  context,
                                  listen: false);

                              pexelPro.setSearching(true);
                              pexelPro.clearSearchVideos();

                              //  hitting api function to get the videos on user searched text

                              pexelPro.searchVideo(value);
                            } else {
                              var pexelPro = Provider.of<PexelsProvider>(
                                  context,
                                  listen: false);
                              pexelPro.setSearching(false);
                              pexelPro.clearSearchVideos();
                            }
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          contentPadding:
                              const EdgeInsets.only(top: 1, bottom: 5),
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                          ),
                          fillColor: Colors.grey[300],
                          filled: true,
                          constraints: BoxConstraints(
                            maxHeight: 40,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                        ),
                      );
              }),
            ),
            Consumer<PexelsProvider>(builder: (context, imagePro, _) {
              //  filtering the videos based on the quality

              List<VideoFile> videoFiles = [];
              List<String> videoImages = [];
              videoImages.clear();
              videoFiles.clear();

              // before adding to the list the list should be clear

              // filtering based on qaulity and also for the searched videos

              if (imagePro.isSearching) {
                for (var video in imagePro.searchVideos) {
                  for (var file in video.videoFiles) {
                    if (file.height == 960 && file.width == 540) {
                      videoFiles.add(file);
                      videoImages.add(video.image);
                    }
                  }
                }
              } else {
                for (var video in imagePro.videos) {
                  for (var file in video.videoFiles) {
                    if (file.height == 960 && file.width == 540) {
                      videoFiles.add(file);
                      videoImages.add(video.image);
                    }
                  }
                }
                // videoFiles = video.videoFiles.where((file) {
                //   if (file.height <= 640 && file.width <= 360) {
                //     return true;
                //   }
                //   return false;
                // }).toList();
              }
              log('video files link $videoFiles');

              // if the user is in video tab show the videos grid

              return imagePro.selectedFilter.contains('videos')
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: GridView.builder(
                          controller: _videoController,
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: videoFiles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  // mainAxisSpacing: 3,
                                  // crossAxisSpacing: 3,
                                  crossAxisCount: 3,
                                  mainAxisExtent: size.height * 0.18),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(3),
                              child: InkWell(
                                onTap: () {
                                  //  defining the type and adding the background video and saving in the provider

                                  notePro.setIsGalleryVideo(false);
                                  notePro.setFileType('video');
                                  notePro
                                      .setSelectedVideo(videoFiles[index].link);
                                  notePro.setEmptySelectedImage();
                                  Provider.of<PlayerProvider>(context,
                                          listen: false)
                                      .initialize(videoFiles[index].link);
                                  navPop(context);
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      height: size.height * 0.18,
                                      width: size.width * 0.32,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                              height: 130,
                                              width: 120,
                                              fit: BoxFit.cover,
                                              imageUrl: videoImages[index])),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )

                  //  if the user is in photos tab show the photos

                  : imagePro.selectedFilter.contains('photos')
                      ? Expanded(
                          child: GridView.builder(
                            controller: _photoController,
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: imagePro.isSearching
                                ? imagePro.searchedImages.length
                                : imagePro.images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, mainAxisExtent: 130),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(3),
                                child: InkWell(
                                  onTap: () {
                                    //  defining the type and adding the background photo and saving in provider

                                    notePro.setIsGalleryVideo(false);
                                    notePro.setNullSelectedVideo();
                                    notePro.setFileType('photo');
                                    notePro.setSelectedImage(imagePro
                                            .isSearching
                                        ? imagePro
                                            .searchedImages[index].src.portrait
                                        : imagePro.images[index].src.portrait);
                                    navPop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    height: size.height * 0.18,
                                    width: size.width * 0.32,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                          imageUrl: imagePro.isSearching
                                              ? imagePro.searchedImages[index]
                                                  .src.portrait
                                              : imagePro
                                                  .images[index].src.portrait,
                                          fit: BoxFit.cover,
                                          height: size.height * 0.18,
                                          width: size.width * 0.32),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )

                      //  this would be in loading position when the user add something from the gallery

                      : imagePro.isLoading
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: LinearProgressIndicator(
                                value: imagePro.uploadProgress,
                                minHeight: 10,
                                backgroundColor: blackColor,
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )

                          //  if certain conditions met  the show the video

                          : imagePro.imageFile != null ||
                                  imagePro.videoFile != null ||
                                  imagePro.editedVideo != null
                              ? InkWell(
                                  onTap: () async {
                                    if (imagePro.editedVideo != null) {
                                      pexelPro.setIsLoading(true);
                                      String url = await AddNoteController()
                                          .uploadFile('backgroundVideos',
                                              imagePro.editedVideo!, context);
                                      notePro.setFileType('video');
                                      notePro.setSelectedImage(url);
                                      pexelPro.setIsLoading(false);
                                      pexelPro.setEditedVideoNull();
                                      navPop(context);
                                    } else if (imagePro.imageFile == null) {
                                      //  if the video from the gallery have not trimmed show again the trim screen

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TrimmerView(
                                                imagePro.videoFile!, ''),
                                          ));
                                    } else {
                                      //  for photo just directly uplods to the storage and then go back to add post screen

                                      Provider.of<PexelsProvider>(context,
                                              listen: false)
                                          .setIsLoading(true);
                                      String url = await AddNoteController()
                                          .uploadFile('backgroundImage',
                                              imagePro.imageFile!, context);
                                      notePro.setFileType('photo');
                                      notePro.setSelectedImage(url);
                                      pexelPro.setIsLoading(false);

                                      navPop(context);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    height: 130,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: imagePro.imageFile == null
                                          ? FileVideoPlayer(
                                              videoUrl:
                                                  imagePro.editedVideo != null
                                                      ? imagePro.editedVideo!
                                                      : imagePro.videoFile!,
                                              height: 130,
                                              width: 120,
                                            )
                                          : Image(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                imagePro.imageFile!,
                                              )),
                                    ),
                                  ),
                                )

                              //  if the user is in upload tab show the custom gallery

                              : Expanded(child: CustomGallery());
            }),
          ],
        ),
      ),
    );
  }
}
