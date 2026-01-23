import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/smart_widget_card.dart';

/// Main dashboard page with draggable widget grid.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state.status) {
            DashboardStatus.initial ||
            DashboardStatus.loading => const LoadingView(),
            DashboardStatus.failure => ErrorStateView(
              message: state.errorMessage ?? 'An error occurred',
              onRetry: () {
                context.read<DashboardCubit>().loadWidgets();
              },
            ),
            DashboardStatus.loaded ||
            DashboardStatus.reordering => _buildDashboardGrid(context, state),
          };
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: false,
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Row(
              children: [
                if (state.user != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      state.user!.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () => _showLogoutConfirmation(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, DashboardState state) {
    final widgets = state.widgets;

    if (widgets.isEmpty) {
      return const Center(child: Text('No widgets available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widgets.length,
          onReorder: (oldIndex, newIndex) {
            context.read<DashboardCubit>().reorderWidgets(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final elevation = Tween<double>(begin: 0, end: 8).evaluate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                );
                return Material(
                  elevation: elevation,
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final widget = widgets[index];
            return _DraggableWidgetItem(
              key: ValueKey(widget.id),
              widget: widget,
              crossAxisCount: crossAxisCount,
            );
          },
        );
      },
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
    );

    if (confirmed && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }
}

/// Individual draggable widget item with responsive sizing.
class _DraggableWidgetItem extends StatelessWidget {
  final dynamic widget;
  final int crossAxisCount;

  const _DraggableWidgetItem({
    super.key,
    required this.widget,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 180, child: SmartWidgetCard(widget: widget)),
    );
  }
}
