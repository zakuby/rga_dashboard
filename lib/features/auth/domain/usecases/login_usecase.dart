import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'login_usecase.freezed.dart';

/// Use case for logging in a user.
@lazySingleton
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Result<User>> call(LoginParams params) async {
    return repository.login(email: params.email, password: params.password);
  }
}

/// Parameters required for login.
@freezed
class LoginParams with _$LoginParams {
  const factory LoginParams({required String email, required String password}) =
      _LoginParams;
}
