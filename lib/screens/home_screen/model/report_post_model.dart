// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReportPostModel {
  final String postId;
  final String postOwner;
  final String reportMessage;
  final String reportedBy;
  final String reportId;

  ReportPostModel(
      {required this.postId,
      required this.postOwner,
      required this.reportMessage,
      required this.reportedBy,
      required this.reportId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'postOwner': postOwner,
      'reportMessage': reportMessage,
      'reportedBy': reportedBy,
      'reportId': reportId,
    };
  }

  factory ReportPostModel.fromMap(Map<String, dynamic> map) {
    return ReportPostModel(
      postId: map['postId'] as String,
      postOwner: map['postOwner'] as String,
      reportMessage: map['reportMessage'] as String,
      reportedBy: map['reportedBy'] as String,
      reportId: map['reportId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportPostModel.fromJson(String source) =>
      ReportPostModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
