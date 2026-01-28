import 'package:equatable/equatable.dart';
import 'package:device_vital_monitor/domain/entities/device_vital.dart';

class DashboardState extends Equatable {
  final DeviceVital? vitals;
  final bool isLoading;
  final bool isLogging;
  final String? error;
  final String? success;

  const DashboardState({
    this.vitals,
    this.isLoading = false,
    this.isLogging = false,
    this.error,
    this.success,
  });

  DashboardState copyWith({
    DeviceVital? vitals,
    bool? isLoading,
    bool? isLogging,
    String? error,
    String? success,
  }) {
    return DashboardState(
      vitals: vitals ?? this.vitals,
      isLoading: isLoading ?? this.isLoading,
      isLogging: isLogging ?? this.isLogging,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [
    vitals,
    isLoading,
    isLogging,
    error,
    success,
  ];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super();
}

class VitalsLoading extends DashboardState {
  const VitalsLoading() : super(isLoading: true);
}

class VitalsLoaded extends DashboardState {
  const VitalsLoaded(DeviceVital vitals) : super(vitals: vitals);
}

class VitalsError extends DashboardState {
  const VitalsError(String error) : super(error: error);
}

class LoggingInProgress extends DashboardState {
  const LoggingInProgress(DeviceVital vitals) : super(vitals: vitals, isLogging: true);
}

class LoggingSuccess extends DashboardState {
  const LoggingSuccess(DeviceVital vitals, String message)
      : super(vitals: vitals, success: message);
}

class LoggingError extends DashboardState {
  const LoggingError(DeviceVital vitals, String error)
      : super(vitals: vitals, error: error);
}
