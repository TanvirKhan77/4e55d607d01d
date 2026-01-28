import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor/core/constants.dart';

void main() {
  group('Constants Tests', () {
    group('AppConstants', () {
      test('should have correct app name', () {
        expect(AppConstants.appName, 'Device Vital Monitor');
      });

      test('should have valid base URL', () {
        expect(
          AppConstants.baseUrl,
          matches(RegExp(r'https?://.*')),
        );
      });

      test('should have method channel name', () {
        expect(
          AppConstants.methodChannelName,
          'com.devicevitalmonitor/device',
        );
      });

      test('should have API timeout of 10 seconds', () {
        expect(AppConstants.apiTimeout, Duration(seconds: 10));
      });

      test('should have positive API timeout', () {
        expect(AppConstants.apiTimeout.inSeconds, greaterThan(0));
      });

      test('should have valid history limit', () {
        expect(AppConstants.historyLimit, isA<int>());
        expect(AppConstants.historyLimit, greaterThan(0));
        expect(AppConstants.historyLimit, 100);
      });

      test('should have valid rolling average window', () {
        expect(AppConstants.rollingAverageWindow, isA<int>());
        expect(AppConstants.rollingAverageWindow, greaterThan(0));
        expect(AppConstants.rollingAverageWindow, 10);
      });

      test('rolling average window should be less than history limit', () {
        expect(
          AppConstants.rollingAverageWindow,
          lessThanOrEqualTo(AppConstants.historyLimit),
        );
      });
    });

    group('ThermalStatus', () {
      test('should have labels for all thermal values', () {
        expect(ThermalStatus.labels.length, 4);
        expect(ThermalStatus.labels[0], 'Normal');
        expect(ThermalStatus.labels[1], 'Light');
        expect(ThermalStatus.labels[2], 'Moderate');
        expect(ThermalStatus.labels[3], 'Severe');
      });

      test('should have descriptions for all thermal values', () {
        expect(ThermalStatus.descriptions.length, 4);
        expect(
          ThermalStatus.descriptions[0],
          'Device temperature is normal',
        );
        expect(
          ThermalStatus.descriptions[1],
          'Device is slightly warm',
        );
        expect(
          ThermalStatus.descriptions[2],
          'Device is moderately warm',
        );
        expect(
          ThermalStatus.descriptions[3],
          'Device is hot - consider cooling',
        );
      });

      test('should have matching keys in labels and descriptions', () {
        expect(
          ThermalStatus.labels.keys,
          ThermalStatus.descriptions.keys,
        );
      });

      test('all thermal status labels should be non-empty', () {
        for (final label in ThermalStatus.labels.values) {
          expect(label, isNotEmpty);
        }
      });

      test('all thermal status descriptions should be non-empty', () {
        for (final description in ThermalStatus.descriptions.values) {
          expect(description, isNotEmpty);
        }
      });

      test('should have labels map as constant', () {
        expect(ThermalStatus.labels, isA<Map<int, String>>());
      });

      test('should be able to get label by thermal value', () {
        for (int i = 0; i <= 3; i++) {
          expect(ThermalStatus.labels[i], isNotNull);
          expect(ThermalStatus.labels[i], isA<String>());
        }
      });

      test('should be able to get description by thermal value', () {
        for (int i = 0; i <= 3; i++) {
          expect(ThermalStatus.descriptions[i], isNotNull);
          expect(ThermalStatus.descriptions[i], isA<String>());
        }
      });
    });

    group('BatteryStatus', () {
      test('should return Excellent for battery > 80', () {
        expect(BatteryStatus.getLabel(85.0), 'Excellent');
        expect(BatteryStatus.getLabel(100.0), 'Excellent');
        expect(BatteryStatus.getLabel(90.5), 'Excellent');
      });

      test('should return Good for 50 < battery <= 80', () {
        expect(BatteryStatus.getLabel(65.0), 'Good');
        expect(BatteryStatus.getLabel(50.1), 'Good');
        expect(BatteryStatus.getLabel(80.0), 'Good');
      });

      test('should return Low for 20 < battery <= 50', () {
        expect(BatteryStatus.getLabel(35.0), 'Low');
        expect(BatteryStatus.getLabel(20.1), 'Low');
        expect(BatteryStatus.getLabel(50.0), 'Low');
      });

      test('should return Critical for battery <= 20', () {
        expect(BatteryStatus.getLabel(15.0), 'Critical');
        expect(BatteryStatus.getLabel(0.0), 'Critical');
        expect(BatteryStatus.getLabel(20.0), 'Critical');
      });

      test('should handle boundary values correctly', () {
        // Test exact boundaries
        expect(BatteryStatus.getLabel(20.0), 'Critical');
        expect(BatteryStatus.getLabel(20.1), 'Low');
        expect(BatteryStatus.getLabel(50.0), 'Low');
        expect(BatteryStatus.getLabel(50.1), 'Good');
        expect(BatteryStatus.getLabel(80.0), 'Good');
        expect(BatteryStatus.getLabel(80.1), 'Excellent');
      });

      test('should handle decimal values', () {
        expect(BatteryStatus.getLabel(75.5), 'Good');
        expect(BatteryStatus.getLabel(45.25), 'Low');
        expect(BatteryStatus.getLabel(89.99), 'Excellent');
      });

      test('should return valid status for all valid battery levels', () {
        const validStatuses = ['Excellent', 'Good', 'Low', 'Critical'];

        for (double i = 0; i <= 100; i += 10) {
          final status = BatteryStatus.getLabel(i);
          expect(validStatuses, contains(status));
        }
      });
    });

    group('MemoryStatus', () {
      test('should return Light for memory < 60', () {
        expect(MemoryStatus.getLabel(50.0), 'Light');
        expect(MemoryStatus.getLabel(0.0), 'Light');
        expect(MemoryStatus.getLabel(59.9), 'Light');
      });

      test('should return Moderate for 60 <= memory < 80', () {
        expect(MemoryStatus.getLabel(60.0), 'Moderate');
        expect(MemoryStatus.getLabel(70.0), 'Moderate');
        expect(MemoryStatus.getLabel(79.9), 'Moderate');
      });

      test('should return Heavy for memory >= 80', () {
        expect(MemoryStatus.getLabel(80.0), 'Heavy');
        expect(MemoryStatus.getLabel(90.0), 'Heavy');
        expect(MemoryStatus.getLabel(100.0), 'Heavy');
      });

      test('should handle boundary values correctly', () {
        expect(MemoryStatus.getLabel(59.9), 'Light');
        expect(MemoryStatus.getLabel(60.0), 'Moderate');
        expect(MemoryStatus.getLabel(79.9), 'Moderate');
        expect(MemoryStatus.getLabel(80.0), 'Heavy');
      });

      test('should handle decimal values', () {
        expect(MemoryStatus.getLabel(55.5), 'Light');
        expect(MemoryStatus.getLabel(70.25), 'Moderate');
        expect(MemoryStatus.getLabel(85.75), 'Heavy');
      });

      test('should return valid status for all valid memory levels', () {
        const validStatuses = ['Light', 'Moderate', 'Heavy'];

        for (double i = 0; i <= 100; i += 10) {
          final status = MemoryStatus.getLabel(i);
          expect(validStatuses, contains(status));
        }
      });

      test('should be consistent across multiple calls', () {
        final status1 = MemoryStatus.getLabel(75.0);
        final status2 = MemoryStatus.getLabel(75.0);

        expect(status1, status2);
      });
    });

    group('Status Labels Consistency', () {
      test('BatteryStatus and MemoryStatus should return non-empty strings', () {
        for (double i = 0; i <= 100; i += 5) {
          final batteryLabel = BatteryStatus.getLabel(i);
          final memoryLabel = MemoryStatus.getLabel(i);

          expect(batteryLabel, isNotEmpty);
          expect(memoryLabel, isNotEmpty);
        }
      });

      test('all status labels should be valid type', () {
        expect(BatteryStatus.getLabel(50.0), isA<String>());
        expect(MemoryStatus.getLabel(50.0), isA<String>());
        expect(ThermalStatus.labels[0], isA<String>());
        expect(ThermalStatus.descriptions[0], isA<String>());
      });
    });

    group('Edge Cases', () {
      test('should handle extremely low values', () {
        expect(BatteryStatus.getLabel(0.0), 'Critical');
        expect(MemoryStatus.getLabel(0.0), 'Light');
      });

      test('should handle maximum values', () {
        expect(BatteryStatus.getLabel(100.0), 'Excellent');
        expect(MemoryStatus.getLabel(100.0), 'Heavy');
      });

      test('should handle very small decimals', () {
        expect(BatteryStatus.getLabel(0.001), 'Critical');
        expect(MemoryStatus.getLabel(0.001), 'Light');
      });

      test('should handle very precise decimals', () {
        expect(BatteryStatus.getLabel(75.123456), 'Good');
        expect(MemoryStatus.getLabel(70.987654), 'Moderate');
      });
    });

    group('Constants Immutability', () {
      test('thermal status labels should be unmodifiable', () {
        expect(
          () => ThermalStatus.labels[4] = 'Invalid',
          throwsUnsupportedError,
        );
      });

      test('thermal status descriptions should be unmodifiable', () {
        expect(
          () => ThermalStatus.descriptions[4] = 'Invalid',
          throwsUnsupportedError,
        );
      });
    });
  });
}
