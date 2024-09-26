import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PlayerControllerClass {
  late AudioPlayer _audioPlayer;
  late String _cachedFilePath;
  late String noteUrl;
  late int _currentIndex;

  void init(int index, String noteUrl) {
    _currentIndex = index;
    this.noteUrl = noteUrl;
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSourceUrl(noteUrl);

    DefaultCacheManager().getFileFromCache(noteUrl).then((file) {
      if (file != null && file.file.existsSync()) {
        _cachedFilePath = file.file.path;
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _audioPlayer.stop();
    });
  }

  void play() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      if (_cachedFilePath.isNotEmpty) {
        await _audioPlayer.play(Platform.isAndroid ? UrlSource(_cachedFilePath) : UrlSource(noteUrl));
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
