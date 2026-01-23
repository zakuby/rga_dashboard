import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/login_usecase.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;

  final testUser = User(
    id: 'test_id',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();

    authCubit = AuthCubit(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthStatusUseCase: mockCheckAuthStatusUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthState.initial', () {
      expect(authCubit.state, const AuthState.initial());
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [loading, authenticated] when user is cached',
        build: () {
          when(() => mockCheckAuthStatusUseCase())
              .thenAnswer((_) async => Success(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState.loading(),
          AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [loading, unauthenticated] when no user is cached',
        build: () {
          when(() => mockCheckAuthStatusUseCase())
              .thenAnswer((_) async => const Success(null));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState.loading(),
          const AuthState.unauthenticated(),
        ],
      );
    });

    group('login validation', () {
      blocTest<AuthCubit, AuthState>(
        'emits validation error for empty email',
        build: () => authCubit,
        act: (cubit) => cubit.login(email: '', password: 'password123'),
        expect: () => [
          const AuthState.validationError(emailError: 'Please enter your email'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits validation error for invalid email format',
        build: () => authCubit,
        act: (cubit) => cubit.login(email: 'invalid-email', password: 'password123'),
        expect: () => [
          const AuthState.validationError(emailError: 'Please enter a valid email'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits validation error for empty password',
        build: () => authCubit,
        act: (cubit) => cubit.login(email: 'test@example.com', password: ''),
        expect: () => [
          const AuthState.validationError(passwordError: 'Please enter your password'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits validation error for short password',
        build: () => authCubit,
        act: (cubit) => cubit.login(email: 'test@example.com', password: '12345'),
        expect: () => [
          const AuthState.validationError(passwordError: 'Password must be at least 6 characters'),
        ],
      );
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [loading, authenticated] when login succeeds',
        build: () {
          when(() => mockLoginUseCase(any()))
              .thenAnswer((_) async => Success(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.login(email: 'test@example.com', password: 'password123'),
        expect: () => [
          const AuthState.loading(),
          AuthState.authenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase(
            const LoginParams(email: 'test@example.com', password: 'password123'),
          )).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [loading, failure] when login fails',
        build: () {
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async => const Failure(
              'Invalid email or password',
              type: FailureType.authentication,
            ),
          );
          return authCubit;
        },
        act: (cubit) => cubit.login(email: 'test@example.com', password: 'wrong123'),
        expect: () => [
          const AuthState.loading(),
          const AuthState.failure(
            message: 'Invalid email or password',
            type: FailureType.authentication,
          ),
        ],
      );
    });

    group('clearValidationErrors', () {
      blocTest<AuthCubit, AuthState>(
        'clears validation errors when called',
        build: () => authCubit,
        seed: () => const AuthState.validationError(emailError: 'Please enter your email'),
        act: (cubit) => cubit.clearValidationErrors(),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when no validation errors',
        build: () => authCubit,
        seed: () => const AuthState.unauthenticated(),
        act: (cubit) => cubit.clearValidationErrors(),
        expect: () => [],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [loading, unauthenticated] when logout succeeds',
        build: () {
          when(() => mockLogoutUseCase())
              .thenAnswer((_) async => const Success(true));
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthState.loading(),
          const AuthState.unauthenticated(),
        ],
      );
    });
  });

  group('AuthState', () {
    test('hasValidationErrors returns true when errors exist', () {
      const state = AuthState.validationError(emailError: 'Error');
      expect(state.hasValidationErrors, isTrue);
    });

    test('hasValidationErrors returns false when no errors', () {
      const state = AuthState.unauthenticated();
      expect(state.hasValidationErrors, isFalse);
    });

    test('copyWith clears validation errors when clearValidationErrors is true', () {
      const state = AuthState.validationError(
        emailError: 'Error',
        passwordError: 'Error',
      );
      final cleared = state.copyWith(clearValidationErrors: true);
      expect(cleared.emailError, isNull);
      expect(cleared.passwordError, isNull);
    });
  });
}
