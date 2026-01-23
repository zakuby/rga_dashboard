import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group('LoginUseCase', () {
    test('should call repository login with correct parameters', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Success(testUser));

      await useCase(testParams);

      verify(() => mockRepository.login(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('should return Success with User when login succeeds', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Success(testUser));

      final result = await useCase(testParams);

      expect(result, isA<Success<User>>());
      expect((result as Success<User>).data, testUser);
    });

    test('should return Failure when repository returns failure', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Failure(
            'Invalid credentials',
            type: FailureType.authentication,
          ));

      final result = await useCase(testParams);

      expect(result, isA<Failure<User>>());
      final failure = result as Failure<User>;
      expect(failure.message, 'Invalid credentials');
      expect(failure.type, FailureType.authentication);
    });

    test('should return timeout failure when repository times out', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Failure(
            'Request timed out',
            type: FailureType.timeout,
          ));

      final result = await useCase(testParams);

      expect(result, isA<Failure<User>>());
      expect((result as Failure<User>).type, FailureType.timeout);
    });

    test('should return network failure when no connection', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Failure(
            'No network connection',
            type: FailureType.network,
          ));

      final result = await useCase(testParams);

      expect(result, isA<Failure<User>>());
      expect((result as Failure<User>).type, FailureType.network);
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

    test('should not be equal when email differs', () {
      const params1 = LoginParams(
        email: 'test1@example.com',
        password: 'password123',
      );
      const params2 = LoginParams(
        email: 'test2@example.com',
        password: 'password123',
      );

      expect(params1, isNot(equals(params2)));
    });

    test('should not be equal when password differs', () {
      const params1 = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );
      const params2 = LoginParams(
        email: 'test@example.com',
        password: 'password456',
      );

      expect(params1, isNot(equals(params2)));
    });

    test('should have correct props for Equatable', () {
      const params = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(params.props, ['test@example.com', 'password123']);
    });
  });
}
