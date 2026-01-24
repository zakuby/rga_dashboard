import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository].
/// Thin data access layer - delegates to data sources.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login({required String email, required String password}) async {
    final userModel = await remoteDataSource.login(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> cacheUser(User user) async {
    await localDataSource.cacheUser(UserModel.fromEntity(user));
  }

  @override
  Future<User?> getCachedUser() async {
    final userModel = await localDataSource.getCachedUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }

  @override
  Future<bool> hasUser() async {
    return localDataSource.hasUser();
  }
}
