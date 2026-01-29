import 'package:equatable/equatable.dart';

// Entity class: Represents a device vital reading
class DeviceVital extends Equatable {
  final String deviceId;
  final DateTime timestamp;
  final int thermalValue;
  final double batteryLevel;
  final double memoryUsage;

  // Constructor
  const DeviceVital({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });
 
  // Computed property: Get thermal status label
  String get thermalStatusLabel {
    switch (thermalValue) {
      case 0:
        return 'Normal';
      case 1:
        return 'Light';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }

  // Computed property: Get thermal status description
  String get thermalStatusDescription {
    switch (thermalValue) {
      case 0:
        return 'Device temperature is normal';
      case 1:
        return 'Device is slightly warm';
      case 2:
        return 'Device is moderately warm';
      case 3:
        return 'Device is hot - consider cooling';
      default:
        return 'Temperature status unknown';
    }
  }

  // Computed property: Get battery status label
  String get batteryStatusLabel {
    if (batteryLevel > 80) return 'Excellent';
    if (batteryLevel > 50) return 'Good';
    if (batteryLevel > 20) return 'Low';
    return 'Critical';
  }

  // Computed property: Get memory usage status label
  String get memoryStatusLabel {
    if (memoryUsage < 60) return 'Light';
    if (memoryUsage < 80) return 'Moderate';
    return 'Heavy';
  }

  @override
  List<Object> get props => [
    deviceId,
    timestamp,
    thermalValue,
    batteryLevel,
    memoryUsage,
  ];
}
