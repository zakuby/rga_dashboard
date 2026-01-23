import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_state.dart';

/// Cubit managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(const AuthState.initial());

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Checks if user is already logged in.
  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());

    final result = await _checkAuthStatusUseCase();

    result.fold(
      onSuccess: (user) {
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
      onFailure: (_) => emit(const AuthState.unauthenticated()),
    );
  }

  /// Validates input and logs in if valid.
  Future<void> login({required String email, required String password}) async {
    // Validate inputs
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);

    if (emailError != null || passwordError != null) {
      emit(AuthState.validationError(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    // Clear validation errors and proceed with login
    emit(const AuthState.loading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      onSuccess: (user) => emit(AuthState.authenticated(user)),
      onFailure: (failure) => emit(AuthState.failure(
        message: failure.message,
        type: failure.type,
      )),
    );
  }

  /// Clears validation errors when user starts typing.
  void clearValidationErrors() {
    if (state.hasValidationErrors) {
      emit(state.copyWith(clearValidationErrors: true));
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    emit(const AuthState.loading());

    final result = await _logoutUseCase();

    result.fold(
      onSuccess: (_) => emit(const AuthState.unauthenticated()),
      onFailure: (failure) => emit(AuthState.failure(
        message: failure.message,
        type: failure.type,
      )),
    );
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
