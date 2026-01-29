import 'package:injectable/injectable.dart';

/// Result of a validation operation.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult._({required this.isValid, this.error});

  /// Creates a successful validation result.
  const ValidationResult.success()
      : isValid = true,
        error = null;

  /// Creates a failed validation result with an error message.
  const ValidationResult.failure(String message)
      : isValid = false,
        error = message;

  bool get isFailure => !isValid;
}

/// Validator for authentication credentials.
/// Contains business rules for email and password validation.
abstract class CredentialsValidator {
  /// Validates an email address.
  ValidationResult validateEmail(String email);

  /// Validates a password.
  ValidationResult validatePassword(String password);
}

/// Implementation of [CredentialsValidator].
@LazySingleton(as: CredentialsValidator)
class CredentialsValidatorImpl implements CredentialsValidator {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static const _minPasswordLength = 6;

  @override
  ValidationResult validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return const ValidationResult.failure('Please enter your email');
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return const ValidationResult.failure('Please enter a valid email');
    }
    return const ValidationResult.success();
  }

  @override
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return const ValidationResult.failure('Please enter your password');
    }
    if (password.length < _minPasswordLength) {
      return const ValidationResult.failure(
        'Password must be at least $_minPasswordLength characters',
      );
    }
    return const ValidationResult.success();
  }
}
