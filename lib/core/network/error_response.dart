import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';
part 'error_response.g.dart';

/// Error response from the backend API.
@freezed
class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    @Default('') String code,
    @Default('') String message,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
