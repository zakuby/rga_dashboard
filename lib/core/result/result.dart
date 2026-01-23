/// A sealed class representing the result of an operation.
/// Either [Success] containing data or [Failure] containing an error.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Transforms the result using the provided functions.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure<T> failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      Failure<T>() => onFailure(this as Failure<T>),
    };
  }

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final data) => Success(transform(data)),
      Failure<T>(message: final msg, type: final t) => Failure(msg, type: t),
    };
  }

  /// Returns the success value or null.
  T? getOrNull() {
    return switch (this) {
      Success<T>(data: final data) => data,
      Failure<T>() => null,
    };
  }

  /// Returns the success value or a default value.
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(data: final data) => data,
      Failure<T>() => defaultValue,
    };
  }
}

/// Represents a successful result containing [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing an error [message] and [type].
final class Failure<T> extends Result<T> {
  final String message;
  final FailureType type;

  const Failure(this.message, {this.type = FailureType.unknown});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;

  @override
  String toString() => 'Failure($message, type: $type)';
}

/// Types of failures that can occur in the application.
enum FailureType {
  /// Authentication failed (wrong credentials)
  authentication,

  /// Network request timed out
  timeout,

  /// No network connection
  network,

  /// Data not found in cache
  cache,

  /// Server returned an error
  server,

  /// Invalid input data
  validation,

  /// Unknown error
  unknown,
}
