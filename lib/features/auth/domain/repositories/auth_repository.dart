import '../entities/user.dart';

/// Abstract repository defining authentication data operations.
/// This is a thin data access layer - business logic belongs in use cases.
abstract class AuthRepository {
  /// Authenticates user with remote service.
  /// Throws exceptions on failure.
  Future<User> login({required String email, required String password});

  /// Caches user locally for session persistence.
  Future<void> cacheUser(User user);

  /// Retrieves cached user from local storage.
  /// Returns null if no user is cached.
  Future<User?> getCachedUser();

  /// Clears cached user data.
  Future<void> clearCache();

  /// Checks if a user session exists locally.
  Future<bool> hasUser();
}
