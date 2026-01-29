import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';
import 'package:device_vital_monitor/domain/repositories/history_repository.dart';
import 'package:device_vital_monitor/data/datasources/remote_data_source.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';
import 'package:device_vital_monitor/data/repositories/device_repository_impl.dart';

// Implementation class: Concrete analytics repository
class AnalyticsRepositoryImpl implements HistoryRepository {
  final RemoteDataSource remoteDataSource;
  final DeviceRepositoryImpl deviceRepository;

  // Constructor: Requires remote data source and device repository
  AnalyticsRepositoryImpl({
    required this.remoteDataSource,
    required this.deviceRepository,
  });

  // Implementation: Get historical vitals for the device
  @override
  Future<Either<Failure, List<DeviceVital>>> getHistoricalVitals() async {
    try {
      final deviceIdResult = await deviceRepository.getDeviceId(); // Get device ID

      // Use fold to handle Either result
      return await deviceIdResult.fold(
            (failure) => Left(failure),
            (deviceId) async {
          try {
            // Fetch historical vitals from remote data source
            final models = await remoteDataSource.getHistoricalVitals(deviceId);
            final entities = models.map((model) => model.toEntity()).toList(); // Convert models to entities
            return Right(entities); // Return successful result
          } on ApiException catch (e) {
            return Left(ServerFailure(e.message, code: e.statusCode));
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get device ID for history: $e'));
    }
  }

  // Implementation: Get analytics data for the device
  @override
  Future<Either<Failure, Analytics>> getAnalytics() async {
    try {
      // Get device ID
      final deviceIdResult = await deviceRepository.getDeviceId();

      // Use fold to handle Either result
      return await deviceIdResult.fold(
            (failure) => Left(failure),
            (deviceId) async {
          try {
            // Fetch analytics data from remote data source
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

// Extension: Convert DeviceVitalModel to DeviceVital entity
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
