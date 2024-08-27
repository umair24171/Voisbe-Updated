import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_notes/screens/add_note_screen/model/image_model.dart';
import 'package:social_notes/screens/add_note_screen/model/pixabay_video.dart';
import 'package:social_notes/screens/add_note_screen/model/video_model.dart';
import 'package:path/path.dart' as path;
import 'package:social_notes/screens/add_note_screen/view/trim_screen.dart';
// import 'package:video_compress/video_compress.dart';

class PexelsProvider with ChangeNotifier {
  String API = "fN0HDzN9vlRkK18bjp2vO9ADib5MV8bQOwqfsvgmUourmsY3JMvMxC3z";
  String pexaBayKey = "44779583-00265e068b4a216f6c2c2cc69";
  String Url = "https://api.pexels.com/v1/curated?per_page=20";
  String videoUrl = "https://api.pexels.com/videos/popular?per_page=80";
  String pexabayUrl =
      "https://pixabay.com/api/videos/?key=44779583-00265e068b4a216f6c2c2cc69";
  String searchUrl =
      "https://api.pexels.com/v1/search?query=nature&per_page=10";
  String searchVideoUrl =
      "https://api.pexels.com/videos/search?query=nature&per_page=1";
  int page = 1;

  List<File> filesVideos = [];
  File? imageFile;
  File? videoFile;
  File? editedVideo;
  bool isLoading = false;
  bool isSearching = false;
  List<PhotoModel> searchedImages = [];
  List<PexelsVideo> videos = [];
  List<PexelsVideo> searchVideos = [];
  String selectedFilter = 'upload';
  double uploadProgress = 0.0;

  //  changing the uplaod progress of the video
  void setUploadProgress(double progress) {
    uploadProgress = progress;
    notifyListeners();
  }

//  setting the picked images null
  setImageNull() {
    imageFile = null;
    notifyListeners();
  }

  //  setting the picked video null or remove

  setVideoNull() {
    videoFile = null;
    notifyListeners();
  }

  //  setting the trimmed video null

  setEditedVideoNull() {
    editedVideo = null;
    notifyListeners();
  }

  //  adding the api videos to a varibale

  setFileVideos(File fil) {
    filesVideos.add(fil);
    notifyListeners();
  }

  //  change loading value

  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // changing the tab value in background screen

  setSelectedFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  //  changing the value of search

  setSearching(bool value) {
    isSearching = value;
    notifyListeners();
  }

  //  all the images of api would store in this variable

  List<PhotoModel> images = [];

  // fetching the photos through apis and saving in the list

  fetchPhotos() async {
    final response = await http.get(
      Uri.parse(Url),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> photosJson = data['photos'];
      List<PhotoModel> photos =
          photosJson.map((json) => PhotoModel.fromJson(json)).toList();
      setImages(photos);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  //  changing page for every load

  changePage() {
    page = page + 1;
    notifyListeners();
  }

  // loading more photos

  loadMore() async {
    changePage();
    log('page numbr $page');
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/curated?per_page=20&page=$page'),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> photosJson = data['photos'];
      List<PhotoModel> photos =
          photosJson.map((json) => PhotoModel.fromJson(json)).toList();
      addAllImages(photos);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  // fetchCompressVideos() async {
  //   final response = await http.get(
  //     Uri.parse(videoUrl),
  //     headers: {
  //       'Authorization': API,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> data = json.decode(response.body);
  //     List<dynamic> videoJson = data['videos'];
  //     log('videos are $videoJson');
  //     List<PexelsVideo> video =
  //         videoJson.map((json) => PexelsVideo.fromJson(json)).toList();
  //     for (var vide in video) {
  //       File? file = await downloadAndCompressVideo(vide.videoFiles.last.link);
  //       setFileVideos(file!);
  //     }
  //     // log('videos are $video');
  //     // setVideos(video);
  //   } else {
  //     throw Exception('Failed to load photos');
  //   }
  // }

  int videoPage = 1;

  // changing the video page

  setVideoPage() {
    videoPage = videoPage + 1;
    notifyListeners();
  }

  //  loading more videos with changing page

  loadMoreVideos() async {
    setVideoPage();
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/videos/popular?per_page=100&page=$videoPage'),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> videoJson = data['videos'];
      log('videos are $videoJson');
      List<PexelsVideo> video =
          videoJson.map((json) => PexelsVideo.fromJson(json)).toList();
      // log('videos are $video');
      addAllVideos(video);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  //  fetching videos

  fetchVideos() async {
    final response = await http.get(
      Uri.parse(videoUrl),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> videoJson = data['videos'];
      log('videos are $videoJson');
      List<PexelsVideo> video =
          videoJson.map((json) => PexelsVideo.fromJson(json)).toList();
      // log('videos are $video');
      setVideos(video);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  //  clearing search videos from the list

  clearSearchVideos() {
    searchVideos.clear();
    notifyListeners();
  }

  //  searching videos based on the query

  searchVideo(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/videos/search?query=$query&per_page=80'),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> videoJson = data['videos'];
      log('videos are $videoJson');
      List<PexelsVideo> video =
          videoJson.map((json) => PexelsVideo.fromJson(json)).toList();
      // log('videos are $video');
      setSearchVideos(video);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  // api of the pexabay videos to fetch videos

  fetchPexaVideos() async {
    final response = await http.get(
      Uri.parse(pexabayUrl),
      // headers: {
      //   'Authorization': API,
      // },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> videoJson = data['hits'];
      log('videos are $videoJson');
      List<PixabayVideo> video =
          videoJson.map((json) => PixabayVideo.fromJson(json)).toList();
      // log('videos are $video');
      // setVideos(video);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  //  search photos based on the query

  searchPhotos(String searchQuery) async {
    changePage();
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/v1/search?query=$searchQuery&per_page=80'),
      headers: {
        'Authorization': API,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> photosJson = data['photos'];
      List<PhotoModel> photos =
          photosJson.map((json) => PhotoModel.fromJson(json)).toList();
      setSearchedImages(photos);
    } else {
      throw Exception('Failed to load photos');
    }
  }

  // clearing the searched images from the list

  clearSearchImages() {
    searchedImages.clear();
    notifyListeners();
  }

  //  setting images from the api

  setImages(List<PhotoModel> photos) {
    images = photos;
    notifyListeners();
  }

  // adding all the images coming from the api

  addAllImages(List<PhotoModel> photos) {
    images.addAll(photos);
    notifyListeners();
  }

  // setting videos in the list

  setVideos(List<PexelsVideo> video) {
    videos = video;
    notifyListeners();
  }

  //  add search videos

  setSearchVideos(List<PexelsVideo> video) {
    searchVideos = video;
    notifyListeners();
  }

  //  adding all the videos

  addAllVideos(List<PexelsVideo> video) {
    videos.addAll(video);
    notifyListeners();
  }

  //  adding the searched images to the list

  setSearchedImages(List<PhotoModel> photos) {
    searchedImages = photos;
    notifyListeners();
  }

  // Future<File?> downloadAndCompressVideo(String url) async {
  //   // Step 1: Download the video
  //   final http.Response response = await http.get(Uri.parse(url));
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final String tempPath = tempDir.path;
  //   final String filePath = '$tempPath/temp_video.mp4';
  //   final File file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);

  //   // Step 2: Compress the video
  //   // final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
  //   //   filePath,
  //   //   quality: VideoQuality.MediumQuality,
  //   //   deleteOrigin: true, // Delete the original file
  //   // );

  //   // Return the compressed video file
  //   // return compressedVideo?.file;
  // }

  //  pick image functiona and saving into the variable

  pickImage() {
    setVideoNull();
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        notifyListeners();
      }
    });
  }

  //  pick media including photos and videos

  pickMedia(context) {
    setVideoNull();
    setEditedVideoNull();
    ImagePicker().pickMedia().then((value) {
      if (value != null) {
        String path = value.path;
        bool isPhoto = isImage(path);
        // bool isPlayer = isImage(path);
        if (isPhoto) {
          imageFile = File(value.path);

          notifyListeners();
        } else {
          setImageNull();
          videoFile = File(value.path);
          notifyListeners();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrimmerView(videoFile!, ''),
              ));
        }
      }
    });
  }

  //  removing the gallery video

  setGalleryVideoFile(File file) {
    editedVideo = file;
    notifyListeners();
  }

  bool isImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.gif';
  }

  bool isVideo(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.mp4' ||
        extension == '.mov' ||
        extension == '.avi' ||
        extension == '.wmv' ||
        extension == '.flv';
  }

  //  picking just the video from the gallery

  pickVideo() {
    setImageNull();
    ImagePicker().pickVideo(source: ImageSource.gallery).then((value) {
      if (value != null) {
        videoFile = File(value.path);
        notifyListeners();
      }
    });
  }

  // setImages(List<PhotoModel> photos) {
  //   images = photos;
  //   notifyListeners();
  // }
}
