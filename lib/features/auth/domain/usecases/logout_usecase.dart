import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out a user.
/// Clears cached session data.
@lazySingleton
class LogoutUseCase implements UseCaseNoParams<bool> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Result<bool>> call() async {
    try {
      await repository.clearCache();
      return const Success(true);
    } catch (e) {
      return Failure(
        'Failed to logout. Please try again.',
        type: FailureType.cache,
      );
    }
  }
}
