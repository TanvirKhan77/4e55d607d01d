import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:flutter/services.dart';

abstract class DeviceDataSource {
  Future<int> getThermalStatus();
  Future<double> getBatteryLevel();
  Future<double> getMemoryUsage();
  Future<String> getDeviceId();
}

class DeviceDataSourceImpl implements DeviceDataSource {
  static const platform = MethodChannel('com.devicevitalmonitor/device');

  @override
  Future<int> getThermalStatus() async {
    try {
      final result = await platform.invokeMethod('getThermalStatus');
      return result as int;
    } on PlatformException catch (e) {
      throw DevicePlatformException(
        'Failed to get thermal status: ${e.message}',
        code: int.tryParse(e.code) ?? 0,
      );
    } catch (e) {
      throw DevicePlatformException('Unknown error getting thermal status: $e');
    }
  }

  @override
  Future<double> getBatteryLevel() async {
    try {
      final result = await platform.invokeMethod('getBatteryLevel');
      return (result as num).toDouble();
    } on PlatformException catch (e) {
      throw DevicePlatformException(
        'Failed to get battery level: ${e.message}',
        code: int.tryParse(e.code) ?? 0,
      );
    } catch (e) {
      throw DevicePlatformException('Unknown error getting battery level: $e');
    }
  }

  @override
  Future<double> getMemoryUsage() async {
    try {
      final result = await platform.invokeMethod('getMemoryUsage');
      return (result as num).toDouble();
    } on PlatformException catch (e) {
      throw DevicePlatformException(
        'Failed to get memory usage: ${e.message}',
        code: int.tryParse(e.code) ?? 0,
      );
    } catch (e) {
      throw DevicePlatformException('Unknown error getting memory usage: $e');
    }
  }

  @override
  Future<String> getDeviceId() async {
    try {
      final result = await platform.invokeMethod('getDeviceId');
      return result as String;
    } on PlatformException catch (e) {
      throw DevicePlatformException(
        'Failed to get device ID: ${e.message}',
        code: int.tryParse(e.code) ?? 0,
      );
    } catch (e) {
      throw DevicePlatformException('Unknown error getting device ID: $e');
    }
  }
}
