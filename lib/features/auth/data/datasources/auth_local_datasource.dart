import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

/// Local data source for authentication using SQLite.
abstract class AuthLocalDataSource {
  /// Caches the authenticated user.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the cached user.
  Future<UserModel?> getCachedUser();

  /// Clears the cached user.
  Future<void> clearCache();

  /// Checks if a user is cached.
  Future<bool> hasUser();
}

/// Implementation of [AuthLocalDataSource] using SQLite.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUser(UserModel user) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      DatabaseHelper.tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(DatabaseHelper.tableUsers, limit: 1);

    if (maps.isEmpty) {
      return null;
    }

    return UserModel.fromMap(maps.first);
  }

  @override
  Future<void> clearCache() async {
    final db = await DatabaseHelper.database;
    await db.delete(DatabaseHelper.tableUsers);
  }

  @override
  Future<bool> hasUser() async {
    final db = await DatabaseHelper.database;
    final result = await db.query(DatabaseHelper.tableUsers, limit: 1);
    return result.isNotEmpty;
  }
}
