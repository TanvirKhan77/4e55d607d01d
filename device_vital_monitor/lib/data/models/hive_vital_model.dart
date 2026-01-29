import 'package:hive/hive.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

part 'hive_vital_model.g.dart';

// Hive Model class: Represents a device vital reading stored in Hive
@HiveType(typeId: 0)
class HiveVitalModel extends HiveObject {
  @HiveField(0)
  String deviceId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  int thermalValue;

  @HiveField(3)
  double batteryLevel;

  @HiveField(4)
  double memoryUsage;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  DateTime createdAt;

  // Constructor
  HiveVitalModel({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
    this.isSynced = false,
    required this.createdAt,
  });

  // Factory constructor: Create HiveVitalModel from DeviceVital entity
  factory HiveVitalModel.fromEntity(DeviceVital entity, {bool isSynced = false}) {
    return HiveVitalModel(
      deviceId: entity.deviceId,
      timestamp: entity.timestamp,
      thermalValue: entity.thermalValue,
      batteryLevel: entity.batteryLevel,
      memoryUsage: entity.memoryUsage,
      isSynced: isSynced,
      createdAt: DateTime.now(),
    );
  }

  // Method: Convert HiveVitalModel to DeviceVital entity
  DeviceVital toEntity() {
    return DeviceVital(
      deviceId: deviceId,
      timestamp: timestamp,
      thermalValue: thermalValue,
      batteryLevel: batteryLevel,
      memoryUsage: memoryUsage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'thermal_value': thermalValue,
      'battery_level': batteryLevel,
      'memory_usage': memoryUsage,
    };
  }
}
