import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/database/database_helper.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late Database testDb;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockPrefs = MockSharedPreferences();

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
    dataSource = AuthLocalDataSourceImpl(mockPrefs);
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
      test(
        'should cache user in database and save ID in SharedPreferences',
        () async {
          when(
            () => mockPrefs.setString(currentUserIdKey, testUser.id),
          ).thenAnswer((_) async => true);

          await dataSource.cacheUser(testUser);

          final result = await testDb.query(DatabaseHelper.tableUsers);
          expect(result.length, 1);
          expect(result.first['id'], 'user-123');
          expect(result.first['email'], 'test@example.com');
          verify(
            () => mockPrefs.setString(currentUserIdKey, 'user-123'),
          ).called(1);
        },
      );

      test('should replace existing user on cache', () async {
        when(
          () => mockPrefs.setString(currentUserIdKey, any()),
        ).thenAnswer((_) async => true);

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
      test(
        'should return cached user when ID exists in SharedPreferences',
        () async {
          when(
            () => mockPrefs.getString(currentUserIdKey),
          ).thenReturn('user-123');
          when(
            () => mockPrefs.setString(currentUserIdKey, any()),
          ).thenAnswer((_) async => true);

          // First cache the user
          await dataSource.cacheUser(testUser);

          final result = await dataSource.getCachedUser();

          expect(result, isNotNull);
          expect(result!.id, 'user-123');
          expect(result.email, 'test@example.com');
          expect(result.name, 'Test User');
        },
      );

      test('should return null when no user ID in SharedPreferences', () async {
        when(() => mockPrefs.getString(currentUserIdKey)).thenReturn(null);

        final result = await dataSource.getCachedUser();

        expect(result, isNull);
      });

      test('should return null when user ID is empty', () async {
        when(() => mockPrefs.getString(currentUserIdKey)).thenReturn('');

        final result = await dataSource.getCachedUser();

        expect(result, isNull);
      });

      test(
        'should return null when user ID exists but user not in database',
        () async {
          when(
            () => mockPrefs.getString(currentUserIdKey),
          ).thenReturn('non-existent-user');

          final result = await dataSource.getCachedUser();

          expect(result, isNull);
        },
      );
    });

    group('clearCache', () {
      test(
        'should clear user ID from SharedPreferences and delete from database',
        () async {
          when(
            () => mockPrefs.getString(currentUserIdKey),
          ).thenReturn('user-123');
          when(
            () => mockPrefs.setString(currentUserIdKey, any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockPrefs.remove(currentUserIdKey),
          ).thenAnswer((_) async => true);

          await dataSource.cacheUser(testUser);
          expect(await dataSource.hasUser(), isTrue);

          await dataSource.clearCache();

          verify(() => mockPrefs.remove(currentUserIdKey)).called(1);

          // Verify user is deleted from database
          final result = await testDb.query(
            DatabaseHelper.tableUsers,
            where: 'id = ?',
            whereArgs: ['user-123'],
          );
          expect(result.isEmpty, isTrue);
        },
      );

      test('should not throw when clearing with no user', () async {
        when(() => mockPrefs.getString(currentUserIdKey)).thenReturn(null);
        when(
          () => mockPrefs.remove(currentUserIdKey),
        ).thenAnswer((_) async => true);

        await expectLater(dataSource.clearCache(), completes);
      });
    });

    group('hasUser', () {
      test(
        'should return true when user ID exists in SharedPreferences',
        () async {
          when(
            () => mockPrefs.getString(currentUserIdKey),
          ).thenReturn('user-123');

          final result = await dataSource.hasUser();

          expect(result, isTrue);
        },
      );

      test(
        'should return false when no user ID in SharedPreferences',
        () async {
          when(() => mockPrefs.getString(currentUserIdKey)).thenReturn(null);

          final result = await dataSource.hasUser();

          expect(result, isFalse);
        },
      );

      test('should return false when user ID is empty', () async {
        when(() => mockPrefs.getString(currentUserIdKey)).thenReturn('');

        final result = await dataSource.hasUser();

        expect(result, isFalse);
      });
    });
  });
}
