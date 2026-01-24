import 'package:flutter/material.dart';

import '../../atoms/icons/weather_icon.dart';
import '../../theme/app_typography.dart';

/// Weather card header molecule with title and weather condition icon.
class WeatherCardHeader extends StatelessWidget {
  final String title;
  final String condition;
  final double iconSize;

  const WeatherCardHeader({
    super.key,
    required this.title,
    required this.condition,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppTypography.weightBold,
          ),
        ),
        WeatherIcon(
          condition: condition,
          size: iconSize,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
