class FamilyGroup {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final DateTime createdAt;

  FamilyGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    this.memberIds = const [],
    this.memberNames = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get memberCount => memberIds.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'inviteCode': inviteCode,
        'createdBy': createdBy,
        'memberIds': memberIds,
        'memberNames': memberNames,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FamilyGroup.fromMap(Map<String, dynamic> m) => FamilyGroup(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Family',
        inviteCode: m['inviteCode'] as String? ?? '',
        createdBy: m['createdBy'] as String? ?? '',
        memberIds: (m['memberIds'] as List?)?.cast<String>() ?? [],
        memberNames: (m['memberNames'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as String)) ??
            {},
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
      );
}
