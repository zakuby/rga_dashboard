import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'base_response.dart';

/// Loads and parses JSON from asset files.
abstract class JsonAssetLoader {
  /// Loads a JSON asset and parses it as [BaseResponse].
  Future<BaseResponse<Map<String, dynamic>>> load(String assetPath);
}

@LazySingleton(as: JsonAssetLoader)
class JsonAssetLoaderImpl implements JsonAssetLoader {
  @override
  Future<BaseResponse<Map<String, dynamic>>> load(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;

    return BaseResponse<Map<String, dynamic>>.fromJson(
      jsonData,
      (data) => data as Map<String, dynamic>,
    );
  }
}
