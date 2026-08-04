import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/backup_migration_service.dart';

void main() {
  group('BackupMigrationService Tests', () {
    final service = BackupMigrationService();

    test('creates backup json with valid SHA-256 checksum and restores successfully', () {
      final jsonStr = service.createBackupJson(
        settings: {'theme': 'dark'},
        chats: [{'id': 'c1'}],
        memories: [{'id': 'm1'}],
        personas: [{'id': 'p1'}],
      );

      expect(jsonStr.contains('"version":"1.0.35"'), isTrue);
      expect(jsonStr.contains('"checksum":'), isTrue);

      final valid = service.verifyAndRestoreBackup(jsonStr);
      expect(valid, isTrue);
    });

    test('rejects tampered backup json with invalid checksum', () {
      final jsonStr = service.createBackupJson(
        settings: {'theme': 'dark'},
        chats: [],
        memories: [],
        personas: [],
      );

      final tampered = jsonStr.replaceAll('"theme":"dark"', '"theme":"light"');
      final valid = service.verifyAndRestoreBackup(tampered);
      expect(valid, isFalse);
    });
  });
}
