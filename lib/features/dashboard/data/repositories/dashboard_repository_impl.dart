import 'package:injectable/injectable.dart';

import '../../domain/entities/dashboard_widget.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_widget_model.dart';

/// Implementation of [DashboardRepository].
/// Handles cache-first data access strategy as an implementation detail.
@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<DashboardWidget>> getWidgets() async {
    // Cache-first strategy: return local if available, otherwise fetch remote
    if (await localDataSource.hasWidgets()) {
      final models = await localDataSource.getWidgets();
      return models.map((m) => m.toEntity()).toList();
    }

    // Fetch from remote and cache locally
    final models = await remoteDataSource.fetchWidgets();
    await localDataSource.saveWidgets(models);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveWidgets(List<DashboardWidget> widgets) async {
    final models =
        widgets.map((w) => DashboardWidgetModel.fromEntity(w)).toList();
    await localDataSource.saveWidgets(models);
  }

  @override
  Future<void> clearWidgets() async {
    await localDataSource.clearWidgets();
  }
}
