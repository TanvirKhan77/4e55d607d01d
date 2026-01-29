import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/device_vital.dart';
import '../repositories/dashboard_repository.dart';

// Use case class: Log device vitals
class LogDeviceVitals implements UseCase<Unit, DeviceVital> {
  final DashboardRepository repository; // Repository dependency

  LogDeviceVitals(this.repository); // Constructor

  @override
  Future<Either<Failure, Unit>> call(DeviceVital params) async {
    return await repository.logVitals(params); // Execute repository method
  }
}
