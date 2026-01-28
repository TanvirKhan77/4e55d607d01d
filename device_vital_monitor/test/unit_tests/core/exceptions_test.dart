import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor/core/exceptions.dart';

void main() {
  group('Exception Classes Tests', () {
    group('AppException', () {
      test('should create AppException with message', () {
        final exception = AppException('Something went wrong');

        expect(exception.message, 'Something went wrong');
        expect(exception.code, null);
      });

      test('should create AppException with message and code', () {
        final exception = AppException('Error occurred', code: 500);

        expect(exception.message, 'Error occurred');
        expect(exception.code, 500);
      });

      test('should implement Exception interface', () {
        final exception = AppException('Test error');

        expect(exception, isA<Exception>());
      });

      test('should have correct toString representation', () {
        final exception = AppException('Connection failed', code: 408);
        final toString = exception.toString();

        expect(toString, contains('AppException'));
        expect(toString, contains('Connection failed'));
        expect(toString, contains('408'));
      });

      test('toString without code should not show code', () {
        final exception = AppException('Simple error');
        final toString = exception.toString();

        expect(toString, contains('AppException'));
        expect(toString, contains('Simple error'));
        expect(toString, isNot(contains('Code:')));
      });
    });

    group('NetworkException', () {
      test('should extend AppException', () {
        final exception = NetworkException('Network error');

        expect(exception, isA<AppException>());
        expect(exception.message, 'Network error');
      });

      test('should create with code', () {
        final exception = NetworkException('Timeout', code: 408);

        expect(exception.message, 'Timeout');
        expect(exception.code, 408);
      });
    });

    group('TimeoutException', () {
      test('should extend NetworkException', () {
        final exception = TimeoutException('Request timeout');

        expect(exception, isA<NetworkException>());
        expect(exception, isA<AppException>());
        expect(exception.message, 'Request timeout');
      });

      test('should not have code parameter', () {
        final exception = TimeoutException('Connection timeout');

        expect(exception.code, null);
      });
    });

    group('DevicePlatformException', () {
      test('should extend AppException', () {
        final exception = DevicePlatformException('Platform not supported');

        expect(exception, isA<AppException>());
        expect(exception.message, 'Platform not supported');
      });

      test('should support code parameter', () {
        final exception = DevicePlatformException('Permission denied', code: 403);

        expect(exception.code, 403);
      });
    });

    group('DataParsingException', () {
      test('should extend AppException', () {
        final exception = DataParsingException('Invalid JSON');

        expect(exception, isA<AppException>());
        expect(exception.message, 'Invalid JSON');
      });

      test('should not have code parameter', () {
        final exception = DataParsingException('Parse error');

        expect(exception.code, null);
      });
    });

    group('ValidationException', () {
      test('should extend AppException', () {
        final exception = ValidationException('Invalid email format');

        expect(exception, isA<AppException>());
        expect(exception.message, 'Invalid email format');
      });

      test('should have message about validation', () {
        final exception = ValidationException('Device ID is required');

        expect(exception.message, contains('Device ID'));
      });
    });

    group('CacheException', () {
      test('should extend AppException', () {
        final exception = CacheException('Cache read failed');

        expect(exception, isA<AppException>());
        expect(exception.message, 'Cache read failed');
      });

      test('should handle different cache errors', () {
        final readError = CacheException('Failed to read from cache');
        final writeError = CacheException('Failed to write to cache');

        expect(readError.message, 'Failed to read from cache');
        expect(writeError.message, 'Failed to write to cache');
      });
    });

    group('ApiException', () {
      test('should extend AppException', () {
        final exception = ApiException('Server error', 500);

        expect(exception, isA<AppException>());
        expect(exception.message, 'Server error');
        expect(exception.statusCode, 500);
      });

      test('should require statusCode', () {
        final exception = ApiException('Not found', 404);

        expect(exception.statusCode, 404);
        expect(exception.code, 404);
      });

      test('should have correct toString with status code', () {
        final exception = ApiException('Unauthorized', 401);
        final toString = exception.toString();

        expect(toString, contains('401'));
        expect(toString, contains('Unauthorized'));
      });
    });

    group('NotFoundException', () {
      test('should extend ApiException', () {
        final exception = NotFoundException('Resource not found');

        expect(exception, isA<ApiException>());
        expect(exception.statusCode, 404);
        expect(exception.code, 404);
      });

      test('should always have 404 status code', () {
        final exception = NotFoundException('User not found');

        expect(exception.statusCode, 404);
      });
    });

    group('Exception Hierarchy', () {
      test('TimeoutException should be catchable as NetworkException', () {
        final exception = TimeoutException('Timeout');

        expect(exception, isA<NetworkException>());
      });

      test('NetworkException should be catchable as AppException', () {
        final exception = NetworkException('Network error');

        expect(exception, isA<AppException>());
      });

      test('NotFoundException should be catchable as ApiException', () {
        final exception = NotFoundException('Not found');

        expect(exception, isA<ApiException>());
      });

      test('ApiException should be catchable as AppException', () {
        final exception = ApiException('Error', 500);

        expect(exception, isA<AppException>());
      });
    });

    group('toString Representation', () {
      test('AppException toString format', () {
        final exception = AppException('Test message', code: 123);
        final toString = exception.toString();

        expect(toString, matches(RegExp(r'AppException:.*Test message.*123')));
      });

      test('NetworkException toString format', () {
        final exception = NetworkException('Connection failed', code: 408);
        final toString = exception.toString();

        expect(toString, contains('Connection failed'));
        expect(toString, contains('408'));
      });

      test('ApiException includes statusCode', () {
        final exception = ApiException('Server error', 500);
        final toString = exception.toString();

        expect(toString, contains('500'));
      });
    });

    group('Exception Messages', () {
      test('should preserve message exactly', () {
        const message = 'Device vital data is invalid';
        final exception = ValidationException(message);

        expect(exception.message, message);
      });

      test('should handle empty messages', () {
        final exception = AppException('');

        expect(exception.message, '');
      });

      test('should handle special characters', () {
        const message = 'Error: @#\$%^&*(){}[]|\\:";\'<>?,.';
        final exception = AppException(message);

        expect(exception.message, message);
      });

      test('should handle very long messages', () {
        final longMessage = 'Error: ${'x' * 1000}';
        final exception = AppException(longMessage);

        expect(exception.message.length, 1007);
      });

      test('should handle multiline messages', () {
        const message = '''
        Error occurred:
        - Invalid device ID
        - Missing timestamp
        ''';
        final exception = AppException(message);

        expect(exception.message, contains('Invalid device ID'));
      });
    });

    group('Code Values', () {
      test('should handle null code', () {
        final exception = AppException('Error', code: null);

        expect(exception.code, null);
      });

      test('should handle zero code', () {
        final exception = AppException('Error', code: 0);

        expect(exception.code, 0);
      });

      test('should handle standard HTTP status codes', () {
        final codes = [200, 201, 400, 401, 403, 404, 500, 502, 503];

        for (final code in codes) {
          final exception = ApiException('Error', code);
          expect(exception.code, code);
          expect(exception.statusCode, code);
        }
      });

      test('should handle negative codes', () {
        final exception = AppException('Error', code: -1);

        expect(exception.code, -1);
      });

      test('should handle large codes', () {
        final exception = AppException('Error', code: 999999);

        expect(exception.code, 999999);
      });
    });

    group('Edge Cases', () {
      test('multiple exceptions should be independent', () {
        final exception1 = AppException('Error 1', code: 100);
        final exception2 = AppException('Error 2', code: 200);

        expect(exception1.message, 'Error 1');
        expect(exception1.code, 100);
        expect(exception2.message, 'Error 2');
        expect(exception2.code, 200);
      });

      test('should handle throwing and catching exceptions', () {
        expect(
          () => throw AppException('Test error'),
          throwsA(isA<AppException>()),
        );
      });

      test('should handle throwing NetworkException as AppException', () {
        expect(
          () => throw NetworkException('Network error'),
          throwsA(isA<AppException>()),
        );
      });

      test('should handle throwing NotFoundException', () {
        expect(
          () => throw NotFoundException('Not found'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('Different Exception Types', () {
      test('should distinguish between exception types', () {
        final appException = AppException('Error');
        final networkException = NetworkException('Error');
        final validationException = ValidationException('Error');

        expect(appException.runtimeType, AppException);
        expect(networkException.runtimeType, NetworkException);
        expect(validationException.runtimeType, ValidationException);
      });
    });
  });
}
