import 'package:dartz/dartz.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/core/usecase.dart';
import '../entities/analytics.dart';
import '../repositories/history_repository.dart';

class GetAnalytics extends UseCaseNoParams<Analytics> {
  final HistoryRepository repository;

  GetAnalytics(this.repository);

  @override
  Future<Either<Failure, Analytics>> call() async {
    return await repository.getAnalytics();
  }
}
