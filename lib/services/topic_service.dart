import 'package:cloud_firestore/cloud_firestore.dart';

class TopicService {
  const TopicService();

  CollectionReference<Map<String, dynamic>> get _topicsCollection {
    return FirebaseFirestore.instance.collection('topics');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> topicFeedStream() {
    return _topicsCollection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createTopic({
    required String text,
    required String authorUid,
    required String authorDisplayName,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw TopicValidationException('Topic cannot be empty.');
    }

    if (trimmedText.length > 50) {
      throw TopicValidationException('Topic must be 50 characters or fewer.');
    }

    await _topicsCollection.add({
      'text': trimmedText,
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class TopicValidationException implements Exception {
  TopicValidationException(this.message);

  final String message;
}
