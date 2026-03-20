import 'package:cloud_firestore/cloud_firestore.dart';

import 'slur_filter.dart';

class UsernameService {
  const UsernameService();

  static const int minLength = 3;
  static const int maxLength = 32;
  static final RegExp allowedCharacters = RegExp(r'^[A-Za-z0-9_]+$');

  String normalize(String username) {
    return username.trim().toLowerCase();
  }

  String? validationError(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return 'Username cannot be empty.';
    }

    if (trimmed.length < minLength) {
      return 'Username must be at least $minLength characters.';
    }

    if (trimmed.length > maxLength) {
      return 'Username must be $maxLength characters or fewer.';
    }

    if (!allowedCharacters.hasMatch(trimmed)) {
      return 'Use only letters, numbers, and underscores.';
    }

    if (SlurFilter.containsSlur(trimmed)) {
      return 'Slurs are not allowed in usernames.';
    }

    return null;
  }

  Future<void> reserveUsername({
    required String username,
    required String uid,
  }) async {
    final trimmed = username.trim();
    final validationMessage = validationError(trimmed);
    if (validationMessage != null) {
      throw InvalidUsernameException(validationMessage);
    }

    final normalized = normalize(trimmed);
    final docRef = FirebaseFirestore.instance
        .collection('usernames')
        .doc(normalized);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final existingUid = snapshot.data()?['uid'] as String?;
        if (existingUid != uid) {
          throw UsernameTakenException();
        }
        return;
      }

      transaction.set(docRef, {
        'uid': uid,
        'username': normalized,
        'normalized': normalized,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

class UsernameTakenException implements Exception {}

class InvalidUsernameException implements Exception {
  InvalidUsernameException(this.message);

  final String message;
}
