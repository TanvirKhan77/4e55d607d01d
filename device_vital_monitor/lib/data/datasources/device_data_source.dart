import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:flutter/services.dart';

// Abstract class: Defines contract for device data sources
abstract class DeviceDataSource {
  Future<int> getThermalStatus(); // Method: Get device thermal status (0-3 integer)
  Future<double> getBatteryLevel(); // Method: Get battery level percentage (0.0-100.0)
  Future<double> getMemoryUsage(); // Method: Get memory usage percentage (0.0-100.0)
  Future<String> getDeviceId(); // Method: Get unique device identifier
}

// Implementation class: Concrete device data source using platform channels
class DeviceDataSourceImpl implements DeviceDataSource {
  // Channel name must match native platform implementation
  static const platform = MethodChannel('com.devicevitalmonitor/device');

  // Implementation: Get device thermal status from native platform
  @override
  Future<int> getThermalStatus() async {
    try {
      // Invoke native method to get thermal status
      final result = await platform.invokeMethod('getThermalStatus');
      return result as int; // Cast to integer (0-3 scale)
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      throw DevicePlatformException(
        'Failed to get thermal status: ${e.message}',
        code: int.tryParse(e.code) ?? 0,
      );
    } catch (e) {
      // Handle any other exceptions
      throw DevicePlatformException('Unknown error getting thermal status: $e');
    }
  }

  // Implementation: Get battery level from native platform
  @override
  Future<double> getBatteryLevel() async {
    try {
      // Invoke native method to get battery level
      final result = await platform.invokeMethod('getBatteryLevel');
      return (result as num).toDouble(); // Cast to double (0.0-100.0)
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      throw DevicePlatformException(
        'Failed to get battery level: ${e.message}',
        code: int.tryParse(e.code) ?? 0, // Convert error code to int
      );
    } catch (e) {
      // Handle any other exceptions
      throw DevicePlatformException('Unknown error getting battery level: $e');
    }
  }

  // Implementation: Get memory usage from native platform
  @override
  Future<double> getMemoryUsage() async {
    try {
      // Invoke native method to get memory usage
      final result = await platform.invokeMethod('getMemoryUsage');
      return (result as num).toDouble(); // Cast to double (0.0-100.0)
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      throw DevicePlatformException(
        'Failed to get memory usage: ${e.message}',
        code: int.tryParse(e.code) ?? 0, // Convert error code to int
      );
    } catch (e) {
      // Handle any other exceptions
      throw DevicePlatformException('Unknown error getting memory usage: $e');
    }
  }

  // Implementation: Get device ID from native platform
  @override
  Future<String> getDeviceId() async {
    try {
      // Invoke native method to get device ID
      final result = await platform.invokeMethod('getDeviceId');
      return result as String; // Cast to string
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      throw DevicePlatformException(
        'Failed to get device ID: ${e.message}',
        code: int.tryParse(e.code) ?? 0, // Convert error code to int
      );
    } catch (e) {
      // Handle any other exceptions
      throw DevicePlatformException('Unknown error getting device ID: $e');
    }
  }
}
