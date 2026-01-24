import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Bullet list item molecule for simple text lists.
/// Used in news summary card.
class BulletListItem extends StatelessWidget {
  final String text;
  final Color? bulletColor;
  final double bulletSize;
  final int maxLines;
  final TextStyle? textStyle;

  const BulletListItem({
    super.key,
    required this.text,
    this.bulletColor,
    this.bulletSize = 6,
    this.maxLines = 2,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = bulletColor ?? theme.colorScheme.tertiary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.xs),
          width: bulletSize,
          height: bulletSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSpacing.gapHorizontalSm,
        Expanded(
          child: Text(
            text,
            style: textStyle ?? theme.textTheme.bodyMedium,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
