import 'package:equatable/equatable.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

// State class: Represents various states of the dashboard
class DashboardState extends Equatable {
  final DeviceVital? vitals;
  final bool isLoading;
  final bool isLogging;
  final String? error;
  final String? success;

  // Constructor
  const DashboardState({
    this.vitals,
    this.isLoading = false,
    this.isLogging = false,
    this.error,
    this.success,
  });

  // CopyWith method for immutability
  DashboardState copyWith({
    DeviceVital? vitals,
    bool? isLoading,
    bool? isLogging,
    String? error,
    String? success,
  }) {
    // Return a new instance with updated values
    return DashboardState(
      vitals: vitals ?? this.vitals,
      isLoading: isLoading ?? this.isLoading,
      isLogging: isLogging ?? this.isLogging,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  // Equatable props
  @override
  List<Object?> get props => [
    vitals,
    isLoading,
    isLogging,
    error,
    success,
  ];
}

// Specific state classes for different scenarios
class DashboardInitial extends DashboardState {
  const DashboardInitial() : super();
}

// State when vitals are being loaded
class VitalsLoading extends DashboardState {
  const VitalsLoading() : super(isLoading: true);
}

// State when vitals are successfully loaded
class VitalsLoaded extends DashboardState {
  const VitalsLoaded(DeviceVital vitals) : super(vitals: vitals);
}

// State when there is an error loading vitals
class VitalsError extends DashboardState {
  const VitalsError(String error) : super(error: error);
}

// State when vitals are being logged
class LoggingInProgress extends DashboardState {
  const LoggingInProgress(DeviceVital vitals) : super(vitals: vitals, isLogging: true);
}

// State when vitals are successfully logged
class LoggingSuccess extends DashboardState {
  const LoggingSuccess(DeviceVital vitals, String message)
      : super(vitals: vitals, success: message);
}

// State when there is an error logging vitals
class LoggingError extends DashboardState {
  const LoggingError(DeviceVital vitals, String error)
      : super(vitals: vitals, error: error);
}
