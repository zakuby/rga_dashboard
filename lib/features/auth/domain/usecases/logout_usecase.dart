import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out a user.
class LogoutUseCase implements UseCaseNoParams<bool> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Result<bool>> call() async {
    return repository.logout();
  }
}
