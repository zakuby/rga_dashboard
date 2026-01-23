import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/entities/dashboard_widget.dart';

/// Quick notes widget card displaying notes list.
/// Uses atomic design components: BaseCard, CardHeader, CheckboxListItem.
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
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.notes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListItem(
                    text: data.notes[index],
                    isChecked: false,
                  ),
                );
              },
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
          const Expanded(
            child: Center(
              child: Text('No notes yet'),
            ),
          ),
        ],
      ),
    );
  }
}
