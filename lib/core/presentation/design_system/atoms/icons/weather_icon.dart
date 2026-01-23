import 'package:flutter/material.dart';

/// Weather condition icon atom.
class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(
      _getWeatherIcon(condition),
      size: size,
      color: color ?? theme.colorScheme.primary,
    );
  }

  IconData _getWeatherIcon(String condition) {
    return switch (condition.toLowerCase()) {
      'sunny' => Icons.wb_sunny,
      'cloudy' => Icons.cloud,
      'rainy' => Icons.umbrella,
      'stormy' => Icons.thunderstorm,
      'snowy' => Icons.ac_unit,
      'partly_cloudy' => Icons.cloud_queue,
      'windy' => Icons.air,
      'foggy' => Icons.foggy,
      _ => Icons.wb_sunny,
    };
  }
}
