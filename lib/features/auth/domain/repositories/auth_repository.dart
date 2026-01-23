import '../../../../core/result/result.dart';
import '../entities/user.dart';

/// Abstract repository defining authentication operations.
/// The concrete implementation is in the data layer.
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  /// Returns [User] on success or [Failure] on error.
  Future<Result<User>> login({required String email, required String password});

  /// Logs out the current user.
  /// Returns true on success.
  Future<Result<bool>> logout();

  /// Checks if there's an authenticated session.
  /// Returns [User] if session exists, null otherwise.
  Future<Result<User?>> getCurrentUser();

  /// Checks if the user session is valid.
  Future<Result<bool>> isLoggedIn();
}
