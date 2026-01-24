import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rga_dashboard/features/auth/presentation/cubit/auth_cubit.dart';

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

void main() {
  late AuthCubit authCubit;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;

  final testUser = User(
    id: 'test_id',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();

    authCubit = AuthCubit(
      logoutUseCase: mockLogoutUseCase,
      checkAuthStatusUseCase: mockCheckAuthStatusUseCase,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthState.initial', () {
      expect(authCubit.state, AuthState.initial());
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [loading, authenticated] when user is cached',
        build: () {
          when(
            () => mockCheckAuthStatusUseCase(),
          ).thenAnswer((_) async => Success(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthState.loading(), AuthState.authenticated(testUser)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [loading, unauthenticated] when no user is cached',
        build: () {
          when(
            () => mockCheckAuthStatusUseCase(),
          ).thenAnswer((_) async => const Success(null));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthState.loading(), AuthState.unauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [loading, unauthenticated] when check fails',
        build: () {
          when(
            () => mockCheckAuthStatusUseCase(),
          ).thenAnswer((_) async => const Failure('Error'));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthState.loading(), AuthState.unauthenticated()],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [unauthenticated] when logout is called',
        build: () {
          when(
            () => mockLogoutUseCase(),
          ).thenAnswer((_) async => const Success(true));
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [AuthState.unauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [unauthenticated] even when logout fails',
        build: () {
          when(
            () => mockLogoutUseCase(),
          ).thenAnswer((_) async => const Failure('Error'));
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [AuthState.unauthenticated()],
      );
    });
  });

  group('AuthState', () {
    test('AuthState.initial has initial status', () {
      final state = AuthState.initial();
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
    });

    test('AuthState.loading has loading status', () {
      final state = AuthState.loading();
      expect(state.status, AuthStatus.loading);
    });

    test('AuthState.authenticated has user', () {
      final state = AuthState.authenticated(testUser);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, testUser);
    });

    test('AuthState.unauthenticated has no user', () {
      final state = AuthState.unauthenticated();
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });
  });
}
