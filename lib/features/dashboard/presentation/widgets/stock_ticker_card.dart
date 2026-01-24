import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/entities/dashboard_widget.dart';

/// Stock ticker widget card displaying stock prices.
/// Uses atomic design components: BaseCard, CardHeader, StockListItem.
class StockTickerCard extends StatelessWidget {
  final DashboardWidget widget;

  const StockTickerCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.stockTickerData;

    if (data == null || data.stocks.isEmpty) {
      return _buildEmptyState(theme);
    }

    return BaseCard(
      gradientColors: [
        theme.colorScheme.secondaryContainer,
        theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.show_chart,
            iconColor: theme.colorScheme.secondary,
          ),
          AppSpacing.gapVerticalMd,
          ...data.stocks.asMap().entries.expand(
            (entry) => [
              if (entry.key > 0) const Divider(height: AppSpacing.sm),
              StockListItem(
                symbol: entry.value.symbol,
                price: entry.value.price,
                change: entry.value.change,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return BaseCard(
      gradientColors: [
        theme.colorScheme.secondaryContainer,
        theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.show_chart,
            iconColor: theme.colorScheme.secondary,
          ),
          AppSpacing.gapVerticalXl,
          const Center(child: Text('No stock data available')),
        ],
      ),
    );
  }
}
