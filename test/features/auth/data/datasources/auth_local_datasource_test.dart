import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/database/database_helper.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late Database testDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    testDb = await databaseFactoryFfi.openDatabase(
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
    dataSource = AuthLocalDataSourceImpl();
  });

  tearDown(() async {
    await testDb.close();
    DatabaseHelper.resetDatabase();
  });

  final testUser = UserModel(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: DateTime(2024, 1, 1),
  );

  group('AuthLocalDataSourceImpl', () {
    group('cacheUser', () {
      test('should cache user successfully', () async {
        await dataSource.cacheUser(testUser);

        final result = await testDb.query(DatabaseHelper.tableUsers);
        expect(result.length, 1);
        expect(result.first['email'], 'test@example.com');
      });

      test('should replace existing user on cache', () async {
        await dataSource.cacheUser(testUser);

        final updatedUser = UserModel(
          id: 'user-123',
          email: 'updated@example.com',
          name: 'Updated User',
          lastLoginAt: DateTime(2024, 2, 1),
        );
        await dataSource.cacheUser(updatedUser);

        final result = await testDb.query(DatabaseHelper.tableUsers);
        expect(result.length, 1);
        expect(result.first['email'], 'updated@example.com');
      });
    });

    group('getCachedUser', () {
      test('should return cached user when exists', () async {
        await dataSource.cacheUser(testUser);

        final result = await dataSource.getCachedUser();

        expect(result, isNotNull);
        expect(result!.id, 'user-123');
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');
      });

      test('should return null when no user cached', () async {
        final result = await dataSource.getCachedUser();

        expect(result, isNull);
      });
    });

    group('clearCache', () {
      test('should clear cached user', () async {
        await dataSource.cacheUser(testUser);
        expect(await dataSource.hasUser(), isTrue);

        await dataSource.clearCache();

        expect(await dataSource.hasUser(), isFalse);
      });

      test('should not throw when clearing empty cache', () async {
        await expectLater(dataSource.clearCache(), completes);
      });
    });

    group('hasUser', () {
      test('should return true when user exists', () async {
        await dataSource.cacheUser(testUser);

        final result = await dataSource.hasUser();

        expect(result, isTrue);
      });

      test('should return false when no user exists', () async {
        final result = await dataSource.hasUser();

        expect(result, isFalse);
      });
    });
  });
}
