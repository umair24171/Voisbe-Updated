import 'dart:developer';
import 'dart:io';
// import 'dart:html';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/add_note_screen/model/personalize_model.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/model/book_mark_model.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';
import 'package:social_notes/screens/home_screen/model/sub_comment_model.dart';
// import 'package:social_notes/screens/home_screen/provider/filter_provider.dart';
import 'package:social_notes/screens/notifications_screen/model/comment_notofication_model.dart';
// import 'package:social_notes/screens/notifications_screen/model/like_notification.dart';

class DisplayNotesProvider with ChangeNotifier {
  List<NoteModel> notes = [];
  List<UserModel> likedUsers = [];
  List<NoteModel> currentUserPosts = [];
  bool isExist = false;
  // PersonalizeModel? userPersonalizeData;
  List<UserModel> allUsers = [];
  List<UserModel> searchedUsers = [];
  bool isSearching = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int changeIndex = 0;
  late AudioPlayer audioPlayer;
  bool isHomeActive = true;
  bool isLoading = false;

  setIsloading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  initializeAudioPlayer() {
    audioPlayer = AudioPlayer();
  }

  // DisplayNotesProvider() {
  //   _initAudioPlayer();
  // }

  void setHomeActive(bool active) {
    isHomeActive = active;
    if (!active) {
      pausePlayer();
    }
    notifyListeners();
  }

  // Future<void> pausePlayer() async {
  //   if (audioPlayer.state == PlayerState.playing) {
  //     await audioPlayer.pause();
  //     setIsPlaying(false);
  //   }
  // }

  updateTag(String noteId, String userID, int index) {
    notes[index].tagPeople.remove(userID);
    notifyListeners();
  }

  addOneNote(NoteModel note) {
    notes.insert(0, note);
    notifyListeners();
  }

  void _initAudioPlayer() {
    audioPlayer.onPlayerComplete.listen((event) {
      setIsPlaying(false);
      setChangeIndex(-1);
      setPosition(Duration.zero);
    });

    audioPlayer.onPositionChanged.listen((position) {
      setPosition(position);
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setDuration(duration);
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    audioPlayer!.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // void activate() {
  //   if (!_isActive) {
  //     _isActive = true;
  //     initAudioPlayers();
  //   }
  // }

  // void deactivate() {
  //   if (_isActive) {
  //     _isActive = false;
  //     pausePlayer();
  //     disposePlayer();
  //   }
  // }

  initAudioPlayers() {
    audioPlayer = AudioPlayer();
    notifyListeners();
  }

  Future<void> pausePlayer() async {
    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.pause();
      setIsPlaying(false);
    }
  }

  setChangeIndex(int index) {
    changeIndex = index;
    notifyListeners();
  }

  setDuration(Duration dura) {
    duration = dura;
    notifyListeners();
  }

  setPosition(Duration posi) {
    position = posi;
    notifyListeners();
  }

  playAudioPlayer(String url, int index) async {
    if (audioPlayer == null) {
      print("AudioPlayer is null. Initializing...");
      audioPlayer = AudioPlayer(); // Or however you initialize your AudioPlayer
    }

    try {
      await audioPlayer!.play(UrlSource(url));
      setChangeIndex(index);
      setIsPlaying(true);

      Duration? audioDuration = await audioPlayer!.getDuration();
      if (audioDuration != null) {
        setDuration(audioDuration);
      } else {
        print("Failed to get audio duration");
      }
    } catch (e) {
      print("Error playing audio: $e");
      setIsPlaying(false);
    }

    notifyListeners();
  }

  resumeAudioPlayer() {
    audioPlayer!.resume();
    notifyListeners();
  }

  disposePlayer() {
    log('player disposed');
    audioPlayer!.stop();
    audioPlayer!.dispose();
    notifyListeners();
  }

  setIsPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  void playPause(String url, int index) async {
    FileInfo? fileInfo;
    if (Platform.isAndroid) {
      final cacheManager = DefaultCacheManager();
      fileInfo = await cacheManager.getFileFromCache(url);

      if (fileInfo == null) {
        // File is not cached, download and cache it
        try {
          fileInfo = await cacheManager.downloadFile(url, key: url);
        } catch (e) {
          print('Error downloading file: $e');
          return;
        }
      }
    }

    // Use the cached file for playback
    if (isPlaying && changeIndex != index) {
      // await audioPlayer!.stop();
      pausePlayer();
      setChangeIndex(-1);
      setIsPlaying(false);
    }

    if (changeIndex == index && isPlaying) {
      if (audioPlayer!.state == PlayerState.playing) {
        pausePlayer();
        setChangeIndex(-1);
        setIsPlaying(false);
      } else {
        resumeAudioPlayer();
        setChangeIndex(index);
        setIsPlaying(true);
      }
    } else {
      playAudioPlayer(fileInfo?.file.path ?? url, index);
    }

    audioPlayer!.onPositionChanged.listen((event) {
      if (changeIndex == index) {
        setPosition(event);
      }
    });
    audioPlayer!.onPlayerComplete.listen((event) {
      setChangeIndex(-1);
      setIsPlaying(false);
      setPosition(Duration.zero);
    });
  }

  // void playPause(String url, int index) async {
  //   FileInfo? fileInfo;
  //   if (Platform.isAndroid) {
  //     final cacheManager = DefaultCacheManager();
  //     fileInfo = await cacheManager.getFileFromCache(url);

  //     if (fileInfo == null) {
  //       // File is not cached, download and cache it
  //       try {
  //         fileInfo = await cacheManager.downloadFile(url, key: url);
  //       } catch (e) {
  //         print('Error downloading file: $e');
  //         return;
  //       }
  //     }
  //   }

  //   // Use the cached file for playback
  //   if (isPlaying && changeIndex != index) {
  //     // await audioPlayer!.stop();
  //     pausePlayer();
  //     setChangeIndex(-1);
  //     setIsPlaying(false);
  //   }

  //   if (changeIndex == index && isPlaying) {
  //     if (audioPlayer!.state == PlayerState.playing) {
  //       pausePlayer();
  //       setChangeIndex(-1);
  //       setIsPlaying(false);
  //     } else {
  //       resumeAudioPlayer();
  //       setChangeIndex(index);
  //       setIsPlaying(true);
  //     }
  //   } else {
  //     playAudioPlayer(fileInfo?.file.path ?? url, index);
  //   }

  //   audioPlayer!.onPositionChanged.listen((event) {
  //     if (changeIndex == index) {
  //       setPosition(event);
  //     }
  //   });
  //   audioPlayer!.onPlayerComplete.listen((event) {
  //     setChangeIndex(-1);
  //     setIsPlaying(false);
  //     setPosition(Duration.zero);
  //   });
  // }

  setIsSearching(bool value) {
    isSearching = value;
    notifyListeners();
  }

  clearSearchedUsers() {
    searchedUsers.clear();
    notifyListeners();
  }

  setSearchedUsers(UserModel user) {
    searchedUsers.add(user);
    notifyListeners();
  }

  // Map<int, bool> voicesMap = {};

  removeNote(NoteModel note) {
    notes.remove(note);
    notifyListeners();
  }

  getAllUsers() async {
    await FirebaseFirestore.instance.collection('users').get().then((value) {
      allUsers = value.docs.map((e) => UserModel.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getCurrentUserPosts() {
    currentUserPosts = notes
        .where((element) =>
            element.userUid == FirebaseAuth.instance.currentUser!.uid)
        .toList();
    notifyListeners();
  }

  addLikeInProvider(String postId) async {
    for (var element in notes) {
      if (element.noteId == postId) {
        element.likes.add(FirebaseAuth.instance.currentUser!.uid);
      } else {
        element.likes.remove(FirebaseAuth.instance.currentUser!.uid);
      }
    }
    notifyListeners();
  }

  getAllNotes(context) async {
    await _firestore
        .collection('notes')
        .orderBy('publishedDate', descending: true)
        .get()
        .then((value) {
      List<NoteModel> notesAll =
          value.docs.map((e) => NoteModel.fromMap(e.data())).toList();

      // for (var note in notesAll) {
      //   if (user.blockedUsers.contains(note.userUid)) {
      //     notesAll.remove(note);
      //   }
      // }

      notes = notesAll;
      notifyListeners();
      // Provider.of<FilterProvider>(context, listen: false)
      //     .setDetailNote(notesAll.first);
    });
  }

  addComment(String postId, String commentId, CommentModel commentModel,
      context) async {
    try {
      await _firestore
          .collection('notes')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(commentModel.toMap());
    } catch (e) {
      Provider.of<NoteProvider>(context, listen: false).setIsLoading(false);
      log(e.toString());
    }
  }

  addSubComment(SubCommentModel subCommentModel, context) async {
    try {
      await _firestore
          .collection('notes')
          .doc(subCommentModel.postId)
          .collection('comments')
          .doc(subCommentModel.commentId)
          .collection('subComments')
          .doc(subCommentModel.subCommentId)
          .set(subCommentModel.toMap());
    } catch (e) {
      Provider.of<NoteProvider>(context, listen: false).setIsLoading(false);
      log(e.toString());
    }
  }

  List<CommentModel> allComments = [];

  addOneComment(CommentModel commentModel) {
    allComments.add(commentModel);
    notifyListeners();
  }

  displayAllComments(String postId) async {
    allComments.clear();
    await _firestore
        .collection('notes')
        .doc(postId)
        .collection('comments')
        .get()
        .then((value) {
      allComments =
          value.docs.map((e) => CommentModel.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  likePost(
      List likes,
      String postId,
      CommentNotoficationModel commentNotoficationModel,
      String userToken,
      String userName,
      String userId,
      String currentUserID,
      context) async {
    if (likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      likes.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      likes.add(FirebaseAuth.instance.currentUser!.uid);
      DocumentSnapshot<Map<String, dynamic>> userModel = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .get();

      UserModel toNotiUser = UserModel.fromMap(userModel.data()!);
      if (toNotiUser.isLike && currentUserID != userId) {
        addLikeNotification(commentNotoficationModel);
        NotificationMethods.sendPushNotification(userId, userToken,
            'liked your post', userName, 'notification', '', context);
      }
    }
    await _firestore.collection('notes').doc(postId).update({
      'likes': likes,
    });
  }

  addLikeNotification(CommentNotoficationModel likeNotification) async {
    try {
      await _firestore
          .collection('commentNotifications')
          .doc(likeNotification.notificationId)
          .set(likeNotification.toMap());
    } catch (e) {
      log(e.toString());
    }
  }

  List<BookmarkModel> bookMarkPosts = [];

  getBookMarkPosts() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('bookmarks')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    bookMarkPosts =
        snapshot.docs.map((e) => BookmarkModel.fromMap(e.data())).toList();
    notifyListeners();
  }

  deleteBookMark(String id) async {
    bookMarkPosts.removeWhere(
      (book) => book.postId == id,
    );

    notifyListeners();
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .where('postId', isEqualTo: id)
        .get()
        .then((value) async {
      BookmarkModel model = BookmarkModel.fromMap(value.docs.first.data());
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(model.bookmarkId)
          .delete();
    });
  }

  addPostToSaved(BookmarkModel bookmarkModel, context) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('bookmarks')
        .where('userId', isEqualTo: bookmarkModel.userId)
        .get();
    bool isSaved = false;
    BookmarkModel? book;
    for (var doc in snapshot.docs) {
      BookmarkModel bookmark = BookmarkModel.fromMap(doc.data());
      if (bookmark.postId == bookmarkModel.postId) {
        // savedNoteModel = savedNote;
        book = bookmark;
        isSaved = true;
        break;
      }
    }
    if (isSaved) {
      await _firestore.collection('bookmarks').doc(book!.bookmarkId).delete();
      // bookMarkPosts
      //     .removeWhere((element) => element.postId == bookmarkModel.postId);
      // notifyListeners();
      // showSnackBar(context, 'Post removed from saved');
      log('deleted');
    } else {
      await _firestore
          .collection('bookmarks')
          .doc(bookmarkModel.bookmarkId)
          .set(bookmarkModel.toMap());
      // bookMarkPosts.add(bookmarkModel);
      // notifyListeners();
      // showSnackBar(context, 'Post saved');
      log('saved');
    }
  }

  // get all comments
  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  List<CommentModel> _firstThreeComments = [];
  List<CommentModel> get firstThreeComments => _firstThreeComments;

  getComments(List<CommentModel> comments) async {
    _comments = comments;
    getFirstThreeComments();
    getOtherComments();
    notifyListeners();
  }

  // get the other comments list
  List<CommentModel> _otherComments = [];
  List<CommentModel> get otherComments => _otherComments;

  getFirstThreeComments() async {
    _firstThreeComments =
        _comments.length > 3 ? _comments.sublist(0, 3) : _comments;
    notifyListeners();
  }

  getOtherComments() async {
    _otherComments.clear(); // Clear the existing list

    if (_comments.length > 3) {
      _otherComments.addAll(_comments.getRange(3, _comments.length).take(3));
    }

    notifyListeners();
  }

  getAllLikedUsers(List likes) async {
    try {
      await _firestore
          .collection('users')
          .where('uid', whereIn: likes)
          .get()
          .then((value) {
        likedUsers =
            value.docs.map((e) => UserModel.fromMap(e.data())).toList();
        notifyListeners();
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
