import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/firebase_service.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ref.read(firebaseServiceProvider);
      final user = service.currentUser;
      if (user == null) throw Exception('Not logged in');

      final profile = await service.getUserProfile(user.uid);
      await service.createGroup(name, user.uid, profile?.name ?? 'User');

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to create group: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Family Group')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Name your group',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'e.g. "The Smiths", "Room 204", "Home"',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Group name',
                prefixIcon: Icon(Icons.group),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _create(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : _create,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_loading ? 'Creating...' : 'Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
