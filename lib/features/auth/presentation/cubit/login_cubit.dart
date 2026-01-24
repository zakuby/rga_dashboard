import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

/// Cubit managing login form state (loading, validation, errors).
@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase,
      super(const LoginState());

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates input and logs in if valid.
  Future<void> login({required String email, required String password}) async {
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);

    if (emailError != null || passwordError != null) {
      emit(LoginState(emailError: emailError, passwordError: passwordError));
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

  String? _validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
