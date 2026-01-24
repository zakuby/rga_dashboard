import 'package:flutter/material.dart';

import '../../molecules/cards/skeleton_card.dart';
import '../../theme/app_spacing.dart';

/// Full skeleton loading view for dashboard.
/// Displays multiple skeleton cards to match dashboard layout.
class SkeletonLoadingView extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  const SkeletonLoadingView({
    super.key,
    this.itemCount = 5,
    this.cardHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SkeletonCard(height: cardHeight),
        );
      },
    );
  }
}
