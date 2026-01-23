import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';

void main() {
  final testDateTime = DateTime(2024, 1, 15, 10, 30);

  final testUserModel = UserModel(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    lastLoginAt: testDateTime,
  );

  final testMap = {
    'id': 'user-123',
    'email': 'test@example.com',
    'name': 'Test User',
    'last_login_at': '2024-01-15T10:30:00.000',
  };

  group('UserModel', () {
    test('should be a subclass of User', () {
      expect(testUserModel, isA<User>());
    });

    test('should create model with all properties', () {
      expect(testUserModel.id, 'user-123');
      expect(testUserModel.email, 'test@example.com');
      expect(testUserModel.name, 'Test User');
      expect(testUserModel.lastLoginAt, testDateTime);
    });

    group('fromMap', () {
      test('should create model from valid map', () {
        final model = UserModel.fromMap(testMap);

        expect(model.id, 'user-123');
        expect(model.email, 'test@example.com');
        expect(model.name, 'Test User');
        expect(model.lastLoginAt.year, 2024);
        expect(model.lastLoginAt.month, 1);
        expect(model.lastLoginAt.day, 15);
      });

      test('should parse lastLoginAt correctly', () {
        final map = {
          'id': 'user-1',
          'email': 'a@b.com',
          'name': 'Name',
          'last_login_at': '2023-06-20T14:45:30.000',
        };

        final model = UserModel.fromMap(map);

        expect(model.lastLoginAt.year, 2023);
        expect(model.lastLoginAt.month, 6);
        expect(model.lastLoginAt.day, 20);
        expect(model.lastLoginAt.hour, 14);
        expect(model.lastLoginAt.minute, 45);
      });
    });

    group('toMap', () {
      test('should convert model to map', () {
        final map = testUserModel.toMap();

        expect(map['id'], 'user-123');
        expect(map['email'], 'test@example.com');
        expect(map['name'], 'Test User');
        expect(map['last_login_at'], contains('2024-01-15'));
      });

      test('should produce map with correct keys', () {
        final map = testUserModel.toMap();

        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('email'), isTrue);
        expect(map.containsKey('name'), isTrue);
        expect(map.containsKey('last_login_at'), isTrue);
        expect(map.length, 4);
      });

      test('should format lastLoginAt as ISO8601', () {
        final map = testUserModel.toMap();

        expect(map['last_login_at'], isA<String>());
        // ISO8601 format contains T separator
        expect(map['last_login_at'], contains('T'));
      });
    });

    group('fromEntity', () {
      test('should create model from User entity', () {
        final user = User(
          id: 'entity-id',
          email: 'entity@test.com',
          name: 'Entity Name',
          lastLoginAt: testDateTime,
        );

        final model = UserModel.fromEntity(user);

        expect(model.id, user.id);
        expect(model.email, user.email);
        expect(model.name, user.name);
        expect(model.lastLoginAt, user.lastLoginAt);
      });

      test('should preserve all properties from entity', () {
        final user = User(
          id: 'preserve-test',
          email: 'preserve@example.com',
          name: 'Preserve Test',
          lastLoginAt: DateTime(2025, 12, 31, 23, 59, 59),
        );

        final model = UserModel.fromEntity(user);

        expect(model.id, 'preserve-test');
        expect(model.email, 'preserve@example.com');
        expect(model.name, 'Preserve Test');
        expect(model.lastLoginAt.year, 2025);
        expect(model.lastLoginAt.month, 12);
        expect(model.lastLoginAt.day, 31);
      });
    });

    group('round-trip conversion', () {
      test('toMap then fromMap should preserve data', () {
        final map = testUserModel.toMap();
        final restored = UserModel.fromMap(map);

        expect(restored.id, testUserModel.id);
        expect(restored.email, testUserModel.email);
        expect(restored.name, testUserModel.name);
        // DateTime comparison within same minute
        expect(restored.lastLoginAt.year, testUserModel.lastLoginAt.year);
        expect(restored.lastLoginAt.month, testUserModel.lastLoginAt.month);
        expect(restored.lastLoginAt.day, testUserModel.lastLoginAt.day);
      });
    });
  });
}
