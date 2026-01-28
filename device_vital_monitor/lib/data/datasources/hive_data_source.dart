import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/data/models/hive_vital_model.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

abstract class HiveDataSource {
  Future<void> initializeHive();
  Future<void> saveVital(DeviceVital vital);
  Future<List<DeviceVital>> getUnsyncedVitals();
  Future<List<DeviceVital>> getAllVitals(String deviceId);
  Future<void> markVitalAsSynced(int index);
  Future<void> markAllAsSynced();
  Future<void> clearVitals();
  Future<void> deleteVital(int index);
}

class HiveDataSourceImpl implements HiveDataSource {
  static const String _vitalsBox = 'device_vitals';
  late Box<HiveVitalModel> _vitalsBox_;
  bool _isInitialized = false;

  @override
  Future<void> initializeHive() async {
    if (_isInitialized) return; // Prevent duplicate initialization
    
    try {
      await Hive.initFlutter();
      
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HiveVitalModelAdapter());
      }

      _vitalsBox_ = await Hive.openBox<HiveVitalModel>(_vitalsBox);
      _isInitialized = true;
    } catch (e) {
      throw CacheException('Failed to initialize Hive: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initializeHive();
    }
  }

  @override
  Future<void> saveVital(DeviceVital vital) async {
    try {
      await _ensureInitialized();
      final hiveVital = HiveVitalModel.fromEntity(vital, isSynced: false);
      await _vitalsBox_.add(hiveVital);
    } catch (e) {
      throw CacheException('Failed to save vital to Hive: $e');
    }
  }

  @override
  Future<List<DeviceVital>> getUnsyncedVitals() async {
    try {
      await _ensureInitialized();
      final vitals = _vitalsBox_.values
          .where((vital) => !vital.isSynced)
          .toList();
      
      return vitals.map((vital) => vital.toEntity()).toList();
    } catch (e) {
      throw CacheException('Failed to get unsynced vitals: $e');
    }
  }

  @override
  Future<List<DeviceVital>> getAllVitals(String deviceId) async {
    try {
      await _ensureInitialized();
      final vitals = _vitalsBox_.values
          .where((vital) => vital.deviceId == deviceId)
          .toList();
      
      // Sort by timestamp descending
      vitals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return vitals.map((vital) => vital.toEntity()).toList();
    } catch (e) {
      throw CacheException('Failed to get all vitals: $e');
    }
  }

  @override
  Future<void> markVitalAsSynced(int index) async {
    try {
      await _ensureInitialized();
      final vital = _vitalsBox_.getAt(index);
      if (vital != null) {
        vital.isSynced = true;
        await vital.save();
      }
    } catch (e) {
      throw CacheException('Failed to mark vital as synced: $e');
    }
  }

  @override
  Future<void> markAllAsSynced() async {
    try {
      await _ensureInitialized();
      for (var i = 0; i < _vitalsBox_.length; i++) {
        final vital = _vitalsBox_.getAt(i);
        if (vital != null && !vital.isSynced) {
          vital.isSynced = true;
          await vital.save();
        }
      }
    } catch (e) {
      throw CacheException('Failed to mark all vitals as synced: $e');
    }
  }

  @override
  Future<void> clearVitals() async {
    try {
      await _ensureInitialized();
      await _vitalsBox_.clear();
    } catch (e) {
      throw CacheException('Failed to clear vitals: $e');
    }
  }

  @override
  Future<void> deleteVital(int index) async {
    try {
      await _ensureInitialized();
      await _vitalsBox_.deleteAt(index);
    } catch (e) {
      throw CacheException('Failed to delete vital: $e');
    }
  }
}
