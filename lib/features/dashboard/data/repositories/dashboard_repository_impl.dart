import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard_widget.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_widget_model.dart';

/// Implementation of [DashboardRepository].
/// Uses local storage for persistence and remote source for initial data fetch.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<DashboardWidget>>> getWidgets() async {
    try {
      final hasLocalWidgets = await localDataSource.hasWidgets();

      if (!hasLocalWidgets) {
        // Fetch from remote and cache locally
        final remoteWidgets = await remoteDataSource.fetchWidgets();
        await localDataSource.saveWidgets(remoteWidgets);
        return Success(remoteWidgets.map((e) => e.toEntity()).toList());
      }

      // Return cached local widgets (preserves user's order)
      final widgets = await localDataSource.getWidgets();
      return Success(widgets.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Failure(
        'Failed to load widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }

  @override
  Future<Result<bool>> saveWidgetOrder(List<DashboardWidget> widgets) async {
    try {
      final models = widgets
          .map((e) => DashboardWidgetModel.fromEntity(e))
          .toList();
      await localDataSource.saveWidgets(models);
      return const Success(true);
    } catch (e) {
      return Failure(
        'Failed to save widget order: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }

  @override
  Future<Result<DashboardWidget>> updateWidget(DashboardWidget widget) async {
    try {
      final widgets = await localDataSource.getWidgets();
      final index = widgets.indexWhere((w) => w.id == widget.id);

      if (index == -1) {
        return const Failure('Widget not found', type: FailureType.cache);
      }

      widgets[index] = DashboardWidgetModel.fromEntity(widget);
      await localDataSource.saveWidgets(widgets);
      return Success(widget);
    } catch (e) {
      return Failure(
        'Failed to update widget: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }

  @override
  Future<Result<List<DashboardWidget>>> resetToDefaults() async {
    try {
      await localDataSource.clearWidgets();
      // Fetch fresh data from remote
      final remoteWidgets = await remoteDataSource.fetchWidgets();
      await localDataSource.saveWidgets(remoteWidgets);
      return Success(remoteWidgets.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Failure(
        'Failed to reset widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}
