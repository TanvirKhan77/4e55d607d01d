import 'package:device_vital_monitor/domain/entities/analytics.dart';

class RollingAverageModel extends RollingAverage {
  const RollingAverageModel({
    required super.thermalValue,
    required super.batteryLevel,
    required super.memoryUsage,
    required super.sampleCount,
  });

  factory RollingAverageModel.fromJson(Map<String, dynamic> json) {
    return RollingAverageModel(
      thermalValue: (json['thermal_value'] as num).toDouble(),
      batteryLevel: (json['battery_level'] as num).toDouble(),
      memoryUsage: (json['memory_usage'] as num).toDouble(),
      sampleCount: json['sample_count'],
    );
  }
}

class DailyStatsModel extends DailyStats {
  const DailyStatsModel({
    required super.minThermal,
    required super.maxThermal,
    required super.minBattery,
    required super.maxBattery,
    required super.minMemory,
    required super.maxMemory,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    return DailyStatsModel(
      minThermal: json['min_thermal'] ?? 0,
      maxThermal: json['max_thermal'] ?? 0,
      minBattery: (json['min_battery'] as num?)?.toDouble() ?? 0.0,
      maxBattery: (json['max_battery'] as num?)?.toDouble() ?? 0.0,
      minMemory: (json['min_memory'] as num?)?.toDouble() ?? 0.0,
      maxMemory: (json['max_memory'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsModel extends Analytics {
  const AnalyticsModel({
    required super.rollingAverage,
    required super.dailyStats,
    required super.deviceId,
    required super.calculatedAt,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      rollingAverage: RollingAverageModel.fromJson(json['rolling_average']),
      dailyStats: DailyStatsModel.fromJson(json['daily_stats']),
      deviceId: json['device_id'],
      calculatedAt: DateTime.parse(json['calculated_at']),
    );
  }
}
