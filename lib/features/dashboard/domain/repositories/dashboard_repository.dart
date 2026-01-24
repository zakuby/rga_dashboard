import '../entities/dashboard_widget.dart';

/// Abstract repository defining dashboard data operations.
/// This is a thin data access layer - business logic belongs in use cases.
abstract class DashboardRepository {
  /// Fetches widgets from remote source.
  Future<List<DashboardWidget>> fetchRemoteWidgets();

  /// Gets widgets from local storage.
  Future<List<DashboardWidget>> getLocalWidgets();

  /// Saves widgets to local storage.
  Future<void> saveWidgets(List<DashboardWidget> widgets);

  /// Clears all widgets from local storage.
  Future<void> clearWidgets();

  /// Checks if widgets exist in local storage.
  Future<bool> hasLocalWidgets();
}
