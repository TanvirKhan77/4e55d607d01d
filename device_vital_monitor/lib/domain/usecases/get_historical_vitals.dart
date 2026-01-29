import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/device_vital.dart';
import '../repositories/history_repository.dart';

// Use case class: Get historical device vitals
class GetHistoricalVitals extends UseCaseNoParams<List<DeviceVital>> {
  final HistoryRepository repository; // Repository dependency

  GetHistoricalVitals(this.repository); // Constructor

  @override
  Future<Either<Failure, List<DeviceVital>>> call() async {
    return await repository.getHistoricalVitals(); // Execute repository method
  }
}
