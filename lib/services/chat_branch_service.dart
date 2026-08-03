import '../features/chat/domain/models/chat_message.dart';

class ChatMessageBranchNode {
  final String id;
  final String? parentId;
  final ChatMessage message;
  final List<String> childIds;
  final int versionIndex;
  final int totalVersions;

  const ChatMessageBranchNode({
    required this.id,
    this.parentId,
    required this.message,
    required this.childIds,
    this.versionIndex = 0,
    this.totalVersions = 1,
  });
}

class ChatBranchTree {
  final Map<String, ChatMessageBranchNode> _nodes = {};
  String? rootId;
  String? activeLeafId;

  Map<String, ChatMessageBranchNode> get nodes => Map.unmodifiable(_nodes);

  void addMessage(ChatMessage message, {String? parentId}) {
    final id = message.timestamp.millisecondsSinceEpoch.toString();
    final parent = parentId != null ? _nodes[parentId] : null;

    final childIds = <String>[];
    int versionIdx = 0;
    int totalVers = 1;

    if (parent != null) {
      parent.childIds.add(id);
      versionIdx = parent.childIds.length - 1;
      totalVers = parent.childIds.length;
    }

    final node = ChatMessageBranchNode(
      id: id,
      parentId: parentId,
      message: message,
      childIds: childIds,
      versionIndex: versionIdx,
      totalVersions: totalVers,
    );

    _nodes[id] = node;
    rootId ??= id;
    activeLeafId = id;
  }

  List<ChatMessage> getActiveBranch() {
    if (activeLeafId == null) return [];

    final List<ChatMessage> path = [];
    String? currentId = activeLeafId;

    while (currentId != null) {
      final node = _nodes[currentId];
      if (node == null) break;
      path.insert(0, node.message);
      currentId = node.parentId;
    }

    return path;
  }
}
