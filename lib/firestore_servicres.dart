import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveSearchHistory(String query) async {
    await _firestore.collection('searchHistory').add({
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getSearchHistory() async {
    final snapshot = await _firestore.collection('searchHistory').orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => doc['query'] as String).toList();
  }
}
