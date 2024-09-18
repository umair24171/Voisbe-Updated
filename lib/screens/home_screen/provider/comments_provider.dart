// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:social_notes/screens/auth_screens/model/user_model.dart';
// import 'package:social_notes/screens/home_screen/model/comment_modal.dart';

// class CommentManager {
//   List<CommentModel> _allComments = [];
//   List<CommentModel> get visibleComments => _filterComments();
//   List<CommentModel> get sheetComments => _sortSheetComments();
//   List<int> closeFriendIndexes = [];
//   List<int> subscriberCommentsIndexes = [];
//   List<int> remainingCommentsIndex = [];
//   int engageCommentIndex = -1;

//   StreamSubscription<QuerySnapshot>? _subscription;
//   Function(void Function()) setState;
//   bool _isInitialized = false;
//   SharedPreferences? _prefs;
//   UserModel? _currentUser;
//   UserModel? _currentNoteUser;

//   CommentManager(this.setState);

//   Future<void> initComments(
//       String postId, UserModel currentUser, UserModel? currentNoteUser) async {
//     if (_isInitialized) {
//       print('CommentManager is already initialized');
//       return;
//     }

//     try {
//       _prefs = await SharedPreferences.getInstance();
//       _currentUser = currentUser;
//       _currentNoteUser = currentNoteUser;

//       _subscription = FirebaseFirestore.instance
//           .collection('notes')
//           .doc(postId)
//           .collection('comments')
//           .orderBy('time', descending: true)
//           .snapshots()
//           .listen((snapshot) {
//         _allComments =
//             snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();
//         _updateCommentIndexes();
//         setState(() {});
//       }, onError: (error) {
//         print('Error in comment stream: $error');
//       });

//       _isInitialized = true;
//     } catch (e) {
//       print('Error initializing CommentManager: $e');
//     }
//   }

//   List<CommentModel> _filterComments() {
//     if (_prefs == null || _currentUser == null) {
//       return _allComments; // Return all comments if prefs or current user is not initialized
//     }
//     List<String> hiddenCommentIds =
//         _prefs!.getStringList(_currentUser!.uid) ?? [];
//     return _allComments
//         .where((comment) => !hiddenCommentIds.contains(comment.commentid))
//         .toList();
//   }

//   List<CommentModel> _sortSheetComments() {
//     List<CommentModel> filtered = _filterComments();
//     if (filtered.isEmpty) return [];

//     // Find the most engaged comment
//     CommentModel mostEngagedComment =
//         filtered.reduce((a, b) => a.playedComment > b.playedComment ? a : b);

//     // Remove the most engaged comment from the list
//     filtered.remove(mostEngagedComment);

//     // Sort the remaining comments by playedComment
//     filtered.sort((a, b) => b.playedComment.compareTo(a.playedComment));

//     // Insert the most engaged comment at the beginning
//     filtered.insert(0, mostEngagedComment);

//     return filtered;
//   }

//   void _updateCommentIndexes() {
//     List<CommentModel> visibleComments = _filterComments();
//     closeFriendIndexes = [];
//     subscriberCommentsIndexes = [];
//     remainingCommentsIndex = [];

//     for (var index = 0; index < visibleComments.length; index++) {
//       var comment = visibleComments[index];
//       if (_currentNoteUser?.closeFriends.contains(comment.userId) ?? false) {
//         closeFriendIndexes.add(index);
//       } else if (_currentNoteUser?.subscribedUsers.contains(comment.userId) ??
//           false) {
//         subscriberCommentsIndexes.add(index);
//       } else {
//         remainingCommentsIndex.add(index);
//       }
//     }

//     if (visibleComments.isNotEmpty) {
//       List<CommentModel> engageComments = List.from(visibleComments);
//       engageComments.sort((a, b) => b.playedComment.compareTo(a.playedComment));
//       CommentModel mostEngageComment = engageComments[0];
//       engageCommentIndex = visibleComments.indexWhere(
//           (element) => element.commentid == mostEngageComment.commentid);
//     } else {
//       engageCommentIndex = -1;
//     }
//   }

//   Future<void> deleteComment(String commentId, bool canDismiss) async {
//     if (_prefs == null || _currentUser == null) {
//       print('CommentManager not fully initialized');
//       return;
//     }

//     if (canDismiss) {
//       // If the user is the owner, delete the comment from Firestore
//       await FirebaseFirestore.instance
//           .collection('notes')
//           .doc(_allComments.first.postId)
//           .collection('comments')
//           .doc(commentId)
//           .delete();
//     } else {
//       // If the user is not the owner, hide the comment locally
//       List<String> hiddenCommentIds =
//           _prefs!.getStringList(_currentUser!.uid) ?? [];
//       if (!hiddenCommentIds.contains(commentId)) {
//         hiddenCommentIds.add(commentId);
//         await _prefs!.setStringList(_currentUser!.uid, hiddenCommentIds);
//       }
//     }

//     // Update the UI
//     setState(() {
//       _updateCommentIndexes();
//     });
//   }

//   void dispose() {
//     _subscription?.cancel();
//     _isInitialized = false;
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/home_screen/model/comment_modal.dart';

class CommentManager {
  List<CommentModel> commentsList = [];
  List<int> closeFriendIndexes = [];
  List<int> subscriberCommentsIndexes = [];
  List<int> remainingCommentsIndex = [];
  int engageCommentIndex = -1;

  StreamSubscription<QuerySnapshot>? _subscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  Function(void Function()) setState;
  bool _isInitialized = false;
  UserModel? _currentUser;
  UserModel? _currentNoteUser;

  CommentManager(this.setState);

  Future<void> initComments(String noteId, UserModel currentUser,
      String noteOwnerId, bool isSheetComment) async {
    if (_isInitialized) {
      print('CommentManager is already initialized');
      return;
    }

    try {
      _currentUser = currentUser;

      // Listen for changes in the note owner's user data
      _userSubscription = FirebaseFirestore.instance
          .collection("users")
          .doc(noteOwnerId)
          .snapshots()
          .listen((snapshot) {
        _currentNoteUser = UserModel.fromMap(snapshot.data() ?? {});
        _updateComments(isSheetComment);
      });

      // Listen for changes in comments
      _subscription = FirebaseFirestore.instance
          .collection('notes')
          .doc(noteId)
          .collection('comments')
          .orderBy('time', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          commentsList =
              snapshot.docs.map((e) => CommentModel.fromMap(e.data())).toList();
          _updateComments(isSheetComment);
        } else {
          setState(() {
            commentsList = [];
            closeFriendIndexes = [];
            subscriberCommentsIndexes = [];
            remainingCommentsIndex = [];
            engageCommentIndex = -1;
          });
        }
      }, onError: (error) {
        print('Error in comment stream: $error');
      });

      _isInitialized = true;
    } catch (e) {
      print('Error initializing CommentManager: $e');
    }
  }

  void _updateComments(bool isSheetComment) {
    if (isSheetComment) {
      if (_currentNoteUser == null) return;

      // Sort comments by playedComment count
      commentsList.sort((a, b) => b.playedComment.compareTo(a.playedComment));

      closeFriendIndexes = [];
      subscriberCommentsIndexes = [];
      remainingCommentsIndex = [];

      for (var index = 0; index < commentsList.length; index++) {
        var comment = commentsList[index];
        if (_currentNoteUser!.closeFriends.contains(comment.userId)) {
          closeFriendIndexes.add(index);
        } else if (_currentNoteUser!.subscribedUsers.contains(comment.userId)) {
          subscriberCommentsIndexes.add(index);
        } else {
          remainingCommentsIndex.add(index);
        }
      }

      // The most engaged comment is now always at index 0
      engageCommentIndex = commentsList.isNotEmpty ? 0 : -1;

      setState(() {});
    } else {
      if (_currentNoteUser == null) return;

      closeFriendIndexes = [];
      subscriberCommentsIndexes = [];
      remainingCommentsIndex = [];

      for (var index = 0; index < commentsList.length; index++) {
        var comment = commentsList[index];
        if (_currentNoteUser!.closeFriends.contains(comment.userId)) {
          closeFriendIndexes.add(index);
        } else if (_currentNoteUser!.subscribedUsers.contains(comment.userId)) {
          subscriberCommentsIndexes.add(index);
        } else {
          remainingCommentsIndex.add(index);
        }
      }

      if (commentsList.isNotEmpty) {
        List<CommentModel> engageComments = List.from(commentsList);
        engageComments
            .sort((a, b) => b.playedComment.compareTo(a.playedComment));
        CommentModel mostEngageComment = engageComments[0];
        engageCommentIndex = commentsList.indexWhere(
            (element) => element.commentid == mostEngageComment.commentid);
      } else {
        engageCommentIndex = -1;
      }

      setState(() {});
    }
  }

  List<CommentModel> getVisibleComments() {
    return commentsList;
  }

  List<CommentModel> getSortedSheetComments() {
    if (commentsList.isEmpty) return [];

    List<CommentModel> sorted = List.from(commentsList);
    sorted.sort((a, b) => b.playedComment.compareTo(a.playedComment));

    return sorted;
  }

  Future<void> deleteComment(String commentId) async {
    if (_currentUser == null || _currentNoteUser == null) {
      print('CommentManager not fully initialized');
      return;
    }

    CommentModel? commentToDelete = commentsList.firstWhere(
      (comment) => comment.commentid == commentId,
      // orElse: () => null,
    );

    if (commentToDelete == null) {
      print('Comment not found');
      return;
    }

    bool canDelete = _currentUser!.uid == _currentNoteUser!.uid || // Post owner
        _currentUser!.uid == commentToDelete.userId; // Comment owner

    if (canDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(commentsList.first.postId)
            .collection('comments')
            .doc(commentId)
            .delete();
        print('Comment deleted successfully');
      } catch (e) {
        print('Error deleting comment: $e');
      }
    } else {
      print('User does not have permission to delete this comment');
    }

    // The UI will update automatically via the Firestore stream
  }

  void dispose() {
    _subscription?.cancel();
    _userSubscription?.cancel();
    _isInitialized = false;
  }
}
