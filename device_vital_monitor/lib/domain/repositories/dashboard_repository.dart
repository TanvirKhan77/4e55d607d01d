import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import '../entities/device_vital.dart';

// Repository interface: Defines dashboard-related data operations
abstract class DashboardRepository {
  Future<Either<Failure, DeviceVital>> getCurrentVitals(); // Get current device vitals
  Future<Either<Failure, Unit>> logVitals(DeviceVital vitals); // Log device vitals
}
