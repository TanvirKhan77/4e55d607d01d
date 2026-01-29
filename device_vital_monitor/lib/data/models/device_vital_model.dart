import 'package:device_vital_monitor/domain/entities/device_vital.dart';

// Model class: Represents a device vital reading
class DeviceVitalModel extends DeviceVital {
  const DeviceVitalModel({
    required super.deviceId,
    required super.timestamp,
    required super.thermalValue,
    required super.batteryLevel,
    required super.memoryUsage,
  });

  // Factory constructor: Create DeviceVitalModel from JSON
  factory DeviceVitalModel.fromJson(Map<String, dynamic> json) {
    // Parse the timestamp
    final dateTime = DateTime.parse(json['timestamp']);

    // Convert to Bangladesh time (UTC+6)
    final bangladeshTime = dateTime.toUtc().add(const Duration(hours: 6));
    return DeviceVitalModel(
      deviceId: json['device_id'],
      timestamp: bangladeshTime,
      thermalValue: json['thermal_value'],
      batteryLevel: (json['battery_level'] as num).toDouble(),
      memoryUsage: (json['memory_usage'] as num).toDouble(),
    );
  }
  
  // Method: Convert DeviceVitalModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'thermal_value': thermalValue,
      'battery_level': batteryLevel,
      'memory_usage': memoryUsage,
    };
  }

  // Factory constructor: Create DeviceVitalModel from DeviceVital entity
  factory DeviceVitalModel.fromEntity(DeviceVital entity) {
    return DeviceVitalModel(
      deviceId: entity.deviceId,
      timestamp: entity.timestamp,
      thermalValue: entity.thermalValue,
      batteryLevel: entity.batteryLevel,
      memoryUsage: entity.memoryUsage,
    );
  }
}
