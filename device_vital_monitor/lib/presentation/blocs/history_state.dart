import 'package:equatable/equatable.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';
import 'package:device_vital_monitor/domain/entities/analytics.dart';

// State class: Represents various states of the history feature
class HistoryState extends Equatable {
  final List<DeviceVital> history;
  final Analytics? analytics;
  final bool isLoading;
  final bool isLoadingAnalytics;
  final String? error;

  // Constructor
  const HistoryState({
    this.history = const [],
    this.analytics,
    this.isLoading = false,
    this.isLoadingAnalytics = false,
    this.error,
  });

  // CopyWith method for immutability
  HistoryState copyWith({
    List<DeviceVital>? history,
    Analytics? analytics,
    bool? isLoading,
    bool? isLoadingAnalytics,
    String? error,
  }) {
    // Return a new instance with updated values
    return HistoryState(
      history: history ?? this.history,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      error: error ?? this.error,
    );
  }

  // Equatable props
  @override
  List<Object?> get props => [
    history,
    analytics,
    isLoading,
    isLoadingAnalytics,
    error,
  ];
}

// Specific state classes for different scenarios
class HistoryInitial extends HistoryState {
  const HistoryInitial() : super();
}

// State when history is being loaded
class HistoryLoading extends HistoryState {
  const HistoryLoading() : super(isLoading: true);
}

// State when history is successfully loaded
class HistoryLoaded extends HistoryState {
  const HistoryLoaded(List<DeviceVital> history, Analytics? analytics)
      : super(history: history, analytics: analytics);
}

// State when there is an error loading history
class HistoryError extends HistoryState {
  const HistoryError(String error) : super(error: error);
}

// State when analytics is being loaded
class AnalyticsLoading extends HistoryState {
  const AnalyticsLoading(List<DeviceVital> history)
      : super(history: history, isLoadingAnalytics: true);
}

// State when analytics is successfully loaded
class AnalyticsLoaded extends HistoryState {
  const AnalyticsLoaded(List<DeviceVital> history, Analytics analytics)
      : super(history: history, analytics: analytics);
}

// State when there is an error loading analytics
class AnalyticsError extends HistoryState {
  const AnalyticsError(List<DeviceVital> history, String error)
      : super(history: history, error: error);
}
