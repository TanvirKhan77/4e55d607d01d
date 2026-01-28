import 'package:equatable/equatable.dart';

class RollingAverage extends Equatable {
  final double thermalValue;
  final double batteryLevel;
  final double memoryUsage;
  final int sampleCount;

  const RollingAverage({
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
    required this.sampleCount,
  });

  @override
  List<Object> get props => [
    thermalValue,
    batteryLevel,
    memoryUsage,
    sampleCount,
  ];
}

class DailyStats extends Equatable {
  final int minThermal;
  final int maxThermal;
  final double minBattery;
  final double maxBattery;
  final double minMemory;
  final double maxMemory;

  const DailyStats({
    required this.minThermal,
    required this.maxThermal,
    required this.minBattery,
    required this.maxBattery,
    required this.minMemory,
    required this.maxMemory,
  });

  @override
  List<Object> get props => [
    minThermal,
    maxThermal,
    minBattery,
    maxBattery,
    minMemory,
    maxMemory,
  ];
}

class Analytics extends Equatable {
  final RollingAverage rollingAverage;
  final DailyStats dailyStats;
  final String deviceId;
  final DateTime calculatedAt;

  const Analytics({
    required this.rollingAverage,
    required this.dailyStats,
    required this.deviceId,
    required this.calculatedAt,
  });

  @override
  List<Object> get props => [
    rollingAverage,
    dailyStats,
    deviceId,
    calculatedAt,
  ];
}
