import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/network/network.dart';

void main() {
  group('BaseResponse', () {
    group('success response', () {
      test('should create from success JSON', () {
        final json = {
          'success': true,
          'data': {'id': '123', 'name': 'Test'},
          'error': null,
        };

        final response = BaseResponse<Map<String, dynamic>>.fromJson(
          json,
          (data) => data as Map<String, dynamic>,
        );

        expect(response.success, isTrue);
        expect(response.data, isNotNull);
        expect(response.data!['id'], '123');
        expect(response.error, isNull);
      });

      test('should have correct helper getters', () {
        const response = BaseResponse<String>(success: true, data: 'test data');

        expect(response.isError, isFalse);
        expect(response.hasData, isTrue);
        expect(response.hasError, isFalse);
      });
    });

    group('error response', () {
      test('should create from error JSON', () {
        final json = {
          'success': false,
          'data': null,
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid input provided',
          },
        };

        final response = BaseResponse<Map<String, dynamic>>.fromJson(
          json,
          (data) => data as Map<String, dynamic>,
        );

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.error, isNotNull);
        expect(response.error!.code, 'VALIDATION_ERROR');
        expect(response.error!.message, 'Invalid input provided');
      });

      test('should have correct helper getters', () {
        const response = BaseResponse<String>(
          success: false,
          error: ErrorResponse(code: 'ERROR', message: 'Something went wrong'),
        );

        expect(response.isError, isTrue);
        expect(response.hasData, isFalse);
        expect(response.hasError, isTrue);
      });
    });

    group('defaults', () {
      test('should have default values', () {
        const response = BaseResponse<String>();

        expect(response.success, isFalse);
        expect(response.data, isNull);
        expect(response.error, isNull);
      });
    });

    group('toJson', () {
      test('should convert success response to JSON', () {
        const response = BaseResponse<String>(success: true, data: 'test data');

        final json = response.toJson((data) => data);

        expect(json['success'], isTrue);
        expect(json['data'], 'test data');
        expect(json['error'], isNull);
      });

      test('should convert error response to JSON', () {
        const response = BaseResponse<String>(
          success: false,
          error: ErrorResponse(code: 'ERR', message: 'Error message'),
        );

        final json = response.toJson((data) => data);

        expect(json['success'], isFalse);
        expect(json['data'], isNull);
        expect(json['error'], isNotNull);
        expect((json['error'] as Map)['code'], 'ERR');
      });
    });
  });

  group('ErrorResponse', () {
    test('should create from JSON', () {
      final json = {'code': 'SERVER_ERROR', 'message': 'Internal server error'};

      final error = ErrorResponse.fromJson(json);

      expect(error.code, 'SERVER_ERROR');
      expect(error.message, 'Internal server error');
    });

    test('should have default values', () {
      const error = ErrorResponse();

      expect(error.code, '');
      expect(error.message, '');
    });

    test('should convert to JSON', () {
      const error = ErrorResponse(
        code: 'NOT_FOUND',
        message: 'Resource not found',
      );

      final json = error.toJson();

      expect(json['code'], 'NOT_FOUND');
      expect(json['message'], 'Resource not found');
    });
  });
}
