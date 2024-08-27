import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

class AudioTesting extends StatefulWidget {
  const AudioTesting({Key? key}) : super(key: key);

  @override
  State<AudioTesting> createState() => _AudioTestingState();
}

class _AudioTestingState extends State<AudioTesting> {
  late Duration maxDuration;
  late Duration elapsedDuration;
  late AudioPlayer audioPlayer;
  late List<double> samples;
  late int totalSamples;

  late List<String> audioData;

  List<List<String>> audioDataList = [
    [
      'https://firebasestorage.googleapis.com/v0/b/voisbe.appspot.com/o/voices%2F59409173-49d1-4715-a3f8-647643e5905a?alt=media&token=af93539d-fd0e-4642-bb6e-bf9687b67597',
    ],
  ];

  Future<void> parseData() async {
    final json = await rootBundle.loadString(audioData[0]);
    Map<String, dynamic> audioDataMap = {
      "json": json,
      "totalSamples": totalSamples,
    };
    final samplesData = await compute((message) {}, audioDataMap);
    // await audioPlayer.get(audioData[1]);
    await audioPlayer.play(UrlSource(audioData[1]));
    // maxDuration in milliseconds
    await Future.delayed(const Duration(milliseconds: 200));

    Duration? maxDurationInmilliseconds = await audioPlayer.getDuration();

    maxDuration =
        Duration(milliseconds: maxDurationInmilliseconds!.inMilliseconds);
    setState(() {
      samples = samplesData["samples"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Change this value to number of audio samples you want.
    // Values between 256 and 1024 are good for showing [RectangleWaveform] and [SquigglyWaveform]
    // While the values above them are good for showing [PolygonWaveform]
    totalSamples = 1000;
    audioData = audioDataList[0];
    audioPlayer = AudioPlayer();

    samples = [];
    maxDuration = const Duration(milliseconds: 1000);
    elapsedDuration = const Duration();
    parseData();
    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        elapsedDuration = maxDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration timeElapsed) {
      setState(() {
        elapsedDuration = timeElapsed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 30,
      width: 30,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flutter Audio Waveforms'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PolygonWaveform(
            maxDuration: maxDuration,
            elapsedDuration: elapsedDuration,
            samples: samples,
            height: 300,
            width: MediaQuery.of(context).size.width,
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  audioPlayer.pause();
                },
                child: const Icon(
                  Icons.pause,
                ),
              ),
              sizedBox,
              ElevatedButton(
                onPressed: () {
                  audioPlayer.resume();
                },
                child: const Icon(Icons.play_arrow),
              ),
              sizedBox,
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    audioPlayer.seek(const Duration(milliseconds: 0));
                  });
                },
                child: const Icon(Icons.replay_outlined),
              ),
            ],
          )
        ],
      ),
    );
  }
}
