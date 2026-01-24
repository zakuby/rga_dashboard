import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for resetting dashboard widgets to defaults.
/// Clears local cache and fetches fresh data from remote.
@lazySingleton
class ResetWidgetsUseCase implements UseCaseNoParams<List<DashboardWidget>> {
  final DashboardRepository repository;

  const ResetWidgetsUseCase(this.repository);

  @override
  Future<Result<List<DashboardWidget>>> call() async {
    try {
      // Clear local cache
      await repository.clearWidgets();

      // Fetch fresh data from remote
      final widgets = await repository.fetchRemoteWidgets();

      // Cache the fresh data
      await repository.saveWidgets(widgets);

      return Success(widgets);
    } catch (e) {
      return Failure(
        'Failed to reset widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}
