import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';
import 'package:device_vital_monitor/domain/repositories/history_repository.dart';
import 'package:device_vital_monitor/data/datasources/remote_data_source.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';
import 'package:device_vital_monitor/data/repositories/device_repository_impl.dart';

class AnalyticsRepositoryImpl implements HistoryRepository {
  final RemoteDataSource remoteDataSource;
  final DeviceRepositoryImpl deviceRepository;

  AnalyticsRepositoryImpl({
    required this.remoteDataSource,
    required this.deviceRepository,
  });

  @override
  Future<Either<Failure, List<DeviceVital>>> getHistoricalVitals() async {
    try {
      final deviceIdResult = await deviceRepository.getDeviceId();

      return await deviceIdResult.fold(
            (failure) => Left(failure),
            (deviceId) async {
          try {
            final models = await remoteDataSource.getHistoricalVitals(deviceId);
            final entities = models.map((model) => model.toEntity()).toList();
            return Right(entities);
          } on ApiException catch (e) {
            return Left(ServerFailure(e.message, code: e.statusCode));
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get device ID for history: $e'));
    }
  }

  @override
  Future<Either<Failure, Analytics>> getAnalytics() async {
    try {
      final deviceIdResult = await deviceRepository.getDeviceId();

      return await deviceIdResult.fold(
            (failure) => Left(failure),
            (deviceId) async {
          try {
            final model = await remoteDataSource.getAnalytics(deviceId);
            return Right(model);
          } on ApiException catch (e) {
            return Left(ServerFailure(e.message, code: e.statusCode));
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get device ID for analytics: $e'));
    }
  }
}

extension on DeviceVitalModel {
  DeviceVital toEntity() {
    return DeviceVital(
      deviceId: deviceId,
      timestamp: timestamp,
      thermalValue: thermalValue,
      batteryLevel: batteryLevel,
      memoryUsage: memoryUsage,
    );
  }
}
