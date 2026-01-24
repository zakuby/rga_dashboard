import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Change indicator badge molecule for stock price changes.
/// Shows positive (green) or negative (red) change with arrow.
class ChangeIndicatorBadge extends StatelessWidget {
  final double change;
  final bool showArrow;
  final bool showPercentSign;

  const ChangeIndicatorBadge({
    super.key,
    required this.change,
    this.showArrow = true,
    this.showPercentSign = true,
  });

  bool get isPositive => change >= 0;

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? AppColors.stockPositive
        : AppColors.stockNegative;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final sign = isPositive ? '+' : '';
    final percent = showPercentSign ? '%' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + AppSpacing.xxs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow) Icon(icon, size: 12, color: color),
          Text(
            '$sign${change.toStringAsFixed(1)}$percent',
            style: TextStyle(
              color: color,
              fontWeight: AppTypography.weightBold,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }
}
