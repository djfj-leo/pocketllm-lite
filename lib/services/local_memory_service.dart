import 'dart:convert';
import '../features/chat/domain/models/chat_message.dart';

enum MemoryType {
  personalFact,
  preference,
  project,
  people,
  goal,
  writingStyle,
  reusableInstruction,
}

extension MemoryTypeExtension on MemoryType {
  String get displayName {
    switch (this) {
      case MemoryType.personalFact:
        return 'Personal Fact';
      case MemoryType.preference:
        return 'Preference';
      case MemoryType.project:
        return 'Project';
      case MemoryType.people:
        return 'Person / Contact';
      case MemoryType.goal:
        return 'Goal';
      case MemoryType.writingStyle:
        return 'Writing Style';
      case MemoryType.reusableInstruction:
        return 'Reusable Instruction';
    }
  }
}

class UserMemoryEntry {
  final String id;
  final MemoryType type;
  final String subject;
  final String fact;
  final double confidence;
  final String? sourceMessageId;
  final bool sensitive;
  final bool pinned;
  final bool enabled;
  final DateTime createdAt;
  DateTime? lastUsedAt;

  UserMemoryEntry({
    required this.id,
    required this.type,
    required this.subject,
    required this.fact,
    required this.confidence,
    this.sourceMessageId,
    this.sensitive = false,
    this.pinned = false,
    this.enabled = true,
    required this.createdAt,
    this.lastUsedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'subject': subject,
        'fact': fact,
        'confidence': confidence,
        'sourceMessageId': sourceMessageId,
        'sensitive': sensitive,
        'pinned': pinned,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
      };

  factory UserMemoryEntry.fromJson(Map<String, dynamic> json) => UserMemoryEntry(
        id: json['id'] as String,
        type: MemoryType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MemoryType.personalFact,
        ),
        subject: json['subject'] as String? ?? 'user',
        fact: json['fact'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.90,
        sourceMessageId: json['sourceMessageId'] as String?,
        sensitive: json['sensitive'] as bool? ?? false,
        pinned: json['pinned'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt'] as String) : null,
      );
}

class LocalMemoryService {
  static final LocalMemoryService _instance = LocalMemoryService._internal();
  factory LocalMemoryService() => _instance;
  LocalMemoryService._internal();

  final List<UserMemoryEntry> _memories = [];

  List<UserMemoryEntry> getMemories({MemoryType? type, bool enabledOnly = false}) {
    return _memories.where((m) {
      if (enabledOnly && !m.enabled) return false;
      if (type != null && m.type != type) return false;
      return true;
    }).toList();
  }

  void saveMemory(UserMemoryEntry entry) {
    if (isSensitive(entry.fact)) return; // Suppress sensitive memories automatically
    final idx = _memories.indexWhere((m) => m.id == entry.id);
    if (idx >= 0) {
      _memories[idx] = entry;
    } else {
      _memories.add(entry);
    }
  }

  void deleteMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
  }

  void toggleMemory(String id, bool enabled) {
    final idx = _memories.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      final old = _memories[idx];
      _memories[idx] = UserMemoryEntry(
        id: old.id,
        type: old.type,
        subject: old.subject,
        fact: old.fact,
        confidence: old.confidence,
        sourceMessageId: old.sourceMessageId,
        sensitive: old.sensitive,
        pinned: old.pinned,
        enabled: enabled,
        createdAt: old.createdAt,
        lastUsedAt: old.lastUsedAt,
      );
    }
  }

  bool isSensitive(String text) {
    final lower = text.toLowerCase();
    final sensitiveKeywords = [
      'password',
      'secret',
      'credit card',
      'ssn',
      'social security',
      'api_key',
      'private_key',
      'token',
      'bank account',
      'medical record',
    ];
    return sensitiveKeywords.any((kw) => lower.contains(kw));
  }

  List<UserMemoryEntry> extractMemoriesFromConversation(List<ChatMessage> messages) {
    final List<UserMemoryEntry> extracted = [];

    for (final msg in messages) {
      if (msg.role != 'user') continue;
      final text = msg.content;
      final lower = text.toLowerCase();

      // Rule-based extraction heuristics
      if (lower.contains('my name is ') || lower.contains("i'm a ") || lower.contains('i live in ')) {
        final factText = text.trim();
        if (!isSensitive(factText)) {
          extracted.add(UserMemoryEntry(
            id: 'mem_${DateTime.now().millisecondsSinceEpoch}_${extracted.length}',
            type: MemoryType.personalFact,
            subject: 'user',
            fact: factText,
            confidence: 0.92,
            sourceMessageId: msg.timestamp.millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now(),
          ));
        }
      } else if (lower.contains('i prefer ') || lower.contains('i like ') || lower.contains('always write ')) {
        final factText = text.trim();
        if (!isSensitive(factText)) {
          extracted.add(UserMemoryEntry(
            id: 'mem_${DateTime.now().millisecondsSinceEpoch}_${extracted.length}',
            type: MemoryType.preference,
            subject: 'user',
            fact: factText,
            confidence: 0.88,
            sourceMessageId: msg.timestamp.millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    for (final mem in extracted) {
      saveMemory(mem);
    }

    return extracted;
  }
}
