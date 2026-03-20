import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/alias_engine.dart';
import 'services/username_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final UsernameService _usernameService = const UsernameService();
  final TextEditingController _usernameController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleAnonymousLogin() async {
    if (_isSubmitting) {
      return;
    }

    _clearError();

    var username = _usernameController.text.trim();
    if (username.isEmpty) {
      final suggestedName = await _showSuggestedAliasDialog();
      if (suggestedName == null) {
        return;
      }
      username = suggestedName;
      _usernameController.text = suggestedName;
    }

    await _completeLogin(username);
  }

  Future<String?> _showSuggestedAliasDialog() {
    var suggestedName = _generateValidAlias();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Use a generated username?'),
              content: Text(suggestedName),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      suggestedName = _generateValidAlias();
                    });
                  },
                  child: const Text('Change'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(suggestedName),
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _generateValidAlias() {
    for (var attempt = 0; attempt < 50; attempt++) {
      final alias = AliasEngine.name;
      if (_usernameService.validationError(alias) == null) {
        return alias;
      }
    }

    return 'Guest${DateTime.now().microsecondsSinceEpoch.remainder(100000000)}';
  }

  Future<void> _completeLogin(String username) async {
    final trimmedUsername = username.trim();
    final validationMessage = _usernameService.validationError(trimmedUsername);
    if (validationMessage != null) {
      _setError(validationMessage);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      var user = auth.currentUser;
      user ??= (await auth.signInAnonymously()).user;

      if (user == null) {
        throw Exception('Anonymous sign-in returned no user.');
      }

      await _usernameService.reserveUsername(
        username: trimmedUsername,
        uid: user.uid,
      );
      await user.updateDisplayName(trimmedUsername);

      await user.reload();
    } on UsernameTakenException {
      if (!mounted) {
        return;
      }
      _setError('That username is already taken. Try another one.');
    } on InvalidUsernameException catch (error) {
      if (!mounted) {
        return;
      }
      _setError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _setError('Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick a username or let the app generate one for you.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  enabled: !_isSubmitting,
                  maxLength: UsernameService.maxLength,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
                  ],
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Letters, numbers, underscores',
                    errorText: _errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => _clearError(),
                  onSubmitted: (_) => _handleAnonymousLogin(),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSubmitting
                      ? 'doin\' stuff...'
                      : 'Use ${UsernameService.minLength}-${UsernameService.maxLength} letters, numbers, or underscores, or leave it blank for a suggested alias.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _handleAnonymousLogin,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: _isSubmitting
                      ? const Text('Signing in...')
                      : const Text('Try it out!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
