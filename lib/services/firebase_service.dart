import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/family_group.dart';
import '../models/shopping_item.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // --- Initialization ---

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // --- Auth ---

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sign in anonymously — no phone, no OTP, no password.
  /// Returns the created/existing user.
  Future<User> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user!;
  }

  Future<void> signOut() async => _auth.signOut();

  // --- User Profile ---

  Future<void> createUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Stream<AppUser?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.data()!) : null,
        );
  }

  // --- Groups ---

  Future<FamilyGroup> createGroup(String name, String createdBy, String creatorName) async {
    final id = _uuid.v4();
    final inviteCode = _uuid.v4().substring(0, 8).toUpperCase();
    final group = FamilyGroup(
      id: id,
      name: name,
      inviteCode: inviteCode,
      createdBy: createdBy,
      memberIds: [createdBy],
      memberNames: {createdBy: creatorName},
    );
    await _firestore.collection('groups').doc(id).set(group.toMap());
    // Add group to user's list
    await _firestore.collection('users').doc(createdBy).set({
      'groupIds': FieldValue.arrayUnion([id]),
    }, SetOptions(merge: true));
    return group;
  }

  Future<FamilyGroup?> joinGroup(String inviteCode, String userId, String userName) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final group = FamilyGroup.fromMap(snapshot.docs.first.data());
    if (group.memberIds.contains(userId)) return group; // already a member

    await _firestore.collection('groups').doc(group.id).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'memberNames.$userId': userName,
    });
    await _firestore.collection('users').doc(userId).set({
      'groupIds': FieldValue.arrayUnion([group.id]),
    }, SetOptions(merge: true));
    return group;
  }

  Stream<List<FamilyGroup>> streamUserGroups(List<String> groupIds) {
    if (groupIds.isEmpty) return Stream.value([]);
    return _firestore
        .collection('groups')
        .where(FieldPath.documentId, whereIn: groupIds)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FamilyGroup.fromMap(d.data())).toList());
  }

  Stream<FamilyGroup?> streamGroup(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map(
          (doc) => doc.exists ? FamilyGroup.fromMap(doc.data()!) : null,
        );
  }

  // --- Shopping Items ---

  Future<void> addItem(ShoppingItem item) async {
    await _firestore
        .collection('groups')
        .doc(item.groupId)
        .collection('items')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> updateItemStatus(String groupId, String itemId, ItemStatus status,
      {String? checkedBy}) async {
    final data = <String, dynamic>{
      'status': status.index,
    };
    if (checkedBy != null) {
      data['checkedBy'] = checkedBy;
      data['checkedAt'] = DateTime.now().toIso8601String();
    }
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('items')
        .doc(itemId)
        .update(data);
  }

  Future<void> updateItem(String groupId, ShoppingItem item) async {
    await _firestore
        .collection('groups')
        .doc(item.groupId)
        .collection('items')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteItem(String groupId, String itemId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Stream<List<ShoppingItem>> streamItems(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ShoppingItem.fromMap(d.data())).toList());
  }
}
