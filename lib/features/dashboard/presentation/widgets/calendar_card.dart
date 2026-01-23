import 'package:flutter/material.dart';

import '../../../../core/presentation/design_system/design_system.dart';
import '../../domain/entities/dashboard_widget.dart';

/// Calendar widget card displaying upcoming events.
/// Uses atomic design components: BaseCard, CardHeader, EventListItem.
class CalendarCard extends StatelessWidget {
  final DashboardWidget widget;

  const CalendarCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.calendarData;

    if (data == null || data.events.isEmpty) {
      return _buildEmptyState(theme);
    }

    return BaseCard(
      gradientColors: [
        theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.calendar_today,
            iconColor: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.events.length,
              itemBuilder: (context, index) {
                final event = data.events[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EventListItem(
                    title: event.title,
                    subtitle: event.time,
                    borderColor: theme.colorScheme.error,
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
        theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: widget.title,
            icon: Icons.calendar_today,
            iconColor: theme.colorScheme.error,
          ),
          const Expanded(
            child: Center(
              child: Text('No events scheduled'),
            ),
          ),
        ],
      ),
    );
  }
}
