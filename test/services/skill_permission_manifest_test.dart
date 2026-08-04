import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/skill_permission_manifest.dart';

void main() {
  group('SkillPermissionManifest Tests', () {
    test('parses low risk manifest default', () {
      final manifest = SkillPermissionManifest.fromFrontmatter({});
      expect(manifest.riskLevel, equals(SkillRiskLevel.low));
      expect(manifest.networkDomains.isEmpty, isTrue);
    });

    test('detects high risk manifest with write access or high risk label', () {
      final manifest = SkillPermissionManifest.fromFrontmatter({
        'permissions': {
          'network': ['api.github.com', 'huggingface.co', 'tavily.com'],
          'filesystem': {
            'write': ['/exports'],
          },
          'risk': 'high',
        }
      });
      expect(manifest.riskLevel, equals(SkillRiskLevel.high));
      expect(manifest.networkDomains.length, equals(3));
    });
  });
}
