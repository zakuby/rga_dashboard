import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  final testUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 15),
  );

  const testParams = LoginParams(
    email: 'test@example.com',
    password: 'password123',
  );

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  group('LoginUseCase', () {
    test('should call repository login and cacheUser on success', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUser);
      when(() => mockRepository.cacheUser(any())).thenAnswer((_) async {});

      await useCase(testParams);

      verify(
        () => mockRepository.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
      verify(() => mockRepository.cacheUser(any())).called(1);
    });

    test('should return Success with User when login succeeds', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUser);
      when(() => mockRepository.cacheUser(any())).thenAnswer((_) async {});

      final result = await useCase(testParams);

      expect(result, isA<Success<User>>());
      expect((result as Success<User>).data, testUser);
    });

    test(
      'should return Failure with authentication type on AuthenticationException',
      () async {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthenticationException('Invalid credentials'));

        final result = await useCase(testParams);

        expect(result, isA<Failure<User>>());
        final failure = result as Failure<User>;
        expect(failure.message, 'Invalid credentials');
        expect(failure.type, FailureType.authentication);
      },
    );

    test(
      'should return Failure with timeout type on TimeoutException',
      () async {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const TimeoutException('Request timed out'));

        final result = await useCase(testParams);

        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).type, FailureType.timeout);
      },
    );

    test(
      'should return Failure with network type on NetworkException',
      () async {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const NetworkException('No network connection'));

        final result = await useCase(testParams);

        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).type, FailureType.network);
      },
    );

    test(
      'should return Failure with unknown type on unexpected error',
      () async {
        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        final result = await useCase(testParams);

        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).type, FailureType.unknown);
      },
    );

    test('should not cache user when login fails', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthenticationException('Invalid credentials'));

      await useCase(testParams);

      verifyNever(() => mockRepository.cacheUser(any()));
    });
  });

  group('LoginParams', () {
    test('should create LoginParams with email and password', () {
      const params = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(params.email, 'test@example.com');
      expect(params.password, 'password123');
    });

    test('should support equality for same values', () {
      const params1 = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );
      const params2 = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(params1, equals(params2));
    });
  });
}
