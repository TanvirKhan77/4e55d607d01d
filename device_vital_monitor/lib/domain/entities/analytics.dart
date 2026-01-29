import 'package:equatable/equatable.dart';

// Entity class: Represents analytics data for device vitals
class RollingAverage extends Equatable {
  final double thermalValue;
  final double batteryLevel;
  final double memoryUsage;
  final int sampleCount;

  // Constructor
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

// Entity class: Represents daily statistics for device vitals
class DailyStats extends Equatable {
  final int minThermal;
  final int maxThermal;
  final double minBattery;
  final double maxBattery;
  final double minMemory;
  final double maxMemory;

  // Constructor
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

// Entity class: Represents overall analytics data
class Analytics extends Equatable {
  final RollingAverage rollingAverage;
  final DailyStats dailyStats;
  final String deviceId;
  final DateTime calculatedAt;

  // Constructor
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
