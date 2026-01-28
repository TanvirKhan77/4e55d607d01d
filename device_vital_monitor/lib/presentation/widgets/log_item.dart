import 'package:flutter/material.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

class LogItem extends StatelessWidget {
  final DeviceVital log;

  const LogItem({
    super.key,
    required this.log,
  });

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateString = _formatDate(log.timestamp);
    final timeString = _formatTime(log.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Values with colored dots
          Row(
            children: [
              _buildValueWithDot('${log.thermalValue}', Colors.orange),
              const SizedBox(width: 16),
              _buildValueWithDot('${log.batteryLevel.toStringAsFixed(0)}%', Colors.green),
              const SizedBox(width: 16),
              _buildValueWithDot('${log.memoryUsage.toStringAsFixed(0)}%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueWithDot(String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}