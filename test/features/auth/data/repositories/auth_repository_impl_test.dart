import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';
import 'package:rga_dashboard/features/auth/data/repositories/auth_repository_impl.dart';

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
      test('should return User when remote login succeeds', () async {
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUserModel);

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.id, testUserModel.id);
        expect(result.email, testUserModel.email);
        verify(
          () => mockRemoteDataSource.login(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test(
        'should throw AuthenticationException on invalid credentials',
        () async {
          when(
            () => mockRemoteDataSource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(const AuthenticationException('Invalid credentials'));

          expect(
            () => repository.login(
              email: 'wrong@example.com',
              password: 'wrongpassword',
            ),
            throwsA(isA<AuthenticationException>()),
          );
        },
      );

      test('should throw TimeoutException on timeout', () async {
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const TimeoutException('Connection timed out'));

        expect(
          () => repository.login(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should throw NetworkException on network error', () async {
        when(
          () => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const NetworkException('No internet connection'));

        expect(
          () => repository.login(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('cacheUser', () {
      test('should cache user via local data source', () async {
        when(
          () => mockLocalDataSource.cacheUser(any()),
        ).thenAnswer((_) async {});

        await repository.cacheUser(testUserModel.toEntity());

        verify(() => mockLocalDataSource.cacheUser(any())).called(1);
      });
    });

    group('getCachedUser', () {
      test('should return User when cached', () async {
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenAnswer((_) async => testUserModel);

        final result = await repository.getCachedUser();

        expect(result, isNotNull);
        expect(result!.email, 'test@example.com');
      });

      test('should return null when no cached user', () async {
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenAnswer((_) async => null);

        final result = await repository.getCachedUser();

        expect(result, isNull);
      });
    });

    group('clearCache', () {
      test('should clear cache via local data source', () async {
        when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {});

        await repository.clearCache();

        verify(() => mockLocalDataSource.clearCache()).called(1);
      });
    });

    group('hasUser', () {
      test('should return true when user exists', () async {
        when(() => mockLocalDataSource.hasUser()).thenAnswer((_) async => true);

        final result = await repository.hasUser();

        expect(result, isTrue);
      });

      test('should return false when no user exists', () async {
        when(
          () => mockLocalDataSource.hasUser(),
        ).thenAnswer((_) async => false);

        final result = await repository.hasUser();

        expect(result, isFalse);
      });
    });
  });
}
