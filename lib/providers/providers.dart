import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/app_user.dart';
import '../models/family_group.dart';
import '../models/shopping_item.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

// --- Auth ---
final authStateProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.valueOrNull;
});

final userProfileProvider = StreamProvider.family<AppUser?, String>((ref, uid) {
  final service = ref.watch(firebaseServiceProvider);
  return service.streamUserProfile(uid);
});

// --- Groups ---
final userGroupsProvider = StreamProvider.family<List<FamilyGroup>, List<String>>((ref, groupIds) {
  final service = ref.watch(firebaseServiceProvider);
  return service.streamUserGroups(groupIds);
});

final groupProvider = StreamProvider.family<FamilyGroup?, String>((ref, groupId) {
  final service = ref.watch(firebaseServiceProvider);
  return service.streamGroup(groupId);
});

// --- Items ---
final itemsProvider = StreamProvider.family<List<ShoppingItem>, String>((ref, groupId) {
  final service = ref.watch(firebaseServiceProvider);
  return service.streamItems(groupId);
});
