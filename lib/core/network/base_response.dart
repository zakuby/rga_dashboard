import 'package:freezed_annotation/freezed_annotation.dart';

import 'error_response.dart';

part 'base_response.freezed.dart';
part 'base_response.g.dart';

/// Base response wrapper for backend API responses.
///
/// Success response:
/// ```json
/// { "success": true, "data": {...}, "error": null }
/// ```
///
/// Error response:
/// ```json
/// { "success": false, "data": null, "error": { "code": "...", "message": "..." } }
/// ```
@Freezed(genericArgumentFactories: true)
class BaseResponse<T> with _$BaseResponse<T> {
  const BaseResponse._();

  const factory BaseResponse({
    @Default(false) bool success,
    T? data,
    ErrorResponse? error,
  }) = _BaseResponse<T>;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);

  /// Whether the response is an error.
  bool get isError => !success;

  /// Whether the response has data.
  bool get hasData => data != null;

  /// Whether the response has an error message.
  bool get hasError => error != null;
}
