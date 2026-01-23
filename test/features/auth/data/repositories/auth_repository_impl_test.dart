import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';
import 'package:rga_dashboard/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  final testUserModel = UserModel(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(testUserModel);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test('should return Success with User when login succeeds', () async {
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUserModel);
        when(
          () => mockLocalDataSource.cacheUser(any()),
        ).thenAnswer((_) async {});

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data.email, 'test@example.com');
        verify(() => mockLocalDataSource.cacheUser(any())).called(1);
      });

      test(
        'should return Failure with authentication type on AuthenticationException',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const AuthenticationException('Invalid credentials'));

          final result = await repository.login(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          );

          expect(result, isA<Failure<User>>());
          expect((result as Failure<User>).type, FailureType.authentication);
          expect(result.message, 'Invalid credentials');
        },
      );

      test(
        'should return Failure with timeout type on TimeoutException',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const TimeoutException('Connection timed out'));

          final result = await repository.login(
            email: 'test@example.com',
            password: 'password123',
          );

          expect(result, isA<Failure<User>>());
          expect((result as Failure<User>).type, FailureType.timeout);
        },
      );

      test(
        'should return Failure with network type on NetworkException',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const NetworkException('No internet connection'));

          final result = await repository.login(
            email: 'test@example.com',
            password: 'password123',
          );

          expect(result, isA<Failure<User>>());
          expect((result as Failure<User>).type, FailureType.network);
        },
      );

      test(
        'should return Failure with unknown type on unexpected error',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Unexpected'));

          final result = await repository.login(
            email: 'test@example.com',
            password: 'password123',
          );

          expect(result, isA<Failure<User>>());
          expect((result as Failure<User>).type, FailureType.unknown);
        },
      );
    });

    group('logout', () {
      test('should return Success when logout succeeds', () async {
        when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {});

        final result = await repository.logout();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isTrue);
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });

      test('should return Failure when logout fails', () async {
        when(
          () => mockLocalDataSource.clearCache(),
        ).thenThrow(Exception('Cache error'));

        final result = await repository.logout();

        expect(result, isA<Failure<bool>>());
        expect((result as Failure<bool>).type, FailureType.cache);
      });
    });

    group('getCurrentUser', () {
      test('should return Success with User when cached', () async {
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenAnswer((_) async => testUserModel);

        final result = await repository.getCurrentUser();

        expect(result, isA<Success<User?>>());
        expect((result as Success<User?>).data, isNotNull);
        expect(result.data!.email, 'test@example.com');
      });

      test('should return Success with null when no cached user', () async {
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenAnswer((_) async => null);

        final result = await repository.getCurrentUser();

        expect(result, isA<Success<User?>>());
        expect((result as Success<User?>).data, isNull);
      });

      test('should return Failure on CacheException', () async {
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenThrow(const CacheException('Cache read error'));

        final result = await repository.getCurrentUser();

        expect(result, isA<Failure<User?>>());
        expect((result as Failure<User?>).type, FailureType.cache);
      });

      test(
        'should return Failure with unknown type on unexpected error',
        () async {
          when(
            () => mockLocalDataSource.getCachedUser(),
          ).thenThrow(Exception('Unexpected'));

          final result = await repository.getCurrentUser();

          expect(result, isA<Failure<User?>>());
          expect((result as Failure<User?>).type, FailureType.unknown);
        },
      );
    });

    group('isLoggedIn', () {
      test('should return Success(true) when user exists', () async {
        when(() => mockLocalDataSource.hasUser()).thenAnswer((_) async => true);

        final result = await repository.isLoggedIn();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isTrue);
      });

      test('should return Success(false) when no user exists', () async {
        when(
          () => mockLocalDataSource.hasUser(),
        ).thenAnswer((_) async => false);

        final result = await repository.isLoggedIn();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isFalse);
      });

      test('should return Success(false) on error', () async {
        when(() => mockLocalDataSource.hasUser()).thenThrow(Exception('Error'));

        final result = await repository.isLoggedIn();

        expect(result, isA<Success<bool>>());
        expect((result as Success<bool>).data, isFalse);
      });
    });
  });
}
