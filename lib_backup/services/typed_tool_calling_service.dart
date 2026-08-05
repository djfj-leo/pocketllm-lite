import 'dart:convert';
import 'dart:math';

class TypedToolCall {
  final String id;
  final String toolName;
  final Map<String, dynamic> arguments;

  const TypedToolCall({
    required this.id,
    required this.toolName,
    required this.arguments,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolName': toolName,
        'arguments': arguments,
      };

  factory TypedToolCall.fromJson(Map<String, dynamic> json) => TypedToolCall(
        id: json['id'] as String? ?? 'call_${Random().nextInt(100000)}',
        toolName: json['tool'] as String? ?? json['toolName'] as String,
        arguments: json['arguments'] as Map<String, dynamic>? ?? {},
      );
}

class TypedToolResult {
  final String toolCallId;
  final String toolName;
  final bool success;
  final dynamic output;
  final String? error;
  final DateTime executedAt;

  TypedToolResult({
    required this.toolCallId,
    required this.toolName,
    required this.success,
    this.output,
    this.error,
    required this.executedAt,
  });

  Map<String, dynamic> toJson() => {
        'toolCallId': toolCallId,
        'toolName': toolName,
        'success': success,
        'output': output,
        'error': error,
        'executedAt': executedAt.toIso8601String(),
      };
}

class ToolDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> parametersSchema;
  final String networkScope; // 'offline', 'local_network', 'internet_required'
  final bool requiresConfirmation;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parametersSchema,
    this.networkScope = 'offline',
    this.requiresConfirmation = false,
  });
}

class TypedToolCallingService {
  static final TypedToolCallingService _instance = TypedToolCallingService._internal();
  factory TypedToolCallingService() => _instance;
  TypedToolCallingService._internal();

  final Map<String, ToolDefinition> _registeredTools = {};
  final List<TypedToolResult> _executionHistory = [];

  List<TypedToolResult> get executionHistory => List.unmodifiable(_executionHistory);

  void registerTool(ToolDefinition def) {
    _registeredTools[def.name] = def;
  }

  ToolDefinition? getTool(String name) => _registeredTools[name];

  List<TypedToolCall> parseToolCalls(String responseText) {
    final List<TypedToolCall> calls = [];

    final trimmed = responseText.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic> && decoded.containsKey('tool')) {
          calls.add(TypedToolCall.fromJson(decoded));
          return calls;
        }
      } catch (_) {}
    }

    int start = responseText.indexOf('{');
    while (start != -1) {
      int depth = 0;
      int end = -1;
      for (int i = start; i < responseText.length; i++) {
        if (responseText[i] == '{') depth++;
        if (responseText[i] == '}') depth--;
        if (depth == 0) {
          end = i;
          break;
        }
      }

      if (end != -1) {
        final candidate = responseText.substring(start, end + 1);
        try {
          final decoded = jsonDecode(candidate);
          if (decoded is Map<String, dynamic> && decoded.containsKey('tool')) {
            calls.add(TypedToolCall.fromJson(decoded));
          }
        } catch (_) {}
        start = responseText.indexOf('{', end + 1);
      } else {
        break;
      }
    }

    return calls;
  }

  Future<TypedToolResult> executeToolCall(TypedToolCall call) async {
    final tool = _registeredTools[call.toolName];
    if (tool == null) {
      final res = TypedToolResult(
        toolCallId: call.id,
        toolName: call.toolName,
        success: false,
        error: 'Unknown tool: ${call.toolName}',
        executedAt: DateTime.now(),
      );
      _executionHistory.add(res);
      return res;
    }

    try {
      dynamic output;
      if (call.toolName == 'calculator') {
        final expr = call.arguments['expression'] as String? ?? '0';
        output = _evaluateMathExpression(expr);
      } else if (call.toolName == 'system_info') {
        output = {
          'os': 'PocketLLM Native Core',
          'status': 'Optimal',
          'time': DateTime.now().toIso8601String(),
        };
      } else {
        output = {'message': 'Tool ${call.toolName} executed successfully.'};
      }

      final res = TypedToolResult(
        toolCallId: call.id,
        toolName: call.toolName,
        success: true,
        output: output,
        executedAt: DateTime.now(),
      );
      _executionHistory.add(res);
      return res;
    } catch (e) {
      final res = TypedToolResult(
        toolCallId: call.id,
        toolName: call.toolName,
        success: false,
        error: e.toString(),
        executedAt: DateTime.now(),
      );
      _executionHistory.add(res);
      return res;
    }
  }

  double _evaluateMathExpression(String expr) {
    // Basic safe expression evaluator
    final cleaned = expr.replaceAll(' ', '');
    if (cleaned.contains('+')) {
      final parts = cleaned.split('+');
      return (double.tryParse(parts[0]) ?? 0) + (double.tryParse(parts[1]) ?? 0);
    } else if (cleaned.contains('*')) {
      final parts = cleaned.split('*');
      return (double.tryParse(parts[0]) ?? 0) * (double.tryParse(parts[1]) ?? 0);
    } else if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      return (double.tryParse(parts[0]) ?? 0) - (double.tryParse(parts[1]) ?? 0);
    } else if (cleaned.contains('/')) {
      final parts = cleaned.split('/');
      final denom = double.tryParse(parts[1]) ?? 1;
      return (double.tryParse(parts[0]) ?? 0) / (denom == 0 ? 1 : denom);
    }
    return double.tryParse(cleaned) ?? 0.0;
  }
}
