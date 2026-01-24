import 'package:flutter/material.dart';

import '../../atoms/effects/shimmer_effect.dart';
import '../../atoms/skeleton/skeleton_box.dart';
import '../../theme/app_spacing.dart';

/// Skeleton card with shimmer animation.
/// Displays placeholder content during loading states.
class SkeletonCard extends StatelessWidget {
  final double? height;

  const SkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShimmerEffect(
      child: Container(
        height: height,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and title
            Row(
              children: [
                SkeletonBox(
                  width: 24,
                  height: 24,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                AppSpacing.gapHorizontalMd,
                const SkeletonBox(width: 120, height: 20),
              ],
            ),
            AppSpacing.gapVerticalLg,
            // Content lines
            const SkeletonBox(width: double.infinity, height: 14),
            AppSpacing.gapVerticalSm,
            const SkeletonBox(width: double.infinity, height: 14),
            AppSpacing.gapVerticalSm,
            const SkeletonBox(width: 180, height: 14),
            const Spacer(),
            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 80, height: 12),
                SkeletonBox(
                  width: 60,
                  height: 24,
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
