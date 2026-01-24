import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Checkbox list item molecule for note/task items.
/// Used in quick notes card.
class CheckboxListItem extends StatelessWidget {
  final String text;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final int maxLines;

  const CheckboxListItem({
    super.key,
    required this.text,
    this.isChecked = false,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
          ),
        ),
        AppSpacing.gapHorizontalSm,
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
