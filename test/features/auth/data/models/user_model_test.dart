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

  final testJson = {
    'id': 'user-123',
    'email': 'test@example.com',
    'name': 'Test User',
    'last_login_at': '2024-01-15T10:30:00.000',
  };

  group('UserModel', () {
    test('should create model with all properties', () {
      expect(testUserModel.id, 'user-123');
      expect(testUserModel.email, 'test@example.com');
      expect(testUserModel.name, 'Test User');
      expect(testUserModel.lastLoginAt, testDateTime);
    });

    test('should have default values for optional fields', () {
      const model = UserModel();

      expect(model.id, '');
      expect(model.email, '');
      expect(model.name, '');
      expect(model.lastLoginAt, isNull);
    });

    group('fromJson', () {
      test('should create model from valid json', () {
        final model = UserModel.fromJson(testJson);

        expect(model.id, 'user-123');
        expect(model.email, 'test@example.com');
        expect(model.name, 'Test User');
        expect(model.lastLoginAt, isNotNull);
        expect(model.lastLoginAt!.year, 2024);
        expect(model.lastLoginAt!.month, 1);
        expect(model.lastLoginAt!.day, 15);
      });

      test('should parse lastLoginAt correctly', () {
        final json = {
          'id': 'user-1',
          'email': 'a@b.com',
          'name': 'Name',
          'last_login_at': '2023-06-20T14:45:30.000',
        };

        final model = UserModel.fromJson(json);

        expect(model.lastLoginAt, isNotNull);
        expect(model.lastLoginAt!.year, 2023);
        expect(model.lastLoginAt!.month, 6);
        expect(model.lastLoginAt!.day, 20);
        expect(model.lastLoginAt!.hour, 14);
        expect(model.lastLoginAt!.minute, 45);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final model = UserModel.fromJson(json);

        expect(model.id, '');
        expect(model.email, '');
        expect(model.name, '');
        expect(model.lastLoginAt, isNull);
      });
    });

    group('toJson', () {
      test('should convert model to json', () {
        final json = testUserModel.toJson();

        expect(json['id'], 'user-123');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
        expect(json['last_login_at'], contains('2024-01-15'));
      });

      test('should produce json with correct keys', () {
        final json = testUserModel.toJson();

        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('email'), isTrue);
        expect(json.containsKey('name'), isTrue);
        expect(json.containsKey('last_login_at'), isTrue);
      });

      test('should format lastLoginAt as ISO8601', () {
        final json = testUserModel.toJson();

        expect(json['last_login_at'], isA<String>());
        expect(json['last_login_at'], contains('T'));
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
        expect(model.lastLoginAt, isNotNull);
        expect(model.lastLoginAt!.year, 2025);
        expect(model.lastLoginAt!.month, 12);
        expect(model.lastLoginAt!.day, 31);
      });
    });

    group('toEntity', () {
      test('should convert model to User entity', () {
        final entity = testUserModel.toEntity();

        expect(entity, isA<User>());
        expect(entity.id, testUserModel.id);
        expect(entity.email, testUserModel.email);
        expect(entity.name, testUserModel.name);
      });

      test('should use current time when lastLoginAt is null', () {
        const model = UserModel(id: 'test', email: 'a@b.com', name: 'Test');
        final before = DateTime.now();
        final entity = model.toEntity();
        final after = DateTime.now();

        expect(
          entity.lastLoginAt.isAfter(
            before.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          entity.lastLoginAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('round-trip conversion', () {
      test('toJson then fromJson should preserve data', () {
        final json = testUserModel.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.id, testUserModel.id);
        expect(restored.email, testUserModel.email);
        expect(restored.name, testUserModel.name);
        expect(restored.lastLoginAt, isNotNull);
        expect(restored.lastLoginAt!.year, testUserModel.lastLoginAt!.year);
        expect(restored.lastLoginAt!.month, testUserModel.lastLoginAt!.month);
        expect(restored.lastLoginAt!.day, testUserModel.lastLoginAt!.day);
      });

      test('fromEntity then toEntity should preserve data', () {
        final user = User(
          id: 'round-trip',
          email: 'roundtrip@test.com',
          name: 'Round Trip',
          lastLoginAt: testDateTime,
        );

        final model = UserModel.fromEntity(user);
        final restored = model.toEntity();

        expect(restored.id, user.id);
        expect(restored.email, user.email);
        expect(restored.name, user.name);
        expect(restored.lastLoginAt, user.lastLoginAt);
      });
    });
  });
}
