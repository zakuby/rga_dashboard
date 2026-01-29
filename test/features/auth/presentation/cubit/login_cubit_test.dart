import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/login_usecase.dart';
import 'package:rga_dashboard/features/auth/domain/validators/credentials_validator.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/login_cubit.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockCredentialsValidator extends Mock implements CredentialsValidator {}

void main() {
  late LoginCubit loginCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockCredentialsValidator mockValidator;

  final testUser = User(
    id: 'test_id',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockValidator = MockCredentialsValidator();
    loginCubit = LoginCubit(
      loginUseCase: mockLoginUseCase,
      validator: mockValidator,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: 'test@example.com', password: 'password'),
    );
  });

  tearDown(() {
    loginCubit.close();
  });

  group('LoginCubit', () {
    test('initial state is LoginState()', () {
      expect(loginCubit.state, const LoginState());
      expect(loginCubit.state.isLoading, false);
      expect(loginCubit.state.isSuccess, false);
      expect(loginCubit.state.emailError, isNull);
      expect(loginCubit.state.passwordError, isNull);
      expect(loginCubit.state.errorMessage, isNull);
    });

    group('login validation', () {
      blocTest<LoginCubit, LoginState>(
        'emits emailError when email validation fails',
        build: () {
          when(() => mockValidator.validateEmail(any())).thenReturn(
            const ValidationResult.failure('Please enter your email'),
          );
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          return loginCubit;
        },
        act: (cubit) => cubit.login(email: '', password: 'password123'),
        expect: () => [
          const LoginState(
            emailError: 'Please enter your email',
            passwordError: null,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockLoginUseCase(any()));
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits emailError when email format is invalid',
        build: () {
          when(() => mockValidator.validateEmail(any())).thenReturn(
            const ValidationResult.failure('Please enter a valid email'),
          );
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'invalid-email', password: 'password123'),
        expect: () => [
          const LoginState(
            emailError: 'Please enter a valid email',
            passwordError: null,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password validation fails',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(() => mockValidator.validatePassword(any())).thenReturn(
            const ValidationResult.failure('Please enter your password'),
          );
          return loginCubit;
        },
        act: (cubit) => cubit.login(email: 'test@example.com', password: ''),
        expect: () => [
          const LoginState(
            emailError: null,
            passwordError: 'Please enter your password',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits passwordError when password is too short',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(() => mockValidator.validatePassword(any())).thenReturn(
            const ValidationResult.failure(
              'Password must be at least 6 characters',
            ),
          );
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: '12345'),
        expect: () => [
          const LoginState(
            emailError: null,
            passwordError: 'Password must be at least 6 characters',
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits both errors when email and password validation fail',
        build: () {
          when(() => mockValidator.validateEmail(any())).thenReturn(
            const ValidationResult.failure('Please enter your email'),
          );
          when(() => mockValidator.validatePassword(any())).thenReturn(
            const ValidationResult.failure('Please enter your password'),
          );
          return loginCubit;
        },
        act: (cubit) => cubit.login(email: '', password: ''),
        expect: () => [
          const LoginState(
            emailError: 'Please enter your email',
            passwordError: 'Please enter your password',
          ),
        ],
      );
    });

    group('login success', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when login succeeds',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockLoginUseCase(any()),
          ).thenAnswer((_) async => Success(testUser));
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: 'password123'),
        expect: () => [
          const LoginState(isLoading: true),
          const LoginState(isSuccess: true),
        ],
        verify: (_) {
          verify(
            () => mockLoginUseCase(
              const LoginParams(
                email: 'test@example.com',
                password: 'password123',
              ),
            ),
          ).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'calls use case when validation passes',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockLoginUseCase(any()),
          ).thenAnswer((_) async => Success(testUser));
          return loginCubit;
        },
        act: (cubit) => cubit.login(
          email: 'user.name@sub.domain.com',
          password: 'password123',
        ),
        expect: () => [
          const LoginState(isLoading: true),
          const LoginState(isSuccess: true),
        ],
      );
    });

    group('login failure', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, error] with authentication failure',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async => const Failure(
              'Invalid credentials',
              type: FailureType.authentication,
            ),
          );
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: 'wrongpassword'),
        expect: () => [
          const LoginState(isLoading: true),
          const LoginState(
            errorMessage: 'Invalid credentials',
            failureType: FailureType.authentication,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, error] with network failure',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async => const Failure(
              'No internet connection',
              type: FailureType.network,
            ),
          );
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: 'password123'),
        expect: () => [
          const LoginState(isLoading: true),
          const LoginState(
            errorMessage: 'No internet connection',
            failureType: FailureType.network,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, error] with timeout failure',
        build: () {
          when(
            () => mockValidator.validateEmail(any()),
          ).thenReturn(const ValidationResult.success());
          when(
            () => mockValidator.validatePassword(any()),
          ).thenReturn(const ValidationResult.success());
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async =>
                const Failure('Request timed out', type: FailureType.timeout),
          );
          return loginCubit;
        },
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: 'password123'),
        expect: () => [
          const LoginState(isLoading: true),
          const LoginState(
            errorMessage: 'Request timed out',
            failureType: FailureType.timeout,
          ),
        ],
      );
    });

    group('clearErrors', () {
      blocTest<LoginCubit, LoginState>(
        'emits empty state when has validation errors',
        build: () => loginCubit,
        seed: () => const LoginState(
          emailError: 'Some error',
          passwordError: 'Another error',
        ),
        act: (cubit) => cubit.clearErrors(),
        expect: () => [const LoginState()],
      );

      blocTest<LoginCubit, LoginState>(
        'emits empty state when has error message',
        build: () => loginCubit,
        seed: () => const LoginState(
          errorMessage: 'Login failed',
          failureType: FailureType.authentication,
        ),
        act: (cubit) => cubit.clearErrors(),
        expect: () => [const LoginState()],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit when no errors',
        build: () => loginCubit,
        seed: () => const LoginState(),
        act: (cubit) => cubit.clearErrors(),
        expect: () => [],
      );

      blocTest<LoginCubit, LoginState>(
        'does not emit when only loading',
        build: () => loginCubit,
        seed: () => const LoginState(isLoading: true),
        act: (cubit) => cubit.clearErrors(),
        expect: () => [],
      );
    });
  });

  group('LoginState', () {
    test('hasValidationErrors returns true when emailError is set', () {
      const state = LoginState(emailError: 'Error');
      expect(state.hasValidationErrors, true);
    });

    test('hasValidationErrors returns true when passwordError is set', () {
      const state = LoginState(passwordError: 'Error');
      expect(state.hasValidationErrors, true);
    });

    test('hasValidationErrors returns false when no validation errors', () {
      const state = LoginState();
      expect(state.hasValidationErrors, false);
    });

    test('hasError returns true when errorMessage is set', () {
      const state = LoginState(errorMessage: 'Error');
      expect(state.hasError, true);
    });

    test('hasError returns false when errorMessage is null', () {
      const state = LoginState();
      expect(state.hasError, false);
    });

    test('hasErrors returns true for validation errors', () {
      const state = LoginState(emailError: 'Error');
      expect(state.hasErrors, true);
    });

    test('hasErrors returns true for error message', () {
      const state = LoginState(errorMessage: 'Error');
      expect(state.hasErrors, true);
    });

    test('hasErrors returns false when no errors', () {
      const state = LoginState();
      expect(state.hasErrors, false);
    });

    test('supports equality', () {
      const state1 = LoginState(isLoading: true);
      const state2 = LoginState(isLoading: true);
      expect(state1, equals(state2));
    });

    test('different states are not equal', () {
      const state1 = LoginState(isLoading: true);
      const state2 = LoginState(isLoading: false);
      expect(state1, isNot(equals(state2)));
    });
  });
}
