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
}
