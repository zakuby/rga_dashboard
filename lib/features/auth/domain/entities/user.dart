import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, name, lastLoginAt];
}
