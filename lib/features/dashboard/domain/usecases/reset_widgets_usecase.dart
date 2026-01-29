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
      // Clear local cache first
      await repository.clearWidgets();

      // getWidgets() will fetch from remote since local cache is now empty
      // and will cache the fresh data automatically
      final widgets = await repository.getWidgets();

      return Success(widgets);
    } catch (e) {
      return Failure(
        'Failed to reset widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}
