// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PersonalizeModel {
  final List interest;
  final List language;
  final String timeRange;
  final String timeOfDay;
  final String contentDuration;
  final String uid;

  PersonalizeModel(
      {required this.interest,
      required this.language,
      required this.timeRange,
      required this.timeOfDay,
      required this.contentDuration,
      required this.uid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'interest': interest,
      'language': language,
      'timeRange': timeRange,
      'timeOfDay': timeOfDay,
      'contentDuration': contentDuration,
      'uid': uid,
    };
  }

  factory PersonalizeModel.fromMap(Map<String, dynamic> map) {
    return PersonalizeModel(
      interest: List.from(map['interest'] as List),
      language: List.from((map['language'] as List)),
      timeRange: map['timeRange'] as String,
      timeOfDay: map['timeOfDay'] as String,
      contentDuration: map['contentDuration'] as String,
      uid: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PersonalizeModel.fromJson(String source) =>
      PersonalizeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
