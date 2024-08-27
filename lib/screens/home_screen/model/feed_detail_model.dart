import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';

class FeedDetailModel {
  final NoteModel note;
  final Duration duration;
  final Duration position;
  final VoidCallback playPause;
  final AudioPlayer audioPlayer;
  final int changeIndex;
  final bool isPlaying;
  final PageController pageController;
  final int currentIndex;
  final bool isMainPlayer;

  FeedDetailModel(
      {required this.note,
      required this.duration,
      required this.position,
      required this.playPause,
      required this.audioPlayer,
      required this.changeIndex,
      required this.isPlaying,
      required this.pageController,
      required this.currentIndex,
      required this.isMainPlayer});
}
