import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/result/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create Success with data', () {
        const result = Success<int>(42);

        expect(result.data, 42);
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
      });

      test('should support equality for same data', () {
        const result1 = Success<String>('test');
        const result2 = Success<String>('test');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different data', () {
        const result1 = Success<String>('test1');
        const result2 = Success<String>('test2');

        expect(result1, isNot(equals(result2)));
      });

      test('should have correct toString representation', () {
        const result = Success<int>(42);

        expect(result.toString(), 'Success(42)');
      });

      test('should handle null data', () {
        const result = Success<String?>(null);

        expect(result.data, isNull);
        expect(result.isSuccess, true);
      });
    });

    group('Failure', () {
      test('should create Failure with message and default type', () {
        const result = Failure<int>('Error occurred');

        expect(result.message, 'Error occurred');
        expect(result.type, FailureType.unknown);
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
      });

      test('should create Failure with specific type', () {
        const result = Failure<int>(
          'Authentication failed',
          type: FailureType.authentication,
        );

        expect(result.message, 'Authentication failed');
        expect(result.type, FailureType.authentication);
      });

      test('should support equality for same message and type', () {
        const result1 = Failure<int>('Error', type: FailureType.network);
        const result2 = Failure<int>('Error', type: FailureType.network);

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different message', () {
        const result1 = Failure<int>('Error1', type: FailureType.network);
        const result2 = Failure<int>('Error2', type: FailureType.network);

        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal for different type', () {
        const result1 = Failure<int>('Error', type: FailureType.network);
        const result2 = Failure<int>('Error', type: FailureType.timeout);

        expect(result1, isNot(equals(result2)));
      });

      test('should have correct toString representation', () {
        const result = Failure<int>('Error', type: FailureType.cache);

        expect(result.toString(), 'Failure(Error, type: FailureType.cache)');
      });
    });

    group('fold', () {
      test('should call onSuccess for Success result', () {
        const result = Success<int>(42);

        final value = result.fold(
          onSuccess: (data) => 'Value: $data',
          onFailure: (failure) => 'Error: ${failure.message}',
        );

        expect(value, 'Value: 42');
      });

      test('should call onFailure for Failure result', () {
        const result = Failure<int>('Something went wrong');

        final value = result.fold(
          onSuccess: (data) => 'Value: $data',
          onFailure: (failure) => 'Error: ${failure.message}',
        );

        expect(value, 'Error: Something went wrong');
      });

      test('should provide failure type in onFailure', () {
        const result = Failure<int>('Timeout', type: FailureType.timeout);

        final value = result.fold(
          onSuccess: (data) => FailureType.unknown,
          onFailure: (failure) => failure.type,
        );

        expect(value, FailureType.timeout);
      });
    });

    group('map', () {
      test('should transform Success value', () {
        const result = Success<int>(42);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Success<String>>());
        expect((mapped as Success<String>).data, '42');
      });

      test('should preserve Failure without transformation', () {
        const result = Failure<int>('Error', type: FailureType.validation);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Failure<String>>());
        final failure = mapped as Failure<String>;
        expect(failure.message, 'Error');
        expect(failure.type, FailureType.validation);
      });
    });

    group('getOrNull', () {
      test('should return data for Success', () {
        const result = Success<int>(42);

        expect(result.getOrNull(), 42);
      });

      test('should return null for Failure', () {
        const result = Failure<int>('Error');

        expect(result.getOrNull(), isNull);
      });
    });

    group('getOrElse', () {
      test('should return data for Success', () {
        const result = Success<int>(42);

        expect(result.getOrElse(0), 42);
      });

      test('should return default value for Failure', () {
        const result = Failure<int>('Error');

        expect(result.getOrElse(0), 0);
      });
    });
  });

  group('FailureType', () {
    test('should have all expected types', () {
      expect(FailureType.values, contains(FailureType.authentication));
      expect(FailureType.values, contains(FailureType.timeout));
      expect(FailureType.values, contains(FailureType.network));
      expect(FailureType.values, contains(FailureType.cache));
      expect(FailureType.values, contains(FailureType.server));
      expect(FailureType.values, contains(FailureType.validation));
      expect(FailureType.values, contains(FailureType.unknown));
    });

    test('should have exactly 7 types', () {
      expect(FailureType.values.length, 7);
    });
  });
}
