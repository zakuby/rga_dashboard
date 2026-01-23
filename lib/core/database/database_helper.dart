import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for the application.
class DatabaseHelper {
  static const _databaseName = 'rga_dashboard.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableUsers = 'users';
  static const tableWidgets = 'dashboard_widgets';

  // Singleton instance
  static Database? _database;

  /// Gets the database instance, initializing if needed.
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        last_login_at TEXT NOT NULL
      )
    ''');

    // Dashboard widgets table
    await db.execute('''
      CREATE TABLE $tableWidgets (
        id TEXT PRIMARY KEY,
        type_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        widget_order INTEGER NOT NULL,
        is_visible INTEGER NOT NULL DEFAULT 1,
        data TEXT
      )
    ''');
  }

  /// Closes the database connection.
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
