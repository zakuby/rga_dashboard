part of 'dashboard_cubit.dart';

/// Status of dashboard operations.
enum DashboardStatus { initial, loading, loaded, reordering, failure }

/// State representing the current dashboard state.
@freezed
class DashboardState with _$DashboardState {
  const DashboardState._();

  const factory DashboardState({
    @Default(DashboardStatus.initial) DashboardStatus status,
    @Default([]) List<DashboardWidget> widgets,
    String? errorMessage,
  }) = _DashboardState;

  factory DashboardState.initial() => const DashboardState();

  factory DashboardState.loading() =>
      const DashboardState(status: DashboardStatus.loading);

  factory DashboardState.loaded(List<DashboardWidget> widgets) =>
      DashboardState(status: DashboardStatus.loaded, widgets: widgets);

  factory DashboardState.reordering(List<DashboardWidget> widgets) =>
      DashboardState(status: DashboardStatus.reordering, widgets: widgets);

  factory DashboardState.failure(String message) =>
      DashboardState(status: DashboardStatus.failure, errorMessage: message);
}
