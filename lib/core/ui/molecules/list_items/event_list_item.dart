import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Event list item molecule with left border indicator.
/// Used in calendar card for displaying events.
class EventListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? borderColor;
  final double borderWidth;

  const EventListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.borderColor,
    this.borderWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = borderColor ?? theme.colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: borderWidth),
        ),
      ),
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.weightMedium,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
