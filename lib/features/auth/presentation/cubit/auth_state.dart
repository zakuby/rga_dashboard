part of 'auth_cubit.dart';

/// Status of authentication operations.
enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

/// State representing the current authentication status.
@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    User? user,
    String? errorMessage,
    FailureType? failureType,
    String? emailError,
    String? passwordError,
  }) = _AuthState;

  factory AuthState.initial() => const AuthState();

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.failure({required String message, FailureType? type}) =>
      AuthState(
        status: AuthStatus.failure,
        errorMessage: message,
        failureType: type,
      );

  factory AuthState.validationError({
    String? emailError,
    String? passwordError,
  }) => AuthState(
    status: AuthStatus.unauthenticated,
    emailError: emailError,
    passwordError: passwordError,
  );

  bool get hasValidationErrors => emailError != null || passwordError != null;
}
