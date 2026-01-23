import 'package:flutter/material.dart';

/// Large temperature display text atom.
class TemperatureText extends StatelessWidget {
  final num temperature;
  final bool showDegreeSymbol;
  final String? unit;

  const TemperatureText({
    super.key,
    required this.temperature,
    this.showDegreeSymbol = true,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suffix = showDegreeSymbol ? '°' : '';
    final unitSuffix = unit ?? '';

    return Text(
      '$temperature$suffix$unitSuffix',
      style: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
