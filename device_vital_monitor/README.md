# Device Vital Monitor

A Flutter application for monitoring and logging device vital statistics with background auto-logging capabilities.

## Features

- Real-time device vital monitoring (thermal status, battery level, memory usage)
- Background auto-logging every 15 minutes using native Android WorkManager
- Local data storage with Hive
- Clean architecture with BLoC pattern
- Material Design 3 UI
- Offline support with sync capabilities
- Analytics dashboard
- Settings management

## Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC
- **Local Storage**: Hive
- **HTTP Client**: http package
- **Architecture**: Clean Architecture
- **Background Tasks**: Android WorkManager (native)
- **Testing**: Flutter test, Mocktail

## Screenshots

*(Add screenshots here)*

## Installation

### Prerequisites

- Flutter SDK (^3.10.7)
- Dart SDK
- Android Studio (for Android development)
- Xcode (for iOS development, optional)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd device_vital_monitor
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## Code Generation

### Hive Model Generation

The app uses Hive for local data storage. To generate the type adapters:

```bash
# One-time generation
flutter pub run build_runner build

# Watch mode (auto-generate on changes)
flutter pub run build_runner watch
```

This will generate `hive_vital_model.g.dart` from `hive_vital_model.dart`.

## Testing

### Unit Tests

Run unit tests:
```bash
flutter test
```

### Integration Tests

Run integration tests:
```bash
flutter test integration_test/
```

### Test Coverage

Generate test coverage:
```bash
flutter test --coverage
```

Coverage reports will be available in `coverage/lcov-report/index.html`.

## Architecture

The app follows Clean Architecture principles:

```
lib/
├── core/              # Core utilities and business logic
├── data/              # Data layer (repositories, models, datasources)
├── domain/            # Domain layer (entities, usecases, repositories)
├── presentation/      # Presentation layer (BLoC, screens, widgets)
└── main.dart          # App entry point
```

### Key Components

- **BLoC**: State management for UI
- **Repository Pattern**: Data abstraction
- **Dependency Injection**: Manual DI for testability
- **Method Channels**: Communication with native Android code

## Background Tasks

The app uses native Android WorkManager for background vital logging:

- **Scheduling**: Configurable intervals (default: 15 minutes)
- **Constraints**: Requires network connectivity
- **Persistence**: Survives app restarts and device reboots
- **Battery Optimization**: Respects Android Doze mode

### Configuration

Background logging can be configured in the app settings:
- Enable/disable auto-logging
- Set logging interval (5, 10, 15, 30, 60 minutes)
- View last log timestamp

## API Integration

The app communicates with a backend API for data synchronization:

- **Base URL**: Configurable in `lib/core/constants.dart`
- **Endpoints**:
  - `POST /api/vitals` - Log vitals
  - `GET /api/vitals` - Get historical data
  - `GET /api/vitals/analytics` - Get analytics

## Permissions

The app requires the following permissions:

### Android
- `BATTERY_STATS` - Battery level monitoring
- `INTERNET` - API communication
- `WAKE_LOCK` - Background task execution
- `SCHEDULE_EXACT_ALARM` - Precise scheduling
- `RECEIVE_BOOT_COMPLETED` - Survive device reboots

### iOS
*(Add iOS permissions if applicable)*

## Building

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Configuration

### Backend URL

Update the backend URL in `lib/core/constants.dart`:

```dart
class AppConstants {
  static const String baseUrl = 'http://your-backend-url:3000';
  // ...
}
```

### Android Emulator

For Android emulator testing, use `10.0.2.2` as the backend host:

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

## Troubleshooting

### Common Issues

1. **Build fails after pub get**
   - Run `flutter clean`
   - Delete `pubspec.lock`
   - Run `flutter pub get` again

2. **Hive code generation fails**
   - Ensure `hive_vital_model.dart` has correct annotations
   - Run `flutter pub run build_runner clean` then rebuild

3. **Background tasks not working**
   - Check AndroidManifest.xml permissions
   - Verify WorkManager dependency in build.gradle.kts
   - Check device battery optimization settings

4. **Network requests failing**
   - Verify backend is running
   - Check network permissions
   - Test with different backend URL

### Debug Mode

Enable debug logging in `lib/core/background_task_manager.dart`:

```dart
debugPrint('Debug message');
```

## Development

### Adding New Features

1. Create use case in `domain/usecases/`
2. Implement repository in `data/repositories/`
3. Add BLoC in `presentation/blocs/`
4. Create UI in `presentation/screens/`
5. Add tests
6. Update this README

### Code Style

The project uses `flutter_lints` for code analysis. Run:

```bash
flutter analyze
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Ensure all tests pass
6. Submit a pull request

## License

*(Add license information)*