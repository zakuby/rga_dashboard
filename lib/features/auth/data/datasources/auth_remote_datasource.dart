import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network.dart';
import '../models/user_model.dart';

/// Remote data source for authentication.
/// Simulates API calls using JSON asset files.
abstract class AuthRemoteDataSource {
  /// Simulates a login request.
  /// Returns [UserModel] on success.
  /// Throws [AuthenticationException] for invalid credentials.
  Future<UserModel> login({required String email, required String password});
}

/// Implementation using JSON asset files to simulate API responses.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final JsonAssetLoader _jsonLoader;

  static const String _loginSuccessPath = 'assets/mock/auth_login_success.json';
  static const String _loginErrorPath = 'assets/mock/auth_login_error.json';

  // Simulated valid credentials
  static const _validEmail = 'test@example.com';
  static const _validPassword = 'password123';

  AuthRemoteDataSourceImpl(this._jsonLoader);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Simulate timeout for specific email
    if (email.toLowerCase().contains('timeout')) {
      await Future<void>.delayed(const Duration(milliseconds: 5000));
      throw const TimeoutException('Connection timed out. Please try again.');
    }

    // Load appropriate mock response based on credentials
    final isValidCredentials =
        email.toLowerCase() == _validEmail && password == _validPassword;

    final jsonPath = isValidCredentials ? _loginSuccessPath : _loginErrorPath;
    final response = await _jsonLoader.load(jsonPath);

    if (!response.success || response.data == null) {
      throw AuthenticationException(
        response.error?.message ?? 'Invalid email or password.',
      );
    }

    final userJson = response.data!['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }
}
