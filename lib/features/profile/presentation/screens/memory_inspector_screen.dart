import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/local_memory_service.dart';

class MemoryInspectorScreen extends ConsumerStatefulWidget {
  const MemoryInspectorScreen({super.key});

  @override
  ConsumerState<MemoryInspectorScreen> createState() => _MemoryInspectorScreenState();
}

class _MemoryInspectorScreenState extends ConsumerState<MemoryInspectorScreen> {
  MemoryType? _selectedCategory;

  void _showAddMemoryDialog() {
    final controller = TextEditingController();
    MemoryType category = MemoryType.personalFact;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Memory Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MemoryType>(
              initialValue: category,
              decoration: const InputDecoration(labelText: '分类'),
              items: MemoryType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) category = val;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '内容/指令',
                hintText: 'e.g. Prefers Python code examples with typing hints',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final mem = UserMemoryEntry(
                  id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                  type: category,
                  subject: 'user',
                  fact: controller.text.trim(),
                  confidence: 1.0,
                  createdAt: DateTime.now(),
                );
                LocalMemoryService().saveMemory(mem);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Save Memory'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memoryService = LocalMemoryService();
    final memories = memoryService.getMemories(type: _selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Memory Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddMemoryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chip bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...MemoryType.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.displayName),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: memories.isEmpty
                ? const Center(
                    child: Text('No persistent memories recorded in this category.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: memories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final mem = memories[index];
                      return Card(
                        child: ListTile(
                          title: Text(mem.fact),
                          subtitle: Text(
                            '${mem.type.displayName} • Confidence: ${(mem.confidence * 100).toInt()}% • Created: ${mem.createdAt.day}/${mem.createdAt.month}/${mem.createdAt.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: mem.enabled,
                                onChanged: (val) {
                                  memoryService.toggleMemory(mem.id, val);
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                onPressed: () {
                                  memoryService.deleteMemory(mem.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
