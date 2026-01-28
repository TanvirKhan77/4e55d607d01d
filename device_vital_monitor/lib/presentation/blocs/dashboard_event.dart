import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadVitalsEvent extends DashboardEvent {
  const LoadVitalsEvent();
}

class LogVitalsEvent extends DashboardEvent {
  const LogVitalsEvent();
}

class RefreshVitalsEvent extends DashboardEvent {
  const RefreshVitalsEvent();
}
