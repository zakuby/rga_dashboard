import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Page header molecule with icon, title, and subtitle.
/// Used in login page and other form pages.
class PageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;
  final Color? iconColor;

  const PageHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 64,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        AppSpacing.gapVerticalLg,
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: AppTypography.weightBold,
          ),
        ),
        if (subtitle != null) ...[
          AppSpacing.gapVerticalSm,
          Text(
            subtitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
