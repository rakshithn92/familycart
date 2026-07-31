enum ItemStatus { pending, inCart, bought }

class ShoppingItem {
  final String id;
  final String groupId;
  final String name;
  final String? category;
  final int quantity;
  final String? note;
  final String addedBy;
  final ItemStatus status;
  final DateTime createdAt;
  final int recurringDays;

  ShoppingItem({
    required this.id,
    required this.groupId,
    required this.name,
    this.category,
    this.quantity = 1,
    this.note,
    required this.addedBy,
    this.status = ItemStatus.pending,
    DateTime? createdAt,
    this.recurringDays = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  ShoppingItem copyWith({
    String? name,
    int? quantity,
    String? category,
    String? note,
    ItemStatus? status,
    int? recurringDays,
  }) =>
      ShoppingItem(
        id: id,
        groupId: groupId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        addedBy: addedBy,
        status: status ?? this.status,
        createdAt: createdAt,
        recurringDays: recurringDays ?? this.recurringDays,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'groupId': groupId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'note': note,
        'addedBy': addedBy,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'recurringDays': recurringDays,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'] as String,
        groupId: m['groupId'] as String,
        name: m['name'] as String,
        category: m['category'] as String?,
        quantity: m['quantity'] as int? ?? 1,
        note: m['note'] as String?,
        addedBy: m['addedBy'] as String? ?? '',
        status: ItemStatus.values[m['status'] as int? ?? 0],
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
        recurringDays: m['recurringDays'] as int? ?? 0,
      );
}
