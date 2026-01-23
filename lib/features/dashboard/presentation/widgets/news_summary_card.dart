import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/entities/dashboard_widget.dart';

/// News summary widget card displaying headlines.
/// Uses atomic design components: BaseCard, CardHeader, BulletListItem.
class NewsSummaryCard extends StatelessWidget {
  final DashboardWidget widget;

  const NewsSummaryCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.newsSummaryData;

    if (data == null || data.headlines.isEmpty) {
      return _buildEmptyState(theme);
    }

    return BaseCard(
      gradientColors: [
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.newspaper,
            iconColor: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.headlines.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BulletListItem(
                    text: data.headlines[index],
                    bulletColor: theme.colorScheme.tertiary,
                    textStyle: theme.textTheme.bodySmall,
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
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.newspaper,
            iconColor: theme.colorScheme.tertiary,
          ),
          const Expanded(child: Center(child: Text('No news available'))),
        ],
      ),
    );
  }
}
