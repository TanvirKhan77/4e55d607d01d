import 'package:equatable/equatable.dart';

// Abstract event class for dashboard-related events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  // Equatable props
  @override
  List<Object> get props => [];
}

// Event class: Load device vitals
class LoadVitalsEvent extends DashboardEvent {
  const LoadVitalsEvent();
}

// Event class: Log device vitals
class LogVitalsEvent extends DashboardEvent {
  const LogVitalsEvent();
}

// Event class: Refresh device vitals
class RefreshVitalsEvent extends DashboardEvent {
  const RefreshVitalsEvent();
}
