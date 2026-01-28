import 'package:bloc/bloc.dart';
import 'package:device_vital_monitor/core/failures.dart';
import 'package:device_vital_monitor/domain/usecases/get_historical_vitals.dart';
import 'package:device_vital_monitor/domain/usecases/get_analytics.dart';
import './history_event.dart';
import './history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoricalVitals getHistoricalVitals;
  final GetAnalytics getAnalytics;

  HistoryBloc({
    required this.getHistoricalVitals,
    required this.getAnalytics,
  }) : super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<RefreshHistoryEvent>(_onRefreshHistory);
  }

  Future<void> _onLoadHistory(
      LoadHistoryEvent event,
      Emitter<HistoryState> emit,
      ) async {
    emit(const HistoryLoading());

    final result = await getHistoricalVitals();

    result.fold(
          (failure) => emit(HistoryError(_mapFailureToMessage(failure))),
          (history) => emit(HistoryLoaded(history, state.analytics)),
    );
  }

  Future<void> _onLoadAnalytics(
      LoadAnalyticsEvent event,
      Emitter<HistoryState> emit,
      ) async {
    if (state.isLoadingAnalytics) return;

    emit(state.copyWith(isLoadingAnalytics: true));

    final result = await getAnalytics();

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

  Future<void> _onRefreshHistory(
      RefreshHistoryEvent event,
      Emitter<HistoryState> emit,
      ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    final historyResult = await getHistoricalVitals();
    final analyticsResult = await getAnalytics();

    historyResult.fold(
          (failure) => emit(state.copyWith(
        error: _mapFailureToMessage(failure),
        isLoading: false,
      )),
          (history) {
        analyticsResult.fold(
              (failure) => emit(state.copyWith(
            history: history,
            error: _mapFailureToMessage(failure),
            isLoading: false,
          )),
              (analytics) => emit(state.copyWith(
            history: history,
            analytics: analytics,
            isLoading: false,
          )),
        );
      },
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
}
