import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/device_vital.dart';
import '../repositories/dashboard_repository.dart';

class LogDeviceVitals implements UseCase<Unit, DeviceVital> {
  final DashboardRepository repository;

  LogDeviceVitals(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeviceVital params) async {
    return await repository.logVitals(params);
  }
}
