import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SoundPackModel {
  final String soundId;
  final String userId;
  final String username;
  final String soundPackName;
  final String soundPackUrl;
  final SoundPackType soundPackType;
  final bool subscriptionEnable;
  SoundPackModel({
    required this.userId,
    required this.soundId,
    required this.username,
    required this.soundPackName,
    required this.soundPackUrl,
    required this.soundPackType,
    required this.subscriptionEnable,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'soundId': soundId,
      'userId': userId,
      'username': username,
      'soundPackName': soundPackName,
      'soundPackUrl': soundPackUrl,
      'soundPackType': soundPackType.name,
      'subscriptionEnable': subscriptionEnable,
    };
  }

  factory SoundPackModel.fromMap(Map<String, dynamic> map) {
    return SoundPackModel(
      soundId: map['soundId'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      soundPackName: map['soundPackName'] as String,
      soundPackUrl: map['soundPackUrl'] as String,
      soundPackType: map['soundPackType'] == 'free'
          ? SoundPackType.free
          : SoundPackType.premium,
      subscriptionEnable: map['subscriptionEnable'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory SoundPackModel.fromJson(String source) =>
      SoundPackModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum SoundPackType { free, premium }
