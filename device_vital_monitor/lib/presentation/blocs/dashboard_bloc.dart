import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/usecases/get_device_vitals.dart';
import 'package:device_vital_monitor/domain/usecases/log_device_vitals.dart';
import './dashboard_event.dart';
import './dashboard_state.dart';

// BLoC class: Manages dashboard state and events
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDeviceVitals getDeviceVitals; // Use case dependency
  final LogDeviceVitals logDeviceVitals; // Use case dependency
  StreamSubscription? _vitalsSubscription; // Subscription for vitals stream

  // Constructor
  DashboardBloc({
    required this.getDeviceVitals, // Use case injection
    required this.logDeviceVitals, // Use case injection
  }) : super(const DashboardInitial()) {
    on<LoadVitalsEvent>(_onLoadVitals); // Event handler for loading vitals
    on<LogVitalsEvent>(_onLogVitals);  // Event handler for logging vitals
    on<RefreshVitalsEvent>(_onRefreshVitals); // Event handler for refreshing vitals
  }

  // Handler for loading device vitals
  Future<void> _onLoadVitals(
      LoadVitalsEvent event, // Event parameter
      Emitter<DashboardState> emit, // Emitter parameter
      ) async {
    emit(const VitalsLoading()); // Emit loading state

    // Get device vitals using the use case
    final result = await getDeviceVitals();

    // Handle the result and emit appropriate states
    result.fold(
          (failure) => emit(VitalsError(_mapFailureToMessage(failure))), // Emit error state
          (vitals) => emit(VitalsLoaded(vitals)), // Emit loaded state with vitals
    );
  }

  // Handler for logging device vitals
  Future<void> _onLogVitals(
      LogVitalsEvent event, // Event parameter
      Emitter<DashboardState> emit, // Emitter parameter
      ) async {
    final currentVitals = state.vitals; // Get current vitals from state
    if (currentVitals == null) return; // If no vitals, return

    // Emit logging in progress state
    emit(LoggingInProgress(currentVitals));
    
    // Log device vitals using the use case
    final result = await logDeviceVitals(currentVitals);

    // Handle the result and emit appropriate states
    result.fold(
          (failure) => emit(LoggingError(currentVitals, _mapFailureToMessage(failure))),
          (_) => emit(LoggingSuccess(currentVitals, 'Vitals logged successfully')),
    );
  }

  // Handler for refreshing device vitals
  Future<void> _onRefreshVitals(
      RefreshVitalsEvent event, // Event parameter
      Emitter<DashboardState> emit, // Emitter parameter
      ) async {
    if (state.isLoading) return; // Prevent multiple simultaneous loads

    emit(const VitalsLoading()); // Emit loading state

    final result = await getDeviceVitals(); // Get device vitals using the use case

    // Handle the result and emit appropriate states
    result.fold(
          (failure) => emit(VitalsError(_mapFailureToMessage(failure))),
          (vitals) => emit(VitalsLoaded(vitals)),
    );
  }

  // Helper method: Map Failure to user-friendly message
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

  // Override close method to cancel subscriptions
  @override
  Future<void> close() {
    _vitalsSubscription?.cancel(); // Cancel vitals subscription if active
    return super.close(); // Call superclass close method
  }
}
