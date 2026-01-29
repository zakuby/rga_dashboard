import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for retrieving dashboard widgets.
/// Delegates to repository which handles caching strategy.
@lazySingleton
class GetWidgetsUseCase implements UseCaseNoParams<List<DashboardWidget>> {
  final DashboardRepository repository;

  const GetWidgetsUseCase(this.repository);

  @override
  Future<Result<List<DashboardWidget>>> call() async {
    try {
      final widgets = await repository.getWidgets();
      return Success(widgets);
    } catch (e) {
      return Failure(
        'Failed to load widgets: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}
