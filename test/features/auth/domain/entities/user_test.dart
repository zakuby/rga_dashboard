import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30);

    test('should create User with required properties', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.lastLoginAt, testDateTime);
    });

    test('should support equality for same properties', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );
      final user2 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user1, equals(user2));
    });

    test('should not be equal when id differs', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );
      final user2 = User(
        id: '456',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('should not be equal when email differs', () {
      final user1 = User(
        id: '123',
        email: 'test1@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );
      final user2 = User(
        id: '123',
        email: 'test2@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('should not be equal when name differs', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'User One',
        lastLoginAt: testDateTime,
      );
      final user2 = User(
        id: '123',
        email: 'test@example.com',
        name: 'User Two',
        lastLoginAt: testDateTime,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('should not be equal when lastLoginAt differs', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: DateTime(2024, 1, 15),
      );
      final user2 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: DateTime(2024, 1, 16),
      );

      expect(user1, isNot(equals(user2)));
    });

    test('should have correct props for Equatable', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user.props, [
        '123',
        'test@example.com',
        'Test User',
        testDateTime,
      ]);
    });

    test('should have same hashCode for equal users', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );
      final user2 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        lastLoginAt: testDateTime,
      );

      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
