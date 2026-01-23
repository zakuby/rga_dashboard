/// Base exception for all custom exceptions in the app.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when authentication fails.
class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Authentication failed']);
}

/// Thrown when a network request times out.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Thrown when there is no network connection.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No network connection']);
}

/// Thrown when cached data is not found.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache data not found']);
}

/// Thrown when the server returns an error.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException([super.message = 'Server error', this.statusCode]);
}
