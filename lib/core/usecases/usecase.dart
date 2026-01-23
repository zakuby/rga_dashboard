import '../result/result.dart';

/// Base class for all use cases.
/// [T] is the return type of the use case.
/// [P] is the input parameters type.
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// Use case that doesn't require any parameters.
abstract class UseCaseNoParams<T> {
  Future<Result<T>> call();
}
