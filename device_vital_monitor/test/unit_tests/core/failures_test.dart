import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor/core/failures.dart';

void main() {
  group('Failure Classes Tests', () {
    group('NetworkFailure', () {
      test('should create NetworkFailure with message', () {
        const failure = NetworkFailure('Network connection failed');

        expect(failure.message, 'Network connection failed');
        expect(failure.code, null);
      });

      test('should create NetworkFailure with message and code', () {
        const failure = NetworkFailure('Network timeout', code: 408);

        expect(failure.message, 'Network timeout');
        expect(failure.code, 408);
      });

      test('should support equality comparison', () {
        const failure1 = NetworkFailure('Connection error');
        const failure2 = NetworkFailure('Connection error');

        expect(failure1, failure2);
      });

      test('should not be equal with different messages', () {
        const failure1 = NetworkFailure('Error 1');
        const failure2 = NetworkFailure('Error 2');

        expect(failure1, isNot(failure2));
      });

      test('should not be equal with different codes', () {
        const failure1 = NetworkFailure('Error', code: 401);
        const failure2 = NetworkFailure('Error', code: 403);

        expect(failure1, isNot(failure2));
      });

      test('should have correct toString representation', () {
        const failure = NetworkFailure('Connection failed', code: 500);
        final toString = failure.toString();

        expect(toString, contains('Failure'));
        expect(toString, contains('Connection failed'));
        expect(toString, contains('500'));
      });
    });

    group('ServerFailure', () {
      test('should create ServerFailure with message', () {
        const failure = ServerFailure('Server error');

        expect(failure.message, 'Server error');
        expect(failure.code, null);
      });

      test('should create ServerFailure with code', () {
        const failure = ServerFailure('Internal server error', code: 500);

        expect(failure.message, 'Internal server error');
        expect(failure.code, 500);
      });

      test('should support equality comparison', () {
        const failure1 = ServerFailure('Service unavailable', code: 503);
        const failure2 = ServerFailure('Service unavailable', code: 503);

        expect(failure1, failure2);
      });
    });

    group('CacheFailure', () {
      test('should create CacheFailure with message only', () {
        const failure = CacheFailure('Cache read failed');

        expect(failure.message, 'Cache read failed');
        expect(failure.code, null);
      });

      test('should support equality comparison', () {
        const failure1 = CacheFailure('Data not cached');
        const failure2 = CacheFailure('Data not cached');

        expect(failure1, failure2);
      });
    });

    group('PlatformFailure', () {
      test('should create PlatformFailure with message', () {
        const failure = PlatformFailure('Platform not supported');

        expect(failure.message, 'Platform not supported');
        expect(failure.code, null);
      });

      test('should create PlatformFailure with code', () {
        const failure = PlatformFailure('Permission denied', code: 403);

        expect(failure.message, 'Permission denied');
        expect(failure.code, 403);
      });
    });

    group('ValidationFailure', () {
      test('should create ValidationFailure with message', () {
        const failure = ValidationFailure('Invalid input format');

        expect(failure.message, 'Invalid input format');
        expect(failure.code, null);
      });

      test('should support equality comparison', () {
        const failure1 = ValidationFailure('Email invalid');
        const failure2 = ValidationFailure('Email invalid');

        expect(failure1, failure2);
      });
    });

    group('UnexpectedFailure', () {
      test('should create UnexpectedFailure with message', () {
        const failure = UnexpectedFailure('Something went wrong');

        expect(failure.message, 'Something went wrong');
        expect(failure.code, null);
      });

      test('should support equality comparison', () {
        const failure1 = UnexpectedFailure('Unexpected error occurred');
        const failure2 = UnexpectedFailure('Unexpected error occurred');

        expect(failure1, failure2);
      });
    });

    group('Props for Equatable', () {
      test('NetworkFailure should include message and code in props', () {
        const failure = NetworkFailure('Error', code: 500);
        final props = failure.props;

        expect(props.length, 2);
        expect(props[0], 'Error');
        expect(props[1], 500);
      });

      test('CacheFailure should include message in props', () {
        const failure = CacheFailure('Cache error');
        final props = failure.props;

        expect(props.length, 2);
        expect(props[0], 'Cache error');
        expect(props[1], null);
      });
    });

    group('Different Failure Types', () {
      test('NetworkFailure should not equal ServerFailure with same message', () {
        const networkFailure = NetworkFailure('Error message');
        const serverFailure = ServerFailure('Error message');

        expect(networkFailure, isNot(serverFailure));
      });

      test('should distinguish between all failure types', () {
        const networkFailure = NetworkFailure('Network error');
        const serverFailure = ServerFailure('Server error');
        const cacheFailure = CacheFailure('Cache error');
        const platformFailure = PlatformFailure('Platform error');
        const validationFailure = ValidationFailure('Validation error');
        const unexpectedFailure = UnexpectedFailure('Unexpected error');

        final failures = [
          networkFailure,
          serverFailure,
          cacheFailure,
          platformFailure,
          validationFailure,
          unexpectedFailure,
        ];

        for (int i = 0; i < failures.length; i++) {
          for (int j = i + 1; j < failures.length; j++) {
            expect(failures[i], isNot(failures[j]));
          }
        }
      });
    });

    group('toString Representation', () {
      test('NetworkFailure toString should contain type and message', () {
        const failure = NetworkFailure('Network timeout');
        expect(failure.toString(), contains('Failure'));
        expect(failure.toString(), contains('Network timeout'));
      });

      test('ServerFailure toString should include code if present', () {
        const failure = ServerFailure('Error', code: 503);
        expect(failure.toString(), contains('503'));
      });

      test('Failure without code should not include code in toString', () {
        const failure = CacheFailure('Cache miss');
        final toString = failure.toString();
        expect(toString, contains('Cache miss'));
        expect(toString, isNot(contains('Code:')));
      });
    });

    group('Edge Cases', () {
      test('should handle empty string messages', () {
        const failure = NetworkFailure('');

        expect(failure.message, '');
        expect(failure.toString(), contains('Failure'));
      });

      test('should handle very long messages', () {
        final longMessage = 'Error: ${'x' * 1000}';
        final failure = NetworkFailure(longMessage);

        expect(failure.message, longMessage);
        expect(failure.message.length, 1007);
      });

      test('should handle special characters in message', () {
        const failure = ServerFailure('Error: @#\$%^&*()');

        expect(failure.message, 'Error: @#\$%^&*()');
      });

      test('should handle null code as valid', () {
        const failure = NetworkFailure('Error', code: null);

        expect(failure.code, null);
      });

      test('should handle zero code', () {
        const failure = NetworkFailure('Error', code: 0);

        expect(failure.code, 0);
      });

      test('should handle negative code', () {
        const failure = NetworkFailure('Error', code: -1);

        expect(failure.code, -1);
      });

      test('should handle large code values', () {
        const failure = NetworkFailure('Error', code: 999999);

        expect(failure.code, 999999);
      });
    });
  });
}
