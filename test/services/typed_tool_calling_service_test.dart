import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/typed_tool_calling_service.dart';

void main() {
  group('TypedToolCallingService Tests', () {
    final service = TypedToolCallingService();

    setUp(() {
      service.registerTool(const ToolDefinition(
        name: 'calculator',
        description: 'Basic math calculation',
        parametersSchema: {'type': 'object'},
      ));
    });

    test('parses json tool call accurately', () {
      const response = 'Here is the result: {"tool": "calculator", "arguments": {"expression": "12 * 5"}}';
      final calls = service.parseToolCalls(response);
      expect(calls.length, equals(1));
      expect(calls.first.toolName, equals('calculator'));
      expect(calls.first.arguments['expression'], equals('12 * 5'));
    });

    test('executes tool call and returns result', () async {
      const call = TypedToolCall(id: 'c1', toolName: 'calculator', arguments: {'expression': '10 + 25'});
      final result = await service.executeToolCall(call);
      expect(result.success, isTrue);
      expect(result.output, equals(35.0));
      expect(service.executionHistory.isNotEmpty, isTrue);
    });
  });
}
