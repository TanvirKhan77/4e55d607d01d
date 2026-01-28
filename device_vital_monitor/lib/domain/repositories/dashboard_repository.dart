import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import '../entities/device_vital.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DeviceVital>> getCurrentVitals();
  Future<Either<Failure, Unit>> logVitals(DeviceVital vitals);
}
