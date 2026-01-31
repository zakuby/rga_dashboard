import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_widget.dart';
import '../repositories/dashboard_repository.dart';

part 'update_widget_usecase.freezed.dart';

/// Use case for updating a single dashboard widget.
/// Finds the widget by ID and updates it in local storage.
@lazySingleton
class UpdateWidgetUseCase
    implements UseCase<DashboardWidget, UpdateWidgetParams> {
  final DashboardRepository repository;

  const UpdateWidgetUseCase(this.repository);

  @override
  Future<Result<DashboardWidget>> call(UpdateWidgetParams params) async {
    try {
      final widgets = await repository.getWidgets();
      final index = widgets.indexWhere((w) => w.id == params.widget.id);

      if (index == -1) {
        return const Failure('Widget not found', type: FailureType.cache);
      }

      // Replace widget at found index
      final updatedWidgets = List<DashboardWidget>.from(widgets);
      updatedWidgets[index] = params.widget;

      await repository.saveWidgets(updatedWidgets);
      return Success(params.widget);
    } catch (e) {
      return Failure(
        'Failed to update widget: ${e.toString()}',
        type: FailureType.cache,
      );
    }
  }
}

/// Parameters for updating a widget.
@freezed
class UpdateWidgetParams with _$UpdateWidgetParams {
  const factory UpdateWidgetParams(DashboardWidget widget) =
      _UpdateWidgetParams;
}
