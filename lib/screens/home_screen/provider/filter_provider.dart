import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';

class FilterProvider with ChangeNotifier {
  String selectedFilter = 'For you';
  bool isSearch = false;
  String searchValue = '';
  List<NoteModel> searcheNote = [];

  AudioPlayer audioPlayer = AudioPlayer();
  Duration position = Duration.zero;
  int changeIndex = 0;
  bool isPlaying = false;

  setIsPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  setChangeIndex(int index) {
    changeIndex = index;
    notifyListeners();
  }

  setPosition(Duration position) {
    position = position;
    notifyListeners();
  }

  initPlayer() {
    audioPlayer = AudioPlayer();
  }

  disposeAudio() {
    setPosition(Duration.zero);
    audioPlayer.dispose();
    notifyListeners();
  }

  void playPause(
    String url,
    int index,
  ) async {
    if (isPlaying && changeIndex != index) {
      await audioPlayer.stop();
    }

    if (changeIndex == index && isPlaying) {
      if (audioPlayer.state == PlayerState.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.resume();
      }
    } else {
      await audioPlayer.play(UrlSource(url));
      setChangeIndex(index);
      setIsPlaying(true);
      // setState(() {
      //   changeIndex = index;
      //   _isPlaying = true;
      // });
    }
    audioPlayer.onPositionChanged.listen((event) {
      if (changeIndex == index) {
        setPosition(event);
      }
    });
    audioPlayer.onPlayerComplete.listen((event) {
      // _updatePlayedComment(commentId, commentsList[index].playedComment);
      setChangeIndex(-1);
      setIsPlaying(false);
      // setPosition(Duration.zero);
      // setState(() {
      //   _isPlaying = false;
      //   changeIndex = -1;

      // });
    });
  }

  addSearchNote(NoteModel noteModel) {
    searcheNote.add(noteModel);
    notifyListeners();
  }

  // List followers = [];
  List<NoteModel> closeFriendsPosts = [];
  // getUserFollowers(List followersList) {
  //   followers = followersList;
  //   notifyListeners();
  // }

  addCloseFriendsPosts(NoteModel closeFriends) {
    closeFriendsPosts.add(closeFriends);
    notifyListeners();
  }

  getSearchEdNotes(List<NoteModel> allNotes) {
    searcheNote = allNotes
        .where((element) =>
            element.topic.toLowerCase().contains(searchValue.toLowerCase()))
        .toList();
    notifyListeners();
  }

  setSearchingValue(String value) {
    searchValue = value;
    notifyListeners();
  }

  setSearching(bool value) {
    isSearch = value;
    notifyListeners();
  }

  setSelectedFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }
}
