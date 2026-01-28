import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_vital_monitor/presentation/blocs/dashboard_bloc.dart';
import 'package:device_vital_monitor/presentation/blocs/dashboard_event.dart';
import 'package:device_vital_monitor/presentation/blocs/dashboard_state.dart';
import 'package:device_vital_monitor/core/constants.dart';
import 'package:device_vital_monitor/core/sync_service.dart';
import '../widgets/vital_card.dart';
import '../widgets/offline_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(const LoadVitalsEvent());
    });
  }

  Color _getThermalColor(int thermalValue) {
    switch (thermalValue) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getBatteryColor(double level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryColor(double usage) {
    if (usage < 70) return Colors.green;
    if (usage < 85) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const RefreshVitalsEvent());
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }

          if (state.success != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.success!),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          }
        },
        builder: (context, state) {
          final vitals = state.vitals;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
                  // Offline indicator
                  OfflineIndicator(
                    syncService: context.read<SyncService>(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vitals?.deviceId ?? 'Unknown Device',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Icon(
                                Icons.copy_all_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;
                    final crossAxisCount = isTablet ? 3 : 2;
                    final childAspectRatio = isTablet ? 1.1 : 1.2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: childAspectRatio,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        VitalCard(
                          title: 'Thermal',
                          value: '${vitals?.thermalValue ?? 0}',
                          subtitle: vitals?.thermalStatusLabel ?? 'Unknown',
                          icon: Icons.thermostat_rounded,
                          color: _getThermalColor(vitals?.thermalValue ?? 0),
                          elevation: 2,
                        ),
                        VitalCard(
                          title: 'Battery',
                          value: '${(vitals?.batteryLevel ?? 0.0).toStringAsFixed(1)}%',
                          subtitle: BatteryStatus.getLabel(vitals?.batteryLevel ?? 0.0),
                          icon: Icons.battery_full_rounded,
                          color: _getBatteryColor(vitals?.batteryLevel ?? 0.0),
                          elevation: 2,
                        ),
                        VitalCard(
                          title: 'Memory',
                          value: '${(vitals?.memoryUsage ?? 0.0).toStringAsFixed(1)}%',
                          subtitle: MemoryStatus.getLabel(vitals?.memoryUsage ?? 0.0),
                          icon: Icons.memory_rounded,
                          color: _getMemoryColor(vitals?.memoryUsage ?? 0.0),
                          elevation: 2,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: state.vitals == null || state.isLogging || state.isLoading
                      ? null
                      : () => context.read<DashboardBloc>().add(const LogVitalsEvent()),
                  icon: state.isLogging
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.save),
                  label: Text(state.isLogging ? 'Logging...' : 'Log Current Status'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 8),

                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<DashboardBloc>().add(const RefreshVitalsEvent()),
                  icon: state.isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh Vitals'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
