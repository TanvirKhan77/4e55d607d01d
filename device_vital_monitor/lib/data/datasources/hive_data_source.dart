import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/data/models/hive_vital_model.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

// Abstract class: Defines contract for local Hive data storage operations
abstract class HiveDataSource {
  Future<void> initializeHive(); // Initialize Hive database
  Future<void> saveVital(DeviceVital vital); // Save a vital reading locally
  Future<List<DeviceVital>> getUnsyncedVitals(); // Get all vitals that haven't been synced to server
  Future<List<DeviceVital>> getAllVitals(String deviceId); // Get all vitals for a specific device
  Future<void> markVitalAsSynced(int index); // Mark a specific vital as synced
  Future<void> markAllAsSynced(); // Mark all vitals as synced
  Future<void> clearVitals(); // Clear all stored vitals
  Future<void> deleteVital(int index);  // Delete a specific vital by index
}

// Implementation class: Concrete Hive data source
class HiveDataSourceImpl implements HiveDataSource {
  
  static const String _vitalsBox = 'device_vitals'; // Box name for storing device vitals
  late Box<HiveVitalModel> _vitalsBox_; // Hive box instance
  bool _isInitialized = false; // Tracks if Hive has been initialized

  // Implementation: Initialize Hive database
  @override
  Future<void> initializeHive() async {
    if (_isInitialized) return; // Prevent duplicate initialization
    
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();
      
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HiveVitalModelAdapter());
      }

      // Open the Hive box for device vitals
      _vitalsBox_ = await Hive.openBox<HiveVitalModel>(_vitalsBox);
      _isInitialized = true; // Mark as initialized
    } catch (e) {
      throw CacheException('Failed to initialize Hive: $e');
    }
  }

  // Ensure Hive is initialized before any operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initializeHive(); // Initialize if not already done
    }
  }

  // Implementation: Save a vital reading locally
  @override
  Future<void> saveVital(DeviceVital vital) async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized(); // Ensure Hive is initialized
      final hiveVital = HiveVitalModel.fromEntity(vital, isSynced: false); // Convert to Hive model
      await _vitalsBox_.add(hiveVital); // Save to Hive box
    } catch (e) {
      throw CacheException('Failed to save vital to Hive: $e');
    }
  }

  // Implementation: Get all vitals that haven't been synced to server
  @override
  Future<List<DeviceVital>> getUnsyncedVitals() async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized();
      final vitals = _vitalsBox_.values
          .where((vital) => !vital.isSynced)
          .toList(); // Filter unsynced vitals
      
      return vitals.map((vital) => vital.toEntity()).toList(); // Convert to entity list
    } catch (e) {
      throw CacheException('Failed to get unsynced vitals: $e');
    }
  }

  // Implementation: Get all vitals for a specific device
  @override
  Future<List<DeviceVital>> getAllVitals(String deviceId) async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized();
      final vitals = _vitalsBox_.values
          .where((vital) => vital.deviceId == deviceId)
          .toList(); // Filter vitals by device ID
      
      // Sort by timestamp descending
      vitals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Convert to entity list
      return vitals.map((vital) => vital.toEntity()).toList();
    } catch (e) {
      throw CacheException('Failed to get all vitals: $e');
    }
  }

  // Implementation: Mark a specific vital as synced
  @override
  Future<void> markVitalAsSynced(int index) async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized();
      final vital = _vitalsBox_.getAt(index); // Get vital by index
      if (vital != null) {
        vital.isSynced = true;
        await vital.save(); // Update the vital in Hive
      }
    } catch (e) {
      throw CacheException('Failed to mark vital as synced: $e');
    }
  }

  // Implementation: Mark all vitals as synced
  @override
  Future<void> markAllAsSynced() async {
    try {
      await _ensureInitialized(); // Ensure Hive is initialized
      for (var i = 0; i < _vitalsBox_.length; i++) {
        final vital = _vitalsBox_.getAt(i); // Get vital by index
        if (vital != null && !vital.isSynced) {
          vital.isSynced = true; // Mark as synced
          await vital.save(); // Update the vital in Hive
        }
      }
    } catch (e) {
      throw CacheException('Failed to mark all vitals as synced: $e');
    }
  }

  // Implementation: Clear all stored vitals
  @override
  Future<void> clearVitals() async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized();
      await _vitalsBox_.clear(); // Clear all entries in the box
    } catch (e) {
      throw CacheException('Failed to clear vitals: $e');
    }
  }

  // Implementation: Delete a specific vital by index
  @override
  Future<void> deleteVital(int index) async {
    try {
      // Ensure Hive is initialized
      await _ensureInitialized();
      await _vitalsBox_.deleteAt(index); // Delete vital at specified index
    } catch (e) {
      throw CacheException('Failed to delete vital: $e');
    }
  }
}
