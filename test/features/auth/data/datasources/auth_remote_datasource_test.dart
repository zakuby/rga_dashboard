import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/error/exceptions.dart';
import 'package:rga_dashboard/core/network/network.dart';
import 'package:rga_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rga_dashboard/features/auth/data/models/user_model.dart';

class MockJsonAssetLoader extends Mock implements JsonAssetLoader {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockJsonAssetLoader mockJsonLoader;

  final successData = {
    'user': {
      'id': 'user_12345',
      'email': 'test@example.com',
      'name': 'Test User',
      'last_login_at': '2024-01-24T10:30:00.000Z',
    },
  };

  final errorResponse = const BaseResponse<Map<String, dynamic>>(
    success: false,
    error: ErrorResponse(
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password. Please try again.',
    ),
  );

  setUp(() {
    mockJsonLoader = MockJsonAssetLoader();
    dataSource = AuthRemoteDataSourceImpl(mockJsonLoader);
  });

  group('AuthRemoteDataSourceImpl', () {
    group('login', () {
      test('should return UserModel with valid credentials', () async {
        when(() => mockJsonLoader.load(any())).thenAnswer(
          (_) async => BaseResponse(success: true, data: successData),
        );

        final result = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');
        expect(result.id, 'user_12345');
        expect(result.lastLoginAt, isNotNull);
        verify(
          () => mockJsonLoader.load('assets/mock/auth_login_success.json'),
        ).called(1);
      });

      test('should throw AuthenticationException for invalid email', () async {
        when(
          () => mockJsonLoader.load(any()),
        ).thenAnswer((_) async => errorResponse);

        await expectLater(
          () => dataSource.login(
            email: 'wrong@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthenticationException>()),
        );
        verify(
          () => mockJsonLoader.load('assets/mock/auth_login_error.json'),
        ).called(1);
      });

      test(
        'should throw AuthenticationException for invalid password',
        () async {
          when(
            () => mockJsonLoader.load(any()),
          ).thenAnswer((_) async => errorResponse);

          expect(
            () => dataSource.login(
              email: 'test@example.com',
              password: 'wrongpassword',
            ),
            throwsA(isA<AuthenticationException>()),
          );
        },
      );

      test('should throw AuthenticationException for both invalid', () async {
        when(
          () => mockJsonLoader.load(any()),
        ).thenAnswer((_) async => errorResponse);

        expect(
          () => dataSource.login(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should be case insensitive for email', () async {
        when(() => mockJsonLoader.load(any())).thenAnswer(
          (_) async => BaseResponse(success: true, data: successData),
        );

        final result = await dataSource.login(
          email: 'TEST@EXAMPLE.COM',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
        verify(
          () => mockJsonLoader.load('assets/mock/auth_login_success.json'),
        ).called(1);
      });

      test('should parse lastLoginAt from response', () async {
        when(() => mockJsonLoader.load(any())).thenAnswer(
          (_) async => BaseResponse(success: true, data: successData),
        );

        final result = await dataSource.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.lastLoginAt, isNotNull);
        expect(result.lastLoginAt!.year, 2024);
        expect(result.lastLoginAt!.month, 1);
        expect(result.lastLoginAt!.day, 24);
      });

      test('should return error message from response', () async {
        when(
          () => mockJsonLoader.load(any()),
        ).thenAnswer((_) async => errorResponse);

        try {
          await dataSource.login(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          );
          fail('Should have thrown AuthenticationException');
        } on AuthenticationException catch (e) {
          expect(e.message, contains('Invalid email or password'));
        }
      });

      test(
        'should throw TimeoutException for timeout email',
        () async {
          expect(
            () => dataSource.login(
              email: 'timeout@example.com',
              password: 'password123',
            ),
            throwsA(isA<TimeoutException>()),
          );
        },
        timeout: const Timeout(Duration(seconds: 10)),
      );
    });
  });
}
