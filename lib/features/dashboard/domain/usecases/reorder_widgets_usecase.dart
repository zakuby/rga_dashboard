import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

part 'reorder_widgets_usecase.freezed.dart';

/// Use case for reordering dashboard widgets.
@lazySingleton
class ReorderWidgetsUseCase implements UseCase<bool, ReorderParams> {
  final DashboardRepository repository;

  const ReorderWidgetsUseCase(this.repository);

  @override
  Future<Result<bool>> call(ReorderParams params) async {
    // Update order values based on new positions
    final reorderedWidgets = <DashboardWidget>[];
    for (var i = 0; i < params.widgets.length; i++) {
      reorderedWidgets.add(params.widgets[i].copyWith(position: i));
    }
    return repository.saveWidgetOrder(reorderedWidgets);
  }
}

/// Parameters for reordering widgets.
@freezed
class ReorderParams with _$ReorderParams {
  const factory ReorderParams(List<DashboardWidget> widgets) = _ReorderParams;
}
