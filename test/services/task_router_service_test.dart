import 'package:flutter_test/flutter_test.dart';
import 'package:pocketllm_lite/services/device_spec_service.dart';
import 'package:pocketllm_lite/services/task_router_service.dart';

void main() {
  late TaskRouterService router;
  late DeviceHardwareProfile profile;

  setUp(() {
    router = TaskRouterService();
    profile = const DeviceHardwareProfile(
      totalRamGB: 8.0,
      availableRamGB: 5.0,
      cpuArchitecture: 'arm64',
      cpuCores: 8,
      hasGpuAcceleration: true,
      availableStorageGB: 32.0,
      thermalState: 'normal',
    );
  });

  final candidates = const [
    CandidateModelSpec(
      modelId: 'qwen3:1.7b',
      parameterCountB: 1.7,
      quantization: 'Q4_K_M',
      contextLength: 8192,
      supportsTools: true,
    ),
    CandidateModelSpec(
      modelId: 'deepseek-r1:7b',
      parameterCountB: 7.0,
      quantization: 'Q4_K_M',
      contextLength: 16384,
      supportsReasoning: true,
    ),
    CandidateModelSpec(
      modelId: 'qwen2.5-coder:7b',
      parameterCountB: 7.0,
      quantization: 'Q4_K_M',
      contextLength: 16384,
      isCodeModel: true,
    ),
    CandidateModelSpec(
      modelId: 'llava:7b',
      parameterCountB: 7.0,
      quantization: 'Q4_K_M',
      contextLength: 4096,
      supportsVision: true,
    ),
  ];

  test('routes vision task to multimodal model', () {
    final result = router.routeTask(
      task: UserTaskCategory.vision,
      availableModels: candidates,
      profile: profile,
    );

    expect(result.selectedModelId, equals('llava:7b'));
  });

  test('routes reasoning task to DeepSeek R1 model', () {
    final result = router.routeTask(
      task: UserTaskCategory.bestReasoning,
      availableModels: candidates,
      profile: profile,
    );

    expect(result.selectedModelId, equals('deepseek-r1:7b'));
  });

  test('manual override takes precedence', () {
    final result = router.routeTask(
      task: UserTaskCategory.vision,
      availableModels: candidates,
      profile: profile,
      manualOverrideModelId: 'qwen3:1.7b',
    );

    expect(result.selectedModelId, equals('qwen3:1.7b'));
    expect(result.isManualOverride, isTrue);
  });
}
