// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReportUserModel {
  final String reportId;
  final String reportedUser;
  final String reportedBy;
  final String reportMessage;

  ReportUserModel(
      {required this.reportId,
      required this.reportedUser,
      required this.reportMessage,
      required this.reportedBy});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reportId': reportId,
      'reportedUser': reportedUser,
      'reportedBy': reportedBy,
      'reportMessage': reportMessage
    };
  }

  factory ReportUserModel.fromMap(Map<String, dynamic> map) {
    return ReportUserModel(
        reportId: map['reportId'] as String,
        reportedUser: map['reportedUser'] as String,
        reportedBy: map['reportedBy'] as String,
        reportMessage: map['reportMessage'] as String);
  }

  String toJson() => json.encode(toMap());

  factory ReportUserModel.fromJson(String source) =>
      ReportUserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
