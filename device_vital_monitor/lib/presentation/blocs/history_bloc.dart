import 'package:bloc/bloc.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/usecases/get_historical_vitals.dart';
import 'package:device_vital_monitor/domain/usecases/get_analytics.dart';
import './history_event.dart';
import './history_state.dart';

// Bloc class: Manages history-related events and states
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoricalVitals getHistoricalVitals; // Use case dependency
  final GetAnalytics getAnalytics; // Use case dependency

  // Constructor
  HistoryBloc({
    required this.getHistoricalVitals, // Use case injection
    required this.getAnalytics, // Use case injection
  }) : super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory); // Event handler for loading history
    on<LoadAnalyticsEvent>(_onLoadAnalytics); // Event handler for loading analytics
    on<RefreshHistoryEvent>(_onRefreshHistory); // Event handler for refreshing history
  }

  // Handler for loading historical device vitals
  Future<void> _onLoadHistory(
      LoadHistoryEvent event,
      Emitter<HistoryState> emit,
      ) async {
    // Prevent duplicate loading
    emit(const HistoryLoading());

    // Get historical vitals using the use case
    final result = await getHistoricalVitals();

    // Handle the result and emit appropriate states
    result.fold(
          (failure) => emit(HistoryError(_mapFailureToMessage(failure))),
          (history) => emit(HistoryLoaded(history, state.analytics)),
    );
  }

  // Handler for loading analytics data
  Future<void> _onLoadAnalytics(
      LoadAnalyticsEvent event,
      Emitter<HistoryState> emit,
      ) async {
    if (state.isLoadingAnalytics) return;

    // Emit loading state for analytics
    emit(state.copyWith(isLoadingAnalytics: true));

    // Get analytics using the use case
    final result = await getAnalytics();

    // Handle the result and emit appropriate states
    result.fold(
          (failure) => emit(state.copyWith(
        error: _mapFailureToMessage(failure),
        isLoadingAnalytics: false,
      )),
          (analytics) => emit(state.copyWith(
        analytics: analytics,
        isLoadingAnalytics: false,
      )),
    );
  }

  // Handler for refreshing both historical vitals and analytics
  Future<void> _onRefreshHistory(
      RefreshHistoryEvent event,
      Emitter<HistoryState> emit,
      ) async {
    if (state.isLoading) return;
    
    // Emit loading state
    emit(state.copyWith(isLoading: true));

    // Get both historical vitals and analytics using the use cases
    final historyResult = await getHistoricalVitals();
    final analyticsResult = await getAnalytics(); // Parallel fetch

    // Handle both results and emit appropriate states
    historyResult.fold(
          (failure) => emit(state.copyWith(
        error: _mapFailureToMessage(failure),
        isLoading: false,
      )),
          (history) {
        // Handle analytics result within the success case of history
        analyticsResult.fold(
              (failure) => emit(state.copyWith(
            history: history,
            error: _mapFailureToMessage(failure),
            isLoading: false,
          )),
          // On successful analytics fetch
              (analytics) => emit(state.copyWith(
            history: history,
            analytics: analytics,
            isLoading: false,
          )),
        );
      },
    );
  }

  // Map failure types to user-friendly error messages
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
}
