import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';

void main() {
  group('AuthenticationException', () {
    test('should have default message', () {
      const exception = AuthenticationException();

      expect(exception.message, 'Authentication failed');
      expect(exception.toString(), 'Authentication failed');
    });

    test('should accept custom message', () {
      const exception = AuthenticationException('Invalid credentials');

      expect(exception.message, 'Invalid credentials');
      expect(exception.toString(), 'Invalid credentials');
    });

    test('should be an AppException', () {
      const exception = AuthenticationException();

      expect(exception, isA<AppException>());
    });

    test('should implement Exception', () {
      const exception = AuthenticationException();

      expect(exception, isA<Exception>());
    });
  });

  group('TimeoutException', () {
    test('should have default message', () {
      const exception = TimeoutException();

      expect(exception.message, 'Request timed out');
      expect(exception.toString(), 'Request timed out');
    });

    test('should accept custom message', () {
      const exception = TimeoutException('Connection timed out after 30s');

      expect(exception.message, 'Connection timed out after 30s');
    });

    test('should be an AppException', () {
      const exception = TimeoutException();

      expect(exception, isA<AppException>());
    });
  });

  group('NetworkException', () {
    test('should have default message', () {
      const exception = NetworkException();

      expect(exception.message, 'No network connection');
      expect(exception.toString(), 'No network connection');
    });

    test('should accept custom message', () {
      const exception = NetworkException('Unable to reach server');

      expect(exception.message, 'Unable to reach server');
    });

    test('should be an AppException', () {
      const exception = NetworkException();

      expect(exception, isA<AppException>());
    });
  });

  group('CacheException', () {
    test('should have default message', () {
      const exception = CacheException();

      expect(exception.message, 'Cache data not found');
      expect(exception.toString(), 'Cache data not found');
    });

    test('should accept custom message', () {
      const exception = CacheException('User data not cached');

      expect(exception.message, 'User data not cached');
    });

    test('should be an AppException', () {
      const exception = CacheException();

      expect(exception, isA<AppException>());
    });
  });

  group('ServerException', () {
    test('should have default message and null status code', () {
      const exception = ServerException();

      expect(exception.message, 'Server error');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'Server error');
    });

    test('should accept custom message', () {
      const exception = ServerException('Internal server error');

      expect(exception.message, 'Internal server error');
      expect(exception.statusCode, isNull);
    });

    test('should accept custom message and status code', () {
      const exception = ServerException('Not found', 404);

      expect(exception.message, 'Not found');
      expect(exception.statusCode, 404);
    });

    test('should be an AppException', () {
      const exception = ServerException();

      expect(exception, isA<AppException>());
    });

    test('should handle common HTTP status codes', () {
      const badRequest = ServerException('Bad request', 400);
      const unauthorized = ServerException('Unauthorized', 401);
      const forbidden = ServerException('Forbidden', 403);
      const notFound = ServerException('Not found', 404);
      const internalError = ServerException('Internal server error', 500);

      expect(badRequest.statusCode, 400);
      expect(unauthorized.statusCode, 401);
      expect(forbidden.statusCode, 403);
      expect(notFound.statusCode, 404);
      expect(internalError.statusCode, 500);
    });
  });
}
