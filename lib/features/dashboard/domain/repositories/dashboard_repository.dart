import '../../../../core/result/result.dart';
import '../entities/dashboard_widget.dart';

/// Abstract repository defining dashboard operations.
abstract class DashboardRepository {
  /// Gets all dashboard widgets sorted by order.
  Future<Result<List<DashboardWidget>>> getWidgets();

  /// Saves the widget order (after reordering).
  Future<Result<bool>> saveWidgetOrder(List<DashboardWidget> widgets);

  /// Updates a single widget.
  Future<Result<DashboardWidget>> updateWidget(DashboardWidget widget);

  /// Resets widgets to default configuration.
  Future<Result<List<DashboardWidget>>> resetToDefaults();
}
