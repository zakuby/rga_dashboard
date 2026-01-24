import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Status badge molecule for displaying status labels.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
  });

  /// Factory for success status.
  factory StatusBadge.success(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.successWithOpacity(),
      textColor: AppColors.success,
    );
  }

  /// Factory for warning status.
  factory StatusBadge.warning(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.warningWithOpacity(),
      textColor: AppColors.warning,
    );
  }

  /// Factory for error status.
  factory StatusBadge.error(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.dangerWithOpacity(),
      textColor: AppColors.danger,
    );
  }

  /// Factory for info status.
  factory StatusBadge.info(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.infoWithOpacity(),
      textColor: AppColors.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final txtColor = textColor ?? theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: txtColor,
          fontWeight: AppTypography.weightMedium,
          fontSize: AppTypography.fontSizeSm,
        ),
      ),
    );
  }
}
