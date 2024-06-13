// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SavedNoteModel {
  String savedNoteId;
  String uid;
  String soundId;
  SavedNoteModel({
    required this.uid,
    required this.soundId,
    required this.savedNoteId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'soundId': soundId,
      'savedNoteId': savedNoteId,
    };
  }

  factory SavedNoteModel.fromMap(Map<String, dynamic> map) {
    return SavedNoteModel(
      uid: map['uid'] as String,
      soundId: map['soundId'] as String,
      savedNoteId: map['savedNoteId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedNoteModel.fromJson(String source) =>
      SavedNoteModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
