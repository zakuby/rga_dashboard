import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

/// Cubit managing authentication status (authenticated/unauthenticated).
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthCubit({
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(AuthState.initial());

  /// Checks if user is already logged in.
  Future<void> checkAuthStatus() async {
    emit(AuthState.loading());

    final result = await _checkAuthStatusUseCase();

    result.fold(
      onSuccess: (user) {
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(AuthState.unauthenticated());
        }
      },
      onFailure: (_) => emit(AuthState.unauthenticated()),
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _logoutUseCase();
    emit(AuthState.unauthenticated());
  }
}
