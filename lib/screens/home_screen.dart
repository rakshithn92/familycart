import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/family_group.dart';
import '../providers/providers.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null
        ? ref.watch(userProfileProvider(user.uid))
        : const AsyncValue<AppUser?>.data(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FamilyCart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final service = ref.read(firebaseServiceProvider);
              await service.signOut();
            },
          ),
        ],
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Loading...'));

          final groupIds = profile.groupIds;
          if (groupIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups_outlined, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'No family groups yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a group or join one with an invite code',
                      style: TextStyle(color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final groupsAsync = ref.watch(userGroupsProvider(groupIds));

          return groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (groups) {
              if (groups.isEmpty) {
                return const Center(child: Text('No groups found'));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                children: groups.map((g) => _GroupCard(group: g)).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'join',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
            ),
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('New Group'),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  final FamilyGroup group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                child: Text(
                  group.name[0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} members',
                      style: TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
