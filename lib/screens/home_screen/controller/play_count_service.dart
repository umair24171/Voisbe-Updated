import 'package:cloud_firestore/cloud_firestore.dart';

class PlayCountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> savePlayCounts(String postId, List<int> playCounts) async {
    await _firestore.collection('audioPlayCounts').doc(postId).set({
      'playCounts': playCounts,
    });
  }

  Future<List<int>> getPlayCounts(String postId) async {
    DocumentSnapshot doc =
        await _firestore.collection('audioPlayCounts').doc(postId).get();

    if (doc.exists) {
      List<dynamic> playCounts = doc['playCounts'];
      return playCounts.map((count) => count as int).toList();
    } else {
      // Return an empty list if no data exists
      return [];
    }
  }
}
