import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication (simulated).
abstract class AuthRemoteDataSource {
  /// Simulates a login request.
  /// Returns [UserModel] on success.
  /// Throws [AuthenticationException] for invalid credentials.
  /// Throws [TimeoutException] for timeouts.
  Future<UserModel> login({required String email, required String password});
}

/// Simulated implementation of [AuthRemoteDataSource].
/// In production, this would make actual API calls.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Simulated valid credentials
  static const _validEmail = 'test@example.com';
  static const _validPassword = 'password123';

  // Simulation delays (in milliseconds)
  static const _networkDelay = 1500;
  static const _timeoutThreshold = 5000;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: _networkDelay));

    // Simulate timeout for specific email
    if (email.toLowerCase().contains('timeout')) {
      await Future.delayed(const Duration(milliseconds: _timeoutThreshold));
      throw const TimeoutException('Connection timed out. Please try again.');
    }

    // Validate credentials
    if (email.toLowerCase() != _validEmail || password != _validPassword) {
      throw const AuthenticationException(
        'Invalid email or password. Please try again.',
      );
    }

    // Return simulated user
    return UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: _extractNameFromEmail(email),
      lastLoginAt: DateTime.now(),
    );
  }

  String _extractNameFromEmail(String email) {
    final localPart = email.split('@').first;
    return localPart
        .split(RegExp(r'[._-]'))
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
