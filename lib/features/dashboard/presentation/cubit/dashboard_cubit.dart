import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/dashboard_widget.dart';
import '../../domain/usecases/get_widgets_usecase.dart';
import '../../domain/usecases/reorder_widgets_usecase.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

/// Cubit managing dashboard state with optimistic UI updates.
///
/// This cubit handles ONLY presentation concerns:
/// - Loading state management
/// - Optimistic UI updates for smooth 60fps feel
/// - Error handling with rollback
///
/// All business logic (reordering algorithm, position calculation)
/// is delegated to use cases in the domain layer.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetWidgetsUseCase _getWidgetsUseCase;
  final ReorderWidgetsUseCase _reorderWidgetsUseCase;

  DashboardCubit({
    required GetWidgetsUseCase getWidgetsUseCase,
    required ReorderWidgetsUseCase reorderWidgetsUseCase,
  }) : _getWidgetsUseCase = getWidgetsUseCase,
       _reorderWidgetsUseCase = reorderWidgetsUseCase,
       super(DashboardState.initial());

  /// Loads dashboard widgets.
  Future<void> loadWidgets() async {
    emit(DashboardState.loading());

    final result = await _getWidgetsUseCase();

    result.fold(
      onSuccess: (widgets) => emit(DashboardState.loaded(widgets)),
      onFailure: (failure) => emit(DashboardState.failure(failure.message)),
    );
  }

  /// Reorders widgets with optimistic UI update.
  ///
  /// UI CONCERN: Shows immediate visual feedback by reordering the list.
  /// BUSINESS LOGIC: Delegated to [ReorderWidgetsUseCase] which handles
  /// index adjustment, position assignment, and persistence.
  Future<void> reorderWidgets(int oldIndex, int newIndex) async {
    // Store original state for potential rollback
    final originalWidgets = state.widgets;

    // === UI CONCERN: Optimistic preview ===
    // Create a quick visual preview by simply moving the item in the list.
    // This is purely for immediate UI feedback (60fps feel).
    // Note: We use the same algorithm here for preview consistency,
    // but the authoritative result comes from the use case.
    final previewWidgets = List<DashboardWidget>.from(originalWidgets);
    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final widget = previewWidgets.removeAt(oldIndex);
    previewWidgets.insert(adjustedIndex, widget);

    // Emit optimistic state immediately for smooth 60fps feel
    emit(DashboardState.reordering(previewWidgets));

    // === DELEGATE TO USE CASE: All business logic ===
    // The use case handles: index adjustment, position assignment, persistence
    final result = await _reorderWidgetsUseCase(
      ReorderParams(
        widgets: originalWidgets,
        oldIndex: oldIndex,
        newIndex: newIndex,
      ),
    );

    // === UI CONCERN: Handle result ===
    result.fold(
      onSuccess: (reorderedWidgets) {
        // Use the authoritative result from use case
        emit(DashboardState.loaded(reorderedWidgets));
      },
      onFailure: (failure) {
        // Rollback to original order on failure
        emit(DashboardState.loaded(originalWidgets));
      },
    );
  }

  /// Resets widgets (reloads from storage).
  Future<void> resetWidgets() async {
    await loadWidgets();
  }
}
