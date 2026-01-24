import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for retrieving dashboard widgets.
/// Implements local-first caching: returns cached widgets if available,
/// otherwise fetches from remote and caches locally.
@lazySingleton
class GetWidgetsUseCase implements UseCaseNoParams<List<DashboardWidget>> {
  final DashboardRepository repository;

  const GetWidgetsUseCase(this.repository);

  @override
  Future<Result<List<DashboardWidget>>> call() async {
    try {
      final hasLocal = await repository.hasLocalWidgets();

      if (hasLocal) {
        // Return cached widgets (preserves user's order)
        final widgets = await repository.getLocalWidgets();
        return Success(widgets);
      }

      // Fetch from remote and cache locally
      final widgets = await repository.fetchRemoteWidgets();
      await repository.saveWidgets(widgets);
      return Success(widgets);
    } catch (e) {
      return Failure(
        'Failed to load widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}
