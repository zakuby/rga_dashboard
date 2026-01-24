import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Basic skeleton placeholder shape.
/// Used as building block for skeleton loading states.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  /// Creates a circular skeleton box.
  const SkeletonBox.circle({super.key, required double size, this.color})
    : width = size,
      height = size,
      borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.surfaceContainerHighest;
    final isCircle = width == height && borderRadius == null && width != null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isCircle
            ? null
            : (borderRadius ?? AppSpacing.borderRadiusMd),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
