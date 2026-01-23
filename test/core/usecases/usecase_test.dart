import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/result/result.dart';
import 'package:rga_dashboard/core/usecases/usecase.dart';

// Concrete implementation of UseCase for testing
class ConcreteUseCase extends UseCase<String, int> {
  @override
  Future<Result<String>> call(int params) async {
    return Success('Result: $params');
  }
}

// Concrete implementation of UseCaseNoParams for testing
class ConcreteUseCaseNoParams extends UseCaseNoParams<String> {
  @override
  Future<Result<String>> call() async {
    return const Success('No params result');
  }
}

void main() {
  group('UseCase', () {
    late ConcreteUseCase useCase;

    setUp(() {
      useCase = ConcreteUseCase();
    });

    test('concrete implementation can be called with params', () async {
      final result = await useCase.call(42);

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'Result: 42');
    });

    test('can be invoked using call syntax', () async {
      final result = await useCase(100);

      expect(result, isA<Success<String>>());
    });
  });

  group('UseCaseNoParams', () {
    late ConcreteUseCaseNoParams useCase;

    setUp(() {
      useCase = ConcreteUseCaseNoParams();
    });

    test('concrete implementation can be called without params', () async {
      final result = await useCase.call();

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'No params result');
    });

    test('can be invoked using call syntax', () async {
      final result = await useCase();

      expect(result, isA<Success<String>>());
    });
  });
}
