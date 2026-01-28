// App Exceptions
class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class TimeoutException extends NetworkException {
  TimeoutException(super.message);
}

// Platform Exceptions - Rename to avoid conflict
class DevicePlatformException extends AppException {
  DevicePlatformException(super.message, {super.code});
}

// Data Exceptions
class DataParsingException extends AppException {
  DataParsingException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

// Cache Exceptions
class CacheException extends AppException {
  CacheException(super.message);
}

// API Exceptions
class ApiException extends AppException {
  final int statusCode;

  ApiException(super.message, this.statusCode) : super(code: statusCode);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}
