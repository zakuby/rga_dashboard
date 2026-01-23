import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for reordering dashboard widgets.
class ReorderWidgetsUseCase implements UseCase<bool, ReorderParams> {
  final DashboardRepository repository;

  const ReorderWidgetsUseCase(this.repository);

  @override
  Future<Result<bool>> call(ReorderParams params) async {
    // Update order values based on new positions
    final reorderedWidgets = <DashboardWidget>[];
    for (var i = 0; i < params.widgets.length; i++) {
      reorderedWidgets.add(params.widgets[i].copyWith(order: i));
    }
    return repository.saveWidgetOrder(reorderedWidgets);
  }
}

/// Parameters for reordering widgets.
class ReorderParams extends Equatable {
  final List<DashboardWidget> widgets;

  const ReorderParams(this.widgets);

  @override
  List<Object?> get props => [widgets];
}
