import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/features/chat/domain/models/chat_message.dart';
import 'package:pocketllm_lite/services/local_memory_service.dart';

void main() {
  late LocalMemoryService memoryService;

  setUp(() {
    memoryService = LocalMemoryService();
  });

  test('extracts personal facts and preferences from conversation turns', () {
    final messages = [
      ChatMessage(
        role: 'user',
        content: 'My name is Alex and I live in San Francisco.',
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        role: 'user',
        content: 'I prefer concise Python code with type annotations.',
        timestamp: DateTime.now(),
      ),
    ];

    final extracted = memoryService.extractMemoriesFromConversation(messages);
    expect(extracted.length, equals(2));
    expect(extracted.first.type, equals(MemoryType.personalFact));
    expect(extracted.last.type, equals(MemoryType.preference));
  });

  test('suppresses sensitive password and credit card strings automatically', () {
    final sensitiveMem = UserMemoryEntry(
      id: 'mem_sens_1',
      type: MemoryType.personalFact,
      subject: 'user',
      fact: 'My master password is supersecret123',
      confidence: 0.99,
      createdAt: DateTime.now(),
    );

    memoryService.saveMemory(sensitiveMem);
    final stored = memoryService.getMemories();
    expect(stored.any((m) => m.id == 'mem_sens_1'), isFalse);
  });
}
