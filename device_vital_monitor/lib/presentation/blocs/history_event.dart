import 'package:equatable/equatable.dart';

// Abstract event class for history-related events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  // Equatable props
  @override
  List<Object> get props => [];
}

// Event class: Load historical device vitals
class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

// Event class: Load analytics data
class LoadAnalyticsEvent extends HistoryEvent {
  const LoadAnalyticsEvent();
}

// Event class: Refresh both historical vitals and analytics
class RefreshHistoryEvent extends HistoryEvent {
  const RefreshHistoryEvent();
}
