import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/entities/dashboard_widget.dart';

/// Quick notes widget card displaying notes list.
/// Uses atomic design components: BaseCard, CardHeader, BulletListItem.
class QuickNotesCard extends StatelessWidget {
  final DashboardWidget widget;

  const QuickNotesCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.quickNotesData;

    if (data == null || data.notes.isEmpty) {
      return _buildEmptyState(theme);
    }

    return BaseCard(
      gradientColors: [
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.sticky_note_2,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.gapVerticalMd,
          ...data.notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BulletListItem(text: note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return BaseCard(
      gradientColors: [
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.sticky_note_2,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.gapVerticalXl,
          const Center(child: Text('No notes yet')),
        ],
      ),
    );
  }
}
