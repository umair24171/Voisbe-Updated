import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/single_post_note.dart';

class BookMarkScreen extends StatelessWidget {
  BookMarkScreen({super.key});

  final PageController pageController = PageController();
  AudioPlayer audioPlayer = AudioPlayer();
  Duration position = Duration.zero;
  // stopMainPlayer() {
  //   _audioPlayer.stop();
  //   setState(() {
  //     _isPlaying = false;
  //     currentIndex = -1;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<DisplayNotesProvider>(builder: (context, displyPro, _) {
        for (var note in displyPro.notes) {
          for (var bookmark in displyPro.bookMarkPosts) {
            if (note.noteId == bookmark.postId) {
              return PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: displyPro.bookMarkPosts.length,
                itemBuilder: (context, index) => SingleNotePost(
                    duration: position,
                    stopMainPlayer: () {},
                    audioPlayer: audioPlayer,
                    playPause: () {},
                    changeIndex: 0,
                    position: position, // position: position,
                    // audioPlayer: audioPlayer,
                    // changeIndex: 0,
                    isPlaying: true,
                    pageController: pageController,
                    currentIndex: index,
                    size: size,
                    note: note),
              );
            }
          }
        }
        return Container();
      }),
    );
  }
}
