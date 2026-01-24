import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking authentication status.
@lazySingleton
class CheckAuthStatusUseCase implements UseCaseNoParams<User?> {
  final AuthRepository repository;

  const CheckAuthStatusUseCase(this.repository);

  @override
  Future<Result<User?>> call() async {
    return repository.getCurrentUser();
  }
}
