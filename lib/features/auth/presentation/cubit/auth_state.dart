part of 'auth_cubit.dart';

/// Status of authentication operations.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

/// State representing the current authentication status.
final class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final FailureType? failureType;
  final String? emailError;
  final String? passwordError;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.failureType,
    this.emailError,
    this.passwordError,
  });

  const AuthState.initial() : this();

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.failure({
    required String message,
    FailureType? type,
  }) : this(
          status: AuthStatus.failure,
          errorMessage: message,
          failureType: type,
        );

  const AuthState.validationError({
    String? emailError,
    String? passwordError,
  }) : this(
          status: AuthStatus.unauthenticated,
          emailError: emailError,
          passwordError: passwordError,
        );

  bool get hasValidationErrors => emailError != null || passwordError != null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    FailureType? failureType,
    String? emailError,
    String? passwordError,
    bool clearValidationErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      failureType: failureType ?? this.failureType,
      emailError: clearValidationErrors ? null : (emailError ?? this.emailError),
      passwordError: clearValidationErrors ? null : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, failureType, emailError, passwordError];
}
