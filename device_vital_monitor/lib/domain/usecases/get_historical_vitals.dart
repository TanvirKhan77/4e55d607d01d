import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/device_vital.dart';
import '../repositories/history_repository.dart';

class GetHistoricalVitals extends UseCaseNoParams<List<DeviceVital>> {
  final HistoryRepository repository;

  GetHistoricalVitals(this.repository);

  @override
  Future<Either<Failure, List<DeviceVital>>> call() async {
    return await repository.getHistoricalVitals();
  }
}
