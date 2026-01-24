part of 'login_cubit.dart';

/// State representing the login form status.
@freezed
class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    FailureType? failureType,
  }) = _LoginState;

  bool get hasValidationErrors => emailError != null || passwordError != null;
  bool get hasError => errorMessage != null;
  bool get hasErrors => hasValidationErrors || hasError;
}
