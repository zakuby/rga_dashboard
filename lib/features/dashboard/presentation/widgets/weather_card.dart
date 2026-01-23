import 'package:flutter/material.dart';

import '../../../../core/presentation/design_system/design_system.dart';
import '../../domain/entities/dashboard_widget.dart';

/// Weather widget card displaying current weather information.
/// Uses atomic design components: BaseCard, WeatherCardHeader, IconListItem, TemperatureDisplay.
class WeatherCard extends StatelessWidget {
  final DashboardWidget widget;

  const WeatherCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.weatherData;

    if (data == null) {
      return _buildEmptyState(theme);
    }

    return BaseCard(
      gradientColors: [
        theme.colorScheme.primaryContainer,
        theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeatherCardHeader(
            title: widget.title,
            condition: data.condition,
          ),
          const SizedBox(height: 8),
          IconListItem(
            icon: Icons.location_on,
            text: data.location,
            textStyle: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          TemperatureDisplay(
            temperature: data.temperature,
            condition: data.condition,
          ),
          const SizedBox(height: 8),
          IconListItem(
            icon: Icons.water_drop,
            iconSize: 14,
            text: '${data.humidity}% humidity',
            textStyle: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return BaseCard(
      gradientColors: [
        theme.colorScheme.primaryContainer,
        theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
      ],
      child: Center(
        child: Text(
          'No weather data available',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
