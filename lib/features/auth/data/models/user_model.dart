import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model for User with JSON serialization support.
/// Fields have defaults for defensive parsing of remote data.
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @Default('') String id,
    @Default('') String email,
    @Default('') String name,
    DateTime? lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Creates a UserModel from a User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Converts to domain entity.
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      lastLoginAt: lastLoginAt ?? DateTime.now(),
    );
  }
}
