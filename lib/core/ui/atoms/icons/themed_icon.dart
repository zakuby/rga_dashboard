import 'package:flutter/material.dart';

/// Themed icon atom with consistent sizing and color options.
class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ThemedIcon({super.key, required this.icon, this.size, this.color});

  /// Small icon variant (16px).
  const ThemedIcon.small({super.key, required this.icon, this.color})
    : size = 16;

  /// Medium icon variant (24px - default).
  const ThemedIcon.medium({super.key, required this.icon, this.color})
    : size = 24;

  /// Large icon variant (32px).
  const ThemedIcon.large({super.key, required this.icon, this.color})
    : size = 32;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}
