import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import '../entities/device_vital.dart';
import '../entities/analytics.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<DeviceVital>>> getHistoricalVitals();
  Future<Either<Failure, Analytics>> getAnalytics();
}
