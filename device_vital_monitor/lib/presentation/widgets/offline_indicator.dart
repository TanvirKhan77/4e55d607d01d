import 'package:flutter/material.dart';
import 'package:device_vital_monitor/core/sync_service.dart';

class OfflineIndicator extends StatelessWidget {
  final SyncService syncService;

  const OfflineIndicator({
    super.key,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: syncService.syncStatus,
      builder: (context, syncStatus, _) {
        if (syncStatus == SyncStatus.idle) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        IconData icon;
        String message;

        switch (syncStatus) {
          case SyncStatus.syncing:
            backgroundColor = Colors.blue;
            icon = Icons.cloud_sync;
            message = 'Syncing data...';
            break;
          case SyncStatus.completed:
            backgroundColor = Colors.green;
            icon = Icons.cloud_done;
            message = 'Data synced';
            break;
          case SyncStatus.failed:
            backgroundColor = Colors.orange;
            icon = Icons.cloud_off;
            message = 'Sync failed - will retry';
            break;
          default:
            return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.1),
            border: Border.all(color: backgroundColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: backgroundColor, size: 18),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: backgroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
