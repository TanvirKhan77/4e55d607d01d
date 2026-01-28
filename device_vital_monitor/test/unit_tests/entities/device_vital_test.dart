import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

void main() {
  group('DeviceVital Entity Tests', () {
    group('Constructor and Equality', () {
      test('should create a DeviceVital with all required parameters', () {
        final timestamp = DateTime.now();
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.deviceId, 'device-001');
        expect(vital.timestamp, timestamp);
        expect(vital.thermalValue, 2);
        expect(vital.batteryLevel, 75.5);
        expect(vital.memoryUsage, 45.2);
      });

      test('should support equality comparison', () {
        final timestamp = DateTime(2026, 1, 15, 10, 30);
        final vital1 = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        final vital2 = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital1, vital2);
      });

      test('should not be equal with different deviceId', () {
        final timestamp = DateTime(2026, 1, 15);
        final vital1 = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        final vital2 = DeviceVital(
          deviceId: 'device-002',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital1, isNot(vital2));
      });

      test('should not be equal with different timestamp', () {
        final vital1 = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime(2026, 1, 15),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        final vital2 = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime(2026, 1, 16),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital1, isNot(vital2));
      });

      test('should not be equal with different thermalValue', () {
        final timestamp = DateTime(2026, 1, 15);
        final vital1 = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 1,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        final vital2 = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital1, isNot(vital2));
      });
    });

    group('Thermal Status Label', () {
      test('should return Normal for thermalValue 0', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 0,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusLabel, 'Normal');
      });

      test('should return Light for thermalValue 1', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 1,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusLabel, 'Light');
      });

      test('should return Moderate for thermalValue 2', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusLabel, 'Moderate');
      });

      test('should return Severe for thermalValue 3', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 3,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusLabel, 'Severe');
      });

      test('should return Unknown for invalid thermalValue', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusLabel, 'Unknown');
      });
    });

    group('Thermal Status Description', () {
      test('should return correct description for thermalValue 0', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 0,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusDescription, 'Device temperature is normal');
      });

      test('should return correct description for thermalValue 1', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 1,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusDescription, 'Device is slightly warm');
      });

      test('should return correct description for thermalValue 2', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusDescription, 'Device is moderately warm');
      });

      test('should return correct description for thermalValue 3', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 3,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        expect(vital.thermalStatusDescription, 'Device is hot - consider cooling');
      });
    });

    group('Battery Status Label', () {
      test('should return Excellent for batteryLevel > 80', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 85.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Excellent');
      });

      test('should return Good for 50 < batteryLevel <= 80', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 65.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Good');
      });

      test('should return Low for 20 < batteryLevel <= 50', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 35.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Low');
      });

      test('should return Critical for batteryLevel <= 20', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 15.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Critical');
      });

      test('should return Critical for batteryLevel 0', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 0.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Critical');
      });

      test('should return Excellent for batteryLevel 100', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 100.0,
          memoryUsage: 45.2,
        );

        expect(vital.batteryStatusLabel, 'Excellent');
      });
    });

    group('Memory Status Label', () {
      test('should return Light for memoryUsage < 60', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 50.0,
        );

        expect(vital.memoryStatusLabel, 'Light');
      });

      test('should return Moderate for 60 <= memoryUsage < 80', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 70.0,
        );

        expect(vital.memoryStatusLabel, 'Moderate');
      });

      test('should return Heavy for memoryUsage >= 80', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 85.0,
        );

        expect(vital.memoryStatusLabel, 'Heavy');
      });

      test('should return Light for memoryUsage 0', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 0.0,
        );

        expect(vital.memoryStatusLabel, 'Light');
      });

      test('should return Heavy for memoryUsage 100', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 100.0,
        );

        expect(vital.memoryStatusLabel, 'Heavy');
      });
    });

    group('Props for Equatable', () {
      test('should include all properties in props', () {
        final timestamp = DateTime(2026, 1, 15);
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: timestamp,
          thermalValue: 2,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
        );

        final props = vital.props;
        expect(props.length, 5);
        expect(props[0], 'device-001');
        expect(props[1], timestamp);
        expect(props[2], 2);
        expect(props[3], 75.5);
        expect(props[4], 45.2);
      });
    });

    group('Edge Cases', () {
      test('should handle minimum boundary values', () {
        final vital = DeviceVital(
          deviceId: 'device',
          timestamp: DateTime(2000, 1, 1),
          thermalValue: 0,
          batteryLevel: 0.0,
          memoryUsage: 0.0,
        );

        expect(vital.thermalValue, 0);
        expect(vital.batteryLevel, 0.0);
        expect(vital.memoryUsage, 0.0);
      });

      test('should handle maximum boundary values', () {
        final vital = DeviceVital(
          deviceId: 'device-${'x' * 100}',
          timestamp: DateTime(2099, 12, 31),
          thermalValue: 3,
          batteryLevel: 100.0,
          memoryUsage: 100.0,
        );

        expect(vital.thermalValue, 3);
        expect(vital.batteryLevel, 100.0);
        expect(vital.memoryUsage, 100.0);
      });

      test('should handle decimal precision', () {
        final vital = DeviceVital(
          deviceId: 'device-001',
          timestamp: DateTime.now(),
          thermalValue: 2,
          batteryLevel: 75.12345,
          memoryUsage: 45.98765,
        );

        expect(vital.batteryLevel, 75.12345);
        expect(vital.memoryUsage, 45.98765);
      });
    });
  });
}
