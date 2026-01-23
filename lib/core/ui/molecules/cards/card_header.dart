import 'package:flutter/material.dart';

/// Card header molecule - title with trailing icon.
/// Used consistently across all dashboard widget cards.
class CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final TextStyle? titleStyle;

  const CardHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titleStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
        ),
      ],
    );
  }
}
