import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/validators/credentials_validator.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

/// Cubit managing login form state (loading, validation, errors).
@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final CredentialsValidator _validator;

  LoginCubit({
    required LoginUseCase loginUseCase,
    required CredentialsValidator validator,
  }) : _loginUseCase = loginUseCase,
       _validator = validator,
       super(const LoginState());

  /// Validates input and logs in if valid.
  Future<void> login({required String email, required String password}) async {
    final emailValidation = _validator.validateEmail(email);
    final passwordValidation = _validator.validatePassword(password);

    if (emailValidation.isFailure || passwordValidation.isFailure) {
      emit(LoginState(
        emailError: emailValidation.error,
        passwordError: passwordValidation.error,
      ));
      return;
    }

    emit(const LoginState(isLoading: true));

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      onSuccess: (_) => emit(const LoginState(isSuccess: true)),
      onFailure: (failure) => emit(
        LoginState(errorMessage: failure.message, failureType: failure.type),
      ),
    );
  }

  /// Clears errors when user starts typing.
  void clearErrors() {
    if (state.hasErrors) {
      emit(const LoginState());
    }
  }
}
