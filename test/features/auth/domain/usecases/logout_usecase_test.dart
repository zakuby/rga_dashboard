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
    test('should call repository clearCache', () async {
      when(() => mockRepository.clearCache()).thenAnswer((_) async {});

      await useCase();

      verify(() => mockRepository.clearCache()).called(1);
    });

    test('should return Success with true when logout succeeds', () async {
      when(() => mockRepository.clearCache()).thenAnswer((_) async {});

      final result = await useCase();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test(
      'should return Failure with cache type when clearCache fails',
      () async {
        when(
          () => mockRepository.clearCache(),
        ).thenThrow(Exception('Cache error'));

        final result = await useCase();

        expect(result, isA<Failure<bool>>());
        final failure = result as Failure<bool>;
        expect(failure.type, FailureType.cache);
        expect(failure.message, 'Failed to logout. Please try again.');
      },
    );
  });
}
