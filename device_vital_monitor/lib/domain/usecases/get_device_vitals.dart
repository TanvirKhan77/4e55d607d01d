import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/device_vital.dart';
import '../repositories/dashboard_repository.dart';

// Use case class: Get device vitals
class GetDeviceVitals extends UseCaseNoParams<DeviceVital> {
  final DashboardRepository repository; // Repository dependency

  GetDeviceVitals(this.repository); // Constructor

  @override
  Future<Either<Failure, DeviceVital>> call() async {
    return await repository.getCurrentVitals(); // Execute repository method
  }
}
