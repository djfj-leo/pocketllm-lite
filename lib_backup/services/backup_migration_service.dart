import 'dart:convert';
import 'package:crypto/crypto.dart';

class BackupArchivePayload {
  final String version;
  final DateTime exportedAt;
  final Map<String, dynamic> settings;
  final List<dynamic> chats;
  final List<dynamic> memories;
  final List<dynamic> personas;
  final String checksum;

  const BackupArchivePayload({
    required this.version,
    required this.exportedAt,
    required this.settings,
    required this.chats,
    required this.memories,
    required this.personas,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'settings': settings,
        'chats': chats,
        'memories': memories,
        'personas': personas,
        'checksum': checksum,
      };

  factory BackupArchivePayload.fromJson(Map<String, dynamic> json) => BackupArchivePayload(
        version: json['version'] as String? ?? '1.0.35',
        exportedAt: DateTime.parse(json['exportedAt'] as String),
        settings: json['settings'] as Map<String, dynamic>? ?? {},
        chats: json['chats'] as List? ?? [],
        memories: json['memories'] as List? ?? [],
        personas: json['personas'] as List? ?? [],
        checksum: json['checksum'] as String? ?? '',
      );
}

class BackupMigrationService {
  static final BackupMigrationService _instance = BackupMigrationService._internal();
  factory BackupMigrationService() => _instance;
  BackupMigrationService._internal();

  String calculateChecksum(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }

  String createBackupJson({
    required Map<String, dynamic> settings,
    required List<dynamic> chats,
    required List<dynamic> memories,
    required List<dynamic> personas,
  }) {
    final now = DateTime.now();
    final rawDataToSign = jsonEncode({
      'settings': settings,
      'chats': chats,
      'memories': memories,
      'personas': personas,
    });
    final checksum = calculateChecksum(rawDataToSign);

    final payload = BackupArchivePayload(
      version: '1.0.35',
      exportedAt: now,
      settings: settings,
      chats: chats,
      memories: memories,
      personas: personas,
      checksum: checksum,
    );

    return jsonEncode(payload.toJson());
  }

  bool verifyAndRestoreBackup(String jsonContent) {
    try {
      final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
      final payload = BackupArchivePayload.fromJson(decoded);

      final rawDataToSign = jsonEncode({
        'settings': payload.settings,
        'chats': payload.chats,
        'memories': payload.memories,
        'personas': payload.personas,
      });

      final calculated = calculateChecksum(rawDataToSign);
      if (payload.checksum.isNotEmpty && payload.checksum != calculated) {
        return false; // Checksum mismatch
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
