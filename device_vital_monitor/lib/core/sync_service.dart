import 'dart:async';
import 'package:device_vital_monitor/core/connectivity_service.dart';
import 'package:device_vital_monitor/data/datasources/hive_data_source.dart';
import 'package:device_vital_monitor/data/datasources/remote_data_source.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final RemoteDataSource remoteDataSource;
  final HiveDataSource hiveDataSource;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  final ValueNotifier<SyncStatus> _syncStatus =
      ValueNotifier<SyncStatus>(SyncStatus.idle);

  SyncService({
    required this.remoteDataSource,
    required this.hiveDataSource,
    required this.connectivityService,
  });

  ValueNotifier<SyncStatus> get syncStatus => _syncStatus;

  void initialize() {
    _connectivitySubscription =
        connectivityService.connectionStatusStream.listen((isConnected) {
      if (isConnected) {
        _syncUnsyncedVitals();
      }
    });
  }

  Future<void> _syncUnsyncedVitals() async {
    try {
      _syncStatus.value = SyncStatus.syncing;

      final unsyncedVitals = await hiveDataSource.getUnsyncedVitals();

      if (unsyncedVitals.isEmpty) {
        _syncStatus.value = SyncStatus.completed;
        return;
      }

      for (int i = 0; i < unsyncedVitals.length; i++) {
        try {
          final vital = unsyncedVitals[i];
          final model = DeviceVitalModel.fromEntity(vital);

          await remoteDataSource.logVitals(model);

          // Mark as synced in Hive
          await hiveDataSource.markVitalAsSynced(i);
        } catch (e) {
          debugPrint('Failed to sync vital at index $i: $e');
          // Continue with next vital even if one fails
        }
      }

      _syncStatus.value = SyncStatus.completed;
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncStatus.value = SyncStatus.failed;
    }
  }

  Future<void> syncNow() async {
    await _syncUnsyncedVitals();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatus.dispose();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}
