import 'package:flutter/material.dart';

/// List item molecule with leading icon and text.
/// Used in weather card (location, humidity) and news card (bullets).
class IconListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double spacing;

  const IconListItem({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.iconSize = 16,
    this.iconColor,
    this.textStyle,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
