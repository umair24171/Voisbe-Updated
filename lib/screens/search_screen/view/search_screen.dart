import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/search_screen/view/provider/search_screen_provider.dart';
import 'package:social_notes/screens/search_screen/view/widgets/single_search_item.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // List<NoteModel> mostEngagedPosts = [];
  List<NoteModel> postsAfterFilter = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isPlaying = false;
  AudioPlayer player = AudioPlayer();
  Duration position = Duration.zero;
  int _currentIndex = 0;

  Duration duration = Duration.zero;

  late StreamSubscription<QuerySnapshot> _subscription;
  List<NoteModel> userPosts = [];
  List<NoteModel> pinnedPosts = [];
  List<NoteModel> nonPinnedPosts = [];

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    // _subscription = FirebaseFirestore.instance
    //     .collection('notes')
    //     .where('userUid',
    //         isEqualTo:
    //             // 'ysGnuGm48ySdv4i20ZKA0XB5g7o1'
    //             Provider.of<UserProfileProvider>(context, listen: false)
    //                 .otherUser!
    //                 .uid)
    //     .orderBy('publishedDate', descending: true)
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (snapshot.docs.isNotEmpty) {
    //     log('snapshots are ${snapshot.docs.first.data()}');
    //     List<NoteModel> otherUserPosts =
    //         snapshot.docs.map((e) => NoteModel.fromMap(e.data())).toList();

    //     List<NoteModel> secondList = List.from(otherUserPosts);

    //     NoteModel newPost = otherUserPosts[0];
    //     pinnedPosts.clear();
    //     nonPinnedPosts.clear();
    //     for (int i = 0; i < otherUserPosts.length; i++) {
    //       if (otherUserPosts[i].isPinned) {
    //         pinnedPosts.add(otherUserPosts[i]);
    //       } else {
    //         nonPinnedPosts.add(otherUserPosts[i]);
    //       }
    //     }
    //     pinnedPosts.removeWhere((element) => element.noteId == newPost.noteId);
    //     nonPinnedPosts
    //         .removeWhere((element) => element.noteId == newPost.noteId);

    //     otherUserPosts = [newPost, ...pinnedPosts, ...nonPinnedPosts];
    //     setState(() {
    //       userPosts = otherUserPosts;
    //       // Update the local list with the sorted list
    //     });
    //   }
    // });
    // Provider.of<UserProfileProvider>(context, listen: false).getUserPosts(
    //     Provider.of<UserProfileProvider>(context, listen: false)
    //         .otherUser!
    //         .uid);
    super.initState();
  }

  stopMainPlayer() {
    _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      currentIndex = -1;
    });
  }

  void playPause(String url, int index) async {
    // Check if the file is already cached
    final cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);

    if (fileInfo == null) {
      // File is not cached, download and cache it
      try {
        fileInfo = await cacheManager.downloadFile(url, key: url);
      } catch (e) {
        print('Error downloading file: $e');
        return;
      }
    }

    // Use the cached file for playback
    if (_isPlaying && _currentIndex != index) {
      await _audioPlayer.stop();
    }

    if (_currentIndex == index && _isPlaying) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
        setState(() {
          _currentIndex = -1;
          _isPlaying = false;
        });
      } else {
        _audioPlayer.resume();
        setState(() {
          _currentIndex = index;
          _isPlaying = true;
        });
      }
    } else {
      await _audioPlayer
          .play(
        UrlSource(fileInfo.file.path),
      )
          .then((value) async {
        setState(() {
          _currentIndex = index;
          _isPlaying = true;
        });
        duration = (await _audioPlayer.getDuration())!;
        setState(() {});
      });
    }

    _audioPlayer.onPositionChanged.listen((event) {
      if (_currentIndex == index) {
        setState(() {
          position = event;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentIndex = -1;
        position = Duration.zero;
      });
    });
  }

  PageController _controller = PageController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<DisplayNotesProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    provider.getAllNotes();
    var allPosts = provider.notes;
    postsAfterFilter.clear();
    // postContainsSubscribers.clear();
    for (int i = 0; i < provider.notes.length; i++) {
      if (allPosts[i].likes.length >= 20) {
        postsAfterFilter.add(allPosts[i]);
        // allPosts.removeAt(i);
      }
    }

    // allPosts = [...mostEngagedPosts, ...postContainsSubscribers, ...allPosts];
    // allPosts.sort((a, b) => b.likes.length.compareTo(a.likes.length));

    // var postsProvider =
    //     Provider.of<DisplayNotesProvider>(context, listen: false);
    // postsProvider.getAllNotes();
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(
                // flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        var pro = Provider.of<SearchScreenProvider>(context,
                            listen: false);
                        pro.setSearching(true);
                        pro.searchedNotes.clear();
                        pro.setSearching(true);
                        for (int i = 0; i < postsAfterFilter.length; i++) {
                          if (postsAfterFilter[i]
                                  .topic
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              postsAfterFilter[i]
                                  .username
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            pro.searchedNotes.add(allPosts[i]);
                          }
                        }
                      } else {
                        var pro = Provider.of<SearchScreenProvider>(context,
                            listen: false);
                        pro.setSearching(false);
                        pro.searchedNotes.clear();
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                          maxHeight: 35, maxWidth: size.width * 0.8),
                      fillColor: Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.only(bottom: 18),
                      hintText: 'Search',
                      hintStyle:
                          TextStyle(fontFamily: fontFamily, color: Colors.grey),
                      // label: Text(
                      //   'Search',
                      //   style: TextStyle(
                      //       fontFamily: fontFamily, color: Colors.grey),
                      // ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 12),
          //     child: Icon(
          //       Icons.more_horiz,
          //       color: blackColor,
          //     ),
          //   ),
          // ],
        ),
        body: Consumer<SearchScreenProvider>(builder: (context, searchPro, _) {
          return GridView.builder(
            itemCount: searchPro.isSearching
                ? searchPro.searchedNotes.length
                : postsAfterFilter.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: size.height * 0.2,
            ),
            itemBuilder: (context, index) => SingleSearchItem(
              postion: position,
              stopMainPlayer: stopMainPlayer,
              isPlaying: _isPlaying,
              pageController: _controller,
              audioPlayer: _audioPlayer,
              duration: duration,
              playPause: () {
                playPause(
                    searchPro.isSearching
                        ? searchPro.searchedNotes[index].noteUrl
                        : postsAfterFilter[index].noteUrl,
                    index);
              },
              changeIndex: _currentIndex,
              index: index,
              noteModel: searchPro.isSearching
                  ? searchPro.searchedNotes[index]
                  : postsAfterFilter[index],
            ),
          );
        }));
  }
}
