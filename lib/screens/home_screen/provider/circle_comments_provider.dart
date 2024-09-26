import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CircleCommentsProvider with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();

  int changeIndex = 0;

  bool isPlaying = false;
  Duration position = Duration.zero;

  void _initAudioPlayer() {
    audioPlayer.onPlayerComplete.listen((event) {
      setIsPlaying(false);
      setChangeIndex(-1);
      setPosition(Duration.zero);
    });

    audioPlayer.onPositionChanged.listen((position) {
      setPosition(position);
    });

    // audioPlayer.onDurationChanged.listen((duration) {
    //   setDuration(duration);
    // });
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
      setChangeIndex(-1);
    }
  }

  setChangeIndex(int index) {
    changeIndex = index;
    notifyListeners();
  }

  // setDuration(Duration dura) {
  //   duration = dura;
  //   notifyListeners();
  // }

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
      await audioPlayer.play(UrlSource(url));
      setChangeIndex(index);
      setIsPlaying(true);

      // Duration? audioDuration = await audioPlayer!.getDuration();
      // if (audioDuration != null) {
      //   setDuration(audioDuration);
      // } else {
      //   print("Failed to get audio duration");
      // }
    } catch (e) {
      print("Error playing audio: $e");
      setIsPlaying(false);
    }

    notifyListeners();
  }

  // playAudioPlayer(String url, int index) async {
  //   await audioPlayer!.play(UrlSource(url)).then((value) async {
  //     setChangeIndex(index);
  //     setIsPlaying(true);

  //     duration = (await audioPlayer!.getDuration())!;
  //     setDuration(duration);
  //   });
  //   notifyListeners();
  // }

  resumeAudioPlayer() {
    audioPlayer!.resume();
    notifyListeners();
  }

  disposePlayer() {
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
  if(Platform.isAndroid){
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
}
