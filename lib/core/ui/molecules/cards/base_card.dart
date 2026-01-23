import 'package:flutter/material.dart';

/// Base card molecule - reusable card wrapper with gradient background.
/// Used as the foundation for all dashboard widget cards.
class BaseCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final double elevation;
  final double borderRadius;
  final EdgeInsets padding;

  const BaseCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.elevation = 2,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.surface,
        ];

    return Card(
      elevation: elevation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
