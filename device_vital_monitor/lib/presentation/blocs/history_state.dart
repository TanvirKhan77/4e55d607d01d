import 'package:equatable/equatable.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';

class HistoryState extends Equatable {
  final List<DeviceVital> history;
  final Analytics? analytics;
  final bool isLoading;
  final bool isLoadingAnalytics;
  final String? error;

  const HistoryState({
    this.history = const [],
    this.analytics,
    this.isLoading = false,
    this.isLoadingAnalytics = false,
    this.error,
  });

  HistoryState copyWith({
    List<DeviceVital>? history,
    Analytics? analytics,
    bool? isLoading,
    bool? isLoadingAnalytics,
    String? error,
  }) {
    return HistoryState(
      history: history ?? this.history,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    history,
    analytics,
    isLoading,
    isLoadingAnalytics,
    error,
  ];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial() : super();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading() : super(isLoading: true);
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(List<DeviceVital> history, Analytics? analytics)
      : super(history: history, analytics: analytics);
}

class HistoryError extends HistoryState {
  const HistoryError(String error) : super(error: error);
}

class AnalyticsLoading extends HistoryState {
  const AnalyticsLoading(List<DeviceVital> history)
      : super(history: history, isLoadingAnalytics: true);
}

class AnalyticsLoaded extends HistoryState {
  const AnalyticsLoaded(List<DeviceVital> history, Analytics analytics)
      : super(history: history, analytics: analytics);
}

class AnalyticsError extends HistoryState {
  const AnalyticsError(List<DeviceVital> history, String error)
      : super(history: history, error: error);
}
