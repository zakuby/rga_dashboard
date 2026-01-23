import 'package:flutter/material.dart';

import '../../../../core/presentation/design_system/design_system.dart';
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
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.stocks.length,
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (context, index) {
                final stock = data.stocks[index];
                return StockListItem(
                  symbol: stock.symbol,
                  price: stock.price,
                  change: stock.change,
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
          const Expanded(
            child: Center(
              child: Text('No stock data available'),
            ),
          ),
        ],
      ),
    );
  }
}
