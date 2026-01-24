import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/smart_widget_card.dart';

/// Main dashboard page with draggable widget grid.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state.status) {
            DashboardStatus.initial ||
            DashboardStatus.loading => const SkeletonLoadingView(),
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
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDarkMode(context);

    return AppBar(
      title: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final name = state.user?.name ?? 'User';
          return Text('Hi, $name');
        },
      ),
      centerTitle: false,
      actions: [
        Row(
          children: [
            Icon(
              Icons.light_mode,
              size: 18,
              color: isDark ? null : Colors.amber,
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
            Icon(
              Icons.dark_mode,
              size: 18,
              color: isDark ? Colors.deepPurple.shade300 : null,
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _showLogoutConfirmation(context),
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
          padding: AppSpacing.pagePadding,
          itemCount: widgets.length,
          onReorder: (oldIndex, newIndex) {
            context.read<DashboardCubit>().reorderWidgets(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final scale = Tween<double>(begin: 1, end: 1.02).evaluate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                );
                return Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: 0.9, child: child),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SmartWidgetCard(widget: widget),
    );
  }
}
