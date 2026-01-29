import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import '../entities/device_vital.dart';
import '../entities/analytics.dart';

// Repository interface: Defines history-related data operations
abstract class HistoryRepository {
  Future<Either<Failure, List<DeviceVital>>> getHistoricalVitals(); // Get historical device vitals
  Future<Either<Failure, Analytics>> getAnalytics(); // Get analytics data
}
