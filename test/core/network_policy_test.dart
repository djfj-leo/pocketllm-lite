import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/network_policy_service.dart';

void main() {
  late NetworkPolicyService service;

  setUp(() {
    service = NetworkPolicyService();
  });

  test('isLoopback correctly identifies local endpoints', () {
    expect(service.isLoopback(Uri.parse('http://127.0.0.1:11434')), isTrue);
    expect(service.isLoopback(Uri.parse('http://localhost:11434')), isTrue);
    expect(service.isLoopback(Uri.parse('http://0.0.0.0:8080')), isTrue);
    expect(service.isLoopback(Uri.parse('https://api.github.com')), isFalse);
    expect(service.isLoopback(Uri.parse('https://huggingface.co')), isFalse);
  });

  test('loopback requests are allowed regardless of default policy', () {
    final result = service.evaluateConnection(
      uri: Uri.parse('http://127.0.0.1:11434'),
      purpose: ConnectionPurpose.remoteInference,
      trigger: 'chat_prompt',
      infoSent: 'Local prompt text',
    );

    expect(result.allowed, isTrue);
    expect(service.auditLog, isNotEmpty);
    expect(service.auditLog.first.domain, equals('127.0.0.1'));
  });

  test('font downloads are blocked when runtime font fetching is disabled', () {
    final result = service.evaluateConnection(
      uri: Uri.parse('https://fonts.googleapis.com/css'),
      purpose: ConnectionPurpose.fontDownload,
      trigger: 'font_request',
      infoSent: 'Inter font family request',
    );

    expect(result.allowed, isFalse);
    expect(result.reason, contains('Runtime font downloading is disabled'));
  });
}
