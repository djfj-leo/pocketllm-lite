import 'dart:io';
import 'package:flutter/services.dart';

class DeviceHardwareProfile {
  final double totalRamGB;
  final double availableRamGB;
  final String cpuArchitecture;
  final int cpuCores;
  final bool hasGpuAcceleration;
  final double availableStorageGB;
  final String thermalState;

  const DeviceHardwareProfile({
    required this.totalRamGB,
    required this.availableRamGB,
    required this.cpuArchitecture,
    required this.cpuCores,
    required this.hasGpuAcceleration,
    required this.availableStorageGB,
    required this.thermalState,
  });
}

class DeviceSpecService {
  static final DeviceSpecService _instance = DeviceSpecService._internal();
  factory DeviceSpecService() => _instance;
  DeviceSpecService._internal();

  DeviceHardwareProfile? _cachedProfile;

  Future<DeviceHardwareProfile> getHardwareProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;

    double totalRamGB = 6.0;
    double availableRamGB = 3.5;
    bool hasGpu = true;
    double storageGB = 32.0;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platform estimate or native invocation fallback
        totalRamGB = 8.0;
        availableRamGB = 4.2;
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        totalRamGB = 16.0;
        availableRamGB = 10.0;
      }
    } catch (_) {}

    final profile = DeviceHardwareProfile(
      totalRamGB: totalRamGB,
      availableRamGB: availableRamGB,
      cpuArchitecture: Platform.operatingSystem,
      cpuCores: Platform.numberOfProcessors,
      hasGpuAcceleration: hasGpu,
      availableStorageGB: storageGB,
      thermalState: 'normal',
    );

    _cachedProfile = profile;
    return profile;
  }
}
