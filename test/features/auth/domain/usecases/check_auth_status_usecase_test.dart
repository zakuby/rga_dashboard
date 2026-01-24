import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';
import 'package:rga_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/check_auth_status_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CheckAuthStatusUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckAuthStatusUseCase(mockRepository);
  });

  final testUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 15),
  );

  group('CheckAuthStatusUseCase', () {
    test('should call repository getCachedUser', () async {
      when(
        () => mockRepository.getCachedUser(),
      ).thenAnswer((_) async => testUser);

      await useCase();

      verify(() => mockRepository.getCachedUser()).called(1);
    });

    test('should return Success with User when user is cached', () async {
      when(
        () => mockRepository.getCachedUser(),
      ).thenAnswer((_) async => testUser);

      final result = await useCase();

      expect(result, isA<Success<User?>>());
      expect((result as Success<User?>).data, testUser);
    });

    test('should return Success with null when no user is cached', () async {
      when(() => mockRepository.getCachedUser()).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isA<Success<User?>>());
      expect((result as Success<User?>).data, isNull);
    });

    test('should return Failure with cache type on CacheException', () async {
      when(
        () => mockRepository.getCachedUser(),
      ).thenThrow(const CacheException('Cache read error'));

      final result = await useCase();

      expect(result, isA<Failure<User?>>());
      final failure = result as Failure<User?>;
      expect(failure.message, 'Cache read error');
      expect(failure.type, FailureType.cache);
    });

    test(
      'should return Failure with unknown type on unexpected error',
      () async {
        when(
          () => mockRepository.getCachedUser(),
        ).thenThrow(Exception('Unexpected'));

        final result = await useCase();

        expect(result, isA<Failure<User?>>());
        final failure = result as Failure<User?>;
        expect(failure.type, FailureType.unknown);
        expect(failure.message, 'Failed to retrieve user session.');
      },
    );
  });
}
