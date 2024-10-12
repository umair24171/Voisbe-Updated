import 'dart:ui';

// defining the post model to make things easier for us

class NoteModel {
  String noteId;
  String username;
  String photoUrl;
  String userToken;
  String title;
  String userUid;
  List tagPeople;
  String noteUrl;
  DateTime publishedDate;
  bool isPinned;
  List likes;
  List comments;
  String topic;
  Color topicColor;
  String backgroundType;
  List<double> mostListenedWaves;
  String videoThumbnail;

  List<String> hashtags;
  bool isPostForSubscribers;
  String backgroundImage;
  List<double>? waveforms;
  NoteModel(
      {required this.noteId,
      required this.username,
      required this.photoUrl,
      required this.title,
      required this.userUid,
      required this.mostListenedWaves,
      required this.videoThumbnail,
      required this.tagPeople,
      required this.likes,
      required this.userToken,
      required this.noteUrl,
      required this.publishedDate,
      required this.backgroundType,
      required this.isPostForSubscribers,
      required this.comments,
      required this.backgroundImage,
      required this.topic,
      required this.isPinned,
      required this.topicColor,
      required this.hashtags,
      this.waveforms});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'noteId': noteId,
      'username': username,
      'photoUrl': photoUrl,
      'title': title,
      'backgroundType': backgroundType,
      'videoThumbnail': videoThumbnail,
      'mostListenedWaves': mostListenedWaves,
      'userUid': userUid,
      'tagPeople': tagPeople,
      'noteUrl': noteUrl,
      'publishedDate': publishedDate,
      'backgroundImage': backgroundImage,
      'userToken': userToken,
      ''
          'isPostForSubscribers': isPostForSubscribers,
      'comments': comments,
      'isPinned': isPinned,
      'topicColor': topicColor.value,
      'likes': likes,
      'topic': topic,
      'hashtags': hashtags,
      'waveforms': waveforms,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      noteId: map['noteId'] as String,
      username: map['username'] as String,
      photoUrl: map['photoUrl'] as String,
      backgroundImage: map['backgroundImage'] as String,
      videoThumbnail: map['videoThumbnail'] as String,
      title: map['title'] as String,
      topicColor: map['topicColor'] as int == 0
          ? const Color(0xffFFD700)
          : Color(map['topicColor'] as int),
      backgroundType: map['backgroundType'] as String,
      userUid: map['userUid'] as String,
      isPostForSubscribers: map['isPostForSubscribers'] as bool,
      tagPeople: List.from(map['tagPeople'] as List),
      mostListenedWaves: List.from(map['mostListenedWaves'] as List),
      comments: List.from(map['comments'] as List),
      likes: List.from(map['likes'] as List),
      userToken: map['userToken'] as String,
      isPinned: map['isPinned'] as bool,
      noteUrl: map['noteUrl'] as String,
      publishedDate: map['publishedDate'].toDate() as DateTime,
      topic: map['topic'] as String,
      hashtags: List<String>.from(map['hashtags'] as List),
      waveforms: map['waveforms'] != null
          ? List<double>.from(map['waveforms'] as List)
          : [],
    );
  }
}
