import '../entities/dashboard_widget.dart';

/// Abstract repository defining dashboard data operations.
/// The repository handles data access strategy (caching, remote fetching)
/// as an implementation detail hidden from the domain layer.
abstract class DashboardRepository {
  /// Gets dashboard widgets using cache-first strategy.
  /// Returns cached widgets if available, otherwise fetches from remote.
  Future<List<DashboardWidget>> getWidgets();

  /// Saves widgets to local storage.
  Future<void> saveWidgets(List<DashboardWidget> widgets);

  /// Clears all widgets from local storage.
  Future<void> clearWidgets();
}
