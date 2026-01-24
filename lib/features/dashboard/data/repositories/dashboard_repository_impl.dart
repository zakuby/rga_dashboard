import 'package:injectable/injectable.dart';

import '../../domain/entities/dashboard_widget.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_widget_model.dart';

/// Implementation of [DashboardRepository].
/// Thin data access layer - delegates to data sources.
@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<DashboardWidget>> fetchRemoteWidgets() async {
    final models = await remoteDataSource.fetchWidgets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DashboardWidget>> getLocalWidgets() async {
    final models = await localDataSource.getWidgets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveWidgets(List<DashboardWidget> widgets) async {
    final models = widgets
        .map((w) => DashboardWidgetModel.fromEntity(w))
        .toList();
    await localDataSource.saveWidgets(models);
  }

  @override
  Future<void> clearWidgets() async {
    await localDataSource.clearWidgets();
  }

  @override
  Future<bool> hasLocalWidgets() async {
    return localDataSource.hasWidgets();
  }
}
