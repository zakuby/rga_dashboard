import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    dataSource = AuthRemoteDataSourceImpl();
  });

  group('AuthRemoteDataSourceImpl', () {
    group('login', () {
      test('should return UserModel with valid credentials', () async {
        final result = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
        expect(result.email, 'test@example.com');
        expect(result.name, isNotEmpty);
        expect(result.id, isNotEmpty);
        expect(result.lastLoginAt, isNotNull);
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should extract name from email correctly', () async {
        final result = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // "test" should become "Test"
        expect(result.name, 'Test');
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should throw AuthenticationException for invalid email',
          () async {
        expect(
          () => dataSource.login(
            email: 'wrong@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should throw AuthenticationException for invalid password',
          () async {
        expect(
          () => dataSource.login(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should throw AuthenticationException for both invalid', () async {
        expect(
          () => dataSource.login(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should be case insensitive for email', () async {
        final result = await dataSource.login(
          email: 'TEST@EXAMPLE.COM',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should generate unique user id', () async {
        final result1 = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        final result2 = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result1.id, isNot(result2.id));
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should set lastLoginAt to current time', () async {
        final before = DateTime.now();

        final result = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        final after = DateTime.now();

        expect(result.lastLoginAt.isAfter(before.subtract(const Duration(seconds: 5))), isTrue);
        expect(result.lastLoginAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      }, timeout: const Timeout(Duration(seconds: 10)));
    });
  });
}
