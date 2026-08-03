import 'device_spec_service.dart';

enum RecommendationBadge {
  recommended,
  canRun,
  riskOfCrash,
  tooLarge,
}

extension RecommendationBadgeExtension on RecommendationBadge {
  String get label {
    switch (this) {
      case RecommendationBadge.recommended:
        return 'Recommended';
      case RecommendationBadge.canRun:
        return 'Can run';
      case RecommendationBadge.riskOfCrash:
        return 'Risk of crash';
      case RecommendationBadge.tooLarge:
        return 'Too large for this device';
    }
  }
}

class ModelRecommendationResult {
  final RecommendationBadge badge;
  final double compatibilityScore;
  final double estimatedRamUsageGB;
  final String estimatedSpeed;
  final String bestFor;
  final String notRecommendedFor;

  const ModelRecommendationResult({
    required this.badge,
    required this.compatibilityScore,
    required this.estimatedRamUsageGB,
    required this.estimatedSpeed,
    required this.bestFor,
    required this.notRecommendedFor,
  });
}

class ModelRecommendationEngine {
  static final ModelRecommendationEngine _instance = ModelRecommendationEngine._internal();
  factory ModelRecommendationEngine() => _instance;
  ModelRecommendationEngine._internal();

  ModelRecommendationResult evaluateModel({
    required DeviceHardwareProfile profile,
    required double parameterCountB,
    required String quantization,
    required int contextLength,
    bool supportsVision = false,
    bool supportsTools = false,
    bool supportsReasoning = false,
    String? targetTask,
  }) {
    double quantFactor = 0.8;
    final quantUpper = quantization.toUpperCase();
    if (quantUpper.contains('Q2')) {
      quantFactor = 0.45;
    } else if (quantUpper.contains('Q4')) {
      quantFactor = 0.65;
    } else if (quantUpper.contains('Q5')) {
      quantFactor = 0.80;
    } else if (quantUpper.contains('Q8')) {
      quantFactor = 1.15;
    } else if (quantUpper.contains('F16') || quantUpper.contains('FP16')) {
      quantFactor = 2.10;
    }

    final kvCacheGB = (contextLength / 8192.0) * 0.45;
    final estimatedRamGB = (parameterCountB * quantFactor) + kvCacheGB;

    // 1. Memory Fit (0.0 to 1.0)
    double memoryFit = 0.0;
    if (estimatedRamGB <= profile.availableRamGB * 0.70) {
      memoryFit = 1.0;
    } else if (estimatedRamGB <= profile.availableRamGB) {
      memoryFit = 0.75;
    } else if (estimatedRamGB <= profile.totalRamGB * 0.90) {
      memoryFit = 0.40;
    } else {
      memoryFit = 0.10;
    }

    // 2. Predicted Speed (0.0 to 1.0)
    double predictedSpeedScore = 0.8;
    int minTps = 8;
    int maxTps = 14;
    if (parameterCountB <= 2.0) {
      predictedSpeedScore = 1.0;
      minTps = 12;
      maxTps = 22;
    } else if (parameterCountB <= 4.0) {
      predictedSpeedScore = 0.85;
      minTps = 8;
      maxTps = 15;
    } else if (parameterCountB <= 8.0) {
      predictedSpeedScore = 0.60;
      minTps = 4;
      maxTps = 9;
    } else {
      predictedSpeedScore = 0.30;
      minTps = 1;
      maxTps = 4;
    }

    // 3. Context Capacity
    double contextScore = (contextLength >= 8192) ? 1.0 : (contextLength / 8192.0);

    // 4. Task Match
    double taskMatch = 0.8;
    if (targetTask == 'coding' && parameterCountB >= 3.0) taskMatch = 1.0;
    if (targetTask == 'vision' && supportsVision) taskMatch = 1.0;
    if (targetTask == 'reasoning' && supportsReasoning) taskMatch = 1.0;

    // 5. Battery Efficiency
    double batteryEfficiency = (parameterCountB <= 3.0) ? 1.0 : 0.5;

    // 6. Runtime Support
    double runtimeSupport = profile.hasGpuAcceleration ? 1.0 : 0.7;

    // Algorithm: 0.30*memory_fit + 0.20*predicted_speed + 0.15*context_capacity + 0.15*task_match + 0.10*battery_efficiency + 0.10*runtime_support
    final compatibilityScore = (0.30 * memoryFit) +
        (0.20 * predictedSpeedScore) +
        (0.15 * contextScore) +
        (0.15 * taskMatch) +
        (0.10 * batteryEfficiency) +
        (0.10 * runtimeSupport);

    RecommendationBadge badge;
    if (compatibilityScore >= 0.75 && estimatedRamGB <= profile.availableRamGB) {
      badge = RecommendationBadge.recommended;
    } else if (compatibilityScore >= 0.55 && estimatedRamGB <= profile.totalRamGB) {
      badge = RecommendationBadge.canRun;
    } else if (estimatedRamGB <= profile.totalRamGB * 1.1) {
      badge = RecommendationBadge.riskOfCrash;
    } else {
      badge = RecommendationBadge.tooLarge;
    }

    String bestFor = 'General chat and summarization';
    String notRecommendedFor = 'None';

    if (parameterCountB <= 2.0) {
      bestFor = 'Fast chat, low battery usage, mobile quick Q&A';
      notRecommendedFor = 'Complex long-context coding or multi-step reasoning';
    } else if (supportsVision) {
      bestFor = 'Image understanding, document OCR, chart analysis';
    } else if (supportsReasoning) {
      bestFor = 'Math, logic puzzles, step-by-step problem solving';
    } else if (parameterCountB >= 7.0) {
      bestFor = 'Detailed coding, technical writing, complex document analysis';
      notRecommendedFor = 'Low battery mode or quick single-line responses';
    }

    return ModelRecommendationResult(
      badge: badge,
      compatibilityScore: compatibilityScore,
      estimatedRamUsageGB: estimatedRamGB,
      estimatedSpeed: '$minTps–$maxTps tokens/sec',
      bestFor: bestFor,
      notRecommendedFor: notRecommendedFor,
    );
  }
}
