import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<void> cacheDeviceId(String deviceId);
  Future<String?> getCachedDeviceId();
  Future<void> clearCache();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheDeviceId(String deviceId) async {
    try {
      await sharedPreferences.setString('device_id', deviceId);
    } catch (e) {
      throw CacheException('Failed to cache device ID: $e');
    }
  }

  @override
  Future<String?> getCachedDeviceId() async {
    try {
      return sharedPreferences.getString('device_id');
    } catch (e) {
      throw CacheException('Failed to get cached device ID: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
