import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/connectivity_service.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';
import 'package:device_vital_monitor/domain/repositories/dashboard_repository.dart';
import 'package:device_vital_monitor/data/datasources/device_data_source.dart';
import 'package:device_vital_monitor/data/datasources/local_data_source.dart';
import 'package:device_vital_monitor/data/datasources/remote_data_source.dart';
import 'package:device_vital_monitor/data/datasources/hive_data_source.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';

class DeviceRepositoryImpl implements DashboardRepository {
  final DeviceDataSource deviceDataSource;
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final HiveDataSource hiveDataSource;
  final ConnectivityService connectivityService;

  DeviceRepositoryImpl({
    required this.deviceDataSource,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.hiveDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, DeviceVital>> getCurrentVitals() async {
    try {
      final thermalStatus = await deviceDataSource.getThermalStatus();
      final batteryLevel = await deviceDataSource.getBatteryLevel();
      final memoryUsage = await deviceDataSource.getMemoryUsage();
      final deviceIdResult = await getDeviceId();

      return deviceIdResult.fold(
            (failure) => Left(failure),
            (deviceId) {
          final vitals = DeviceVital(
            deviceId: deviceId,
            timestamp: DateTime.now(),
            thermalValue: thermalStatus,
            batteryLevel: batteryLevel,
            memoryUsage: memoryUsage,
          );
          return Right(vitals);
        },
      );
    } on DevicePlatformException catch (e) {
      return Left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get device vitals: $e'));
    }
  }

  Future<Either<Failure, String>> getDeviceId() async {
    try {
      // Try to get from local cache first
      final cachedId = await localDataSource.getCachedDeviceId();
      if (cachedId != null) {
        return Right(cachedId);
      }

      // If not cached, get from device and cache it
      final deviceId = await deviceDataSource.getDeviceId();
      await localDataSource.cacheDeviceId(deviceId);

      return Right(deviceId);
    } on DevicePlatformException catch (e) {
      return Left(PlatformFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get device ID: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logVitals(DeviceVital vitals) async {
    try {
      final vitalModel = DeviceVitalModel.fromEntity(vitals);
      
      // Check if online
      final isOnline = await connectivityService.isConnected();
      
      if (isOnline) {
        // Try to log to remote
        try {
          await remoteDataSource.logVitals(vitalModel);
          return const Right(unit);
        } on ServerException {
          // Network error - save to local for later sync
          await hiveDataSource.saveVital(vitals);
          return const Right(unit);
        }
      } else {
        // Offline - save to local storage
        await hiveDataSource.saveVital(vitals);
        return const Right(unit);
      }
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to log vitals: $e'));
    }
  }
}
