import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_widget.dart';
import '../../domain/usecases/get_widgets_usecase.dart';
import '../../domain/usecases/reorder_widgets_usecase.dart';

part 'dashboard_state.dart';

/// Cubit managing dashboard state with optimistic UI updates.
class DashboardCubit extends Cubit<DashboardState> {
  final GetWidgetsUseCase _getWidgetsUseCase;
  final ReorderWidgetsUseCase _reorderWidgetsUseCase;

  DashboardCubit({
    required GetWidgetsUseCase getWidgetsUseCase,
    required ReorderWidgetsUseCase reorderWidgetsUseCase,
  }) : _getWidgetsUseCase = getWidgetsUseCase,
       _reorderWidgetsUseCase = reorderWidgetsUseCase,
       super(const DashboardState.initial());

  /// Loads dashboard widgets.
  Future<void> loadWidgets() async {
    emit(const DashboardState.loading());

    final result = await _getWidgetsUseCase();

    result.fold(
      onSuccess: (widgets) => emit(DashboardState.loaded(widgets)),
      onFailure: (failure) => emit(DashboardState.failure(failure.message)),
    );
  }

  /// Reorders widgets with optimistic UI update.
  Future<void> reorderWidgets(int oldIndex, int newIndex) async {
    final currentWidgets = List<DashboardWidget>.from(state.widgets);

    // Calculate new index accounting for removal
    var adjustedNewIndex = newIndex;
    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }

    // Optimistic UI update
    final widget = currentWidgets.removeAt(oldIndex);
    currentWidgets.insert(adjustedNewIndex, widget);

    // Update order values
    final reorderedWidgets = currentWidgets.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    // Emit optimistic state immediately for smooth 60fps feel
    emit(DashboardState.reordering(reorderedWidgets));

    // Persist in background
    final result = await _reorderWidgetsUseCase(
      ReorderParams(reorderedWidgets),
    );

    result.fold(
      onSuccess: (_) => emit(DashboardState.loaded(reorderedWidgets)),
      onFailure: (failure) {
        // Revert to original order on failure
        emit(DashboardState.loaded(state.widgets));
      },
    );
  }

  /// Resets widgets (reloads from storage).
  Future<void> resetWidgets() async {
    await loadWidgets();
  }
}
