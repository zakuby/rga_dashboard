import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out a user.
@lazySingleton
class LogoutUseCase implements UseCaseNoParams<bool> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Result<bool>> call() async {
    return repository.logout();
  }
}
