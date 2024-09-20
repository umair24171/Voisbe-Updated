import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/home_screen/provider/circle_comments_provider.dart';
import 'package:social_notes/screens/home_screen/view/widgets/circle_comments.dart';
import 'package:social_notes/screens/search_screen/view/widgets/single_search_item.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OptimizedSearchGrid extends StatefulWidget {
  const OptimizedSearchGrid({
    super.key,
    required this.postsAfterFilter,
    required this.size,
  });

  // getting data from the constructor

  final List<NoteModel> postsAfterFilter;
  final Size size;

  @override
  State<OptimizedSearchGrid> createState() => _OptimizedSearchGridState();
}

class _OptimizedSearchGridState extends State<OptimizedSearchGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: widget.postsAfterFilter.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: widget.size.height * 0.2,
        ),
        itemBuilder: (context, index) {
          //  single post item to show in grid

          return Consumer<CircleCommentsProvider>(
              builder: (context, circlePro, _) {
            return SingleSearchItem(
              isPlaying: circlePro.isPlaying,
              audioPlayer: circlePro.audioPlayer,
              changeIndex: circlePro.changeIndex,
              playPause: () {
                circlePro.playPause(
                    widget.postsAfterFilter[index].noteUrl, index);
              },
              position: circlePro.position,
              index: index,
              noteModel: widget.postsAfterFilter[index],
            );
          });
        });
  }
}
