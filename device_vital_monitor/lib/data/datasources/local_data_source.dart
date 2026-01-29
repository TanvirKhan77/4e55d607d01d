import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Abstract class: Defines contract for local data storage operations
abstract class LocalDataSource {
  Future<void> cacheDeviceId(String deviceId); // Cache the device ID locally
  Future<String?> getCachedDeviceId(); // Retrieve the cached device ID
  Future<void> clearCache(); // Clear all cached data
}

// Implementation class: Concrete local data source using SharedPreferences
class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences; // Dependency: SharedPreferences instance

  LocalDataSourceImpl(this.sharedPreferences); // Constructor: Requires SharedPreferences instance

  // Implementation: Cache the device ID locally
  @override
  Future<void> cacheDeviceId(String deviceId) async {
    try {
      await sharedPreferences.setString('device_id', deviceId); // Store device ID
    } catch (e) {
      throw CacheException('Failed to cache device ID: $e'); // Handle exceptions
    }
  }

  // Implementation: Retrieve the cached device ID
  @override
  Future<String?> getCachedDeviceId() async {
    try {
      return sharedPreferences.getString('device_id'); // Get device ID
    } catch (e) {
      throw CacheException('Failed to get cached device ID: $e');
    }
  }

  // Implementation: Clear all cached data
  @override
  Future<void> clearCache() async {
    try {
      // Clear all entries in SharedPreferences
      await sharedPreferences.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
