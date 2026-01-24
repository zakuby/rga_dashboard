import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rga_dashboard/core/network/network.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late JsonAssetLoaderImpl loader;

  const mockSuccessJson = '''
{
  "success": true,
  "data": {"key": "value"},
  "error": null
}
''';

  const mockErrorJson = '''
{
  "success": false,
  "data": null,
  "error": {"code": "ERROR", "message": "Something went wrong"}
}
''';

  setUp(() {
    loader = JsonAssetLoaderImpl();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final String key = utf8.decode(message!.buffer.asUint8List());
          if (key.contains('success')) {
            return ByteData.sublistView(
              Uint8List.fromList(utf8.encode(mockSuccessJson)),
            );
          } else if (key.contains('error')) {
            return ByteData.sublistView(
              Uint8List.fromList(utf8.encode(mockErrorJson)),
            );
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('JsonAssetLoaderImpl', () {
    test('should load and parse success response', () async {
      final response = await loader.load('assets/mock/success.json');

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!['key'], 'value');
      expect(response.error, isNull);
    });

    test('should load and parse error response', () async {
      final response = await loader.load('assets/mock/error.json');

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.error, isNotNull);
      expect(response.error!.code, 'ERROR');
      expect(response.error!.message, 'Something went wrong');
    });
  });
}
