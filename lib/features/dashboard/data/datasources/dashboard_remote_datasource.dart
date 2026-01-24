import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network.dart';
import '../models/dashboard_widget_model.dart';

/// Remote data source for dashboard widgets.
/// Simulates fetching data from a backend API using JSON asset files.
abstract class DashboardRemoteDataSource {
  /// Fetches dashboard widgets from the remote source (mock JSON).
  Future<List<DashboardWidgetModel>> fetchWidgets();
}

/// Implementation using JSON asset files to simulate API responses.
@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final JsonAssetLoader _jsonLoader;

  static const String _dashboardSuccessPath =
      'assets/mock/dashboard_success.json';

  DashboardRemoteDataSourceImpl(this._jsonLoader);

  @override
  Future<List<DashboardWidgetModel>> fetchWidgets() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final response = await _jsonLoader.load(_dashboardSuccessPath);

    if (!response.success || response.data == null) {
      throw ServerException(
        response.error?.message ?? 'Failed to fetch dashboard data',
      );
    }

    final widgetsJson = response.data!['widgets'] as List<dynamic>;
    return widgetsJson
        .map((w) => DashboardWidgetModel.fromJson(w as Map<String, dynamic>))
        .toList();
  }
}
