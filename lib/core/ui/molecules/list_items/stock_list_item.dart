import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../badges/change_indicator_badge.dart';

/// Stock list item molecule displaying symbol, price, and change.
class StockListItem extends StatelessWidget {
  final String symbol;
  final double price;
  final double change;
  final String currencySymbol;
  final bool showPercentSign;

  const StockListItem({
    super.key,
    required this.symbol,
    required this.price,
    required this.change,
    this.currencySymbol = '\$',
    this.showPercentSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          symbol,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: AppTypography.weightBold,
          ),
        ),
        Row(
          children: [
            Text(
              '$currencySymbol${price.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium,
            ),
            AppSpacing.gapHorizontalSm,
            ChangeIndicatorBadge(
              change: change,
              showPercentSign: showPercentSign,
            ),
          ],
        ),
      ],
    );
  }
}
