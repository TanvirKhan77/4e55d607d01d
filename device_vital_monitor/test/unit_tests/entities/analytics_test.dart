import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';

void main() {
  group('Analytics Entity Tests', () {
    group('RollingAverage', () {
      test('should create RollingAverage with all required fields', () {
        const average = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        expect(average.thermalValue, 1.5);
        expect(average.batteryLevel, 75.5);
        expect(average.memoryUsage, 45.2);
        expect(average.sampleCount, 10);
      });

      test('should support equality comparison', () {
        const average1 = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        const average2 = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        expect(average1, average2);
      });

      test('should not be equal with different thermalValue', () {
        const average1 = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        const average2 = RollingAverage(
          thermalValue: 2.0,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        expect(average1, isNot(average2));
      });

      test('should not be equal with different sampleCount', () {
        const average1 = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        const average2 = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 20,
        );

        expect(average1, isNot(average2));
      });

      test('should handle zero values', () {
        const average = RollingAverage(
          thermalValue: 0.0,
          batteryLevel: 0.0,
          memoryUsage: 0.0,
          sampleCount: 0,
        );

        expect(average.thermalValue, 0.0);
        expect(average.sampleCount, 0);
      });

      test('should handle maximum values', () {
        const average = RollingAverage(
          thermalValue: 3.0,
          batteryLevel: 100.0,
          memoryUsage: 100.0,
          sampleCount: 1000,
        );

        expect(average.thermalValue, 3.0);
        expect(average.batteryLevel, 100.0);
        expect(average.memoryUsage, 100.0);
        expect(average.sampleCount, 1000);
      });

      test('props should contain all fields', () {
        const average = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        final props = average.props;
        expect(props.length, 4);
        expect(props[0], 1.5);
        expect(props[1], 75.5);
        expect(props[2], 45.2);
        expect(props[3], 10);
      });
    });

    group('DailyStats', () {
      test('should create DailyStats with all required fields', () {
        const stats = DailyStats(
          minThermal: 0,
          maxThermal: 3,
          minBattery: 20.0,
          maxBattery: 100.0,
          minMemory: 30.0,
          maxMemory: 90.0,
        );

        expect(stats.minThermal, 0);
        expect(stats.maxThermal, 3);
        expect(stats.minBattery, 20.0);
        expect(stats.maxBattery, 100.0);
        expect(stats.minMemory, 30.0);
        expect(stats.maxMemory, 90.0);
      });

      test('should support equality comparison', () {
        const stats1 = DailyStats(
          minThermal: 0,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        const stats2 = DailyStats(
          minThermal: 0,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        expect(stats1, stats2);
      });

      test('should not be equal with different minThermal', () {
        const stats1 = DailyStats(
          minThermal: 0,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        const stats2 = DailyStats(
          minThermal: 1,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        expect(stats1, isNot(stats2));
      });

      test('should validate min/max relationships', () {
        // Min should be less than or equal to max
        const stats = DailyStats(
          minThermal: 0,
          maxThermal: 3,
          minBattery: 20.0,
          maxBattery: 100.0,
          minMemory: 30.0,
          maxMemory: 90.0,
        );

        expect(stats.minThermal, lessThanOrEqualTo(stats.maxThermal));
        expect(stats.minBattery, lessThanOrEqualTo(stats.maxBattery));
        expect(stats.minMemory, lessThanOrEqualTo(stats.maxMemory));
      });

      test('props should contain all fields', () {
        const stats = DailyStats(
          minThermal: 1,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        final props = stats.props;
        expect(props.length, 6);
        expect(props[0], 1);
        expect(props[1], 2);
        expect(props[2], 50.0);
        expect(props[3], 85.0);
        expect(props[4], 40.0);
        expect(props[5], 75.0);
      });
    });

    group('Analytics', () {
      late RollingAverage rollingAverage;
      late DailyStats dailyStats;
      late DateTime now;

      setUp(() {
        rollingAverage = const RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        dailyStats = const DailyStats(
          minThermal: 0,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        now = DateTime.now();
      });

      test('should create Analytics with all required fields', () {
        final analytics = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        expect(analytics.rollingAverage, rollingAverage);
        expect(analytics.dailyStats, dailyStats);
        expect(analytics.deviceId, 'device-001');
        expect(analytics.calculatedAt, now);
      });

      test('should support equality comparison', () {
        final analytics1 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        final analytics2 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        expect(analytics1, analytics2);
      });

      test('should not be equal with different deviceId', () {
        final analytics1 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        final analytics2 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-002',
          calculatedAt: now,
        );

        expect(analytics1, isNot(analytics2));
      });

      test('should not be equal with different calculatedAt', () {
        final analytics1 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: DateTime(2024, 1, 15),
        );

        final analytics2 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: DateTime(2024, 1, 16),
        );

        expect(analytics1, isNot(analytics2));
      });

      test('should not be equal with different rollingAverage', () {
        final analytics1 = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        const differentAverage = RollingAverage(
          thermalValue: 2.0,
          batteryLevel: 80.0,
          memoryUsage: 50.0,
          sampleCount: 10,
        );

        final analytics2 = Analytics(
          rollingAverage: differentAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        expect(analytics1, isNot(analytics2));
      });

      test('props should contain all fields', () {
        final analytics = Analytics(
          rollingAverage: rollingAverage,
          dailyStats: dailyStats,
          deviceId: 'device-001',
          calculatedAt: now,
        );

        final props = analytics.props;
        expect(props.length, 4);
        expect(props[0], rollingAverage);
        expect(props[1], dailyStats);
        expect(props[2], 'device-001');
        expect(props[3], now);
      });

      test('should handle different device IDs', () {
        final deviceIds = ['device-001', 'device-002', 'sensor-123', 'phone-abc'];

        for (final deviceId in deviceIds) {
          final analytics = Analytics(
            rollingAverage: rollingAverage,
            dailyStats: dailyStats,
            deviceId: deviceId,
            calculatedAt: now,
          );

          expect(analytics.deviceId, deviceId);
        }
      });

      test('should handle different timestamps', () {
        final timestamps = [
          DateTime(2024, 1, 1),
          DateTime(2024, 6, 15),
          DateTime(2024, 12, 31),
        ];

        for (final timestamp in timestamps) {
          final analytics = Analytics(
            rollingAverage: rollingAverage,
            dailyStats: dailyStats,
            deviceId: 'device-001',
            calculatedAt: timestamp,
          );

          expect(analytics.calculatedAt, timestamp);
        }
      });
    });

    group('Analytics Integration', () {
      test('complete analytics with extreme values', () {
        const rollingAvg = RollingAverage(
          thermalValue: 0.0,
          batteryLevel: 0.0,
          memoryUsage: 0.0,
          sampleCount: 0,
        );

        const dailyStats = DailyStats(
          minThermal: 0,
          maxThermal: 3,
          minBattery: 0.0,
          maxBattery: 100.0,
          minMemory: 0.0,
          maxMemory: 100.0,
        );

        final analytics = Analytics(
          rollingAverage: rollingAvg,
          dailyStats: dailyStats,
          deviceId: 'extreme-device',
          calculatedAt: DateTime.now(),
        );

        expect(analytics.rollingAverage.thermalValue, 0.0);
        expect(analytics.dailyStats.maxBattery, 100.0);
      });

      test('complete analytics with realistic values', () {
        const rollingAvg = RollingAverage(
          thermalValue: 1.8,
          batteryLevel: 65.5,
          memoryUsage: 52.3,
          sampleCount: 10,
        );

        const dailyStats = DailyStats(
          minThermal: 1,
          maxThermal: 2,
          minBattery: 55.0,
          maxBattery: 75.0,
          minMemory: 45.0,
          maxMemory: 60.0,
        );

        final analytics = Analytics(
          rollingAverage: rollingAvg,
          dailyStats: dailyStats,
          deviceId: 'realistic-device',
          calculatedAt: DateTime.now(),
        );

        expect(analytics.rollingAverage.sampleCount, 10);
        expect(
          analytics.rollingAverage.thermalValue,
          lessThan(analytics.dailyStats.maxThermal.toDouble()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle very long device IDs', () {
        const rollingAvg = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 10,
        );

        const dailyStats = DailyStats(
          minThermal: 0,
          maxThermal: 2,
          minBattery: 50.0,
          maxBattery: 85.0,
          minMemory: 40.0,
          maxMemory: 75.0,
        );

        final longDeviceId = 'device-${'x' * 100}';
        final analytics = Analytics(
          rollingAverage: rollingAvg,
          dailyStats: dailyStats,
          deviceId: longDeviceId,
          calculatedAt: DateTime.now(),
        );

        expect(analytics.deviceId.length, 107);
      });

      test('should handle very large sample counts', () {
        const rollingAvg = RollingAverage(
          thermalValue: 1.5,
          batteryLevel: 75.5,
          memoryUsage: 45.2,
          sampleCount: 1000000,
        );

        expect(rollingAvg.sampleCount, 1000000);
      });

      test('should handle precise decimal values', () {
        const rollingAvg = RollingAverage(
          thermalValue: 1.123456,
          batteryLevel: 75.987654,
          memoryUsage: 45.555555,
          sampleCount: 10,
        );

        expect(rollingAvg.thermalValue, 1.123456);
        expect(rollingAvg.batteryLevel, 75.987654);
      });
    });
  });
}
