import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking authentication status.
/// Retrieves cached user session if exists.
@lazySingleton
class CheckAuthStatusUseCase implements UseCaseNoParams<User?> {
  final AuthRepository repository;

  const CheckAuthStatusUseCase(this.repository);

  @override
  Future<Result<User?>> call() async {
    try {
      final user = await repository.getCachedUser();
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
}
