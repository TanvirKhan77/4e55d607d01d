import 'package:flutter/material.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';

class AnalyticsCard extends StatelessWidget {
  final Analytics analytics;

  const AnalyticsCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Analytics (Last 10 logs)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Averages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat(
                'Thermal',
                analytics.rollingAverage.thermalValue.toStringAsFixed(1),
                Colors.orange,
              ),
              _buildSimpleStat(
                'Battery',
                '${analytics.rollingAverage.batteryLevel.toStringAsFixed(1)}%',
                Colors.green,
              ),
              _buildSimpleStat(
                'Memory',
                '${analytics.rollingAverage.memoryUsage.toStringAsFixed(1)}%',
                Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Ranges
          Text(
            'Daily Ranges',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: [
              _buildSimpleRange(
                'Thermal',
                '${analytics.dailyStats.minThermal} → ${analytics.dailyStats.maxThermal}',
                Colors.orange,
              ),
              const SizedBox(height: 10),
              _buildSimpleRange(
                'Battery',
                '${analytics.dailyStats.minBattery.toStringAsFixed(1)}% → ${analytics.dailyStats.maxBattery.toStringAsFixed(1)}%',
                Colors.green,
              ),
              const SizedBox(height: 10),
              _buildSimpleRange(
                'Memory',
                '${analytics.dailyStats.minMemory.toStringAsFixed(1)}% → ${analytics.dailyStats.maxMemory.toStringAsFixed(1)}%',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRange(String label, String range, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            range,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}