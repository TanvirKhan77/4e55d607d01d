# Device Vital Monitor System

A comprehensive device monitoring system consisting of a Flutter mobile app and Node.js backend for collecting, storing, and analyzing device vital statistics.

## 🚀 Overview

This project provides end-to-end device vital monitoring with:
- **Mobile App**: Flutter application for real-time monitoring and background logging
- **Backend API**: Node.js/Express server with SQLite database
- **Background Tasks**: Native Android WorkManager for reliable background logging
- **Analytics**: Data visualization and insights

## 📁 Project Structure

```
├── backend/                    # Node.js/Express API server
│   ├── src/
│   ├── tests/
│   ├── package.json
│   └── README.md
├── device_vital_monitor/       # Flutter mobile application
│   ├── lib/
│   ├── android/
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md
└── README.md                   # This file
```

## 🛠️ Quick Start

### Prerequisites

- **Node.js** (v16+)
- **Flutter** SDK (^3.10.7)
- **Android Studio** (for Android development)
- **npm** or **yarn**

### 1. Backend Setup

```bash
cd backend
npm install
npm run dev
```

The backend will start on `http://localhost:3000`

### 2. Mobile App Setup

```bash
cd device_vital_monitor
flutter pub get
flutter pub run build_runner build  # Generate Hive adapters
flutter run
```

## 🔧 Development Setup

### Backend Development

See [backend/README.md](backend/README.md) for detailed backend setup instructions.

### Mobile App Development

See [device_vital_monitor/README.md](device_vital_monitor/README.md) for detailed Flutter app setup.

### Code Generation (Flutter)

The Flutter app uses Hive for local storage. Generate the required adapters:

```bash
cd device_vital_monitor
flutter pub run build_runner build
```

This generates `hive_vital_model.g.dart` from the Hive model definitions.

## 🧪 Testing

### Backend Tests

```bash
cd backend
npm test
```

### Flutter Tests

```bash
cd device_vital_monitor
flutter test
```

### Integration Tests

```bash
cd device_vital_monitor
flutter test integration_test/
```

## 📱 Features

### Mobile App
- ✅ Real-time vital monitoring (thermal, battery, memory)
- ✅ Background auto-logging every 15 minutes
- ✅ Native Android WorkManager integration
- ✅ Offline data storage with Hive
- ✅ Clean Architecture with BLoC pattern
- ✅ Material Design 3 UI
- ✅ Settings management
- ✅ Analytics dashboard

### Backend API
- ✅ RESTful API for vital logging
- ✅ SQLite database persistence
- ✅ Input validation and error handling
- ✅ Analytics endpoints
- ✅ Health check endpoint
- ✅ Comprehensive test coverage

## 🔄 API Endpoints

- `GET /health` - Health check
- `POST /api/vitals` - Log device vitals
- `GET /api/vitals` - Get historical data
- `GET /api/vitals/analytics` - Get analytics

## 🏗️ Architecture

### Backend
- **Framework**: Express.js
- **Database**: SQLite3
- **Testing**: Jest + Supertest
- **Validation**: Custom middleware

### Mobile App
- **Framework**: Flutter
- **State Management**: BLoC
- **Local Storage**: Hive
- **Background Tasks**: Android WorkManager (native)
- **Architecture**: Clean Architecture

## 🚀 Deployment

### Backend Deployment

```bash
cd backend
npm start
```

Set `PORT` environment variable for custom port.

### Mobile App Build

```bash
cd device_vital_monitor

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 🔧 Configuration

### Backend URL

Update the backend URL in the Flutter app:

**File**: `device_vital_monitor/lib/core/constants.dart`

```dart
class AppConstants {
  static const String baseUrl = 'http://your-backend-url:3000';
}
```

For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

## 🐛 Troubleshooting

### Common Issues

1. **Flutter pub get fails**
   ```bash
   cd device_vital_monitor
   flutter clean
   rm pubspec.lock
   flutter pub get
   ```

2. **Hive generation fails**
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build
   ```

3. **Background tasks not working**
   - Check AndroidManifest.xml permissions
   - Verify WorkManager dependency
   - Check battery optimization settings

4. **Network connection issues**
   - Verify backend is running
   - Check firewall settings
   - Test with different IP addresses

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

*(Add license information)*

## 📞 Support

For issues and questions:
- Check the individual README files
- Review troubleshooting section
- Create an issue in the repository

---

**Note**: This project demonstrates modern mobile and backend development practices with a focus on reliability, testability, and maintainability.