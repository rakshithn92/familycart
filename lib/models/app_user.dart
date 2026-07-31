class AppUser {
  final String uid;
  final String name;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final List<String> groupIds;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    this.phone,
    this.email,
    this.photoUrl,
    this.groupIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'photoUrl': photoUrl,
        'groupIds': groupIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] as String,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        photoUrl: m['photoUrl'] as String?,
        groupIds: (m['groupIds'] as List?)?.cast<String>() ?? [],
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
      );
}
