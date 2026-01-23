import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for retrieving dashboard widgets.
class GetWidgetsUseCase implements UseCaseNoParams<List<DashboardWidget>> {
  final DashboardRepository repository;

  const GetWidgetsUseCase(this.repository);

  @override
  Future<Result<List<DashboardWidget>>> call() async {
    return repository.getWidgets();
  }
}
