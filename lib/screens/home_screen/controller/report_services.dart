import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_notes/screens/home_screen/model/report_post_model.dart';

class ReportServices {
  reportPost(ReportPostModel report) async {
    try {
      await FirebaseFirestore.instance
          .collection('post_reports')
          .doc(report.reportId)
          .set(report.toMap());
    } catch (e) {
      log(e.toString());
    }
  }
}
