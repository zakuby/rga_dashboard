import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
    final color = isPositive ? AppColors.stockPositive : AppColors.stockNegative;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final sign = isPositive ? '+' : '';
    final percent = showPercentSign ? '%' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow)
            Icon(
              icon,
              size: 12,
              color: color,
            ),
          Text(
            '$sign${change.toStringAsFixed(1)}$percent',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
