import '../../../../core/error/exceptions.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository].
/// Coordinates between remote and local data sources.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user for session persistence
      await localDataSource.cacheUser(user);

      return Success(user);
    } on AuthenticationException catch (e) {
      return Failure(e.message, type: FailureType.authentication);
    } on TimeoutException catch (e) {
      return Failure(e.message, type: FailureType.timeout);
    } on NetworkException catch (e) {
      return Failure(e.message, type: FailureType.network);
    } catch (e) {
      return Failure(
        'An unexpected error occurred. Please try again.',
        type: FailureType.unknown,
      );
    }
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Success(true);
    } catch (e) {
      return Failure(
        'Failed to logout. Please try again.',
        type: FailureType.cache,
      );
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Success(user);
    } on CacheException catch (e) {
      return Failure(e.message, type: FailureType.cache);
    } catch (e) {
      return Failure(
        'Failed to retrieve user session.',
        type: FailureType.unknown,
      );
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final hasUser = await localDataSource.hasUser();
      return Success(hasUser);
    } catch (e) {
      return const Success(false);
    }
  }
}
