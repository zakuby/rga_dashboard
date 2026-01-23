import '../../domain/entities/user.dart';

/// Data model for User with SQLite serialization support.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.lastLoginAt,
  });

  /// Creates a UserModel from a database map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      lastLoginAt: DateTime.parse(map['last_login_at'] as String),
    );
  }

  /// Converts the model to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'last_login_at': lastLoginAt.toIso8601String(),
    };
  }

  /// Creates a UserModel from a User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
