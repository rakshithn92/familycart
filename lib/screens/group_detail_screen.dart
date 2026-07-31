import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/family_group.dart';
import '../models/shopping_item.dart';
import '../providers/providers.dart';
import '../services/firebase_service.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final FamilyGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final _itemController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'General';
  int _quantity = 1;

  final _categories = [
    'General', 'Groceries', 'Snacks', 'Beverages',
    'Household', 'Personal Care', 'Electronics', 'Other',
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final name = _itemController.text.trim();
    if (name.isEmpty) return;

    final service = ref.read(firebaseServiceProvider);
    final user = service.currentUser;
    if (user == null) return;

    final item = ShoppingItem(
      id: const Uuid().v4(),
      groupId: widget.group.id,
      name: name,
      category: _selectedCategory,
      quantity: _quantity,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      addedBy: user.uid,
    );

    await service.addItem(item);
    _itemController.clear();
    _noteController.clear();
    setState(() {
      _quantity = 1;
      _selectedCategory = 'General';
    });
  }

  Future<void> _toggleStatus(ShoppingItem item) async {
    final service = ref.read(firebaseServiceProvider);
    final user = service.currentUser;
    if (user == null) return;

    final newStatus = switch (item.status) {
      ItemStatus.pending => ItemStatus.inCart,
      ItemStatus.inCart => ItemStatus.bought,
      ItemStatus.bought => ItemStatus.pending,
    };

    await service.updateItemStatus(
      widget.group.id, item.id, newStatus,
      checkedBy: newStatus == ItemStatus.pending ? null : user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider(widget.group.id));
    final groupAsync = ref.watch(groupProvider(widget.group.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Invite Code'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Share this code with family:'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.group.inviteCode,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add item form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                          hintText: 'Add an item...',
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => setState(() => _quantity = (_quantity + 1).clamp(1, 99)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat, style: const TextStyle(fontSize: 12)),
                              selected: _selectedCategory == cat,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              selectedColor: const Color(0xFF6C63FF),
                              labelStyle: TextStyle(fontSize: 12),
                              visualDensity: VisualDensity.compact,
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addItem,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 40),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text('Shopping list is empty',
                            style: TextStyle(color: Colors.white38)),
                        Text('Add items above to get started',
                            style: TextStyle(fontSize: 13, color: Colors.white24)),
                      ],
                    ),
                  );
                }

                // Group by status
                final pending = items.where((i) => i.status == ItemStatus.pending).toList();
                final inCart = items.where((i) => i.status == ItemStatus.inCart).toList();
                final bought = items.where((i) => i.status == ItemStatus.bought).toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(title: 'To Buy', count: pending.length),
                      ...pending.map((i) => _ItemTile(item: i, onToggle: () => _toggleStatus(i))),
                    ],
                    if (inCart.isNotEmpty) ...[
                      _SectionHeader(title: 'In Cart', count: inCart.length, color: const Color(0xFFFFD93D)),
                      ...inCart.map((i) => _ItemTile(item: i, onToggle: () => _toggleStatus(i))),
                    ],
                    if (bought.isNotEmpty) ...[
                      _SectionHeader(title: 'Bought', count: bought.length, color: const Color(0xFF4ECDC4)),
                      ...bought.map((i) => _ItemTile(item: i, onToggle: () => _toggleStatus(i))),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;
  const _SectionHeader({required this.title, required this.count, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(title, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white54,
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? Colors.white54).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: TextStyle(fontSize: 12, color: color ?? Colors.white54)),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  const _ItemTile({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.status) {
      ItemStatus.pending => (Icons.check_box_outline_blank, Colors.white54),
      ItemStatus.inCart => (Icons.shopping_cart, const Color(0xFFFFD93D)),
      ItemStatus.bought => (Icons.check_box, const Color(0xFF4ECDC4)),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: item.status == ItemStatus.bought
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.status == ItemStatus.bought
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                        if (item.quantity > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('x${item.quantity}',
                                style: TextStyle(fontSize: 11, color: Colors.white54)),
                          ),
                        ],
                      ],
                    ),
                    if (item.category != null && item.category != 'General')
                      Text(item.category!, style: TextStyle(fontSize: 11, color: Colors.white24)),
                  ],
                ),
              ),
              if (item.note != null && item.note!.isNotEmpty)
                Icon(Icons.notes, size: 16, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
