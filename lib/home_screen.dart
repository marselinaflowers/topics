import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'services/topic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.displayName});

  final String displayName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TopicService _topicService = const TopicService();

  Future<void> _showCreateTopicDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateTopicDialog(
        topicService: _topicService,
        authorDisplayName: widget.displayName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic Feed'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTopicDialog,
        icon: const Icon(Icons.add_comment),
        label: const Text('Create Topic'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _topicService.topicFeedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load feed. ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No topics yet. Tap Create Topic to post the first one.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final text = (data['text'] as String?)?.trim() ?? '';
              final author =
                  (data['authorDisplayName'] as String?)?.trim().isNotEmpty ==
                      true
                  ? data['authorDisplayName'] as String
                  : 'Unknown';
              final timestamp = data['createdAt'] as Timestamp?;
              final postedAt = timestamp != null
                  ? _formatTimestamp(timestamp.toDate())
                  : 'Just now';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(
                        '$author • $postedAt',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day ${local.year} $hour:$minute';
  }
}

class CreateTopicDialog extends StatefulWidget {
  const CreateTopicDialog({
    super.key,
    required this.topicService,
    required this.authorDisplayName,
  });

  final TopicService topicService;
  final String authorDisplayName;

  @override
  State<CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<CreateTopicDialog> {
  final TextEditingController _topicController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorText = 'You must be signed in to post.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.topicService.createTopic(
        text: _topicController.text,
        authorUid: user.uid,
        authorDisplayName: widget.authorDisplayName,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on TopicValidationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.message;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.message ?? 'Failed to create topic.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Topic'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _topicController,
            enabled: !_isSubmitting,
            autofocus: true,
            maxLength: 50,
            maxLines: 4,
            minLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
}
