import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/usecases/get_device_vitals.dart';
import 'package:device_vital_monitor/domain/usecases/log_device_vitals.dart';
import './dashboard_event.dart';
import './dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDeviceVitals getDeviceVitals;
  final LogDeviceVitals logDeviceVitals;
  StreamSubscription? _vitalsSubscription;

  DashboardBloc({
    required this.getDeviceVitals,
    required this.logDeviceVitals,
  }) : super(const DashboardInitial()) {
    on<LoadVitalsEvent>(_onLoadVitals);
    on<LogVitalsEvent>(_onLogVitals);
    on<RefreshVitalsEvent>(_onRefreshVitals);
  }

  Future<void> _onLoadVitals(
      LoadVitalsEvent event,
      Emitter<DashboardState> emit,
      ) async {
    emit(const VitalsLoading());

    final result = await getDeviceVitals();

    result.fold(
          (failure) => emit(VitalsError(_mapFailureToMessage(failure))),
          (vitals) => emit(VitalsLoaded(vitals)),
    );
  }

  Future<void> _onLogVitals(
      LogVitalsEvent event,
      Emitter<DashboardState> emit,
      ) async {
    final currentVitals = state.vitals;
    if (currentVitals == null) return;

    emit(LoggingInProgress(currentVitals));

    final result = await logDeviceVitals(currentVitals);

    result.fold(
          (failure) => emit(LoggingError(currentVitals, _mapFailureToMessage(failure))),
          (_) => emit(LoggingSuccess(currentVitals, 'Vitals logged successfully')),
    );
  }

  Future<void> _onRefreshVitals(
      RefreshVitalsEvent event,
      Emitter<DashboardState> emit,
      ) async {
    if (state.isLoading) return;

    emit(const VitalsLoading());

    final result = await getDeviceVitals();

    result.fold(
          (failure) => emit(VitalsError(_mapFailureToMessage(failure))),
          (vitals) => emit(VitalsLoaded(vitals)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case PlatformFailure:
        return 'Device error: ${failure.message}';
      case CacheFailure:
        return 'Storage error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }

  @override
  Future<void> close() {
    _vitalsSubscription?.cancel();
    return super.close();
  }
}
