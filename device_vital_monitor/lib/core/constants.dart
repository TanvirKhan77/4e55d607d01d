class AppConstants {
  static const String appName = 'Device Vital Monitor';
  static const String baseUrl = 'http://10.0.2.2:3000'; // Use 10.0.2.2 for Android Emulator, or your machine IP for physical devices
  static const String methodChannelName = 'com.devicevitalmonitor/device';

  static const Duration apiTimeout = Duration(seconds: 10);
  static const int historyLimit = 100;
  static const int rollingAverageWindow = 10;
}

class ThermalStatus {
  static const Map<int, String> labels = {
    0: 'Normal',
    1: 'Light',
    2: 'Moderate',
    3: 'Severe',
  };

  static const Map<int, String> descriptions = {
    0: 'Device temperature is normal',
    1: 'Device is slightly warm',
    2: 'Device is moderately warm',
    3: 'Device is hot - consider cooling',
  };
}

class BatteryStatus {
  static String getLabel(double level) {
    if (level > 80) return 'Excellent';
    if (level > 50) return 'Good';
    if (level > 20) return 'Low';
    return 'Critical';
  }
}

class MemoryStatus {
  static String getLabel(double usage) {
    if (usage < 60) return 'Light';
    if (usage < 80) return 'Moderate';
    return 'Heavy';
  }
}
