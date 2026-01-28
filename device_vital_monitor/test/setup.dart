// test/setup.dart
import 'package:device_vital_monitor/presentation/blocs/dashboard_event.dart';
import 'package:device_vital_monitor/presentation/blocs/history_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

// Call this in main() before running tests
void setupTestEnvironment() {
  // Mock SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up fallback values for null safety
  registerFallbackValue(const LoadVitalsEvent());
  registerFallbackValue(const RefreshVitalsEvent());
  registerFallbackValue(const LoadHistoryEvent());
  registerFallbackValue(const LoadAnalyticsEvent());

  // Initialize mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
}