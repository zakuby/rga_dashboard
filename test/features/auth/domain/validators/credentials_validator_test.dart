import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/auth/domain/validators/credentials_validator.dart';

void main() {
  late CredentialsValidatorImpl validator;

  setUp(() {
    validator = CredentialsValidatorImpl();
  });

  group('CredentialsValidator', () {
    group('validateEmail', () {
      test('returns failure when email is empty', () {
        final result = validator.validateEmail('');

        expect(result.isValid, false);
        expect(result.isFailure, true);
        expect(result.error, 'Please enter your email');
      });

      test('returns failure when email is whitespace only', () {
        final result = validator.validateEmail('   ');

        expect(result.isValid, false);
        expect(result.error, 'Please enter your email');
      });

      test('returns failure when email is invalid format', () {
        final result = validator.validateEmail('invalid-email');

        expect(result.isValid, false);
        expect(result.error, 'Please enter a valid email');
      });

      test('returns failure when email missing domain', () {
        final result = validator.validateEmail('test@');

        expect(result.isValid, false);
        expect(result.error, 'Please enter a valid email');
      });

      test('returns failure when email missing @', () {
        final result = validator.validateEmail('testexample.com');

        expect(result.isValid, false);
        expect(result.error, 'Please enter a valid email');
      });

      test('returns failure when email has invalid TLD', () {
        final result = validator.validateEmail('test@example.c');

        expect(result.isValid, false);
        expect(result.error, 'Please enter a valid email');
      });

      test('returns success for valid email', () {
        final result = validator.validateEmail('test@example.com');

        expect(result.isValid, true);
        expect(result.isFailure, false);
        expect(result.error, isNull);
      });

      test('returns success for email with subdomain', () {
        final result = validator.validateEmail('user@sub.domain.com');

        expect(result.isValid, true);
      });

      test('returns success for email with dots in local part', () {
        final result = validator.validateEmail('user.name@example.com');

        expect(result.isValid, true);
      });

      test('returns success for email with hyphen in domain', () {
        final result = validator.validateEmail('user@my-domain.com');

        expect(result.isValid, true);
      });

      test('trims whitespace before validation', () {
        final result = validator.validateEmail('  test@example.com  ');

        expect(result.isValid, true);
      });
    });

    group('validatePassword', () {
      test('returns failure when password is empty', () {
        final result = validator.validatePassword('');

        expect(result.isValid, false);
        expect(result.isFailure, true);
        expect(result.error, 'Please enter your password');
      });

      test('returns failure when password is too short', () {
        final result = validator.validatePassword('12345');

        expect(result.isValid, false);
        expect(result.error, 'Password must be at least 6 characters');
      });

      test('returns success for password with exactly 6 characters', () {
        final result = validator.validatePassword('123456');

        expect(result.isValid, true);
        expect(result.error, isNull);
      });

      test('returns success for password with more than 6 characters', () {
        final result = validator.validatePassword('password123');

        expect(result.isValid, true);
      });

      test('returns success for long password', () {
        final result = validator.validatePassword(
          'verylongpasswordwithmanychars',
        );

        expect(result.isValid, true);
      });

      test('does not trim password whitespace', () {
        // Password " 12345" is 6 chars including space
        final result = validator.validatePassword(' 12345');

        expect(result.isValid, true);
      });
    });
  });

  group('ValidationResult', () {
    test('success creates valid result', () {
      const result = ValidationResult.success();

      expect(result.isValid, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
    });

    test('failure creates invalid result with error', () {
      const result = ValidationResult.failure('Error message');

      expect(result.isValid, false);
      expect(result.isFailure, true);
      expect(result.error, 'Error message');
    });
  });
}
