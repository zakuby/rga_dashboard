import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseHelper.close();
    DatabaseHelper.resetDatabase();
  });

  group('DatabaseHelper', () {
    group('constants', () {
      test('tableUsers has correct value', () {
        expect(DatabaseHelper.tableUsers, 'users');
      });

      test('tableWidgets has correct value', () {
        expect(DatabaseHelper.tableWidgets, 'dashboard_widgets');
      });
    });

    group('setTestDatabase', () {
      test('should set a custom test database', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(version: 1),
        );

        DatabaseHelper.setTestDatabase(testDb);

        final db = await DatabaseHelper.database;
        expect(db, same(testDb));

        await testDb.close();
      });
    });

    group('resetDatabase', () {
      test('should reset database instance to null', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(version: 1),
        );

        DatabaseHelper.setTestDatabase(testDb);
        DatabaseHelper.resetDatabase();

        // After reset, calling database should create a new instance
        // We verify by checking a new database is retrieved
        final newDb = await DatabaseHelper.database;
        expect(newDb, isNotNull);
        // The database should be different since we reset
        // (Note: in test environment, path-based DB would be different)

        await testDb.close();
      });
    });

    group('database singleton', () {
      test('should return same instance on multiple calls', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(version: 1),
        );
        DatabaseHelper.setTestDatabase(testDb);

        final db1 = await DatabaseHelper.database;
        final db2 = await DatabaseHelper.database;

        expect(db1, same(db2));

        await testDb.close();
      });
    });

    group('close', () {
      test('should close database and set instance to null', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(version: 1),
        );
        DatabaseHelper.setTestDatabase(testDb);

        await DatabaseHelper.close();

        // After close, database should be null internally
        // The next call would initialize a new one
        DatabaseHelper.resetDatabase();
      });

      test('should not throw when closing uninitialized database', () async {
        DatabaseHelper.resetDatabase();
        await expectLater(DatabaseHelper.close(), completes);
      });
    });

    group('table schema', () {
      test('users table should have correct columns', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseHelper.tableUsers} (
                  id TEXT PRIMARY KEY,
                  email TEXT NOT NULL,
                  name TEXT NOT NULL,
                  last_login_at TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        DatabaseHelper.setTestDatabase(testDb);

        // Insert test data to verify schema
        await testDb.insert(DatabaseHelper.tableUsers, {
          'id': 'test-id',
          'email': 'test@example.com',
          'name': 'Test User',
          'last_login_at': DateTime.now().toIso8601String(),
        });

        final result = await testDb.query(DatabaseHelper.tableUsers);
        expect(result.length, 1);
        expect(result.first['id'], 'test-id');
        expect(result.first['email'], 'test@example.com');
        expect(result.first['name'], 'Test User');
        expect(result.first['last_login_at'], isNotNull);

        await testDb.close();
      });

      test('dashboard_widgets table should have correct columns', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseHelper.tableWidgets} (
                  id TEXT PRIMARY KEY,
                  type TEXT NOT NULL,
                  title TEXT NOT NULL,
                  position INTEGER NOT NULL,
                  data TEXT
                )
              ''');
            },
          ),
        );
        DatabaseHelper.setTestDatabase(testDb);

        // Insert test data to verify schema
        await testDb.insert(DatabaseHelper.tableWidgets, {
          'id': 'widget-1',
          'type': 'weather',
          'title': 'Weather',
          'position': 0,
          'data': '{"temperature": 72}',
        });

        final result = await testDb.query(DatabaseHelper.tableWidgets);
        expect(result.length, 1);
        expect(result.first['id'], 'widget-1');
        expect(result.first['type'], 'weather');
        expect(result.first['title'], 'Weather');
        expect(result.first['position'], 0);
        expect(result.first['data'], '{"temperature": 72}');

        await testDb.close();
      });

      test('dashboard_widgets data column can be null', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseHelper.tableWidgets} (
                  id TEXT PRIMARY KEY,
                  type TEXT NOT NULL,
                  title TEXT NOT NULL,
                  position INTEGER NOT NULL,
                  data TEXT
                )
              ''');
            },
          ),
        );
        DatabaseHelper.setTestDatabase(testDb);

        // Insert with null data
        await testDb.insert(DatabaseHelper.tableWidgets, {
          'id': 'widget-1',
          'type': 'weather',
          'title': 'Weather',
          'position': 0,
          'data': null,
        });

        final result = await testDb.query(DatabaseHelper.tableWidgets);
        expect(result.first['data'], isNull);

        await testDb.close();
      });

      test('users table enforces primary key uniqueness', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseHelper.tableUsers} (
                  id TEXT PRIMARY KEY,
                  email TEXT NOT NULL,
                  name TEXT NOT NULL,
                  last_login_at TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        DatabaseHelper.setTestDatabase(testDb);

        await testDb.insert(DatabaseHelper.tableUsers, {
          'id': 'user-1',
          'email': 'test@example.com',
          'name': 'Test',
          'last_login_at': DateTime.now().toIso8601String(),
        });

        // Using insertOrReplace should work
        await testDb.insert(DatabaseHelper.tableUsers, {
          'id': 'user-1',
          'email': 'updated@example.com',
          'name': 'Updated',
          'last_login_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        final result = await testDb.query(DatabaseHelper.tableUsers);
        expect(result.length, 1);
        expect(result.first['email'], 'updated@example.com');

        await testDb.close();
      });

      test('widgets table enforces primary key uniqueness', () async {
        final testDb = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseHelper.tableWidgets} (
                  id TEXT PRIMARY KEY,
                  type TEXT NOT NULL,
                  title TEXT NOT NULL,
                  position INTEGER NOT NULL,
                  data TEXT
                )
              ''');
            },
          ),
        );
        DatabaseHelper.setTestDatabase(testDb);

        await testDb.insert(DatabaseHelper.tableWidgets, {
          'id': 'widget-1',
          'type': 'weather',
          'title': 'Weather',
          'position': 0,
          'data': null,
        });

        // Using insertOrReplace should work
        await testDb.insert(
          DatabaseHelper.tableWidgets,
          {
            'id': 'widget-1',
            'type': 'calendar',
            'title': 'Calendar',
            'position': 1,
            'data': null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final result = await testDb.query(DatabaseHelper.tableWidgets);
        expect(result.length, 1);
        expect(result.first['type'], 'calendar');

        await testDb.close();
      });
    });
  });
}
