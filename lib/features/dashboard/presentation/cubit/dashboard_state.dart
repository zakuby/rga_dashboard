part of 'dashboard_cubit.dart';

/// Status of dashboard operations.
enum DashboardStatus { initial, loading, loaded, reordering, failure }

/// State representing the current dashboard state.
final class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<DashboardWidget> widgets;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.widgets = const [],
    this.errorMessage,
  });

  const DashboardState.initial() : this();

  const DashboardState.loading() : this(status: DashboardStatus.loading);

  const DashboardState.loaded(List<DashboardWidget> widgets)
    : this(status: DashboardStatus.loaded, widgets: widgets);

  const DashboardState.reordering(List<DashboardWidget> widgets)
    : this(status: DashboardStatus.reordering, widgets: widgets);

  const DashboardState.failure(String message)
    : this(status: DashboardStatus.failure, errorMessage: message);

  DashboardState copyWith({
    DashboardStatus? status,
    List<DashboardWidget>? widgets,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      widgets: widgets ?? this.widgets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, widgets, errorMessage];
}
