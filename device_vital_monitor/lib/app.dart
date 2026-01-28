import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import 'core/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/connectivity_service.dart';
import 'core/sync_service.dart';

// Data layer
import 'data/datasources/device_data_source.dart';
import 'data/datasources/local_data_source.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/datasources/hive_data_source.dart';
import 'data/repositories/device_repository_impl.dart';
import 'data/repositories/analytics_repository_impl.dart';

// Domain layer
import 'domain/usecases/get_device_vitals.dart';
import 'domain/usecases/log_device_vitals.dart';
import 'domain/usecases/get_historical_vitals.dart';
import 'domain/usecases/get_analytics.dart';

// Presentation layer
import 'presentation/blocs/dashboard_bloc.dart';
import 'presentation/blocs/history_bloc.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/history_screen.dart';

class DeviceVitalMonitorApp extends StatefulWidget {
  const DeviceVitalMonitorApp({super.key});

  @override
  State<DeviceVitalMonitorApp> createState() => _DeviceVitalMonitorAppState();
}

class _DeviceVitalMonitorAppState extends State<DeviceVitalMonitorApp> {
  late Future<SharedPreferences> _sharedPreferencesFuture;
  late Future<void> _hiveInitializationFuture;

  @override
  void initState() {
    super.initState();
    _sharedPreferencesFuture = SharedPreferences.getInstance();
    _hiveInitializationFuture = _initializeHive();
  }

  Future<void> _initializeHive() async {
    final hiveDataSource = HiveDataSourceImpl();
    await hiveDataSource.initializeHive();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _hiveInitializationFuture,
      builder: (context, hiveSnapshot) {
        if (hiveSnapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (hiveSnapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing offline storage: ${hiveSnapshot.error}'),
              ),
            ),
          );
        }

        return FutureBuilder<SharedPreferences>(
          future: _sharedPreferencesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ),
              );
            }

            final sharedPreferences = snapshot.data!;

            return ChangeNotifierProvider(
              create: (_) => ThemeProvider(),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<DeviceDataSource>(
                        create: (_) => DeviceDataSourceImpl(),
                      ),
                      RepositoryProvider<SharedPreferences>.value(
                        value: sharedPreferences,
                      ),
                      RepositoryProvider<LocalDataSource>(
                        create: (context) => LocalDataSourceImpl(
                          context.read<SharedPreferences>(),
                        ),
                      ),
                      RepositoryProvider<RemoteDataSource>(
                        create: (_) => RemoteDataSourceImpl(client: http.Client()),
                      ),
                      RepositoryProvider<HiveDataSource>(
                        create: (_) => HiveDataSourceImpl(),
                      ),
                      RepositoryProvider<ConnectivityService>(
                        create: (_) => ConnectivityServiceImpl(Connectivity()),
                      ),
                      RepositoryProvider<DeviceRepositoryImpl>(
                        create: (context) => DeviceRepositoryImpl(
                          deviceDataSource: context.read<DeviceDataSource>(),
                          remoteDataSource: context.read<RemoteDataSource>(),
                          localDataSource: context.read<LocalDataSource>(),
                          hiveDataSource: context.read<HiveDataSource>(),
                          connectivityService: context.read<ConnectivityService>(),
                        ),
                      ),
                      RepositoryProvider<SyncService>(
                        create: (context) {
                          final syncService = SyncService(
                            remoteDataSource: context.read<RemoteDataSource>(),
                            hiveDataSource: context.read<HiveDataSource>(),
                            connectivityService: context.read<ConnectivityService>(),
                          );
                          syncService.initialize();
                          return syncService;
                        },
                      ),
                      RepositoryProvider<AnalyticsRepositoryImpl>(
                        create: (context) => AnalyticsRepositoryImpl(
                          remoteDataSource: context.read<RemoteDataSource>(),
                          deviceRepository: context.read<DeviceRepositoryImpl>(),
                        ),
                      ),
                    ],
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider<DashboardBloc>(
                          create: (context) => DashboardBloc(
                            getDeviceVitals: GetDeviceVitals(
                              context.read<DeviceRepositoryImpl>(),
                            ),
                            logDeviceVitals: LogDeviceVitals(
                              context.read<DeviceRepositoryImpl>(),
                            ),
                          ),
                        ),
                        BlocProvider<HistoryBloc>(
                          create: (context) => HistoryBloc(
                            getHistoricalVitals: GetHistoricalVitals(
                              context.read<AnalyticsRepositoryImpl>(),
                            ),
                            getAnalytics: GetAnalytics(
                              context.read<AnalyticsRepositoryImpl>(),
                            ),
                          ),
                        ),
                      ],
                      child: MaterialApp(
                        title: 'Device Vital Monitor',
                        theme: AppThemes.lightTheme,
                        darkTheme: AppThemes.darkTheme,
                        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                        home: const MainScreen(),
                        debugShowCheckedModeBanner: false,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
  ];

  @override
  void dispose() {
    // Dispose SyncService when app closes
    try {
      final syncService = context.read<SyncService>();
      syncService.dispose();
    } catch (e) {
      debugPrint('Error disposing SyncService: $e');
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.device_hub_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Device Vital Monitor',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: context.read<ConnectivityService>().connectionStatusStream,
            initialData: true,
            builder: (context, snapshot) {
              final isOnline = snapshot.data ?? true;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.indigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: themeProvider.isDarkMode ? Colors.amber : Colors.indigo,
                  ),
                  tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 0
                        ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    )
                        : null,
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: _selectedIndex == 0
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 1
                        ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    )
                        : null,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: _selectedIndex == 1
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                label: 'History',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}