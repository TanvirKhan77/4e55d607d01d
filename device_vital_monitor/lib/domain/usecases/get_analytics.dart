import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/analytics.dart';
import '../repositories/history_repository.dart';

// Use case class: Get analytics data
class GetAnalytics extends UseCaseNoParams<Analytics> {
  final HistoryRepository repository; // Repository dependency

  GetAnalytics(this.repository); // Constructor

  @override
  Future<Either<Failure, Analytics>> call() async {
    return await repository.getAnalytics(); // Execute repository method
  }
}
