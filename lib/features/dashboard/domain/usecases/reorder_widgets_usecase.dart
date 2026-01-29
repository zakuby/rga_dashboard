import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

part 'reorder_widgets_usecase.freezed.dart';

/// Use case for reordering dashboard widgets.
///
/// This use case contains ALL business logic for reordering:
/// - Index adjustment algorithm (handling removal offset)
/// - List reordering operation
/// - Position value assignment
/// - Persistence to repository
///
/// The presentation layer should only pass raw indices and let this
/// use case handle the actual reordering logic.
@lazySingleton
class ReorderWidgetsUseCase
    implements UseCase<List<DashboardWidget>, ReorderParams> {
  final DashboardRepository repository;

  const ReorderWidgetsUseCase(this.repository);

  @override
  Future<Result<List<DashboardWidget>>> call(ReorderParams params) async {
    try {
      // === BUSINESS LOGIC: Index adjustment ===
      // When moving an item forward in a list, removing it shifts
      // all subsequent items down by 1, so we adjust the target index.
      var adjustedNewIndex = params.newIndex;
      if (params.oldIndex < params.newIndex) {
        adjustedNewIndex -= 1;
      }

      // === BUSINESS LOGIC: List reordering ===
      final widgets = List<DashboardWidget>.from(params.widgets);
      final widget = widgets.removeAt(params.oldIndex);
      widgets.insert(adjustedNewIndex, widget);

      // === BUSINESS LOGIC: Position assignment ===
      // Each widget's position field must match its index in the list
      // for correct ordering when loaded from persistence.
      final reorderedWidgets = widgets.asMap().entries.map((entry) {
        return entry.value.copyWith(position: entry.key);
      }).toList();

      // === DATA OPERATION: Persist to repository ===
      await repository.saveWidgets(reorderedWidgets);

      return Success(reorderedWidgets);
    } catch (e) {
      return Failure(
        'Failed to save widget order: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}

/// Parameters for reordering widgets.
///
/// Contains the raw inputs needed for reordering:
/// - [widgets]: The current list of widgets before reordering
/// - [oldIndex]: The original position of the widget being moved
/// - [newIndex]: The target position (before removal adjustment)
@freezed
class ReorderParams with _$ReorderParams {
  const factory ReorderParams({
    required List<DashboardWidget> widgets,
    required int oldIndex,
    required int newIndex,
  }) = _ReorderParams;
}
