import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:rga_dashboard/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should call repository logout', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Success(true));

      await useCase();

      verify(() => mockRepository.logout()).called(1);
    });

    test('should return Success with true when logout succeeds', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Success(true));

      final result = await useCase();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Failure when logout fails', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => const Failure(
            'Failed to clear session',
            type: FailureType.cache,
          ));

      final result = await useCase();

      expect(result, isA<Failure<bool>>());
      final failure = result as Failure<bool>;
      expect(failure.message, 'Failed to clear session');
      expect(failure.type, FailureType.cache);
    });

    test('should return unknown failure on unexpected error', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => const Failure(
            'Unexpected error',
            type: FailureType.unknown,
          ));

      final result = await useCase();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).type, FailureType.unknown);
    });
  });
}
