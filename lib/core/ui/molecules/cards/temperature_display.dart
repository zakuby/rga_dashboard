import 'package:flutter/material.dart';

import '../../atoms/text/temperature_text.dart';

/// Temperature display molecule with large temp and condition label.
class TemperatureDisplay extends StatelessWidget {
  final num temperature;
  final String? condition;
  final String? unit;

  const TemperatureDisplay({
    super.key,
    required this.temperature,
    this.condition,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TemperatureText(
          temperature: temperature,
          unit: unit,
        ),
        if (condition != null) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              condition!.toUpperCase(),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}
