import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'login_usecase.freezed.dart';

/// Use case for logging in a user.
/// Handles authentication flow: validate -> login -> cache session.
@lazySingleton
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Result<User>> call(LoginParams params) async {
    try {
      // Authenticate with remote service
      final user = await repository.login(
        email: params.email,
        password: params.password,
      );

      // Cache user for session persistence
      await repository.cacheUser(user);

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
}

/// Parameters required for login.
@freezed
class LoginParams with _$LoginParams {
  const factory LoginParams({required String email, required String password}) =
      _LoginParams;
}
