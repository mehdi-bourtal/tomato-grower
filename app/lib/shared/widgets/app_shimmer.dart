import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.soil700,
      highlightColor: AppColors.soil600,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.soil700,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class AppShimmerCard extends StatelessWidget {
  final double height;

  const AppShimmerCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(height: 16, width: 100, borderRadius: AppRadius.sm),
          const SizedBox(height: AppSpacing.md),
          AppShimmer(height: 28, width: 80, borderRadius: AppRadius.sm),
          const Spacer(),
          AppShimmer(height: 32, borderRadius: AppRadius.sm),
        ],
      ),
    );
  }
}
