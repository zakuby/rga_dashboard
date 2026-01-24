import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

/// Key for storing current user ID in SharedPreferences.
const String currentUserIdKey = 'current_user_id';

/// Local data source for authentication using SQLite and SharedPreferences.
abstract class AuthLocalDataSource {
  /// Caches the authenticated user and saves their ID as current user.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the cached user by current user ID.
  Future<UserModel?> getCachedUser();

  /// Clears the current user ID and removes user from database.
  Future<void> clearCache();

  /// Checks if a current user ID is saved.
  Future<bool> hasUser();
}

/// Implementation of [AuthLocalDataSource] using SQLite and SharedPreferences.
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheUser(UserModel user) async {
    final db = await DatabaseHelper.database;

    // Save user to database
    await db.insert(
      DatabaseHelper.tableUsers,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save current user ID to SharedPreferences
    await _prefs.setString(currentUserIdKey, user.id);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    // Get current user ID from SharedPreferences
    final userId = _prefs.getString(currentUserIdKey);
    if (userId == null || userId.isEmpty) {
      return null;
    }

    // Fetch user from database by ID
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserModel.fromJson(maps.first);
  }

  @override
  Future<void> clearCache() async {
    // Get current user ID before clearing
    final userId = _prefs.getString(currentUserIdKey);

    // Clear current user ID from SharedPreferences
    await _prefs.remove(currentUserIdKey);

    // Remove user from database if ID existed
    if (userId != null && userId.isNotEmpty) {
      final db = await DatabaseHelper.database;
      await db.delete(
        DatabaseHelper.tableUsers,
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  @override
  Future<bool> hasUser() async {
    final userId = _prefs.getString(currentUserIdKey);
    return userId != null && userId.isNotEmpty;
  }
}
