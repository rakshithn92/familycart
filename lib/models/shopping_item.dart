enum ItemStatus { pending, inCart, bought }

class ShoppingItem {
  final String id;
  final String groupId;
  final String name;
  final String? category;
  final int quantity;
  final String? unit;
  final String? note;
  final String addedBy;
  final String? checkedBy;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime? checkedAt;

  ShoppingItem({
    required this.id,
    required this.groupId,
    required this.name,
    this.category,
    this.quantity = 1,
    this.unit,
    this.note,
    required this.addedBy,
    this.checkedBy,
    this.status = ItemStatus.pending,
    DateTime? createdAt,
    this.checkedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ShoppingItem copyWith({
    String? name,
    int? quantity,
    String? category,
    String? note,
    String? checkedBy,
    ItemStatus? status,
    DateTime? checkedAt,
  }) =>
      ShoppingItem(
        id: id,
        groupId: groupId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit,
        note: note ?? this.note,
        addedBy: addedBy,
        checkedBy: checkedBy ?? this.checkedBy,
        status: status ?? this.status,
        createdAt: createdAt,
        checkedAt: checkedAt ?? this.checkedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'groupId': groupId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'note': note,
        'addedBy': addedBy,
        'checkedBy': checkedBy,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'checkedAt': checkedAt?.toIso8601String(),
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'] as String,
        groupId: m['groupId'] as String,
        name: m['name'] as String,
        category: m['category'] as String?,
        quantity: m['quantity'] as int? ?? 1,
        unit: m['unit'] as String?,
        note: m['note'] as String?,
        addedBy: m['addedBy'] as String? ?? '',
        checkedBy: m['checkedBy'] as String?,
        status: ItemStatus.values[m['status'] as int? ?? 0],
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
        checkedAt: m['checkedAt'] != null
            ? DateTime.tryParse(m['checkedAt'] as String)
            : null,
      );
}
