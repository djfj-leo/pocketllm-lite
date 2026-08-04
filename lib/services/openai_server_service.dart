import 'dart:async';
import 'dart:convert';
import 'dart:io';

class OpenAiServerConfig {
  final bool enabled;
  final int port;
  final String apiKey;
  final bool localhostOnly;

  const OpenAiServerConfig({
    this.enabled = false,
    this.port = 8080,
    this.apiKey = 'pk-pocketllm-local-key',
    this.localhostOnly = true,
  });
}

class OpenAiServerLog {
  final DateTime timestamp;
  final String clientIp;
  final String path;
  final int statusCode;

  const OpenAiServerLog({
    required this.timestamp,
    required this.clientIp,
    required this.path,
    required this.statusCode,
  });
}

class OpenAiServerService {
  static final OpenAiServerService _instance = OpenAiServerService._internal();
  factory OpenAiServerService() => _instance;
  OpenAiServerService._internal();

  HttpServer? _server;
  OpenAiServerConfig _config = const OpenAiServerConfig();
  final List<OpenAiServerLog> _logs = [];

  bool get isRunning => _server != null;
  OpenAiServerConfig get config => _config;
  List<OpenAiServerLog> get logs => List.unmodifiable(_logs);

  Future<bool> startServer(OpenAiServerConfig config) async {
    await stopServer();
    _config = config;

    if (!config.enabled) return false;

    try {
      final host = config.localhostOnly ? InternetAddress.loopbackIPv4 : InternetAddress.anyIPv4;
      _server = await HttpServer.bind(host, config.port);
      _server!.listen(_handleRequest);
      return true;
    } catch (e) {
      _server = null;
      return false;
    }
  }

  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
  }

  void _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    final clientIp = request.connectionInfo?.remoteAddress.address ?? '127.0.0.1';

    // Verify auth
    final authHeader = request.headers.value(HttpHeaders.authorizationHeader);
    final expectedAuth = 'Bearer ${_config.apiKey}';
    if (_config.apiKey.isNotEmpty && authHeader != expectedAuth) {
      request.response.statusCode = HttpStatus.unauthorized;
      request.response.write(jsonEncode({'error': 'Unauthorized: Invalid API Key'}));
      await request.response.close();
      _logRequest(clientIp, path, HttpStatus.unauthorized);
      return;
    }

    if (path == '/v1/models') {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'object': 'list',
        'data': [
          {
            'id': 'pocketllm-local-qwen3',
            'object': 'model',
            'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'owned_by': 'pocketllm-lite'
          }
        ]
      }));
      request.response.statusCode = HttpStatus.ok;
    } else if (path == '/v1/chat/completions') {
      final body = await utf8.decoder.bind(request).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>? ?? {};
      final messages = decoded['messages'] as List? ?? [];
      final lastPrompt = messages.isNotEmpty ? messages.last['content'].toString() : 'Hello';

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'id': 'chatcmpl-${DateTime.now().millisecondsSinceEpoch}',
        'object': 'chat.completion',
        'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'model': 'pocketllm-local',
        'choices': [
          {
            'index': 0,
            'message': {
              'role': 'assistant',
              'content': 'Response from PocketLLM Lite Local Server to: "$lastPrompt"',
            },
            'finish_reason': 'stop'
          }
        ]
      }));
      request.response.statusCode = HttpStatus.ok;
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write(jsonEncode({'error': 'Endpoint not found'}));
    }

    await request.response.close();
    _logRequest(clientIp, path, request.response.statusCode);
  }

  void _logRequest(String clientIp, String path, int statusCode) {
    _logs.insert(
      0,
      OpenAiServerLog(
        timestamp: DateTime.now(),
        clientIp: clientIp,
        path: path,
        statusCode: statusCode,
      ),
    );
    if (_logs.length > 50) _logs.removeLast();
  }
}
